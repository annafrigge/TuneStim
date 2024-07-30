function out = compareSuggested2Clinical(pat_path,space,hand,...
    clinicalSettings,Vol_target,Vol_constraint,...
    computeDice,computeTargetCoverage)

dataEnorm = {cell(length(clinicalSettings(1)),1),cell(length(clinicalSettings(1)),1)};

%load lead-specific model
model = mphload(append(pat_path,'DBS_simulation.mph'));
EThresh = 200;
%EThresh = pw_adjusted_EThresh(pw);

for h = 1:length(hand)
    model.param.loadFile(append(pat_path,'lead_parameters_',...
        space,'_',hand{h},'.txt'));

    for j = 1:length(clinicalSettings)
        % set current amplitude
        model.param.set('I0', clinicalSettings{1,h}{j,2}*1e-3);   

        % set active contacts
        activeContacts = strsplit(clinicalSettings{1,h}{j},',')';
        N1 = size(activeContacts,1);% # active negative contacts
        model.component('comp1').geom('geom1').selection.create('csel1', 'CumulativeSelection');

        for i=1:N1
            model.component('comp1').geom('geom1').feature(append('sel_',activeContacts(i,:))).set('contributeto', 'csel1');
        end
        model.component('comp1').geom('geom1').run('fin');

        model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        
        model.sol('sol1').runAll;

        dataEnorm{j,h} = mpheval(model,'ec.normE','selection','geom1_sel11');
        dataEnormTarget{j,h} = mphinterp(model,'ec.normE','coord',Vol_target');
        dataEnormConstraint{j,h} = mphinterp(model,'ec.normE','coord',Vol_constraint');
        model.component('comp1').geom('geom1').selection.remove('csel1.bnd');
    end
    if computeDice
        fprintf('Dice Coefficients for %s : \n',hand{h})
        for j=1:length(clinicalSettings)-1
            diceEnorm{j,h} = dice(dataEnorm{j,h}.d1>=EThresh,dataEnorm{j+1,h}.d1>=EThresh);
            diceEnormTarget{j,h} = dice(dataEnormTarget{j,h}>=EThresh,dataEnormTarget{j+1,h}>=EThresh);
            diceEnormConstraint{j,h} = dice(dataEnormConstraint{j,h}>=EThresh,dataEnormConstraint{j+1,h}>=EThresh);
            fprintf('Inhomogeneous tissue: %1.2f \n',diceEnorm{j,h})
            fprintf('Target: S = %1.2f \n',diceEnormTarget{j,h})
            fprintf('Constraint: S = %1.2f \n \n',diceEnormConstraint{j,h})
        end
    end

    if computeTargetCoverage
        fprintf('Coverages for %s : \n',hand{h})
        for j=1:length(clinicalSettings )
            coverageTarget{j,h} = sum(dataEnormTarget{j,h}>=EThresh)/numel(dataEnormTarget{j,h});
            coverageConstraint{j,h} = sum(dataEnormConstraint{j,h}>=EThresh)/numel(dataEnormConstraint{j,h});
            fprintf('Target coverage: %3.2f %% \n',coverageTarget{j,h}*100)
            fprintf('Constraint coverage: %3.2f %% \n \n',coverageConstraint{j,h}*100)
        end
    end

end



out =1;





