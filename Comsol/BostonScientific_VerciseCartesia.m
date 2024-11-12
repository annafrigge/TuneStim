%addpath('/sw/apps/comsol/x86_64/5.6/mli');
%mphstart;
% OBS: adjust selections, see "Desktop.mph" file

function out = BostonScientific_Vercise_Cartesia()
%
% BostonScientific2202
%
% Model exported on Jan 26 2022, 13:50 by COMSOL 5.6.0.401.

pat.name = 'PilotDBS_1';
pat.path = append('C:\Users\annfr888\Documents\DBS\patient_data\',...
                  pat.name,'\');

hand = 'dx';
pat.space = 'native';

% CALL to lead_parameters function 

%pat.path = append('C:\Users\annfr888\Documents\DBS\results\',...
%                  pat.name,'\');
%pat.path = append('/proj/snic2021-22-840/nobackup/Anna/',pat.name,'/');

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('C:\Users\annfr888\Documents\DBS\code\Comsol code\models\BostonScientific');
%model.modelPath('/proj/snic2021-22-840/nobackup/Anna');

model.component.create('comp1', true);

model.component('comp1').geom.create('geom1', 3);

model.component('comp1').mesh.create('mesh1');

model.component('comp1').physics.create('ec', 'ConductiveMedia', 'geom1');

model.study.create('std1');
model.study('std1').create('stat', 'Stationary');
model.study('std1').feature('stat').activate('ec', true);

% geometry needs to be build from patient 3 sin paramters (anchor). 
% Paramters are then changed after build to allow automatic re-definition 
% of selections. 
% importing anchor parameters from file
%model.param.loadFile(append('C:\Users\annfr888\Documents\DBS\code\',...
%                           'Comsol code\models\anchor_lead_parameters_v4.txt'));
%model.param.loadFile(append(pat.path,'\',pat.name,'_lead_parameters_',hand,...
%                     '.txt'));

%%

% check paramters by typing mphgetexpressions(model.param)

model.param.set('A_shell_tot', '0.0000085');
model.param.set('A_shell_seg', '0.0000037');
model.param.set('head_x', '0.01');
model.param.set('head_y', '0.01');
model.param.set('head_z', '0.01');
model.param.set('orientation', '0');
model.param.set('rot_axis_x', '0.3');
model.param.set('rot_axis_y', '0.1');
model.param.set('rot_axis_z', '0.0000000');
model.param.set('rot_angle', '25.0');
model.param.set('V0', '-1.0');
model.param.set('I0', '-0.0010');

% building geometry
model.component('comp1').geom('geom1').create('imp1', 'Import');
model.component('comp1').geom('geom1').feature('imp1').set('type', 'native');
model.component('comp1').geom('geom1').feature('imp1').set('filename', 'C:\Users\annfr888\Documents\DBS\comsol_models_mph\leads\BostonScientific\BostonScientific2202_lead.mphbin');
model.component('comp1').geom('geom1').feature('imp1').importData;
model.component('comp1').geom('geom1').run('imp1');

% rotate around lead axis (orientation
model.component('comp1').geom('geom1').create('rot1', 'Rotate');
model.component('comp1').geom('geom1').feature.move('rot1', 1);
model.component('comp1').geom('geom1').runPre('rot1');
model.component('comp1').geom('geom1').feature('rot1').selection('input').set({'imp1'});
model.component('comp1').geom('geom1').feature('rot1').set('rot', 'orientation');
model.component('comp1').geom('geom1').run('rot1');

% inhomogeneous block
model.component('comp1').geom('geom1').create('blk1', 'Block');
model.component('comp1').geom('geom1').feature('blk1').set('size', [0.05 0.05 0.05]);
model.component('comp1').geom('geom1').feature('blk1').set('base', 'center');
model.component('comp1').geom('geom1').feature('blk1').set('pos', {'head_x' 'head_y' '0'});
model.component('comp1').geom('geom1').feature('blk1').setIndex('pos', 'head_z', 2);
model.component('comp1').geom('geom1').run('blk1');

% homogeneous block
model.component('comp1').geom('geom1').create('blk2', 'Block');
model.component('comp1').geom('geom1').feature('blk2').set('size', [0.4 0.4 0.4]);
model.component('comp1').geom('geom1').feature('blk2').set('base', 'center');
model.component('comp1').geom('geom1').feature('blk2').set('pos', {'head_x' 'head_y' 'head_z'});
model.component('comp1').geom('geom1').run('blk2');

% translate lead
model.component('comp1').geom('geom1').create('mov1', 'Move');
model.component('comp1').geom('geom1').feature('mov1').selection('input').set({'rot1'});
model.component('comp1').geom('geom1').feature('mov1').set('displx', 'head_x');
model.component('comp1').geom('geom1').feature('mov1').set('disply', 'head_y');
model.component('comp1').geom('geom1').feature('mov1').set('displz', 'head_z');
model.component('comp1').geom('geom1').run('mov1');

% rotate lead 
model.component('comp1').geom('geom1').create('rot2', 'Rotate');
model.component('comp1').geom('geom1').feature('rot2').set('axistype', 'cartesian');
model.component('comp1').geom('geom1').feature('rot2').set('ax3', {'rot_axis_x' '0' '1'});
model.component('comp1').geom('geom1').feature('rot2').setIndex('ax3', 'rot_axis_y', 1);
model.component('comp1').geom('geom1').feature('rot2').setIndex('ax3', 'rot_axis_z', 2);
model.component('comp1').geom('geom1').feature('rot2').set('rot', 'rot_angle');
model.component('comp1').geom('geom1').feature('rot2').set('pos', {'head_x' 'head_y' '0'});
model.component('comp1').geom('geom1').feature('rot2').setIndex('pos', 'head_z', 2);
model.component('comp1').geom('geom1').feature('rot2').selection('input').set({'mov1'});
model.component('comp1').geom('geom1').run('rot2');

model.component('comp1').geom('geom1').run('fin');

% define contact selections for later use
model.component('comp1').geom('geom1').create('sel1', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel1').label('Contact 1');
model.component('comp1').geom('geom1').feature('sel1').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel1').selection('selection').set('fin', 12);

model.component('comp1').geom('geom1').create('sel2', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel2').label('Contact 2A');
model.component('comp1').geom('geom1').feature('sel2').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel2').selection('selection').set('fin', 23);

model.component('comp1').geom('geom1').create('sel3', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel3').label('Contact 2C');
model.component('comp1').geom('geom1').feature('sel3').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel3').selection('selection').set('fin', 15);

model.component('comp1').geom('geom1').create('sel4', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel4').label('Contact 2B');
model.component('comp1').geom('geom1').feature('sel4').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel4').selection('selection').set('fin', 55);

model.component('comp1').geom('geom1').create('sel5', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel5').label('Contact 3A');
model.component('comp1').geom('geom1').feature('sel5').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel5').selection('selection').set('fin', 38);

model.component('comp1').geom('geom1').create('sel6', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel6').label('Contact 3C');
model.component('comp1').geom('geom1').feature('sel6').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel6').selection('selection').set('fin', 26);

model.component('comp1').geom('geom1').create('sel7', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel7').label('Contact 3B');
model.component('comp1').geom('geom1').feature('sel7').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel7').selection('selection').set('fin', 64);

model.component('comp1').geom('geom1').create('sel8', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel8').label('Contact 4');
model.component('comp1').geom('geom1').feature('sel8').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel8').selection('selection').set('fin', 41);

% all contacts
model.component('comp1').geom('geom1').create('sel9', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel9').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel9').label('All Contacts');
model.component('comp1').geom('geom1').feature('sel9').selection('selection').set('fin', [12, 15, 23, 26, 38, 41, 55, 64]);

% all contacts with exceptions
model.component('comp1').geom('geom1').create('sel10', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel10').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel10').label('All Contacts except 1');
model.component('comp1').geom('geom1').feature('sel10').selection('selection').set('fin', [15, 23, 26, 38, 41, 55, 64]);

model.component('comp1').geom('geom1').create('sel11', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel11').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel11').label('All Contacts except 2A');
model.component('comp1').geom('geom1').feature('sel11').selection('selection').set('fin', [12, 15, 26, 38, 41, 55, 64]);

model.component('comp1').geom('geom1').create('sel12', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel12').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel12').label('All Contacts except 2C');
model.component('comp1').geom('geom1').feature('sel12').selection('selection').set('fin', [12, 23, 26, 38, 41, 55, 64]);

model.component('comp1').geom('geom1').create('sel13', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel13').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel13').label('All Contacts except 2B');
model.component('comp1').geom('geom1').feature('sel13').selection('selection').set('fin', [12, 15, 23, 26, 38, 41, 64]);

model.component('comp1').geom('geom1').create('sel14', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel14').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel14').label('All Contacts except 3A');
model.component('comp1').geom('geom1').feature('sel14').selection('selection').set('fin', [12, 15, 23, 26, 41, 55, 64]);

model.component('comp1').geom('geom1').create('sel15', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel15').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel15').label('All Contacts except 3C');
model.component('comp1').geom('geom1').feature('sel15').selection('selection').set('fin', [12, 15, 23, 38, 41, 55, 64]);

model.component('comp1').geom('geom1').create('sel16', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel16').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel16').label('All Contacts except 3B');
model.component('comp1').geom('geom1').feature('sel16').selection('selection').set('fin', [12, 15, 23, 26, 38, 41, 55]);

model.component('comp1').geom('geom1').create('sel17', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel17').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel17').label('All Contacts except 4');
model.component('comp1').geom('geom1').feature('sel17').selection('selection').set('fin', [12, 15, 23, 26, 38, 55, 64]);

model.component('comp1').geom('geom1').create('sel18', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel18').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel18').label('All Contacts except 2A2C');
model.component('comp1').geom('geom1').feature('sel18').selection('selection').set('fin', [12, 26, 38, 41, 55, 64]);

model.component('comp1').geom('geom1').create('sel19', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel19').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel19').label('All Contacts except 2B2C');
model.component('comp1').geom('geom1').feature('sel19').selection('selection').set('fin', [12, 23, 26, 38, 41, 64]);

model.component('comp1').geom('geom1').create('sel20', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel20').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel20').label('All Contacts except 2B2A');
model.component('comp1').geom('geom1').feature('sel20').selection('selection').set('fin', [12, 15, 26, 38, 41, 64]);

model.component('comp1').geom('geom1').create('sel21', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel21').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel21').label('All Contacts except 3A3C');
model.component('comp1').geom('geom1').feature('sel21').selection('selection').set('fin', [12, 15, 23, 41, 55, 64]);

model.component('comp1').geom('geom1').create('sel22', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel22').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel22').label('All Contacts except 3B3C');
model.component('comp1').geom('geom1').feature('sel22').selection('selection').set('fin', [12, 15, 23, 38, 41, 55]);

model.component('comp1').geom('geom1').create('sel23', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel23').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel23').label('All Contacts except 3B3A');
model.component('comp1').geom('geom1').feature('sel23').selection('selection').set('fin', [12, 15, 23, 26, 41, 55]);

model.component('comp1').geom('geom1').create('sel24', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel24').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel24').label('All Contacts except 2A3A');
model.component('comp1').geom('geom1').feature('sel24').selection('selection').set('fin', [12, 15, 26, 41, 55, 64]);

model.component('comp1').geom('geom1').create('sel25', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel25').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel25').label('All Contacts except 2C3C');
model.component('comp1').geom('geom1').feature('sel25').selection('selection').set('fin', [12, 23, 38, 41, 55, 64]);

model.component('comp1').geom('geom1').create('sel26', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel26').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel26').label('All Contacts except 2B3B');
model.component('comp1').geom('geom1').feature('sel26').selection('selection').set('fin', [12, 15, 23, 26, 38, 41]);

model.component('comp1').geom('geom1').create('sel27', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel27').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel27').label('All Contacts except 2A2B2C');
model.component('comp1').geom('geom1').feature('sel27').selection('selection').set('fin', [12, 26, 38, 41, 64]);

model.component('comp1').geom('geom1').create('sel28', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel28').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel28').label('All Contacts except 3A3B3C');
model.component('comp1').geom('geom1').feature('sel28').selection('selection').set('fin', [12, 15, 23, 41, 55]);

model.component('comp1').geom('geom1').run;



model.component('comp1').physics('ec').feature('cucn1').setIndex('minput_temperature_src', 'userdef', 0);
model.component('comp1').physics('ec').feature('cucn1').set('sigma_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn1').set('sigma', [0.1 0 0 0 0.1 0 0 0 0.1]);


% loading conductivity map 
model.func.create('int1', 'Interpolation');
model.func('int1').set('source', 'file');
model.func('int1').set('filename', append(pat.path,pat.name,'_conductivity_map_',hand,'.csv'));
%model.func('int1').set('filename', 'C:\Users\annfr888\Documents\DBS\results\pre_op.csv');
%model.func('int1').set('filename', '/proj/snic2021-22-840/nobackup/Anna/pre_op.csv');
model.func('int1').setIndex('funcs', 'sigma_brain', 0, 0);
model.func('int1').importData;
model.func('int1').set('interp', 'neighbor');
model.func('int1').set('extrap', 'value');
model.func('int1').set('extrapvalue', 0.1);
model.func('int1').set('argunit', 'm,m,m');
model.func('int1').set('fununit', 'S/m');

% electric currents settings
model.component('comp1').physics('ec').selection.set([1 2 3 22]);

% bulk brain inhomogeneous
model.component('comp1').physics('ec').feature('cucn1').label('Bulk brain inhomogeneous');
model.component('comp1').physics('ec').feature('cucn1').set('sigma', {'sigma_brain(root.x,root.y,root.z)' '0' '0' '0' 'sigma_brain(root.x,root.y,root.z)' '0' '0' '0' 'sigma_brain(root.x,root.y,root.z)'});
model.component('comp1').physics('ec').feature('cucn1').set('epsilonr_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn1').set('epsilonr', [1380000 0 0 0 1380000 0 0 0 1380000]);

% bulk brain homogeneous
model.component('comp1').physics('ec').create('cucn2', 'CurrentConservation', 3);
model.component('comp1').physics('ec').feature('cucn2').label('Bulk brain homogeneous');
model.component('comp1').physics('ec').feature('cucn2').selection.set([1]);
model.component('comp1').physics('ec').feature('cucn2').set('epsilonr_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn2').set('epsilonr', [1380000 0 0 0 1380000 0 0 0 1380000]);
model.component('comp1').physics('ec').feature('cucn2').set('sigma_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn2').set('sigma', [0.1 0 0 0 0.1 0 0 0 0.1]);

% encapsulation
model.component('comp1').physics('ec').create('cucn3', 'CurrentConservation', 3);
model.component('comp1').physics('ec').feature('cucn3').label('Encapsulation');
model.component('comp1').physics('ec').feature('cucn3').selection.set([3 22]);
model.component('comp1').physics('ec').feature('cucn3').setIndex('minput_temperature_src', 'userdef', 0);
model.component('comp1').physics('ec').feature('cucn3').set('sigma_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn3').set('sigma', [0.18 0 0 0 0.18 0 0 0 0.18]);
model.component('comp1').physics('ec').feature('cucn3').set('epsilonr_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn3').set('epsilonr', [1380000 0 0 0 1380000 0 0 0 1380000]);

% external ground
model.component('comp1').physics('ec').create('gnd1', 'Ground', 2);
model.component('comp1').physics('ec').feature('gnd1').selection.set([1,2,3,4,5, 81]);
model.component('comp1').physics('ec').feature('gnd1').label('Ground External');

% contacts - floating potential
model.component('comp1').physics('ec').create('fp1', 'FloatingPotential', 2);
model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel9');
model.component('comp1').physics('ec').feature('fp1').set('Group', true);
model.component('comp1').physics('ec').feature('fp1').active(false); % deactivate floating potential


% contacts - grounded
model.component('comp1').physics('ec').create('gnd2', 'Ground', 2);
model.component('comp1').physics('ec').feature('gnd2').label('Ground Contacts');
model.component('comp1').physics('ec').feature('gnd2').selection.named('geom1_sel9'); 
%model.component('comp1').physics('ec').feature('gnd2').active(false); % deactive grounding

% contacts - normal current density
model.component('comp1').physics('ec').create('ncd1', 'NormalCurrentDensity', 2);
model.component('comp1').physics('ec').feature('ncd1').label('Current Contact 1');
model.component('comp1').physics('ec').feature('ncd1').selection.named('geom1_sel1');
model.component('comp1').physics('ec').feature('ncd1').set('nJ', 'I0/A_shell_tot');

model.component('comp1').physics('ec').create('ncd2', 'NormalCurrentDensity', 2);
model.component('comp1').physics('ec').feature('ncd2').label('Current Contact 2A');
model.component('comp1').physics('ec').feature('ncd2').selection.named('geom1_sel2');
model.component('comp1').physics('ec').feature('ncd2').set('nJ', 'I0/A_shell_seg');

model.component('comp1').physics('ec').create('ncd3', 'NormalCurrentDensity', 2);
model.component('comp1').physics('ec').feature('ncd3').label('Current Contact 2C');
model.component('comp1').physics('ec').feature('ncd3').selection.named('geom1_sel3');
model.component('comp1').physics('ec').feature('ncd3').set('nJ', 'I0/A_shell_seg');

model.component('comp1').physics('ec').create('ncd4', 'NormalCurrentDensity', 2);
model.component('comp1').physics('ec').feature('ncd4').label('Current Contact 2B');
model.component('comp1').physics('ec').feature('ncd4').selection.named('geom1_sel4');
model.component('comp1').physics('ec').feature('ncd4').set('nJ', 'I0/A_shell_seg');

model.component('comp1').physics('ec').create('ncd5', 'NormalCurrentDensity', 2);
model.component('comp1').physics('ec').feature('ncd5').label('Current Contact 3A');
model.component('comp1').physics('ec').feature('ncd5').selection.named('geom1_sel5');
model.component('comp1').physics('ec').feature('ncd5').set('nJ', 'I0/A_shell_seg');

model.component('comp1').physics('ec').create('ncd6', 'NormalCurrentDensity', 2);
model.component('comp1').physics('ec').feature('ncd6').label('Current Contact 3C');
model.component('comp1').physics('ec').feature('ncd6').selection.named('geom1_sel6');
model.component('comp1').physics('ec').feature('ncd6').set('nJ', 'I0/A_shell_seg');

model.component('comp1').physics('ec').create('ncd7', 'NormalCurrentDensity', 2);
model.component('comp1').physics('ec').feature('ncd7').label('Current Contact 3B');
model.component('comp1').physics('ec').feature('ncd7').selection.named('geom1_sel7');
model.component('comp1').physics('ec').feature('ncd7').set('nJ', 'I0/A_shell_seg');

model.component('comp1').physics('ec').create('ncd8', 'NormalCurrentDensity', 2);
model.component('comp1').physics('ec').feature('ncd8').label('Current Contact 4');
model.component('comp1').physics('ec').feature('ncd8').selection.named('geom1_sel8');
model.component('comp1').physics('ec').feature('ncd8').set('nJ', 'I0/A_shell_tot');

% deactivating normal current density on contacts
model.component('comp1').physics('ec').feature('ncd1').active(false);
model.component('comp1').physics('ec').feature('ncd2').active(false);
model.component('comp1').physics('ec').feature('ncd3').active(false);
model.component('comp1').physics('ec').feature('ncd4').active(false);
model.component('comp1').physics('ec').feature('ncd5').active(false);
model.component('comp1').physics('ec').feature('ncd6').active(false);
model.component('comp1').physics('ec').feature('ncd7').active(false);
model.component('comp1').physics('ec').feature('ncd8').active(false);

% contacts electric potential (voltage)
model.component('comp1').physics('ec').create('pot1', 'ElectricPotential', 2);
model.component('comp1').physics('ec').feature('pot1').label('Voltage Contact 1');
model.component('comp1').physics('ec').feature('pot1').set('V0', 'V0');
model.component('comp1').physics('ec').feature('pot1').selection.named('geom1_sel1');

model.component('comp1').physics('ec').create('pot2', 'ElectricPotential', 2);
model.component('comp1').physics('ec').feature('pot2').label('Voltage Contact 2A');
model.component('comp1').physics('ec').feature('pot2').selection.named('geom1_sel2');
model.component('comp1').physics('ec').feature('pot2').set('V0', 'V0');

model.component('comp1').physics('ec').create('pot3', 'ElectricPotential', 2);
model.component('comp1').physics('ec').feature('pot3').label('Voltage Contact 2C');
model.component('comp1').physics('ec').feature('pot3').selection.named('geom1_sel3');
model.component('comp1').physics('ec').feature('pot3').set('V0', 'V0');

model.component('comp1').physics('ec').create('pot4', 'ElectricPotential', 2);
model.component('comp1').physics('ec').feature('pot4').label('Voltage Contact 2B');
model.component('comp1').physics('ec').feature('pot4').selection.named('geom1_sel4');
model.component('comp1').physics('ec').feature('pot4').set('V0', 'V0');

model.component('comp1').physics('ec').create('pot5', 'ElectricPotential', 2);
model.component('comp1').physics('ec').feature('pot5').label('Voltage Contact 3A');
model.component('comp1').physics('ec').feature('pot5').selection.named('geom1_sel5');
model.component('comp1').physics('ec').feature('pot5').set('V0', 'V0');

model.component('comp1').physics('ec').create('pot6', 'ElectricPotential', 2);
model.component('comp1').physics('ec').feature('pot6').label('Voltage Contact 3C');
model.component('comp1').physics('ec').feature('pot6').selection.named('geom1_sel6');
model.component('comp1').physics('ec').feature('pot6').set('V0', 'V0');

model.component('comp1').physics('ec').create('pot7', 'ElectricPotential', 2);
model.component('comp1').physics('ec').feature('pot7').label('Voltage Contact 3B');
model.component('comp1').physics('ec').feature('pot7').selection.named('geom1_sel7');
model.component('comp1').physics('ec').feature('pot7').set('V0', 'V0');

model.component('comp1').physics('ec').create('pot8', 'ElectricPotential', 2);
model.component('comp1').physics('ec').feature('pot8').label('Voltage Contact 4');
model.component('comp1').physics('ec').feature('pot8').selection.named('geom1_sel8');
model.component('comp1').physics('ec').feature('pot8').set('V0', 'V0');

model.component('comp1').physics('ec').feature('pot1').active(false);
model.component('comp1').physics('ec').feature('pot2').active(false);
model.component('comp1').physics('ec').feature('pot3').active(false);
model.component('comp1').physics('ec').feature('pot4').active(false);
model.component('comp1').physics('ec').feature('pot5').active(false);
model.component('comp1').physics('ec').feature('pot6').active(false);
model.component('comp1').physics('ec').feature('pot7').active(false);
model.component('comp1').physics('ec').feature('pot8').active(false);


% Create table for coupling constants
model.component('comp1').probe.create('bnd1', 'Boundary');
model.component('comp1').probe('bnd1').set('intsurface', true);
model.component('comp1').probe('bnd1').label('Contact 1 V');
model.component('comp1').probe('bnd1').selection.named('geom1_sel1');

model.component('comp1').probe.create('bnd2', 'Boundary');
model.component('comp1').probe('bnd2').set('intsurface', true);
model.component('comp1').probe('bnd2').label('Contact 2A V');
model.component('comp1').probe('bnd2').selection.named('geom1_sel2');

model.component('comp1').probe.create('bnd3', 'Boundary');
model.component('comp1').probe('bnd3').set('intsurface', true);
model.component('comp1').probe('bnd3').label('Contact 2C V');
model.component('comp1').probe('bnd3').selection.named('geom1_sel3');

model.component('comp1').probe.create('bnd4', 'Boundary');
model.component('comp1').probe('bnd4').set('intsurface', true);
model.component('comp1').probe('bnd4').label('Contact 2B V');
model.component('comp1').probe('bnd4').selection.named('geom1_sel4');

model.component('comp1').probe.create('bnd5', 'Boundary');
model.component('comp1').probe('bnd5').set('intsurface', true);
model.component('comp1').probe('bnd5').label('Contact 3A V');
model.component('comp1').probe('bnd5').selection.named('geom1_sel5');

model.component('comp1').probe.create('bnd6', 'Boundary');
model.component('comp1').probe('bnd6').set('intsurface', true);
model.component('comp1').probe('bnd6').label('Contact 3C V');
model.component('comp1').probe('bnd6').selection.named('geom1_sel6');

model.component('comp1').probe.create('bnd7', 'Boundary');
model.component('comp1').probe('bnd7').set('intsurface', true);
model.component('comp1').probe('bnd7').label('Contact 3B V');
model.component('comp1').probe('bnd7').selection.named('geom1_sel7');

model.component('comp1').probe.create('bnd8', 'Boundary');
model.component('comp1').probe('bnd8').set('intsurface', true);
model.component('comp1').probe('bnd8').label('Contact 4 V');
model.component('comp1').probe('bnd8').selection.named('geom1_sel8');

model.component('comp1').probe('bnd1').genResult('none');
model.component('comp1').probe('bnd2').genResult('none');
model.component('comp1').probe('bnd3').genResult('none');
model.component('comp1').probe('bnd4').genResult('none');
model.component('comp1').probe('bnd5').genResult('none');
model.component('comp1').probe('bnd6').genResult('none');
model.component('comp1').probe('bnd7').genResult('none');
model.component('comp1').probe('bnd8').genResult('none');


% meshing
model.component('comp1').mesh('mesh1').automatic(false);
model.component('comp1').mesh('mesh1').feature('size').set('custom', true);
model.component('comp1').mesh('mesh1').feature('size').set('hmax', '0.0008');
model.component('comp1').mesh('mesh1').feature('size').set('hmin', 1.4E-6);
model.component('comp1').mesh('mesh1').feature('size').set('hgrad', 1.3);
model.component('comp1').mesh('mesh1').feature('size').set('hcurve', 0.2);
model.component('comp1').mesh('mesh1').feature('size').set('hnarrow', 1);
model.component('comp1').mesh('mesh1').feature('ftet1').create('size1', 'Size');
model.component('comp1').mesh('mesh1').feature('ftet1').selection.all;
model.component('comp1').mesh('mesh1').feature('ftet1').feature('size1').selection.set([3 22]);
model.component('comp1').mesh('mesh1').feature('ftet1').feature('size1').set('hauto', 2);
model.component('comp1').mesh('mesh1').feature('ftet1').create('size2', 'Size');
model.component('comp1').mesh('mesh1').feature('ftet1').feature('size2').set('hauto', 3);
model.component('comp1').mesh('mesh1').feature('ftet1').feature('size2').selection.set([1 2]);
model.component('comp1').mesh('mesh1').run;


% solution
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

% switch to the actual patient of choice
model.param.loadFile(append(pat.path,'\',pat.name,'_lead_parameters_',pat.space,...
                            '_',hand,'.txt'));
model.component('comp1').geom('geom1').run('fin');

model.component('comp1').probe('bnd1').genResult('none');
model.component('comp1').probe('bnd2').genResult('none');
model.component('comp1').probe('bnd3').genResult('none');
model.component('comp1').probe('bnd4').genResult('none');
model.component('comp1').probe('bnd5').genResult('none');
model.component('comp1').probe('bnd6').genResult('none');
model.component('comp1').probe('bnd7').genResult('none');
model.component('comp1').probe('bnd8').genResult('none');

model.sol('sol1').runAll;

% create export of coupling constants
model.result.export.create('tbl1', 'Table');
model.result.export('tbl1').set('table', 'tbl1');
model.result.export('tbl1').set('header', false);
model.result.export('tbl1').label('Coupling Constants');


% create export of electric field data
model.result.export.create('data1', 'Data');
model.result.export('data1').label('Volume data');
model.result.export('data1').setIndex('expr', 'V', 0);
model.result.export('data1').setIndex('expr', 'ec.Ex', 1);
model.result.export('data1').setIndex('expr', 'ec.Ey', 2);
model.result.export('data1').setIndex('expr', 'ec.Ez', 3);
model.result.export('data1').setIndex('expr', 'ec.normE', 4);

model.result.export('data1').set('location', 'grid'); % export field on grid
model.result.export('data1').set('gridx3', 'range(-0.008+head_x,0.016/89,0.008+head_x)');
model.result.export('data1').set('gridy3', 'range(-0.008+head_y,0.016/89,0.008+head_y)');
model.result.export('data1').set('gridz3', 'range(-0.019+head_z,0.04/89,0.021+head_z)');

%model.result.export('data1').set('location', 'file'); % export field on coordinates from file (target/constraint)
%model.result.export('data1').set('filename', 'C:\Users\annfr888\Documents\DBS\patient_data\PilotDBS_1\FEM_exports\FEM_at_target_points_dx.csv');
model.result.export('data1').set('header', false);
model.sol('sol1').runAll;


% list of contact names
contacts = ['1X';'2A';'2B';'2C';'3A';'3B';'3C';'4X'];

% looping over all grounded-one active 1V contact
mkdir(append(pat.path,'VEF_',hand,'_1mA\'));


% Include Parallelization here?
for i=1:length(contacts)

% deactivating current density on all contacts
model.component('comp1').physics('ec').feature('ncd1').active(false);
model.component('comp1').physics('ec').feature('ncd2').active(false);
model.component('comp1').physics('ec').feature('ncd3').active(false);
model.component('comp1').physics('ec').feature('ncd4').active(false);
model.component('comp1').physics('ec').feature('ncd5').active(false);
model.component('comp1').physics('ec').feature('ncd6').active(false);
model.component('comp1').physics('ec').feature('ncd7').active(false);
model.component('comp1').physics('ec').feature('ncd8').active(false);

% ground all contacts
model.component('comp1').physics('ec').feature('gnd2').selection.named('geom1_sel9'); 
%model.component('comp1').physics('ec').feature('gnd2').active(false); % deactive grounding

% activating current density on single contacts while grounding all other
switch i
    case 1 % contact 1
    model.component('comp1').physics('ec').feature('gnd2').selection.named('geom1_sel10');  
    model.component('comp1').physics('ec').feature('ncd1').active(true);
    case 2 % contact 2A
    model.component('comp1').physics('ec').feature('gnd2').selection.named('geom1_sel11');  
    model.component('comp1').physics('ec').feature('ncd2').active(true);
    case 3 % contact 2B
    model.component('comp1').physics('ec').feature('gnd2').selection.named('geom1_sel13');  
    model.component('comp1').physics('ec').feature('ncd4').active(true);
    case 4 % contact 2C
    model.component('comp1').physics('ec').feature('gnd2').selection.named('geom1_sel12');  
    model.component('comp1').physics('ec').feature('ncd3').active(true);
    case 5 % contact 3A
    model.component('comp1').physics('ec').feature('gnd2').selection.named('geom1_sel14');  
    model.component('comp1').physics('ec').feature('ncd5').active(true);
    case 6 % contact 3B
    model.component('comp1').physics('ec').feature('gnd2').selection.named('geom1_sel16');  
    model.component('comp1').physics('ec').feature('ncd7').active(true);
    case 7 % contact 3C
    model.component('comp1').physics('ec').feature('gnd2').selection.named('geom1_sel15');  
    model.component('comp1').physics('ec').feature('ncd6').active(true);
    case 8 % contact 4
    model.component('comp1').physics('ec').feature('gnd2').selection.named('geom1_sel17');  
    model.component('comp1').physics('ec').feature('ncd8').active(true);
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



% export electric field data
model.result.export('data1').set('filename', append(pat.path,...
                                 'VEF_',hand,'_1mA\V_EF_cont_',contacts(i,:),'_', ...
                                 hand,'_1mA_gnd.csv'));
%model.result.export('data1').set('filename', append(pat.path,...
%                                 'VEF_',hand,'\V_EF_cont_',contacts(i,:),'_', ...
%                                 hand,'_1V_gnd.csv'));
model.result.export('data1').run;

end



% coupling combinations (H=Horizontal combination, V=Vertical combination)
coupl_combos = ['Mono_1X'; 'Mono_2A'; 'Mono_2B'; 'Mono_2C'; 'Mono_3A';...
                 'Mono_3B'; 'Mono_3C'; 'Mono_4X';...
                 'H_2A_2B'; 'H_2B_2C'; 'H_2C_2A'; 'H_3A_3B'; 'H_3B_3C';...
                 'H_3C_3A'; ...
                 'V_2A_3A'; 'V_2B_3B'; 'V_2C_3C';...
                 'Ring_R2'; 'Ring_R3'];


% determining coupling constants by keeping inactive contacts floating 
mkdir(append(pat.path,'CouplingMatrix_',hand,'_1mA'));

% deactive grounding on contacts
model.component('comp1').physics('ec').feature('gnd2').active(false);

% Include Parallelization here?
for i=1:length(coupl_combos)

% deactivating current density on all contacts
model.component('comp1').physics('ec').feature('ncd1').active(false);
model.component('comp1').physics('ec').feature('ncd2').active(false);
model.component('comp1').physics('ec').feature('ncd3').active(false);
model.component('comp1').physics('ec').feature('ncd4').active(false);
model.component('comp1').physics('ec').feature('ncd5').active(false);
model.component('comp1').physics('ec').feature('ncd6').active(false);
model.component('comp1').physics('ec').feature('ncd7').active(false);
model.component('comp1').physics('ec').feature('ncd8').active(false);

% activate floating potential on all contacts
model.component('comp1').physics('ec').feature('fp1').active(true);
disp(append(num2str(i),'/',num2str(length(coupl_combos))))
model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel9');

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
        model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel20');
        model.component('comp1').physics('ec').feature('ncd4').active(true);
        model.component('comp1').physics('ec').feature('ncd2').active(true);
    case 10 % contact 2B and 2C
        model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel19');
        model.component('comp1').physics('ec').feature('ncd3').active(true);
        model.component('comp1').physics('ec').feature('ncd4').active(true);
    case 11 % contact 2C and 2A
        model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel18');
        model.component('comp1').physics('ec').feature('ncd2').active(true);  
        model.component('comp1').physics('ec').feature('ncd3').active(true);
    case 12 % contact 3A and 3B
        model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel23');
        model.component('comp1').physics('ec').feature('ncd7').active(true);
        model.component('comp1').physics('ec').feature('ncd5').active(true); 
    case 13 % contact 3B and 3C
        model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel22');
        model.component('comp1').physics('ec').feature('ncd6').active(true);
        model.component('comp1').physics('ec').feature('ncd7').active(true);
    case 14 % contact 3C and 3A
        model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel21');
        model.component('comp1').physics('ec').feature('ncd5').active(true);
        model.component('comp1').physics('ec').feature('ncd6').active(true);
    case 15 % contact 2A and 3A 
        model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel24');
        model.component('comp1').physics('ec').feature('ncd2').active(true);
        model.component('comp1').physics('ec').feature('ncd5').active(true);
    case 16 % contact 2B and 3B
        model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel26');
        model.component('comp1').physics('ec').feature('ncd4').active(true);
        model.component('comp1').physics('ec').feature('ncd7').active(true);
    case 17 % contact 2C and 3C
        model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel25');
        model.component('comp1').physics('ec').feature('ncd3').active(true);
        model.component('comp1').physics('ec').feature('ncd6').active(true);
    case 18 % contact 2A, 2B and 2C
        model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel27');
        model.component('comp1').physics('ec').feature('ncd2').active(true);
        model.component('comp1').physics('ec').feature('ncd3').active(true);
        model.component('comp1').physics('ec').feature('ncd4').active(true);
    case 19 % contact 3A, 3B and 3C
        model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel28');
        model.component('comp1').physics('ec').feature('ncd5').active(true);
        model.component('comp1').physics('ec').feature('ncd6').active(true);
        model.component('comp1').physics('ec').feature('ncd7').active(true);
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


% export coupling constants
model.result.export('tbl1').set('filename', append(pat.path,...
                                'CouplingMatrix_',hand,'_1mA\',...
                                coupl_combos(i,:),'.csv'));
model.result.export('tbl1').run;


end

% plotting electric field together with lead geometry (pat.name 3 sin
% selections)
model.result.create('pg2', 'PlotGroup3D');
model.result('pg2').label('Electric field norm');
model.result('pg2').set('data', 'dset1');
model.result('pg2').set('frametype', 'spatial');
%model.result('pg2').create('iso1', 'Isosurface');
%model.result('pg2').feature('iso1').set('expr', 'ec.normE');
%model.result('pg2').feature('iso1').set('descr', 'Electric field norm');
%model.result('pg2').feature('iso1').set('levelmethod', 'levels');
%model.result('pg2').feature('iso1').set('levelmethod', 'levels');
%model.result('pg2').feature('iso1').set('levels', 150);
%model.result('pg2').feature('iso1').set('coloring', 'uniform');
model.result('pg2').create('surf1', 'Surface');
model.result('pg2').feature('surf1').set('expr', '1');
model.result('pg2').feature('surf1').create('sel1', 'Selection');
%model.result('pg2').feature('surf1').feature('sel1').selection.set([30, 31, 33, 34, 38, 39, 43, 46, 48, 58, 62, 64, 66, 69, 71, 78, 86, 87, 90, 94, 100, 102, 105, 106, 108, 109]);
%model.result('pg2').feature('surf1').feature('sel1').selection.set([31, 32, 33, 34, 38, 40, 43, 46, 49, 53, 61, 65, 68, 70, 74, 78, 81, 89, 91, 93, 100, 104, 106, 107, 108,109]); 
model.result('pg2').feature('surf1').feature('sel1').selection.set([17, 18, 22, 23, 25, 26, 28, 38, 40, 41, 42, 45, 46, 62, 64, 66, 67,68, 73, 84, 85, 87, 88, 91, 92, 93]);
model.result('pg2').feature('surf1').set('coloring', 'uniform');
model.result('pg2').feature('surf1').set('color', 'gray');
model.result('pg2').feature('surf1').label('lead');
model.result('pg2').create('surf2', 'Surface');
model.result('pg2').feature('surf2').label('contacts');
model.result('pg2').feature('surf2').set('coloring', 'uniform');
model.result('pg2').feature('surf2').set('color', 'black');
model.result('pg2').feature('surf2').create('sel1', 'Selection');
%model.result('pg2').feature('surf2').feature('sel1').selection.set([36, 41, 50, 52, 72, 74, 89, 101]);
model.result('pg2').feature('surf2').feature('sel1').selection.named('geom1_sel9')
model.result('pg2').set('edges', false);
model.result('pg2').run;

out = model;