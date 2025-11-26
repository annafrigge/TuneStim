clear all
pat.path = 'C:\Users\annfr888\Documents\MATLAB\lead\templates\space\MNI_ICBM_2009b_NLIN_ASYM\'; %'C:\Users\annfr888\Documents\DBS\patient_data\OCD\Pat6\';
pat.space = 'mni'; % 'Native' use patient MRI, 'native' for warping MNI-space 
                      % template to native space
pat.lead = 'Medtronic';
pat.TuneSderivativesPath = pat.path;
pat.orientation = 0;

segment_wt1_job(pat,1)

if strcmp(pat.space, 'native') % MNI templated warped to MNI space
    GM = fullfile(pat.path,'c1wt1.nii');
    WM = fullfile(pat.path,'c2wt1.nii');
    CSF = fullfile(pat.path,'c3wt1.nii');
elseif strcmp(pat.space, 'Native') % Native patient T1 image
    GM = fullfile(pat.path,'c1raw_anat_t1.nii');
    WM = fullfile(pat.path,'c2raw_anat_t1.nii');
    CSF = fullfile(pat.path,'c3raw_anat_t1.nii');
elseif strcmp(pat.space, 'mni')
    GM = fullfile(pat.path,'c1t1.nii');
    WM = fullfile(pat.path,'c2t1.nii');
    CSF = fullfile(pat.path,'c3t1.nii');
end

% Grey matter
volumeInfo = spm_vol(GM);
[GM_intensities, GM_xyz] = spm_read_vols(volumeInfo);

% White matter';
volumeInfo = spm_vol(WM);
[WM_intensities, WM_xyz] = spm_read_vols(volumeInfo); %each column in WM_xyz corresponds to point

% Brain fluid
volumeInfo = spm_vol(CSF);
[CSF_intensities, CSF_xyz] = spm_read_vols(volumeInfo);

% change units from mm to m
GM_xyz = GM_xyz * 1e-3;

%% assign conductivitty values
% conductivity values from Cubo et al. (2019), adapt to frequency and pulse width?
GM_conductivities = GM_intensities;
GM_conductivities(GM_conductivities<0.5)  = 0.0;
GM_conductivities(GM_conductivities>=0.5) = 0.09;%1

WM_conductivities = WM_intensities;
WM_conductivities(WM_conductivities<0.5)  = 0.0;
WM_conductivities(WM_conductivities>=0.5) = 0.06; %3

CSF_conductivities = CSF_intensities;
CSF_conductivities(CSF_conductivities>=0.5) = 2.0;
CSF_conductivities(CSF_conductivities<0.5)  = 0.0;

comb_conductivities = GM_conductivities + WM_conductivities + CSF_conductivities;

% make sure that there is no overlap in assigned conductivities

gm_frac = length(find(GM_conductivities==0.09))/length(find(comb_conductivities(:,:,:)>0));
wm_frac =length(find(WM_conductivities==0.06))/length(find(comb_conductivities(:,:,:)>0));
csf_frac = length(find(CSF_conductivities==2.0))/length(find(comb_conductivities(:,:,:)>0));

assert(gm_frac>0, 'Grey matter fraction should be larger than 0')
assert(wm_frac>0, 'White matter fraction should be larger than 0')
assert(csf_frac>0, 'CSF fraction should be larger than 0')


overlapping_voxels = length(find(comb_conductivities(:,:,:)~=0.06 & comb_conductivities(:,:,:)~=2 & comb_conductivities(:,:,:)~=0.09 & comb_conductivities(:,:,:)~=0));
assert(overlapping_voxels==0, 'number of overlapping voxels should be 0')


%% assigning conductivities
% first write all coordinates + corresponding conductivity into one matrix
conductivities = reshape(comb_conductivities,length(GM_xyz),1);
conductivity_map = [GM_xyz',conductivities];


%% check that the map is correct
x = randi((size(comb_conductivities,1)));
y = randi((size(comb_conductivities,2)));
z = randi((size(comb_conductivities,3)));

index = 1+(x-1)+(y-1)*size(comb_conductivities,1)+(z-1)*size(comb_conductivities,2)*size(comb_conductivities,1);
assert(conductivities(index) == comb_conductivities(x,y,z))

%% %% Anisotropic conductivity from DTI (ITT)
% Load the dataC:\Users\annfr888\Documents\MATLAB\leaddbs31\templates\space\MNI152NLin2009bAsym
dti_path = 'C:\Users\annfr888\Documents\MATLAB\leaddbs31\templates\space\MNI152NLin2009bAsym\IITMeanTensor.nii.gz';%('comsol','anisotropy', 'human_iso.nii.gz');
nii_tensor = niftiread(dti_path);
info = niftiinfo(dti_path);

% Extract tensor components (assuming order: Dxx, Dyy, Dzz , Dxy, Dxz,  Dyz)
D_xx = nii_tensor(:,:,:,1);
D_xy = nii_tensor(:,:,:,2); 
D_yy = nii_tensor(:,:,:,3);
D_xz = nii_tensor(:,:,:,4);
D_yz = nii_tensor(:,:,:,5);
D_zz = nii_tensor(:,:,:,6);

% Get coordinate grids (MNI space)
[nx, ny, nz] = size(D_xx);
voxel_size = info.PixelDimensions(1:3); % should be 0.5 0.5 0.5 (mm voxel size)

% Create coordinate arrays (MNI coordinates)
% Typical MNI space: x: -90 to 90, y: -126 to 90, z: -72 to 108
x = conductivity_map(:,1);
y = conductivity_map(:,1);
z = conductivity_map(:,1);

% Save to MAT file
save('DTI_MNI_template.mat', 'D_xx', 'D_yy', 'D_zz', 'D_xy', 'D_xz', 'D_yz', ...
     'x', 'y', 'z', 'info');

trace_D = (D_xx + D_yy + D_zz)/3;

fprintf('\nComputing anisotropic conductivity tensor...\n');

comb_conductivities(comb_conductivities==0) = 0.1;

%
sigma_xx = comb_conductivities .* (D_xx ./ trace_D);
sigma_yy = comb_conductivities .* (D_yy ./ trace_D);
sigma_zz = comb_conductivities .* (D_zz ./ trace_D);
sigma_xy = comb_conductivities .* (D_xy ./ trace_D);
sigma_xz = comb_conductivities .* (D_xz ./ trace_D);
sigma_yz = comb_conductivities .* (D_yz ./ trace_D);

fprintf('Checking tensor components:\n');
fprintf('  sigma_xx: NaN=%d, Inf=%d, Negative=%d\n', ...
    sum(isnan(sigma_xx(:))), sum(isinf(sigma_xx(:))), sum(sigma_xx(:) < 0));
fprintf('  sigma_yy: NaN=%d, Inf=%d, Negative=%d\n', ...
    sum(isnan(sigma_yy(:))), sum(isinf(sigma_yy(:))), sum(sigma_yy(:) < 0));
fprintf('  sigma_zz: NaN=%d, Inf=%d, Negative=%d\n', ...
    sum(isnan(sigma_zz(:))), sum(isinf(sigma_zz(:))), sum(sigma_zz(:) < 0));
fprintf('  sigma_xy: NaN=%d, Inf=%d, Negative=%d\n', ...
    sum(isnan(sigma_xy(:))), sum(isinf(sigma_xy(:))), sum(sigma_xy(:) < 0));
fprintf('  sigma_xz: NaN=%d, Inf=%d, Negative=%d\n', ...
    sum(isnan(sigma_xz(:))), sum(isinf(sigma_xz(:))), sum(sigma_xz(:) < 0));
fprintf('  sigma_yz: NaN=%d, Inf=%d, Negative=%d\n', ...
    sum(isnan(sigma_yz(:))), sum(isinf(sigma_yz(:))), sum(sigma_yz(:) < 0));

% Define half of inhomogeneous box length
box_length = 3.0*1e-2; %25e-3;
centre_coord = [0 0 0];

% Single combined filter for GM_xyz coordinates (with box_length radius)
in_box = all(vecnorm((GM_xyz' - centre_coord),2,2) <= box_length, 2);

% Filter all sigma variables at once
sigma_xx_filtered = sigma_xx(in_box);
sigma_yy_filtered = sigma_yy(in_box);
sigma_zz_filtered = sigma_zz(in_box);
sigma_xy_filtered = sigma_xy(in_box);
sigma_xz_filtered = sigma_xz(in_box); 
sigma_yz_filtered = sigma_yz(in_box);

% Filter coordinates
GM_xyz_filtered = GM_xyz(:, in_box);  % Note: GM_xyz is already transposed

% Create maps efficiently (pre-allocate if possible, but this is already fast)
sigma_xx_map = [GM_xyz_filtered', sigma_xx_filtered];
sigma_yy_map = [GM_xyz_filtered', sigma_yy_filtered];
sigma_zz_map = [GM_xyz_filtered', sigma_zz_filtered];
sigma_xy_map = [GM_xyz_filtered', sigma_xy_filtered];
sigma_xz_map = [GM_xyz_filtered', sigma_xz_filtered];
sigma_yz_map = [GM_xyz_filtered', sigma_yz_filtered];

% Save all at once using a loop
sigma_components = {'xx', 'yy', 'zz', 'xy', 'xz', 'yz'};
sigma_maps = {sigma_xx_map, sigma_yy_map, sigma_zz_map, ...
              sigma_xy_map, sigma_xz_map, sigma_yz_map};

for i = 1:length(sigma_components)
    filename = sprintf('sigma_%s_map_full_%s.csv', sigma_components{i}, pat.space);
    writematrix(sigma_maps{i}, filename);
end


%% extract region of interest
hands = {"sin","dx"};
[heads,tails] = get_lead_parameters(pat,hands);

centre_coord = (heads.sin+heads.dx)*0.5;

% define half of inhomogeneous box length
box_length = 25e-3; 

% Combine all three conditions into one logical array
in_box = conductivity_map(:,1) >= centre_coord(1) - box_length & ...
         conductivity_map(:,1) <= centre_coord(1) + box_length & ...
         conductivity_map(:,2) >= centre_coord(2) - box_length & ...
         conductivity_map(:,2) <= centre_coord(2) + box_length & ...
         conductivity_map(:,3) >= centre_coord(3) - box_length & ...
         conductivity_map(:,3) <= centre_coord(3) + box_length;

% Filter once
conductivity_map = conductivity_map(in_box, :);


%% set conductivity for all points that were not labelled GM, WM or CSF
conductivity_map(conductivity_map(:,:)==0) = 0.1;
% write to file
writematrix(conductivity_map,...
           append(pat.path,'conductivity_map_both_hands_',pat.space,'.csv'))



%% Permittivity map
%% assign permittivity values
% conductivity values from Cubo et al. (2019), adapt to frequency and pulse width?

GM_permittivities(GM_intensities<0.5)  = 0.0;
GM_permittivities(GM_intensities>=0.5) = 30.407*1e4;%1

WM_permittivities(WM_intensities<0.5)  = 0.0;
WM_permittivities(WM_intensities>=0.5) = 13.752*1e4; %3

CSF_permittivities(CSF_intensities>=0.5) = 0.0109*1e4;
CSF_permittivities(CSF_intensities<0.5)  = 0.0;

comb_permittivities = GM_permittivities + WM_permittivities + CSF_permittivities;

% make sure that there is no overlap in assigned conductivities

gm_frac = length(find(GM_permittivities==30.407*1e4))/length(find(comb_permittivities(:,:,:)>0));
wm_frac =length(find(WM_permittivities==13.752*1e4))/length(find(comb_permittivities(:,:,:)>0));
csf_frac = length(find(CSF_permittivities==0.0109*1e4))/length(find(comb_permittivities(:,:,:)>0));

assert(gm_frac>0, 'Grey matter fraction should be larger than 0')
assert(wm_frac>0, 'White matter fraction should be larger than 0')
assert(csf_frac>0, 'CSF fraction should be larger than 0')


overlapping_voxels = length(find(comb_permittivities(:,:,:)~=13.752*1e4 & comb_permittivities(:,:,:)~=0.0109*1e4 & comb_permittivities(:,:,:)~=30.407*1e4 & comb_permittivities(:,:,:)~=0));
assert(overlapping_voxels==0, 'number of overlapping voxels should be 0')
%% assigning conductivities
% first write all coordinates + corresponding conductivity into one matrix
permittivities = reshape(comb_permittivities,length(GM_xyz),1);
permittivity_map = [GM_xyz',permittivities];


%% check that the map is correct
x = randi((size(comb_permittivities,1)));
y = randi((size(comb_permittivities,2)));
z = randi((size(comb_permittivities,3)));

index = 1+(x-1)+(y-1)*size(comb_permittivities,1)+(z-1)*size(comb_permittivities,2)*size(comb_permittivities,1);
assert(permittivities(index) == comb_permittivities(x,y,z))


%% extract region of interest

% define half of inhomogeneous box length
box_length = 25*1e-3;
logical = permittivity_map(:,1)>= centre_coord(1)-box_length & permittivity_map(:,1)<= centre_coord(1)+box_length;
permittivity_map = permittivity_map(logical,:);

%y
logical = permittivity_map(:,2)>= centre_coord(2)-box_length & permittivity_map(:,2)<= centre_coord(2)+box_length;
permittivity_map = permittivity_map(logical,:);

%z
logical = permittivity_map(:,3)>= centre_coord(3)-box_length & permittivity_map(:,3)<= centre_coord(3)+box_length;
permittivity_map = permittivity_map(logical,:);

permittivity_map(permittivity_map(:,:)==0) = 13.752*1e4;
writematrix(permittivity_map,...
           append(pat.path,'permittivity_map_both_hands_',pat.space,'.csv'))


