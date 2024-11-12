function assign_conductivites(pat)

% Summary  
% --------
% Assign conductivity values to different tissue types, based on segmented T1 MRI            %
% For each tissue type                                                    
% 1. load .nii file                                                       
% 2. convert into .mat file and use double precision                      
% 3. assign conductivity value to all voxels with intensity >= 0.5        
% Combine segmented images to one complete image.                         
% Write data to csv file, using MNI coordinates.      

% Input
% ------
% pat.path  :   (str) the path to the patient directory
% hand  :       (str) dx or sin, corresponding to the right or left
%               hemisphere
% pat.space
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  
% load lead parameters
opts = detectImportOptions(append(pat.path,'lead_parameters_',...
                           pat.space,'_',pat.hand,'.txt'));
lead_parameters = readtable(append(pat.path,'lead_parameters_',...
                           pat.space,'_',pat.hand,'.txt'),opts);

head = table2array(lead_parameters(3:5,2))';
tail = table2array(lead_parameters(7:9,2))';


%% read intensity values and coordinates from file

GM = fullfile(pat.path,'c1wt1.nii');
WM = fullfile(pat.path,'c2wt1.nii');
CSF = fullfile(pat.path,'c3wt1.nii');

%grey matter
volumeInfo = spm_vol(GM);
[GM_intensities, GM_xyz] = spm_read_vols(volumeInfo);



%White matter';
volumeInfo = spm_vol(WM);
[WM_intensities, WM_xyz] = spm_read_vols(volumeInfo); %each column in WM_xyz corresponds to point

%brain fluid
volumeInfo = spm_vol(CSF);
[CSF_intensities, CSF_xyz] = spm_read_vols(volumeInfo);

% change units from mm to m
GM_xyz = GM_xyz * 1e-3;

% check coordinates% extract head point coordinates in native space
disp('Reconstructed head coordinates from LeadDBS in mm:')
head %= [reco.native.markers.head] %*1e-3;
disp('MRI coordinates, which are closest to reconstructed coordinates in mm:')

[minValue closestIndex] = min(sum(abs(GM_xyz'-head),2)); %added -head
GM_xyz(:,closestIndex)'


%% assign conductivitty values
% conductivity values from Cubo et al. (2019), adapt to frequency and pulse width?



GM_intensities(GM_intensities<0.5)  = 0.0;
GM_intensities(GM_intensities>=0.5) = 0.09;%1

WM_intensities(WM_intensities<0.5)  = 0.0;
WM_intensities(WM_intensities>=0.5) = 0.06; %3

CSF_intensities(CSF_intensities>=0.5) = 2.0;
CSF_intensities(CSF_intensities<0.5)  = 0.0;

comb_intensities = GM_intensities + WM_intensities + CSF_intensities;

% make sure that there is no overlap in assigned conductivities

gm_frac = length(find(GM_intensities==0.09))/length(find(comb_intensities(:,:,:)>0));
wm_frac =length(find(WM_intensities==0.06))/length(find(comb_intensities(:,:,:)>0));
csf_frac = length(find(CSF_intensities==2.0))/length(find(comb_intensities(:,:,:)>0));

assert(gm_frac>0, 'Grey matter fraction should be larger than 0')
assert(wm_frac>0, 'White matter fraction should be larger than 0')
assert(csf_frac>0, 'CSF fraction should be larger than 0')


overlapping_voxels = length(find(comb_intensities(:,:,:)~=0.06 & comb_intensities(:,:,:)~=2 & comb_intensities(:,:,:)~=0.09 & comb_intensities(:,:,:)~=0));
assert(overlapping_voxels==0, 'number of overlapping voxels should be 0')
%% assigning conductivities
% first write all coordinates + corresponding conductivity into one matrix
intensities = reshape(comb_intensities,length(GM_xyz),1);
conductivity_map = [GM_xyz',intensities];


%% check that the map is correct
x = randi((size(comb_intensities,1)));
y = randi((size(comb_intensities,2)));
z = randi((size(comb_intensities,3)));

index = 1+(x-1)+(y-1)*size(comb_intensities,1)+(z-1)*size(comb_intensities,2)*size(comb_intensities,1);
assert(intensities(index) == comb_intensities(x,y,z))



%% extract region of interest

% define half of inhomogeneous box length
box_length = 25*1e-3;
logical = conductivity_map(:,1)>= head(1)-box_length & conductivity_map(:,1)<= head(1)+box_length;
conductivity_map = conductivity_map(logical,:);

%y
logical = conductivity_map(:,2)>= head(2)-box_length & conductivity_map(:,2)<= head(2)+box_length;
conductivity_map = conductivity_map(logical,:);

%z
logical = conductivity_map(:,3)>= head(3)-box_length & conductivity_map(:,3)<= head(3)+box_length;
conductivity_map = conductivity_map(logical,:);


%% set conductivity for all points that were not labelled GM, WM or CSF
conductivity_map(conductivity_map(:,:)==0) = 0.1;
% write to file
writematrix(conductivity_map,...
           append(pat.path,'conductivity_map','_',pat.hand,'_',pat.space,'.csv'))






end

