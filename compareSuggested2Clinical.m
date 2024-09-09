function out = compareSuggested2Clinical(pat_path,space,hand,head,tail,...
    clinicalSettings,atlas,target_names,constraint_names,Vol_target,Vol_constraint,...
    computeDice,computeTargetCoverage)

leadvector=(tail-head)/norm(head-tail);
vlead0=[0,0,1];
r = vrrotvec(vlead0,leadvector);
R = vrrotvec2mat(r);
dataEnorm = {cell(length(clinicalSettings(1)),1),cell(length(clinicalSettings(1)),1)};

%load lead-specific model
model = mphload(append(pat_path,'DBS_simulation.mph'));
EThresh = zeros(size(clinicalSettings,1),1);
for j = 1:length(EThresh)
    EThresh(j) = pw_adjusted_EThresh(clinicalSettings{j,3});
end
if contains(target_names{1,1},'tract')
            load([pat_path,'atlases',filesep,atlas,filesep,'neurostructures.mat'])
            Targetfibs = concat_fibertracts(region,space,target_names,hand);
            Constraintfibs = concat_fibertracts(region,space,constraint_names,hand);
end


     model.param.loadFile(append(pat_path,'lead_parameters_',...
        space,'_',hand,'.txt'));


    for j = 1:size(clinicalSettings,1)
        % set current amplitude
        model.param.set('I0', clinicalSettings{j,2}*1e-3);   
        % set active contacts
        activeContacts = strsplit(clinicalSettings{j},',')';
        N1 = size(activeContacts,1);% # active negative contacts
        model.component('comp1').geom('geom1').selection.create('csel1', 'CumulativeSelection');

        for i=1:N1
            model.component('comp1').geom('geom1').feature(append('sel_',activeContacts(i,:))).set('contributeto', 'csel1');
        end
        model.component('comp1').geom('geom1').run('fin');

        model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        
        model.sol('sol1').runAll;
        models{j} = model;

        dataEnorm{j} = mpheval(model,{'x','y','z','ec.normE'},'selection','geom1_sel11');
        dataEnormTarget{j} = mphinterp(model,'ec.normE','coord',Vol_target');
        dataEnormConstraint{j} = mphinterp(model,'ec.normE','coord',Vol_constraint');
        if contains(target_names{1,1},'tract')
        dataEnormTargetFibs{j} = mphinterp(model,'ec.normE','coord',Targetfibs(:,1:3)','dataset','dset1');
        dataEnormConstraintFibs{j} = mphinterp(model,'ec.normE','coord',Constraintfibs(:,1:3)','dataset','dset1');
        end

        model.component('comp1').geom('geom1').selection.remove('csel1.bnd');
        
    end
    if computeDice
        mkdir(append(pat_path,'Suggestions',filesep,extractBefore(target_names{1,1},'.'),filesep,'DiceScores'))
        fid=fopen(append(pat_path,'Suggestions',filesep,extractBefore(target_names{1,1},'.'),filesep,'DiceScores',filesep,'Dice_',space,'_',hand,'.txt'),'w');
        fprintf(fid,'Contacts \t Amplitude %s \t Pulse width %s \t EThreshold %s \t Dice VTA \t Dice Target \t Dice Constraint \n\n','[mA]','[us]','[V/m]');

        %fprintf('Dice Coefficients for %s : \n',hand)
        for j=1:size(clinicalSettings,1)
            diceEnorm{j} = dice(dataEnorm{1}.d4>=EThresh(1),...
                                dataEnorm{j}.d4>=EThresh(j));
            diceEnormTarget{j} = dice(dataEnormTarget{1}>=EThresh(1),...
                                        dataEnormTarget{j}>=EThresh(j));
            diceEnormConstraint{j} = dice(dataEnormConstraint{1}>=EThresh(1),...
                                          dataEnormConstraint{j}>=EThresh(j));
            %fprintf('Inhomogeneous tissue: %1.2f \n',diceEnorm{j})
            %fprintf('Target: S = %1.2f \n',diceEnormTarget{j})
            %fprintf('Constraint: S = %1.2f \n \n',diceEnormConstraint{j})'
            fprintf(fid,' %s \t %s \t\t\t %s \t\t\t %s \t\t %s \t %s \t\t\t %s \n', ...
                clinicalSettings{j},num2str(clinicalSettings{j,2}),...
                num2str(clinicalSettings{j,3}),num2str(EThresh(j)),...
                num2str(diceEnorm{j}),num2str(diceEnormTarget{j}),...
                num2str(diceEnormConstraint{j}));
        end
        fclose(fid);
    end

    if computeTargetCoverage
        mkdir(append(pat_path,'Suggestions',filesep,extractBefore(target_names{1,1},'.'),filesep,'Coverages'))
        fid=fopen(append(pat_path,'Suggestions',filesep,extractBefore(target_names{1,1},'.'),filesep,'Coverages',filesep,'Coverages_',space,'_',hand,'.txt'),'w');
        fprintf(fid,'Contacts \t Amplitude %s \t Pulse width %s \t EThreshold %s \t  Target Coverage \t Spill \t Constraint Coverage \n\n','[mA]','[us]','[V/m]');
        if contains(target_names{1,1},'tract')
            for j=1:size(clinicalSettings,1)
                [afibs,pActTarget{j}] = get_fibers_covered_by_VTA(Targetfibs,dataEnormTargetFibs{j},EThresh(j)); 
                pActSpill{j} = NaN;
            end
        else
            for j=1:size(clinicalSettings,1)
                [pActTarget{j},pActSpill{j},~] = volume_of_tissue_activated(dataEnorm{j},Vol_target,R,head,leadvector,EThresh(j));
            end
        end
        if contains(constraint_names,'tract')
            for j=1:size(clinicalSettings,1)

                [afibs,pActConstraint{j}] = get_fibers_covered_by_VTA(Targetfibs,dataEnormConstraintFibs{j},EThresh(j)); 
                pActSpill{j} = NaN;
            end
        else
            [pActConstraint{j},~,~] = volume_of_tissue_activated(dataEnorm{j},Vol_constraint,R,head,leadvector,EThresh(j));
        end

        

        for j=1:size(clinicalSettings,1)
            fprintf(fid,' %s \t %s \t\t\t %s \t\t\t %s \t\t %s \t %s \t\t\t %s \n', ...
                clinicalSettings{j},num2str(clinicalSettings{j,2}),...
                num2str(clinicalSettings{j,3}),num2str(EThresh(j)),...
                num2str(pActTarget{j}),num2str(pActSpill{j}),...
                num2str(pActConstraint{j}));
        end
        fclose(fid);
    end


out = 1;
end

                %coverageTarget{j} = sum(dataEnormTarget{j}>=EThresh(j))/numel(dataEnormTarget{j});
                %coverageConstraint{j} = sum(dataEnormConstraint{j}>=EThresh(j))/numel(dataEnormConstraint{j});
                %spill{j} = sum(dataEnorm{j}.d1>=EThresh(j));




