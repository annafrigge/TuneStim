function msg = main(cohort)

% main function that finds the optimal stimulation given the pre-processed
% neuroimages in pat.path. The stimulation target and constraint are
% defined by the file names in 'targets' and 'constraints' which can be
% found in the 'atlas' lead-DBS directory.

% Input Arguments
% ---------------
% path      :   (str) path to the patient directory.
%                   Required.
% hand          :   (cell) brain hemispheres of interest. {'dx'},{'sin'} or {'both'}.
%                   Required.
% lead          : (str)
% lead orientation : (cell of int)
%
% atlas         :   (str) atlas name (must be identical to leadDBS)
%                   Optional. Default = DISTAL Minimal (Ewert 2017)
% targets       :   (cell of str) target names.
%                   Optional. Default = {STN motor}
% optischeme    :   Optimization scheme, either "Linear" or
%                           "Nonlinear"
% constraints   :   (cell of str) constraint names.
%                   Optional. Default = {STN limbic, STN associative}
% EThreshold    : (int)
%
% Relaxation    :   (int) Optimization 1: percentage of constraint points
%                   that do not need to fulfill constraints.
%                   Optimization 2: percentage of target points that need
%                   to be activated

% threads      :   (int)  number of parallel processes
%                   Optional. Default = None
% space         :   (str) which pat.space to use for simulation. native or mni.
%
% rebuild       : (bool) indicates whether certain steps in the pipeline
%                 should be recomputed (segmentation, conducivitymap,
%                 comsol..)

% Output
% ------
% best_suggestion   :   (cell) containing the optimal stimulation settings
%  for each lead side defined in hand
%

tic
settings;
warning('off','MATLAB:dispatcher:nameConflict')

% Incorporate in GUI:
cohort.simulationSettings.tractActivation = 'pointwise';%'fiberwise'; % 
%cohort.simulationSettings.includeAnisotropy = 0;

cohort.omega = str2num(replace(cohort.omega,'-',' '));
if strcmp(cohort.optischeme,'Linear')| strcmp(cohort.optischeme,'Nonlinear')
    relaxation = 0:10:90;
elseif strcmp(cohort.optischeme,'mincov')
    relaxation = 10:10:90;
elseif strcmp(cohort.optischeme, 'MILP') | strcmp(cohort.optischeme, 'LP')
    relaxation = 1;
end
counter = 1;
for patient=1%:length(cohort.patNames)
    disp(append('Patient ',cohort.patNames{patient,:},' loading ...'))
    pat.patientNo = patient;
    pat.encapsulationThickness = cohort.simulationSettings.encapsulationThickness;

    % Input and Output directories
    if cohort.simulationSettings.LeadDBSVersion < 3.0
        pat.path = char(append(cohort.folder,filesep,cohort.patNames{patient,:},filesep));
        pat.TuneSderivativesPath = pat.path;
        pat.outputPath = [pat.path,'Suggestions',filesep,...
            extractBefore(cohort.targets{1,1},'.'),filesep,...
            cohort.optischeme,filesep,num2str(cohort.CThreshold),...
            filesep,'S-',num2str(cohort.omega(1)),'-',...
            num2str(cohort.omega(2)),'-',num2str(cohort.omega(3))];

        mkdir(pat.outputPath)
    else
        pat.path = char(append(cohort.folder,filesep,'derivatives',filesep,...
            'leaddbs', filesep, cohort.patNames{patient,:},filesep));
        pat.TuneSderivativesPath = [cohort.folder,filesep,'derivatives',filesep,'TuneS',filesep,...
            cohort.patNames{patient,:},filesep];
        % Collect all targets into one string, remove extensions
        allTargets = cellfun(@(x) extractBefore(x, '.'), cohort.targets(1,:), 'UniformOutput', false);
        targetsStr = strjoin(allTargets, '_');

        % Collect all constraints into one string
        allConstraints = cellfun(@(x) extractBefore(x, '.'),cohort.constraints(1,:), 'UniformOutput', false);
        constraintsStr = strjoin(allConstraints, '_');

        if strcmp(cohort.optischeme,'MILP') | strcmp(cohort.optischeme,'LP')
            pat.outputPath = [pat.TuneSderivativesPath,'Suggestions',filesep,...
                extractBefore(cohort.targets{1,1},'.'),filesep,...
                cohort.optischeme,filesep,num2str(cohort.EThreshold),'-',num2str(cohort.CThreshold)];
        else

            % Build output path
            pat.outputPath = [pat.TuneSderivativesPath,'Suggestions',filesep,...
                targetsStr,'__',constraintsStr,filesep,...
                cohort.optischeme,filesep,num2str(cohort.CThreshold),...
                filesep,'S-',num2str(cohort.omega(1)),'-',...
                num2str(cohort.omega(2)),'-',num2str(cohort.omega(3))];
            % pat.outputPath = [pat.TuneSderivativesPath,'Suggestions',filesep,...
            %     extractBefore(cohort.targets{1,1},'.'),filesep,...
            %     cohort.optischeme,filesep,num2str(cohort.CThreshold),...
            %     filesep,'S-',num2str(cohort.omega(1)),'-',...
            %     num2str(cohort.omega(2)),'-',num2str(cohort.omega(3))];
        end
        mkdir(pat.outputPath)
    end
    
    pat.orientation.sin = cohort.leadOrientations{patient,1};
    pat.orientation.dx = cohort.leadOrientations{patient,2}; % sin, dx
    hands = {"sin","dx"};

    pat.lead = cohort.leads{patient,1};
    pat.space = cohort.space;
    pat.unit = cohort.unit;
    pat.includeAnisotropy = cohort.simulationSettings.includeAnisotropy;
    pat = assign_coupl_combos(pat,cohort);


    %define patient directory and root directory
    strArray= strsplit(pat.path,filesep);
    pat.name = strArray{end-1};
    root = string(join(strArray(:,1:end-1),filesep));

    if exist('lead','dir')==0
        addpath(genpath('/castor/project/proj_nobackup/MATLAB/lead'));
        addpath(genpath('/castor/project/proj_nobackup/MATLAB/spm12'));
        % add path to Human Dysfunctome atlas (Hollunder 2024)
        addpath(genpath('C:\Users\annfr888\Documents\MATLAB\leaddbs31\templates\space\MNI152NLin2009bAsym\atlases\Human Dysfunctome Atlas (Hollunder 2024)'))
    end

    %try
    if cohort.threads > 1
        try
            %maxNumCompThreads(cohort.threads)
            parpool(cohort.threads);
        catch ME
            disp(ME)
        end
    else
        cohort.threads = 0;
    end



    %% reconstructed lead parameters
    [pat.heads,pat.tails] = get_lead_parameters(pat,hands);


    %% conductivity maps
    %% map from 7T MNI space to anchor modality
    %use the mapped file wt1.nii/wt2.nii to construct conductivity maps

    if strcmp(pat.space,'native')
        %warp from high resolution images to n
        MNI7T_to_native(pat.path(1:end-1),cohort.rebuild);

        %segment the warped image with SPM
        segment_wt1_job(pat.path,cohort.rebuild,pat.space)

        %construct conductivity map for dx and sin (right -and left hemisphere)
        for i = 1:length(hands)
            assign_conductivites(pat)
        end

        disp('Conductivity map in native pat.space computed.')
    end



    %% get target in native pat.space and load region of interest
    targets_and_constraints = [cohort.targets,cohort.constraints];

    %initiate a .mat file in  which target/constraint structure data are to
    %be stored
    create_structure_file(pat,cohort)

    if strcmp(pat.space,'native')
        % warp structures of interest to native pat.space
        warp_regions(pat.name,root,cohort.atlas,targets_and_constraints);
    end


    for i = 1:2

        pat.hand = hands{i};
        if isnan(pat.orientation.(pat.hand))
            continue
        end
        head = pat.heads.(hands{i});
        tail = pat.tails.(hands{i});



        %% Build comsol model
        % simulate the electric field for unit stimulus in case that has
        % not been done previously or if the user requests a rebuild.

        FEM_sol_dir = append(pat.TuneSderivativesPath,'EFdistribution_',pat.hand,'_',pat.unit);

        if ~exist(FEM_sol_dir,'dir') || cohort.rebuild == 1
            run_comsol_terminal(pat,cohort.threads);
        end


        %% load cleaned volume electric data
        InitialSolution = load_comsol_solution(pat,cohort.threads);
        pat.contactNames = fieldnames(InitialSolution);

        % Get maximum coordinate point in ROI
        pat.maxPoint = max(InitialSolution.(pat.contactNames{1})(:,1:3));
        pat.minPoint = min(InitialSolution.(pat.contactNames{1})(:,1:3));

        %% load target and constraint, apply voxelfilter and consider only target points within max and min range
        pat = load_atlas_roi(pat,cohort);

        %% Remove points of target/constraint volumes that lie within the lead volume
        mask_Target = remove_lead_volume2(pat,pat.TargetPoints,head,tail);
        Vol_target = pat.TargetPoints(mask_Target,:);
        mask_Constraint = remove_lead_volume2(pat,pat.ConstraintPoints,head,tail);
        Vol_constraint = pat.ConstraintPoints(mask_Constraint,:);

        try
            assert(length(Vol_target)>100)
        catch
            disp('warning! Number of target points fewer than 100')
        end

        try
            assert(length(Vol_constraint)>100)
        catch
            disp('warning! Number of constraint points fewer than 100')
        end

        if cohort.optimize == 1
            %disp(['Computing closes distance to target centroid for Patient ', pat.path(end-3:end-1), ' ', convertStringsToChars(pat.hand)])
            %distance_contacts_to_target(pat,Vol_target,head,tail)


            fid = fopen(append(pat.outputPath,filesep,'Top_Suggestions_',pat.space,'_',convertStringsToChars(pat.hand),'_',cohort.optischeme,'_',cohort.simulationSettings.tractActivation,'.txt'),'w');
            fprintf(fid,'Contacts \t Target \t Constraint \t Spill \t Alpha \t VTA \t Score\n\n');
            fclose(fid);

            %% Interpolate E-field norm at points of interest (target and constraint)
            pat.InitialSolution_cell = struct2cell(InitialSolution);
            pat.FEMCoordinates = InitialSolution.(pat.contactNames{1})(:,1:3);

            ActiveContactsCombos = fieldnames(InitialSolution);

            if contains(cohort.targets{1,1},'tract') & strcmp(cohort.simulationSettings.tractActivation,'fiberwise')
                %% use pat.Targets and pat.Constraints
                load([pat.path,filesep,'atlases',filesep,cohort.atlas,filesep,'neurostructures.mat'],'region');
                Targetfibs = concat_fibertracts(region,pat,cohort.targets,pat.hand);
                Constraintfibs = concat_fibertracts(region,pat,cohort.constraints,pat.hand);

                mask_Targetfibs = remove_lead_volume2(pat,Targetfibs(:,1:3),head,tail);
                Targetfibs = Targetfibs(mask_Targetfibs,:);
                mask_Constraintfibs = remove_lead_volume2(pat,Constraintfibs(:,1:3),head,tail);
                Constraintfibs = Constraintfibs(mask_Constraintfibs,:);


                for k = 1:length(fieldnames(InitialSolution))
                    field = ActiveContactsCombos{k};
                    F = scatteredInterpolant(InitialSolution.(field)(:,1),InitialSolution.(field)(:,2),InitialSolution.(field)(:,3),InitialSolution.(field)(:,8));
                    VqT{k,1} = F(Targetfibs(:,1),Targetfibs(:,2),Targetfibs(:,3));
                    VqC{k,1} = F(Constraintfibs(:,1),Constraintfibs(:,2),Constraintfibs(:,3));

                    % Only keep the point along each fiber that has the
                    % highest E-field norm
                    VqTarget{k,1} = [];
                    VqTargetCoords{k,1} = [];
                    for id = min(Targetfibs(:,4)):max(Targetfibs(:,4))
                        idx = (Targetfibs(:,4) == id);
                        [~,imax] = max(VqT{k,1}(idx));
                        selectedIdx = find(idx);
                        VqTargetCoords{k,1}(end+1,:) = [Targetfibs(selectedIdx(imax),1:3), id];
                        VqTarget{k,1}(end+1,:) = VqT{k,1}(selectedIdx(imax));
                    end
                    
                    VqConstraint{k,1} = [];
                    VqConstraintCoords{k,1} = [];
                    for id = min(Constraintfibs(:,4)):max(Constraintfibs(:,4))
                        idx = (Constraintfibs(:,4) == id);
                        [~,imax] = max(VqC{k,1}(idx));
                        selectedIdx = find(idx);
                        VqConstraintCoords{k,1}(end+1,:) = [Constraintfibs(selectedIdx(imax),1:3), id];
                        VqConstraint{k,1}(end+1,:) = [VqC{k,1}(imax)];
                    end
                end
                pat.VqTargetCoords = VqTargetCoords;
                pat.VqConstraintCoords = VqConstraintCoords;
            else
                for k = 1:length(fieldnames(InitialSolution))
                    field = ActiveContactsCombos{k};
                    F = scatteredInterpolant(InitialSolution.(field)(:,1),InitialSolution.(field)(:,2),InitialSolution.(field)(:,3),InitialSolution.(field)(:,8));
                    VqTarget{k,1} = F(Vol_target(:,1),Vol_target(:,2),Vol_target(:,3));
                    VqConstraint{k,1} = F(Vol_constraint(:,1),Vol_constraint(:,2),Vol_constraint(:,3));
                end
            end
            pat.VqTarget = VqTarget;
            pat.VqConstraint = VqConstraint;

            %% Optimization
            for k = 1:length(relaxation)
                pat.rel = relaxation(k);
                cou = eye(length(pat.contactNames));
                [cohort, pat] = run_optimization(cohort,pat,VqTarget,VqConstraint,pat.rel,cou,i);

                if ~strcmp(cohort.optischeme,'MILP') && ~strcmp(cohort.optischeme,'LP')
                    write_recommendations_to_file(cohort,pat,head,tail,pat.InitialSolution_cell,pat.Targets,pat.Constraints)
                end
            end
            %bestOption{counter} = sprintf(' Patient %s %s \n Best Suggestion: \n --------------------- \n Contacts: %s \n Target activation %s : %s \n Amplitude :%s \n Spill %s: %s \n Constraint activation %s : %s \n VTA : %s mm%s \n Score : %s \n',char(cohort.patNames(patient,:)),pat.hand,bestConfig,'%',bestTarget,bestAlpha,'%',bestSpill,'%',bestConstraint,bestVTA,char(179),bestScore);
            %counter = counter +1;
            save([pat.outputPath,filesep,char(pat.hand),'_suggestions.mat'],'pat','cohort')
        end
    
        if cohort.plotoption
            disp('Plotting...')
            % visualisation
            plot_lead(pat)
            % plot_lead(head,tail,VTAfig,lead,orientation)
            % if exist("bestSolution")
            %     plot_lead(cohort,pat)
            % elseif cohort.compareSettings
            %     I0 = cohort.clinicalSettings{1,i}.(cohort.patNames{patient,:}){1,2};
            %     Contacts = strrep(cohort.clinicalSettings{1,i}.(cohort.patNames{patient,:}){1,1},',','_');
            %     pw = cohort.clinicalSettings{1,i}.(cohort.patNames{patient,:}){1,3};
            %     bestSolution = {Contacts,'','','',I0};
            %     plot_lead(pat.path,bestSolution,pat.hand,pat.space)
            %     clear I0 Contacts pw
            % end
            ax = gca;
            hold on
            plot_target_and_constraint(pat)
            plot_VTA(cohort,pat)
            % adjust figure properties
            axis off
            %light("Position",[-1 0 0],"Style","infinite")
            light("Style","infinite","Position",[0 10 0]);
            xlim([head(1)-10*1e-3, head(1)+10*1e-3])
            ylim([head(2)-10*1e-3, head(2)+10*1e-3])
            zlim([head(3)-10*1e-3, head(3)+10*1e-3])
            title(pat.hand)
            %fig1=figure('visible','off');
            %set(gcf, 'color',[0.1 0.1 0.1])
            %copyobj([ax,ax.Legend],fig1);
            %savefig(append(pat.outputPath,pat.hand,'_stimulation.fig'))
            camzoom(1.2)
            savefig([pat.outputPath,char(pat.hand),'_DBS_scenario.fig'])
            exportgraphics(gcf,[pat.outputPath,char(pat.hand),'_DBS_scenario.png'],'Resolution',300)
        else
            disp('Not plotting...')
        end
        if cohort.compareSettings %&& strcmp(char(cohort.patNames(pat.name,:)),cohort.selectedPatient)
            out = compare_suggested_2_clinical_settings(pat,pat.hand,head,tail,cohort,Vol_target,Vol_constraint);
            msg = 'Done comparing settings.';
        end


    end
end
if cohort.optimize==1
    %
end


gcp('nocreate');


% catch ME
%       if (strcmp(ME.identifier,'MATLAB:load:couldNotReadFileXX'))
%           msg = 'Needed files are missing. Are you sure you picked the correct patient directory and that it contains all necessary files?';
%
%      else
%          msg = ME.message;
%          disp(ME.identifier)
%
%       end
% end

if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end
msg = 'Computations finished.';
toc

end
