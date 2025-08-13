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

%% extract region of interest
hands = {"sin","dx"};
[heads,tails] = get_lead_parameters(pat,hands);

centre_coord = (heads.sin+heads.dx)*0.5;

% define half of inhomogeneous box length
box_length = 25*1e-3;
logical = conductivity_map(:,1)>= centre_coord(1)-box_length & conductivity_map(:,1)<= centre_coord(1)+box_length;
conductivity_map = conductivity_map(logical,:);

%y
logical = conductivity_map(:,2)>= centre_coord(2)-box_length & conductivity_map(:,2)<= centre_coord(2)+box_length;
conductivity_map = conductivity_map(logical,:);

%z
logical = conductivity_map(:,3)>= centre_coord(3)-box_length & conductivity_map(:,3)<= centre_coord(3)+box_length;
conductivity_map = conductivity_map(logical,:);


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
