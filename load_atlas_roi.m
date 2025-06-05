function pat = load_atlas_roi(pat,cohort,max,min,head)
% This function reads in x,y and z coordinates of target and constraint
% areas from .csv files.

if strcmp(pat.hand,'dx')
    hand ='rh';
elseif strcmp(pat.hand,'sin')
    hand = 'lh';
end

if strcmp(pat.space,'native')
    apath=pat.path;
else
    lpath = ea_getearoot;
    if contains(lpath,'leaddbs')
        spacename= 'MNI152NLin2009bAsym';
    else
        spacename='MNI_ICBM_2009b_NLIN_ASYM';
    end
    apath=[ea_getearoot,'templates',filesep,'space',filesep,spacename,...
        filesep,'atlases',filesep];
end

path = append(apath,cohort.atlas,filesep,hand,filesep);

 
for t=1:length(cohort.targets)
    try gunzip(append(path,cohort.targets{t})); end
    cohort.targets{t} = erase(cohort.targets{t},'.gz');
end

for t=1:length(cohort.constraints)
    try gunzip(append(path,cohort.constraints{t})); end
    cohort.constraints{t} = erase(cohort.constraints{t},'.gz');
end

[target_lst,constraint_lst, atlas_struct] = get_target_and_constraint_coordinates(path, cohort.targets,cohort.constraints,hand,max,min);


% Sampling with given Voxel Filter size (default 0.95 mm)
if cohort.simulationSettings.downsample
    target_roi = [];
    constraint_roi = [];
    for j=1:length(target_lst)
        target_roi_pc = pointCloud(target_lst{j,1}(:,1:3));
        target_roi_sampled{j,1} = pcdownsample(target_roi_pc,"gridAverage",cohort.simulationSettings.VoxelFilterSize);
        target_roi = vertcat(target_roi,target_roi_sampled{j,1}.Location);
    end
    for j=1:length(constraint_lst)
        constraint_roi_pc = pointCloud(constraint_lst{j,1}(:,1:3));
        constraint_roi_sampled{j,1} = pcdownsample(constraint_roi_pc,"gridAverage",cohort.simulationSettings.VoxelFilterSize);
        constraint_roi = vertcat(constraint_roi,constraint_roi_sampled{j,1}.Location);
    end
end

%target_roi = cell2mat({cat(1, target_lst{:})});

%constraint_roi = cell2mat({cat(1, constraint_lst{:})});

%save current structure coordinates in .mat file
load([pat.path,filesep,'atlases',filesep,cohort.atlas,filesep,'neurostructures.mat'],'region');


if strcmp(pat.space,'native')
    region.native = atlas_struct;
else
    region.MNI = atlas_struct;
end
destination = append(pat.path,'atlases',filesep,cohort.atlas);
matname = fullfile(destination, 'neurostructures.mat');
save(matname, 'region','-append');

for t=1:length(cohort.targets)
    if exist(fullfile(path, cohort.targets{t}),'file')
        delete(fullfile(path, cohort.targets{t}))
    end
end

for t=1:length(cohort.constraints)
    if exist(fullfile(path, cohort.constraints{t}),'file')
        delete(fullfile(path, cohort.constraints{t}))
    end
end

pat.TargetPoints = target_roi;
pat.ConstraintPoints = constraint_roi;
pat.Targets = target_lst;
pat.Constraints = constraint_lst;


end

