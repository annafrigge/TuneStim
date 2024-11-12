function plot_lead(pat.path,bestSolution,hand,pat.space)
%plot_lead(head,tail,VTAfig,lead,orientation)
%plot cylinder

    model = mphload(append(pat.path,'DBS_simulation.mph'));
    model.param.loadFile(append(pat.path,'lead_parameters_',...
        pat.space,'_',hand,'.txt'));
    if isstring(bestSolution{5})
        model.param.set('I0', str2double(bestSolution{5})*1e-3); 
    else
        model.param.set('I0', bestSolution{5}*1e-3); 
    end
    % set active contacts
    activeContacts = strsplit(bestSolution{1},'_')';
    N1 = size(activeContacts,1);% # active negative contacts
    model.component('comp1').geom('geom1').selection.create('csel1', 'CumulativeSelection');

    for i=1:N1
        model.component('comp1').geom('geom1').feature(append('sel_',activeContacts(i,:))).set('contributeto', 'csel1');
    end
    model.component('comp1').geom('geom1').run('fin');

    model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');

    model.sol('sol1').runAll;
    %model.result('pg2').feature('iso1').active(false);
    model.result('pg2').feature('surf1').feature('sel1').selection.named('geom1_sel9');
    model.result('pg2').run;
    model.result('pg2').feature('surf2').feature('sel1').selection.named('geom1_sel10');
 
    model.result('pg2').run;
    figure
    mphplot(model,'pg2');
    hold on
    %camlight
    % dataEnorm = mpheval(model,'ec.normE','selection','geom1_sel11');
    % idx = dataEnorm.d1>=200;
    % VTApoints= dataEnorm.p(:,idx)';
    % [VTA,~] = convhull(VTApoints);
    % hold on
    % plot(VTApoints(k))
    % leadvector=(tail-head)/norm(head-tail);
    % vlead0=[0,0,1];
    % r = vrrotvec(vlead0,leadvector);
    % Rotation = vrrotvec2mat(r);
    % 
    % Rotation_z =rotz(orientation);
    % if strcmp(lead,'S:t Jude 1331')
    %     load("Leads/stjude_directed_short.mat")
    % elseif strcmp(lead,'Boston Scientific 2202')
    %     load("Leads/boston_vercise_directed.mat")
    % 
    % end
    % 
    % N_insulation = length(electrode.insulation);
    % tilt_insulation_points = cell(N_insulation);
    % 
    % 
    % N_electrode = length(electrode.contacts);
    % tilt_electrode_points = cell(N_electrode);
    % 
    % %tilt lead axis
    % 
    % 
    % 
    % for i=1:N_electrode
    %     electrode_points = electrode.contacts(i).vertices;
    %     N_points = length(electrode_points);
    %     for j=1:N_points
    % 
    %         electrode.contacts(i).vertices(j,1:3) = 10^(-3)*(Rotation*Rotation_z*(electrode_points(j,1:3))')'+head- 2.25e-3 * leadvector;
    % 
    %     end
    % 
    %     patch(VTAfig,electrode.contacts(i),'EdgeColor','none','FaceColor',[0.4,0.4,0.4],'HandleVisibility','off')
    %     hold(VTAfig,'on')
    % end
    % 
    % for i=1:N_insulation
    %     insulation_points = electrode.insulation(i).vertices;
    %     N_points = length(insulation_points);
    %     for j=1:N_points
    % 
    %         electrode.insulation(i).vertices(j,1:3) = 10^(-3)*(Rotation*(insulation_points(j,1:3))')'+head- 2.25e-3 * leadvector;
    % 
    %     end
    % 
    % 
    %     patch(VTAfig,electrode.insulation(i),'EdgeColor','none','FaceColor',[0.8,0.8,0.8],'HandleVisibility','off')
    %     hold(VTAfig,'on')
    % end
    
   
end