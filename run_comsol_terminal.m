function out = run_comsol_terminal(pat,nProc)
disp(nProc)
%addpath('/sw/apps/comsol/x86_64/6.0/mli');
%addpath('C:\Program Files\COMSOL\COMSOL56\Multiphysics\bin\win64')

%open Comsol server at a number of ports
%cmd = ['. ' pwd '/Comsol/ComsolServers.sh ' num2str(nProc+1)];
%system(cmd);

%this command displays the open ports. 
%system('netstat -tuplen');


%disp('trying to connect to the Comsol server...')
%tic
%mphstart(2036);
%fprintf('Connected, the time it took to establish a connection was %.2f seconds \n',toc);

import com.comsol.model.*
import com.comsol.model.util.*


if strcmp(pat.lead,'Boston Scientific 2202')
    disp('Loading Boston 2202 lead')
    modelname = 'bostonsctf_simulationTerminal.mph';
elseif strcmp(pat.lead,'S:t Jude 1331')
    disp('Loading Stjude 1331 lead')
    modelname = 'stjude1331_simulationTerminal.mph';
elseif strcmp(pat.lead,'Boston Scientific Vercise Cartesia')
    disp('Loading Boston Scientific Vercise Cartesia')
    modelname = 'bostonsctf_vercartesia_simulation.mph';
elseif strcmp(pat.lead,'Medtronic 3887')
    disp('Loading Medtronic 3887')
    modelname = 'medtronic3887_simulationTerminal.mph';
end


%load lead-specific model
model = mphload(modelname);

if strcmp(pat.lead,'Boston Scientific 2202') || strcmp(pat.lead,'S:t Jude 1331')
% coupling combinations (H=Horizontal combination, V=Vertical combination)
coupl_combos = {'C1X'; 'C2A'; 'C2B'; 'C2C'; 'C3A';...
            'C3B'; 'C3C'; 'C4X';...
            'C2A_C2B'; 'C2B_C2C'; 'C2C_C2A'; 'C3A_C3B'; 'C3B_C3C';...
            'C3C_C3A'; ...
            'C2A_C3A'; 'C2B_C3B'; 'C2C_C3C';...
            'C2A_C2B_C2C'; 'C3A_C3B_C3C';...
            'C1X_C2A';'C1X_C2B';'C1X_C2C';...
            'C4X_C3A';'C4X_C3B';'C4X_C3C';...
            'C2A_C3B';'C2A_C3C';'C2B_C3A';...
            'C2B_C3C';'C2C_C3A';'C2C_C3B'};
elseif strcmp(pat.lead,'Boston Scientific Vercise Cartesia')
    coupl_combos = ['Mono_1X'; 'Mono_2A'; 'Mono_2B'; 'Mono_2C'; 'Mono_3A';...
                 'Mono_3B'; 'Mono_3C'; 'Mono_4X';...
                 'Duo_1_2'; 'Duo_2_3'; 'Duo_3_4'; 'Duo_4_5'; 'Duo_5_6';...
                 'Duo_6_7'; 'Duo_7_8'];
end
comsolPorts = 2036:1:2036+nProc ;

try parpool(nProc); end

%switch to the actual patient of choice
lead_path = append(pat.path,'lead_parameters_',pat.space,...
                            '_',pat.hand,'.txt');
model.param.loadFile(lead_path);

model.component('comp1').geom('geom1').run('fin');

model.component('comp1').probe('bnd1').genResult('none');
model.component('comp1').probe('bnd2').genResult('none');
model.component('comp1').probe('bnd3').genResult('none');
model.component('comp1').probe('bnd4').genResult('none');
model.component('comp1').probe('bnd5').genResult('none');
model.component('comp1').probe('bnd6').genResult('none');
model.component('comp1').probe('bnd7').genResult('none');
model.component('comp1').probe('bnd8').genResult('none');

% loading conductivity map 
model.func.remove('int1');
model.func.create('int1', 'Interpolation');
model.func('int1').set('source', 'file');
if strcmp(pat.space,'native')
    model.func('int1').set('filename', append(pat.path,'conductivity_map_',pat.hand,'_native.csv'));
else
    model.func('int1').set('filename', append(pwd,filesep,'MNI',filesep,'conductivity_map_',pat.hand,'_MNI.csv'));
end
model.func('int1').setIndex('funcs', 'sigma_brain', 0, 0);
model.func('int1').importData;
model.func('int1').set('interp', 'neighbor');
model.func('int1').set('extrap', 'value');
model.func('int1').set('extrapvalue', 0.1);
model.func('int1').set('argunit', 'm,m,m');
model.func('int1').set('fununit', 'S/m');



%model.sol('sol1').runAll;

% create export of coupling constants
model.result.export.create('tbl1', 'Table');
model.result.export('tbl1').set('table', 'tbl1');
model.result.export('tbl1').set('header', false);
model.result.export('tbl1').label('Coupling Constants');


model.result.export.create('data1', 'Data');
model.result.export('data1').label('Volume data');
model.result.export('data1').setIndex('expr', 'V', 0);
model.result.export('data1').setIndex('expr', 'ec.Ex', 1);
model.result.export('data1').setIndex('expr', 'ec.Ey', 2);
model.result.export('data1').setIndex('expr', 'ec.Ez', 3);
model.result.export('data1').setIndex('expr', 'ec.normE', 4);


EfieldFrame = 'mesh'; % or 'grid'
if strcmp(EfieldFrame,'grid')
    disp('Exporting Efield at grid points...')
    model.result.dataset('dset2').set('frametype', 'geometry');
    model.result.export('data1').set('data', 'dset2');
    % create export of electric field data
    model.result.export('data1').set('location', 'grid');
    model.result.export('data1').set('gridx3', 'range(-0.008+head_x,0.016/89,0.008+head_x)');
    model.result.export('data1').set('gridy3', 'range(-0.008+head_y,0.016/89,0.008+head_y)');
    model.result.export('data1').set('gridz3', 'range(-0.019+head_z,0.04/89,0.021+head_z)');

elseif strcmp(EfieldFrame,'mesh')
    disp('Exporting E-field at mesh nodes...')
    model.result.dataset('dset2').set('frametype', 'mesh');
    model.result.export('data1').set('data', 'dset2');
    model.result.export('data1').set('resolution', 'finer');
    model.result.export('data1').set('smooth', 'internal');
end
model.result.export('data1').set('header', false);
model.sol('sol1').runAll;



% determining coupling constants by keeping inactive contacts floating 
mkdir(append(pat.path,'EFdistribution_',pat.hand,'_1mA'));

% deactive grounding on contacts
model.component('comp1').physics('ec').feature('gnd2').active(false);

name = append(pat.path,'DBS_simulation.mph');
mphsave(model,name)


tic
    parfor(i=1:length(coupl_combos),nProc)
    %for i=1:length(coupl_combos)
        if nProc>1
            t=getCurrentTask();
            taskid = t.ID;
            comsolPort = comsolPorts(taskid);
            try
                mphstart(comsolPort);
            end
        else
            comsolPort=2036;
        end
       
        try 
            EF_for_config(i,name,pat.path,pat.hand,coupl_combos,pat.lead,EfieldFrame)
        catch ME
            disp(comsolPort)
            disp(ME)
        end
    end

out = model;
disp('comsol done')
end

function EF_for_config(i,name,pat,coupl_combos,EfieldFrame)
    
    model = mphload(name);

    % activate floating potential on all contacts
    model.component('comp1').physics('ec').feature('fp1').active(true);
    %disp(append(num2str(i),'/',num2str(length(coupl_combos))))
    model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel9');

     
    if strcmp(pat.lead,'Boston Scientific 2202') || strcmp(pat.lead,'S:t Jude 1331')
        model.component('comp1').geom('geom1').selection.create('csel1', 'CumulativeSelection');
    switch i
        case 1 % contact 1
            model.component('comp1').geom('geom1').feature('sel_C1X').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 2 % contact 2A
            model.component('comp1').geom('geom1').feature('sel_C2A').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 3 % contact 2B
            model.component('comp1').geom('geom1').feature('sel_C2B').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 4 % contact 2C
            model.component('comp1').geom('geom1').feature('sel_C2C').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 5 % contact 3A
            model.component('comp1').geom('geom1').feature('sel_C3A').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 6 % contact 3B
            model.component('comp1').geom('geom1').feature('sel_C3B').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 7 % contact 3C
            model.component('comp1').geom('geom1').feature('sel_C3C').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 8 % contact 4
            model.component('comp1').geom('geom1').feature('sel_C4X').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 9 % contact 2A and 2B
            model.component('comp1').geom('geom1').feature('sel_C2A').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C2B').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 10 % contact 2B and 2C
            model.component('comp1').geom('geom1').feature('sel_C2B').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C2C').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 11 % contact 2C and 2A
            model.component('comp1').geom('geom1').feature('sel_C2C').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C2A').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 12 % contact 3A and 3B
            model.component('comp1').geom('geom1').feature('sel_C3A').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C3B').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 13 % contact 3B and 3C
            model.component('comp1').geom('geom1').feature('sel_C3B').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C3C').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');        
        case 14 % contact 3C and 3A
            model.component('comp1').geom('geom1').feature('sel_C3C').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C3A').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 15 % contact 2A and 3A 
            model.component('comp1').geom('geom1').feature('sel_C2A').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C3A').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 16 % contact 2B and 3B
            model.component('comp1').geom('geom1').feature('sel_C2B').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C3B').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 17 % contact 2C and 3C
            model.component('comp1').geom('geom1').feature('sel_C2C').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C3C').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 18 % contact 2A, 2B and 2C
            model.component('comp1').geom('geom1').feature('sel_C2A').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C2B').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C2C').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 19 % contact 3A, 3B and 3C
            model.component('comp1').geom('geom1').feature('sel_C3A').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C3B').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C3C').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 20 % contact 1 and 2A
            model.component('comp1').geom('geom1').feature('sel_C1X').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C2A').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 21 % contact 1 and 2B
            model.component('comp1').geom('geom1').feature('sel_C1X').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C2B').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 22 % contact 1 and 2C
            model.component('comp1').geom('geom1').feature('sel_C1X').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C2C').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 23 % contact 4 and 3A
            model.component('comp1').geom('geom1').feature('sel_C4X').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C3A').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 24 % contact 4 and 3B
            model.component('comp1').geom('geom1').feature('sel_C4X').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C3B').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 25 % contact 4 and 3C
            model.component('comp1').geom('geom1').feature('sel_C4X').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C3C').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 26 % contact 2A and 3B
            model.component('comp1').geom('geom1').feature('sel_C2A').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C3B').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 27 % contact 2A and 3C
            model.component('comp1').geom('geom1').feature('sel_C2A').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C3C').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 28 % contact 2B and 3A
            model.component('comp1').geom('geom1').feature('sel_C2B').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C3A').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 29 % contact 2B and 3C
            model.component('comp1').geom('geom1').feature('sel_C2B').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C3C').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 30 % contact 2C and 3A
            model.component('comp1').geom('geom1').feature('sel_C2C').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C3A').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
        case 31 % contact 2C and 3B
            model.component('comp1').geom('geom1').feature('sel_C2C').set('contributeto', 'csel1');
            model.component('comp1').geom('geom1').feature('sel_C3B').set('contributeto', 'csel1');
            model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');
    end
    elseif strcmp(pat.lead,'Boston Scientific Vercise Cartesia')
        switch i
        
        case 1 % contact 1
            model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel10');
            model.component('comp1').physics('ec').feature('ncd1').active(true);
        case 2 % contact 2A
            model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel11');
            model.component('comp1').physics('ec').feature('ncd2').active(true);
        case 3 % contact 2B
            model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel13');
            model.component('comp1').physics('ec').feature('ncd4').active(true);
        case 4 % contact 2C
            model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel12');
            model.component('comp1').physics('ec').feature('ncd3').active(true);
        case 5 % contact 3A
            model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel14');
            model.component('comp1').physics('ec').feature('ncd5').active(true);
        case 6 % contact 3B
            model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel16');
            model.component('comp1').physics('ec').feature('ncd7').active(true);
        case 7 % contact 3C
            model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel15');
            model.component('comp1').physics('ec').feature('ncd6').active(true);
        case 8 % contact 4
            model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel17');
            model.component('comp1').physics('ec').feature('ncd8').active(true);            
        case 9 % contact 2A and 2B
            model.param.set('I0', '-0.0005');
            model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel18');
            model.component('comp1').physics('ec').feature('ncd2').active(true);
            model.component('comp1').physics('ec').feature('ncd1').active(true);
        case 10 % contact 2B and 2C
            model.param.set('I0', '-0.0005');
            model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel19');
            model.component('comp1').physics('ec').feature('ncd3').active(true);
            model.component('comp1').physics('ec').feature('ncd2').active(true);
        case 11 % contact 2C and 2A
            model.param.set('I0', '-0.0005');
            model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel20');
            model.component('comp1').physics('ec').feature('ncd4').active(true);  
            model.component('comp1').physics('ec').feature('ncd3').active(true);
        case 12 % contact 3A and 3B
            model.param.set('I0', '-0.0005');
            model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel21');
            model.component('comp1').physics('ec').feature('ncd4').active(true);
            model.component('comp1').physics('ec').feature('ncd5').active(true); 
        case 13 % contact 3B and 3C
            model.param.set('I0', '-0.0005');
            model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel22');
            model.component('comp1').physics('ec').feature('ncd6').active(true);
            model.component('comp1').physics('ec').feature('ncd5').active(true);
        case 14 % contact 3C and 3A
            model.param.set('I0', '-0.0005');
            model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel23');
            model.component('comp1').physics('ec').feature('ncd7').active(true);
            model.component('comp1').physics('ec').feature('ncd6').active(true);
        case 15 % contact 2A and 3A 
            model.param.set('I0', '-0.0005');
            model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel24');
            model.component('comp1').physics('ec').feature('ncd8').active(true);
            model.component('comp1').physics('ec').feature('ncd7').active(true);

        end

    end
    
    model.component('comp1').probe('bnd1').genResult('none');
    model.component('comp1').probe('bnd2').genResult('none');
    model.component('comp1').probe('bnd3').genResult('none');
    model.component('comp1').probe('bnd4').genResult('none');
    model.component('comp1').probe('bnd5').genResult('none');
    model.component('comp1').probe('bnd6').genResult('none');
    model.component('comp1').probe('bnd7').genResult('none');
    model.component('comp1').probe('bnd8').genResult('none');
    model.sol('sol1').runAll;

    if strcmp(EfieldFrame,'mesh')
        dataV = mpheval(model,'V','selection','geom1_sel11'); % geom1_sel11 corresponds to inhomogeneous box
        dataEx = mpheval(model,'ec.Ex','selection','geom1_sel11');
        dataEy = mpheval(model,'ec.Ey','selection','geom1_sel11');
        dataEz = mpheval(model,'ec.Ez','selection','geom1_sel11');
        dataEnorm = mpheval(model,'ec.normE','selection','geom1_sel11');

        data = [dataV.p',dataV.d1',dataEx.d1',dataEy.d1',dataEz.d1',dataEnorm.d1'];
        writematrix(data,append(pat.path,...
            'EFdistribution_',pat.hand,'_1mA/V_EF_cont_',coupl_combos{i,:},'_', ...
            hand,'_1mA_gnd.csv'),'Delimiter',',');
    elseif strcmp(EfieldFrame,'grid')
        % export coupling constants
        model.result.export('data1').set('filename', append(pat.path,...
            'EFdistribution_',pat.hand,'_1mA/V_EF_cont_',coupl_combos{i,:},'_', ...
            pat.hand,'_1mA_gnd.csv'));
        model.result.export('data1').run;
    end
    model.component('comp1').geom('geom1').selection.remove('csel1.bnd');
    disp(i)

end