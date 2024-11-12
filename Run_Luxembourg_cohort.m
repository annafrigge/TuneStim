% Define patient cohort directory

cohort_path = 'C:\Users\annfr888\Documents\DBS\patient_data\2024_Luxembourg_testcases\PilotPatients';

% S = dir(cohort_path);
% 
% % Initialize an empty cell array to store folder names
% pat_names = {};
% 
% % Loop through each item in the directory contents
% for i = 1:length(S)
%     % Check if the item is a directory and not '.' or '..'
%     if S(i).isdir && ~strcmp(S(i).name, '.') && ~strcmp(S(i).name, '..')
%         % Add the folder name to the cell array
%         pat_names{end+1} = S(i).name;
%     end
% end
pat_names = ['12';'15';'26';'28'];
leads = {'Boston Scientific 2202','Boston Scientific 2202',...
         'Boston Scientific 2202','Boston Scientific 2202'};
orientations = {[25.4,267.1],[133.2,206.9],[0,0],[218.3,268.6]};
atlas = 'DISTAL Minimal (Ewert 2017)';
cohort.targets = {'STN_motor.nii.gz'};
cohort.constraints = {'STN_associative.nii.gz','STN_limbic.nii.gz'};
cohort.optischeme = 'conservative';% 'mincov';%
cohort.EThreshold = 200;
relaxation = 0:10:90;
cohort.threads = 1;
pat.space = 'MNI';
cohort.plotoption = 0;
cohort.rebuild = 1;
%hand = {"sin","dx"};
hand = {"dx"};


scoretype = 'score2';
%% Running optimization algorithm of choice for all patients
for i=1:1%length(pat_names)
    disp(append('Patient ',pat_names(i,:),' loading ...'))
    pat.path = append(cohort_path,filesep,pat_names(i,:),filesep);
    %if strcmp(leads{1,i},'Boston Scientific 2202')
    %    continue
    %end
    lead = leads{1,i};
    pat.orientation = orientations{1,i};

    main(pat.path,hand,lead,pat.orientation,atlas,cohort.targets,cohort.constraints,cohort.optischeme,cohort.EThreshold,relaxation,cohort.threads,pat.space,cohort.plotoption,scoretype,cohort.rebuild)  

end