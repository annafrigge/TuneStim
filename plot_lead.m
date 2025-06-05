function plot_lead(pat)

    model = mphload(append(pat.TuneSderivativesPath,'DBS_simulation.mph'));
    model.param.loadFile(append(pat.TuneSderivativesPath,'lead_parameters_',...
        pat.space,'_',pat.hand,'.txt'));

    % if isstring(bestSolution{5})
    %     model.param.set('I0', str2double(bestSolution{5})*1e-3); 
    % else
    %     model.param.set('I0', bestSolution{5}*1e-3); 
    % end
    % % set active contacts
    % activeContacts = strsplit(bestSolution{1},'_')';
    % N1 = size(activeContacts,1);% # active negative contacts
    % model.component('comp1').geom('geom1').selection.create('csel1', 'CumulativeSelection');
    % 
    % for i=1:N1
    %     model.component('comp1').geom('geom1').feature(append('sel_',activeContacts(i,:))).set('contributeto', 'csel1');
    % end
    model.component('comp1').geom('geom1').run('fin');
    % 
    % model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
    % 
    model.sol('sol1').runAll;
    model.result('pg2').feature('iso1').active(false);
    model.result('pg2').feature('surf1').feature('sel1').selection.named('geom1_sel9');
    model.result('pg2').run;
    model.result('pg2').feature('surf2').feature('sel1').selection.named('geom1_sel10');
 
    model.result('pg2').run;
    figure
    mphplot(model,'pg2');
    hold on

   
end