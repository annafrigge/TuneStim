function out = stjude1331_short_v4_mni_static(pat.name,pat.path,hand,...
               pat.space, activeContacts1, activeContacts2, I0, pat.outputPath)
%
% stjude1331_short_v4_native_dynamic.m
%
% Model exported on Nov 15 2022, 10:38 by COMSOL 5.6.0.401.
activeContacts1_string='';
for i=1:size(activeContacts1,1)
activeContacts1_string=append(activeContacts1_string,activeContacts1(i,:));
end

activeContacts2_string='';
for i=1:size(activeContacts2,1)
activeContacts2_string=append(activeContacts2_string,activeContacts2(i,:));
end


import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath([pwd,filesep,'comsol',filesep]);

model.component.create('comp1', true);

model.component('comp1').geom.create('geom1', 3);

model.component('comp1').mesh.create('mesh1');

model.component('comp1').physics.create('ec', 'ConductiveMedia', 'geom1');

model.study.create('std1');
model.study('std1').create('stat', 'Stationary');
model.study('std1').feature('stat').activate('ec', true);

model.param.set('A_shell_tot', '6e-6');
model.param.set('A_shell_seg', '1.2e-6');
model.param.set('head_x', '0');
model.param.set('head_y', '0');
model.param.set('head_z', '0');
model.param.set('orientation', '0');
model.param.set('tail_x', '0');
model.param.set('tail_y', '0');
model.param.set('tail_z', '5.5e-3');
model.param.set('rot_axis_x', '0.1');
model.param.set('rot_axis_y', '0.1');
model.param.set('rot_axis_z', '0');
model.param.set('rot_angle', '0');
model.param.set('I0', '1e-3');

% loading conductivity map
model.func.create('int1', 'Interpolation');
model.func('int1').label('Conductivity map');
model.func('int1').set('source', 'file');
model.func('int1').set('filename', append('C:\Users\annfr888\Documents\DBS\code\TuneStim\MNI\','conductivity_map_',hand,'_',pat.space,'.csv'));
model.func('int1').setIndex('funcs', 'sigma_brain', 0, 0);
model.func('int1').set('interp', 'neighbor');
model.func('int1').set('extrap', 'value');
model.func('int1').set('extrapvalue', 0.1);
model.func('int1').set('argunit', 'm,m,m');
model.func('int1').set('fununit', 'S/m');

% % loading permittivity map - not used!
% model.func.create('int2', 'Interpolation');
% model.func('int2').label('Permittivity map');
% model.func('int2').set('source', 'file');
% model.func('int2').set('filename', append(pat.path,'permittivity_map_',hand,'_',pat.space,'.csv'));
% model.func('int2').setIndex('funcs', 'epsilon_brain', 0, 0);
% model.func('int2').set('interp', 'neighbor');
% model.func('int2').set('extrap', 'value');
% model.func('int2').set('extrapvalue', 13.752);
% model.func('int2').set('argunit', 'm,m,m');

% building geometry
model.component('comp1').geom('geom1').create('imp1', 'Import');
model.component('comp1').geom('geom1').feature('imp1').set('filename', ['C:\Users\annfr888\Documents\DBS\code\Comsol code\leads\StJude1331',filesep,'StJude1331_lead_v5.mphbin']);
model.component('comp1').geom('geom1').feature('imp1').importData;
model.component('comp1').geom('geom1').run('imp1');
model.component('comp1').geom('geom1').create('rot1', 'Rotate');
model.component('comp1').geom('geom1').feature('rot1').selection('input').set({'imp1'});
model.component('comp1').geom('geom1').feature('rot1').set('rot', 'orientation');
model.component('comp1').geom('geom1').run('rot1');
model.component('comp1').geom('geom1').create('blk1', 'Block');
model.component('comp1').geom('geom1').feature('blk1').set('size', [0.05 0.05 0.05]);
model.component('comp1').geom('geom1').feature('blk1').set('base', 'center');
model.component('comp1').geom('geom1').feature('blk1').set('pos', {'head_x' 'head_y' '0'});
model.component('comp1').geom('geom1').feature('blk1').setIndex('pos', 'head_z', 2);
model.component('comp1').geom('geom1').run('blk1');
model.component('comp1').geom('geom1').create('blk2', 'Block');
model.component('comp1').geom('geom1').feature('blk2').set('size', [0.4 0.4 0.4]);
model.component('comp1').geom('geom1').feature('blk2').set('base', 'center');
model.component('comp1').geom('geom1').feature('blk2').set('pos', {'head_x' 'head_y' '0'});
model.component('comp1').geom('geom1').feature('blk2').setIndex('pos', 'head_z', 2);
model.component('comp1').geom('geom1').run('blk2');
model.component('comp1').geom('geom1').create('mov1', 'Move');
model.component('comp1').geom('geom1').feature('mov1').selection('input').set({'rot1'});
model.component('comp1').geom('geom1').run('mov1');
model.component('comp1').geom('geom1').create('rot2', 'Rotate');
model.component('comp1').geom('geom1').feature('rot2').selection('input').set({'mov1'});
model.component('comp1').geom('geom1').feature('rot2').set('axistype', 'cartesian');
model.component('comp1').geom('geom1').feature('rot2').set('ax3', {'rot_axis_x' '0' '1'});
model.component('comp1').geom('geom1').feature('rot2').setIndex('ax3', 'rot_axis_y', 1);
model.component('comp1').geom('geom1').feature('rot2').setIndex('ax3', 'rot_axis_z', 2);
model.component('comp1').geom('geom1').feature('rot2').set('rot', 'rot_angle');


model.component('comp1').geom('geom1').feature('rot2').set('pos', {'head_x' 'head_y' '0'});
model.component('comp1').geom('geom1').feature('rot2').setIndex('pos', 'head_z', 2);
model.component('comp1').geom('geom1').feature('mov1').set('displx', 'head_x');
model.component('comp1').geom('geom1').feature('mov1').set('disply', 'head_y');
model.component('comp1').geom('geom1').feature('mov1').set('displz', 'head_z');
model.component('comp1').geom('geom1').run('mov1');


model.component('comp1').geom('geom1').run('rot2');
model.component('comp1').geom('geom1').run('fin');

% Selections
model.component('comp1').geom('geom1').create('sel1', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel1').label('All contacts');
model.component('comp1').geom('geom1').feature('sel1').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel1').selection('selection').set('fin', [20 27 32 37 57 61 107 108]);
model.component('comp1').geom('geom1').run('sel1');

model.component('comp1').geom('geom1').create('sel_C1X', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C1X').label('Contact 1');
model.component('comp1').geom('geom1').feature('sel_C1X').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C1X').selection('selection').set('fin', 20);
model.component('comp1').geom('geom1').run('sel_C1X');

model.component('comp1').geom('geom1').create('sel_C2A', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C2A').label('Contact 2A');
model.component('comp1').geom('geom1').feature('sel_C2A').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C2A').selection('selection').set('fin', 57);
model.component('comp1').geom('geom1').run('sel_C2A');

model.component('comp1').geom('geom1').create('sel_C2B', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C2B').label('Contact 2B');
model.component('comp1').geom('geom1').feature('sel_C2B').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C2B').selection('selection').set('fin', 107);
model.component('comp1').geom('geom1').run('sel_C2B');

model.component('comp1').geom('geom1').create('sel_C2C', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C2C').label('Contact 2C');
model.component('comp1').geom('geom1').feature('sel_C2C').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C2C').selection('selection').set('fin', 27);
model.component('comp1').geom('geom1').run('sel_C2C');

model.component('comp1').geom('geom1').create('sel_C3A', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C3A').label('Contact 3A');
model.component('comp1').geom('geom1').feature('sel_C3A').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C3A').selection('selection').set('fin', 61);
model.component('comp1').geom('geom1').run('sel_C3A');

model.component('comp1').geom('geom1').create('sel_C3B', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C3B').label('Contact 3B');
model.component('comp1').geom('geom1').feature('sel_C3B').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C3B').selection('selection').set('fin', 108);
model.component('comp1').geom('geom1').run('sel_C3B');

model.component('comp1').geom('geom1').create('sel_C3C', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C3C').label('Contact 3C');
model.component('comp1').geom('geom1').feature('sel_C3C').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C3C').selection('selection').set('fin', 32);
model.component('comp1').geom('geom1').run('sel_C3C');

model.component('comp1').geom('geom1').create('sel_C4X', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C4X').label('Contact 4');
model.component('comp1').geom('geom1').feature('sel_C4X').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C4X').selection('selection').set('fin', 37);
model.component('comp1').geom('geom1').run('sel_C4X');

model.component('comp1').geom('geom1').create('sel2', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel2').label('Lead without contacts');
model.component('comp1').geom('geom1').feature('sel2').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel2').selection('selection').set('fin', [21 23 24 25 29 30 34 35 39 40 49 53 66 70 76 77 78 79 80 84 99 100 101 102 109 110]);
model.component('comp1').geom('geom1').run('sel2');

model.component('comp1').geom('geom1').run;


% Electrical current settings
model.component('comp1').physics('ec').selection.set([1 2 3 4 5]);

% Bulk brain inhomogeneous
model.component('comp1').physics('ec').feature('cucn1').label('Bulk brain inhomogeneous');
model.component('comp1').physics('ec').feature('cucn1').set('sigma_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn1').set('sigma', {'sigma_brain(root.x,root.y,root.z)' '0' '0' '0' 'sigma_brain(root.x,root.y,root.z)' '0' '0' '0' 'sigma_brain(root.x,root.y,root.z)'});
model.component('comp1').physics('ec').feature('cucn1').set('epsilonr_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn1').set('epsilonr', [138000 0 0 0 138000 0 0 0 138000]);

% Bulk brain homgeneous
model.component('comp1').physics('ec').create('cucn2', 'CurrentConservation', 3);
model.component('comp1').physics('ec').feature('cucn2').label('Bulk brain homogeneoeus');
model.component('comp1').physics('ec').feature('cucn2').selection.set([1]);
model.component('comp1').physics('ec').feature('cucn2').setIndex('minput_temperature_src', 'userdef', 0);
model.component('comp1').physics('ec').feature('cucn2').set('sigma_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn2').set('sigma', [0.1 0 0 0 0.1 0 0 0 0.1]);
model.component('comp1').physics('ec').feature('cucn2').set('epsilonr_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn2').set('epsilonr', [138000 0 0 0 138000 0 0 0 138000]);

% Encapsulation
model.component('comp1').physics('ec').create('cucn3', 'CurrentConservation', 3);
model.component('comp1').physics('ec').feature('cucn3').label('Encapsulation');
model.component('comp1').physics('ec').feature('cucn3').selection.set([3 4 5]);
model.component('comp1').physics('ec').feature('cucn3').setIndex('minput_temperature_src', 'userdef', 0);
model.component('comp1').physics('ec').feature('cucn3').set('sigma_mat', 'userdef');
%model.component('comp1').physics('ec').feature('cucn3').set('sigma', [0.18 0 0 0 0.18 0 0 0 0.18]);
model.component('comp1').physics('ec').feature('cucn3').set('sigma', [0.05 0 0 0 0.05 0 0 0 0.05]);
model.component('comp1').physics('ec').feature('cucn3').set('epsilonr_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn3').set('epsilonr', [138000 0 0 0 138000 0 0 0 138000]);


% External ground
model.component('comp1').physics('ec').create('gnd1', 'Ground', 2);
model.component('comp1').physics('ec').feature('gnd1').label('Ground External');
model.component('comp1').physics('ec').feature('gnd1').selection.set([1 2 3 4 5 112]);

% Floating potential
model.component('comp1').physics('ec').create('fp1', 'FloatingPotential', 2);
model.component('comp1').physics('ec').feature('fp1').set('Group', true);
%model.component('comp1').physics('ec').feature('fp1').selection.set([20 27 32 37 57 61 107 108]);
model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel1');


% Terminal 1
model.component('comp1').physics('ec').create('term1', 'Terminal', 2);
model.component('comp1').physics('ec').feature('term1').label('Active Contacts');
model.component('comp1').physics('ec').feature('term1').set('I0', 'I0');
%model.component('comp1').physics('ec').feature('term1').selection.set([20]);
model.component('comp1').physics('ec').feature('term1').selection.named('geom1_sel_C1X'); % default

% Terminal 2
model.component('comp1').physics('ec').create('term2', 'Terminal', 2);
model.component('comp1').physics('ec').feature('term2').label('Active Contacts 2');
model.component('comp1').physics('ec').feature('term2').set('I0', '-I0');
model.component('comp1').physics('ec').feature('term2').active(false);

% Meshing
model.component('comp1').mesh('mesh1').autoMeshSize(2); % Extra fine mesh
model.component('comp1').mesh('mesh1').run;


% Solver settings
model.sol.create('sol1');
model.sol('sol1').study('std1');
model.study('std1').feature('stat').set('notlistsolnum', 1);
model.study('std1').feature('stat').set('notsolnum', '1');
model.study('std1').feature('stat').set('listsolnum', 1);
model.study('std1').feature('stat').set('solnum', '1');

model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').feature('st1').set('study', 'std1');
model.sol('sol1').feature('st1').set('studystep', 'stat');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').feature('v1').set('control', 'stat');
model.sol('sol1').create('s1', 'Stationary');
model.sol('sol1').feature('s1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').create('i1', 'Iterative');
model.sol('sol1').feature('s1').feature('i1').set('linsolver', 'cg');
model.sol('sol1').feature('s1').feature('i1').create('mg1', 'Multigrid');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').set('prefun', 'amg');
model.sol('sol1').feature('s1').feature('fc1').set('linsolver', 'i1');
model.sol('sol1').feature('s1').feature.remove('fcDef');
model.sol('sol1').attach('std1');
model.sol('sol1').runAll;

model.result.export.create('data1', 'Data');
model.result.export('data1').label('Volume data');
model.result.export('data1').setIndex('expr', 'ec.normE', 0);

model.result.export('data1').set('location', 'grid'); % export field on grid
model.result.export('data1').set('gridx3', 'range(-0.008+head_x,0.016/89,0.008+head_x)');
model.result.export('data1').set('gridy3', 'range(-0.008+head_y,0.016/89,0.008+head_y)');
model.result.export('data1').set('gridz3', 'range(-0.019+head_z,0.04/89,0.021+head_z)');

model.result.export('data1').set('header', false);
model.result.export('data1').set('filename', append(pat.outputPath,filesep,'V_EF_unipolar_',...
                                 activeContacts1_string,'_',num2str(I0*1e3),'mA.csv'));


% Switch to patient-specific paramters
model.param.loadFile(append(pat.path,'lead_parameters_',...
                     pat.space,'_',hand,'.txt'));
model.param.set('I0', num2str(I0));            
                 
model.component('comp1').geom('geom1').run('fin');


% set active contacts
N1 = size(activeContacts1,1);% # active negative contacts
model.component('comp1').geom('geom1').selection.create('csel1', 'CumulativeSelection');
for i=1:N1
    model.component('comp1').geom('geom1').feature(append('sel_',activeContacts1(i,:))).set('contributeto', 'csel1');
end

model.component('comp1').physics('ec').feature('term1').selection.named('geom1_csel1_bnd');

if ~strcmp(activeContacts2,'none')
    N2 = size(activeContacts2,1);% # active positive contacts
    model.component('comp1').geom('geom1').selection.create('csel2', 'CumulativeSelection');
    for i=1:N2
        model.component('comp1').geom('geom1').feature(append('sel_',activeContacts2(i,:))).set('contributeto', 'csel2');
    end
    model.component('comp1').physics('ec').feature('term2').active(true);
    model.component('comp1').physics('ec').feature('term2').selection.named('geom1_csel2_bnd');
    
    model.result.export('data1').set('filename', append(pat.outputPath,'V_EF_bipolar_',...
                                 activeContacts1_string,'_', activeContacts2_string, '_',num2str(I0*1e3),'mA.csv'));
end

model.sol('sol1').runAll;



% export V,Ex,Ey,Ez and Enorm to file
%model.result.export('data1').run;
out = model;

end
