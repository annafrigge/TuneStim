function [target_roi,constraint_roi,target_lst,constraint_lst] = load_atlas_roi(pat,cohort,max,min,head)
% This function reads in x,y and z coordinates of target and constraint
% areas from .csv files.
downsampling = 0;

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
    apath=[ea_getearoot,'templates',filesep,'space',filesep,spacename,filesep];
end

if strcmp(cohort.atlas,'STN Sweetspots (Dembek 2019)')
    path = append(apath,'atlases/',...
                   'STN Sweetspots (Dembek 2019)/',hand,'/');

elseif strcmp(cohort.atlas,'STN-Subdivisions (Accolla 2014)')
    path = append(apath,'atlases/',...
                   'STN-Subdivisions (Accolla 2014)/mixed/');

elseif strcmp(cohort.atlas,'Essential Tremor Hypointensity (Neudorfer 2022)')
    path = append(apath,'atlases/',...
                   'Essential Tremor Hypointensity (Neudorfer 2022)/',hand,'/');

elseif strcmp(cohort.atlas,'DISTAL Minimal (Ewert 2017)')
    path = append(apath,'atlases',filesep,cohort.atlas,filesep,hand,filesep);

elseif strcmp(cohort.atlas,'DBS Tractography Atlas (Middlebrooks 2020)')
    path = append(apath,'atlases',filesep,cohort.atlas,filesep,hand,filesep);
    downsampling = 1;

elseif strcmp(cohort.atlas,'Human Dysfunctome Atlas (Hollunder 2024)')
    disp('Humand Dysfunctome atlas is not yet supported in native space.')
    path = append('C:\Users\annfr888\Documents\MATLAB\leaddbs31\',...
          'templates\space\MNI152NLin2009bAsym\',...
          'atlases',filesep,cohort.atlas,filesep,hand,filesep);
    downsampling = 1;
end
  
for t=1:length(cohort.targets)
    try gunzip(append(path,cohort.targets{t})); end
    cohort.cohort.targets{t} = erase(cohort.targets{t},'.gz');
end

for t=1:length(cohort.constraints)
    try gunzip(append(path,cohort.constraints{t})); end
    cohort.cohort.constraints{t} = erase(cohort.constraints{t},'.gz');
end

[target_lst,constraint_lst, atlas_struct] = get_target_and_constraint_coordinates(path, cohort.cohort.targets,cohort.cohort.constraints,hand,max,min);
if downsampling
    target_lst{1,1} = target_lst{1,1}(target_lst{1,1}(:,3) > head(3)-15e-3 & target_lst{1,1}(:,3) < head(3)+15e-3, :);
    target_lst{1,1} = target_lst{1,1}(target_lst{1,1}(:,2) > head(2)-15e-3 & target_lst{1,1}(:,2) < head(2)+15e-3, :);
    target_lst{1,1} = target_lst{1,1}(target_lst{1,1}(:,1) > head(1)-15e-3 & target_lst{1,1}(:,1) < head(1)+15e-3, :);
    for j=1:length(constraint_lst)
    constraint_lst{j,1} = constraint_lst{1,1}(constraint_lst{1,1}(:,3) > head(3)-15e-3 & constraint_lst{1,1}(:,3) < head(3)+15e-3, :);
    constraint_lst{j,1} = constraint_lst{1,1}(constraint_lst{1,1}(:,2) > head(2)-15e-3 & constraint_lst{1,1}(:,3) < head(2)+15e-3, :);
    constraint_lst{j,1} = constraint_lst{1,1}(constraint_lst{1,1}(:,1) > head(1)-15e-3 & constraint_lst{1,1}(:,1) < head(1)+15e-3, :);
    %constraint_lst{1,1} = downsample(constraint_lst{1,1},5);
    end
end

target_roi = cell2mat({cat(1, target_lst{:})});

constraint_roi = cell2mat({cat(1, constraint_lst{:})});

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

