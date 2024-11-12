% Define patient cohort directory

cohort_path = 'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study';

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
pat_names = ['DBS_104';'DBS_128';'DBS_133';'DBS_139';'DBS_167';...
             'DBS_168';'DBS_171';'DBS_185';'DBS_199';'DBS_204'];
leads = {'S:t Jude 1331','Boston Scientific 2202', 'S:t Jude 1331',...
         'S:t Jude 1331','Boston Scientific 2202','S:t Jude 1331'...
         'Boston Scientific 2202','S:t Jude 1331',...
         'Boston Scientific 2202','Boston Scientific 2202'};
orientations = {[293,313],[94,288],[12,302],[25,153],[98,193],[52,345],...
               [32,116],[202,184],16.4,[308,38]};
atlas = 'DBS Tractography Atlas (Middlebrooks 2020)';%'DISTAL Minimal (Ewert 2017)'; %'Human Dysfunctome Atlas (Hollunder 2024)';%
cohort.targets = {'STN_motor_tract.mat'};%{'STN_motor.nii.gz'}; %{'Sweet_Streamline_PD.nii'};%
cohort.constraints = {'STN_associative_tract.mat','STN_limbic_tract.mat'};%{'STN_associative.nii.gz','STN_limbic.nii.gz'};%
cohort.optischeme = 'conservative';%'Ruben';% 'mincov';%
cohort.EThreshold = 200;
relaxation = 10:10:90;
cohort.threads = 1;
pat.space = 'MNI';
cohort.plotoption = 0;
cohort.rebuild = 0;
scoretype = 'score2';


%% Running optimization algorithm of choice for all patients
for i=1:length(pat_names)
    disp(append('Patient ',pat_names(i,:),' loading ...'))
    pat.path = append(cohort_path,filesep,pat_names(i,:),filesep);
    %if strcmp(leads{1,i},'Boston Scientific 2202')
    %    continue
    %end
    if strcmp(pat_names(i,:),'DBS_199')
        hand = {"dx"};
    else
        hand = {"sin","dx"};
        %hand = {"dx"};
    end
    lead = leads{1,i};
    pat.orientation = orientations{1,i};

    main(pat.path,hand,lead,pat.orientation,atlas,cohort.targets,cohort.constraints,cohort.optischeme,cohort.EThreshold,relaxation,cohort.threads,pat.space,cohort.plotoption,scoretype,cohort.rebuild); 

end

%% Compute activation for clinical settings

% 13852 interpolation points for STN motor, limbic, associative


