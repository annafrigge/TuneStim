function [target_roi,constraint_roi,target_lst,constraint_lst] = load_atlas_roi_2(hand,space,pat_path,atlasset,targets,constraints,max,min,head)
% This function reads in x,y and z coordinates of target and constraint
% areas from .csv files.
downsampling = 0;

if strcmp(hand,'dx')
    hand ='rh';
elseif strcmp(hand,'sin')
    hand = 'lh';
end

if strcmp(space,'native')
    apath=pat_path;
else
    lpath = ea_getearoot;
    if contains(lpath,'leaddbs')
        spacename= 'MNI152NLin2009bAsym';
    else
        spacename='MNI_ICBM_2009b_NLIN_ASYM';
    end
    apath=[ea_getearoot,'templates',filesep,'space',filesep,spacename,filesep];
end

if strcmp(atlasset,'STN Sweetspots (Dembek 2019)')
    path = append(apath,'atlases/',...
                   'STN Sweetspots (Dembek 2019)/',hand,'/');

elseif strcmp(atlasset,'STN-Subdivisions (Accolla 2014)')
    path = append(apath,'atlases/',...
                   'STN-Subdivisions (Accolla 2014)/mixed/');

elseif strcmp(atlasset,'Essential Tremor Hypointensity (Neudorfer 2022)')
    path = append(apath,'atlases/',...
                   'Essential Tremor Hypointensity (Neudorfer 2022)/',hand,'/');

elseif strcmp(atlasset,'DISTAL Minimal (Ewert 2017)')
    path = append(apath,'atlases',filesep,atlasset,filesep,hand,filesep);

elseif strcmp(atlasset,'DBS Tractography Atlas (Middlebrooks 2020)')
    path = append(apath,'atlases',filesep,atlasset,filesep,hand,filesep);
    downsampling = 1;

elseif strcmp(atlasset,'Human Dysfunctome Atlas (Hollunder 2024)')
    disp('Humand Dysfunctome atlas is not yet supported in native space.')
    path = append('C:\Users\annfr888\Documents\MATLAB\leaddbs31\',...
          'templates\space\MNI152NLin2009bAsym\',...
          'atlases',filesep,atlasset,filesep,hand,filesep);
    downsampling = 1;
end
  
for t=1:length(targets)
    try gunzip(append(path,targets{t})); end
    target_names{t} = erase(targets{t},'.gz');
end

for t=1:length(constraints)
    try gunzip(append(path,constraints{t})); end
    constraint_names{t} = erase(constraints{t},'.gz');
end

[target_lst,constraint_lst, atlas_struct] = get_target_and_constraint_coordinates(path, target_names,constraint_names,hand,max,min);
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
load([pat_path,filesep,'atlases',filesep,atlasset,filesep,'neurostructures.mat'],'region');


if strcmp(space,'native')
    region.native = atlas_struct;
else
    region.MNI = atlas_struct;
end
destination = append(pat_path,'atlases',filesep,atlasset);
matname = fullfile(destination, 'neurostructures.mat');
save(matname, 'region','-append');

