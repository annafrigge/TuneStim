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
% ToDo:
% 1. Include all other leads
% 2. Boston Scientific Vercise Standard 2201 -- Terminal!
% 3. Lead DBS version 3.1 support
% 4. Include tests and error messages!
% 5. Include option for current and voltage stimulation!!!

tic
settings;
warning('off','MATLAB:dispatcher:nameConflict')



cohort.omega = str2num(replace(cohort.omega,'-',' '));
if strcmp(cohort.optischeme,'Linear')| strcmp(cohort.optischeme,'Nonlinear')
    relaxation = 0:10:90;
elseif strcmp(cohort.optischeme,'mincov')
    relaxation = 10:10:90;
end
counter = 1;
for patient=1:length(cohort.patNames)
    disp(append('Patient ',cohort.patNames{patient,:},' loading ...'))
    pat.path = char(append(cohort.folder,filesep,cohort.patNames{patient,:},filesep));
    pat.orientation = [cohort.leadOrientations{patient,1}, cohort.leadOrientations{patient,2}];    
    hands = {"sin","dx"};
    
    pat.lead = cohort.leads{patient,1};
    pat.space = cohort.space;
    pat.unit = cohort.unit;
    pat = assign_coupl_combos(pat);


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

    %% Outout directories

    mkdir([pat.path,'Suggestions'])
    pat.outputPath = [pat.path,'Suggestions',filesep,extractBefore(cohort.targets{1,1},'.'),filesep,cohort.optischeme,filesep,num2str(cohort.CThreshold),filesep,'S-',num2str(cohort.omega(1)),'-',num2str(cohort.omega(2)),'-',num2str(cohort.omega(3))];

    mkdir(pat.outputPath)


    %% reconstructed lead parameters
    [heads,tails]=get_lead_parameters(pat,hands);


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
        if isnan(pat.orientation(i))
            continue
        end
        pat.hand = hands{i};
        head = heads.(hands{i});
        tail = tails.(hands{i});



        %% build comsol model
        % simulate the electric field for unit stimulus in case that has
        % not been done previously or if the user requests a rebuild.

        FEM_sol_dir = append(pat.path,'EFdistribution_',pat.hand,'_',pat.unit);

        if ~exist(FEM_sol_dir,'dir') || cohort.rebuild == 1
            run_comsol_terminal(pat,cohort.threads);
        end


        %% load cleaned volume electric data
        InitialSolution = load_comsol_solution(pat,cohort.threads);
        contactNames = fieldnames(InitialSolution);

        % Get maximum coordinate point in ROI
        maxPoint = max(InitialSolution.(contactNames{1})(:,1:3));
        minPoint = min(InitialSolution.(contactNames{1})(:,1:3));


        %% load target and constraint and  consider only target points within max and min range
        [target,constraint, target_lst,constraint_lst] = load_atlas_roi(pat,cohort,maxPoint,minPoint,head);


        %% Remove points of target/constraint volumes that lie within the lead volume
        Vol_target = remove_lead_volume2(target,head,tail);
        Vol_constraint = remove_lead_volume2(constraint,head,tail);

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
            disp(['Computing closes distance to target centroid for Patient ', pat.path(end-3:end-1), ' ', convertStringsToChars(pat.hand)])
            distance_contacts_to_target(Vol_target,head,tail)


            fid = fopen(append(pat.outputPath,filesep,'Top_Suggestions_',pat.space,'_',convertStringsToChars(pat.hand),'_',cohort.optischeme,'_','.txt'),'w');
            fprintf(fid,'Contacts \t Target \t Constraint \t Spill \t Alpha \t VTA \t Score\n\n');
            fclose(fid);

            %% approximate target points E-field
            InitialSolution_cell = struct2cell(InitialSolution);
            solution_coords = InitialSolution.(contactNames{1})(:,1:3);

            fprintf('Interpolating comsol model E-field for %d points...',length(Vol_target)+length(Vol_constraint))

            %pick one of two methods,method of fundamental solutions (MFS) or
            %nearest neighbor (NNB)
            method = 'MFS';
            EF_nearest=cell(length(Vol_target),1);

            parfor(j = 1:length(Vol_target),cohort.threads)
                [EF_nearest{j},test_point{j}] = nearest_EF(InitialSolution_cell,solution_coords,Vol_target(j,1:3));
                [~,~,EFnorm_target(j)] = EV_point(EF_nearest{j} ,contactNames,Vol_target(j,1:3),0,1e8,method);
            end

            % test that the interpolation error is not above 10%
            test_interpolation(EF_nearest,test_point,contactNames,method)
            clear test_point EF_nearest

            parfor(j = 1:length(Vol_constraint),cohort.threads)
                [EF_nearest{j},test_point{j}] = nearest_EF(InitialSolution_cell,solution_coords,Vol_constraint(j,1:3));
                [~,~,EFnorm_constraint(j)] = EV_point(EF_nearest{j} ,contactNames,Vol_constraint(j,1:3),0,1e8,method);
            end

            % test that the interpolation error is not above 10%
            test_interpolation(EF_nearest,test_point,contactNames,method)
            clear test_point EF_nearest

            % save constraint and target EF in cell array - one cell for each contact
            EnormConstraint = cell(length(contactNames),1);
            for k = 1:length(contactNames)
                for p = 1:length(Vol_constraint)
                    EnormConstraint{k}(p) = EFnorm_constraint(p).(contactNames{k});
                end
            end

            EnormTarget = cell(length(contactNames),1);
            for k = 1:length(contactNames)
                for p = 1:length(Vol_target)
                    EnormTarget{k}(p) = EFnorm_target(p).(contactNames{k});
                end
            end

            % Carry coordinates for fiber targeting optimization scheme
            EnormConstraint{1,2} = Vol_constraint;
            EnormTarget{1,2} = Vol_target;
            %% Optimization

            for k = 1:length(relaxation)
                rel = relaxation(k);
                cou = eye(length(contactNames));
                [alpha, J] = run_optimization(cohort,EnormTarget,...
                    EnormConstraint,rel,cou);

                %% Compute VTA
                disp('Computing volume of tissue activated...')

                %compute target activation and spill
                disp("Computing target activation")
                [pAct_target,pSpill_target,VTA] = ...
                    computing_volumes(head,tail,InitialSolution_cell,alpha,target_lst,cohort);


                %compute constraint activation and spill
                disp('Computing constraint activation')
                [pAct_constraint,pSpill_constraint,VTA] = ...
                    computing_volumes(head,tail,InitialSolution_cell,alpha,constraint_lst,cohort);




                %% write array of recommendations
                wt= cohort.omega(1);% scores need to be normalized for meaningful comparison across a dataset of patients?
                wc = cohort.omega(2);
                ws = cohort.omega(3);
                scores = wt*pAct_target*100-wc*pAct_constraint*100-ws*pSpill_target*100;
                %scores = (relaxation/100-pSpill_target*100)^2;

                [desc_order,idx] = sort(scores, 'descend');
                best_idx = idx(1);


                % write results to .txt
                fid=fopen(append(pat.outputPath,filesep,'Suggestions_',pat.space,'_',pat.hand,'_',cohort.optischeme,'_',num2str(rel),'.txt'),'w+');
                fprintf(fid,'Contacts \t Target activation %s \t Constraint activation %s \t Spill %s \t Alpha \t VTA \t Score\n\n','%','%','%');

                a = cell(length(idx),7);
                for j = 1:length(idx)
                    in = idx(j);
                    a{j,1} = erase(contactNames{in},'.csv');
                    a{j,2} = [9 num2str( round(pAct_target(in)*100,2))];
                    a{j,3} = num2str( round(pAct_constraint(in)*100,2));
                    a{j,4} = num2str( round(pSpill_target(in)*100,2));
                    a{j,5} = num2str( round(alpha(in),2) );
                    a{j,6} = num2str( round(VTA(in),2) );
                    a{j,7} = num2str( round(scores(in),2));

                    fprintf(fid,' %s \t %s \t\t\t %s \t\t\t %s \t\t %s \t %s \t\t\t %s \n', a{j,1},a{j,2},a{j,3},a{j,4},a{j,5},a{j,6},a{j,7});
                end

                fclose(fid);

                %% Top suggestions for all relaxations
                fid = fopen(append(pat.outputPath,filesep,'Top_Suggestions_',pat.space,'_',convertStringsToChars(pat.hand),'_',cohort.optischeme,'_','.txt'),'a');
                fprintf(fid,' %s \t %s \t %s \t %s\t %s \t %s \t %s \n',a{1,1},a{1,2},a{1,3},a{1,4},a{1,5},a{1,6},a{1,7});
                fclose(fid);
                [bestScore, bestIdx] =  max(str2double({a{:,7}}));
                if ~exist('bestSolution','var')
                    bestSolution = a(bestIdx,:);
                elseif bestScore > str2double(bestSolution{1,7})
                    bestSolution = a(bestIdx,:);
                end

                % print out best option
                bestAlpha = bestSolution{5};%num2str( round(alpha(best_idx),2) );
                bestTarget = bestSolution{2};%num2str( round(pAct_target(best_idx)*100,2));
                bestConstraint = bestSolution{3};%num2str( round(pAct_constraint(best_idx)*100,2));
                bestSpill = bestSolution{4};%num2str( round(pSpill_target(best_idx)*100,2));
                bestConfig = bestSolution{1};%erase(contactNames{best_idx},'.csv');
                bestVTA  = bestSolution{6};%num2str( round(VTA(best_idx),2) );
                bestScore = bestSolution{7};




            end
            bestOption{counter} = sprintf(' Patient %s %s \n Best Suggestion: \n --------------------- \n Contacts: %s \n Target activation %s : %s \n Amplitude :%s \n Spill %s: %s \n Constraint activation %s : %s \n VTA : %s mm%s \n Score : %s \n',char(cohort.patNames(patient,:)),pat.hand,bestConfig,'%',bestTarget,bestAlpha,'%',bestSpill,'%',bestConstraint,bestVTA,char(179),bestScore);
            counter = counter +1;
        end


        if cohort.plotoption
            disp('Plotting...')
            % visualisation
            %[fig,VTAfig,lgd] = visualize();
            %plot_target_and_constraint(pat.path,atlas,targets_and_constraints,hand{i},pat.space,VTAfig)
            %plot_VTA(InitialSolution,alpha,EFobj_target,best_idx,VTAfig)
            % plot_lead(head,tail,VTAfig,lead,orientation)
            if exist("bestSolution")
                plot_lead(pat.path,bestSolution,pat.hand,pat.space)
            elseif cohort.compareSettings
                I0 = cohort.clinicalSettings{1,i}.(cohort.patNames{patient,:}){1,2};
                Contacts = strrep(cohort.clinicalSettings{1,i}.(cohort.patNames{patient,:}){1,1},',','_');
                pw = cohort.clinicalSettings{1,i}.(cohort.patNames{patient,:}){1,3};
                bestSolution = {Contacts,'','','',I0};
                plot_lead(pat.path,bestSolution,pat.hand,pat.space)
                clear I0 Contacts pw
            end
            VTAfig = gca;
            hold on
            plot_target_and_constraint(pat.path,cohort.atlas,targets_and_constraints,pat.hand,pat.space,VTAfig)
            %plot_VTA(InitialSolution,alpha,EFobj_target,best_idx,VTAfig)
            %adjust figure properties
            fac=1;
            ax=VTAfig;

            ax.XLim(1)=ax.XLim(1)-fac*norm(ax.XLim(1)-ax.XLim(2));
            ax.XLim(2)=ax.XLim(2)+fac*norm(ax.XLim(1)-ax.XLim(2));

            ax.YLim(1)=ax.YLim(1)-fac*norm(ax.YLim(1)-ax.YLim(2));
            ax.YLim(2)=ax.YLim(2)+fac*norm(ax.YLim(1)-ax.YLim(2));
            axis(ax,'equal')
            light("Position",[-1 0 0],"Style","infinite")


            fig1=figure('visible','off');
            set(gcf, 'color',[0.1 0.1 0.1])
            copyobj([VTAfig,VTAfig.Legend],fig1);
            savefig(append(pat.path,pat.hand,'_stimulation.fig'))
        else
            disp('Not plotting...')
        end
        if cohort.compareSettings %&& strcmp(char(cohort.patNames(pat.name,:)),cohort.selectedPatient)
            out = compare_suggested_2_clinical_settings(pat,pat.hand,head,tail,cohort,Vol_target,Vol_constraint);
        end
        msg = 'Done comparing settings.';
    end
    if cohort.optimize==1
        msg = bestOption{:};
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

    toc

end


end