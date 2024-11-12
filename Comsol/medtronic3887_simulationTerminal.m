function out = model
%
% medtronic3887_simulationTerminal.m
%
% Model exported on Nov 11 2024, 15:59 by COMSOL 5.6.0.401.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('C:\Users\annfr888\Documents\DBS\code\TuneStim\Comsol');

model.component.create('comp1', true);

model.component('comp1').geom.create('geom1', 3);

model.component('comp1').mesh.create('mesh1');

model.component('comp1').physics.create('ec', 'ConductiveMedia', 'geom1');

model.study.create('std1');
model.study('std1').create('stat', 'Stationary');
model.study('std1').feature('stat').activate('ec', true);

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

model.component('comp1').geom('geom1').create('imp1', 'Import');
model.component('comp1').geom('geom1').feature('imp1').set('type', 'native');
model.component('comp1').geom('geom1').feature('imp1').set('filename', 'C:\Users\annfr888\Documents\DBS\code\TuneStim\Comsol\Leads\BostonScientific2202_lead.mphbin');
model.component('comp1').geom('geom1').feature('imp1').importData;
model.component('comp1').geom('geom1').run('imp1');
model.component('comp1').geom('geom1').create('rot1', 'Rotate');
model.component('comp1').geom('geom1').feature.move('rot1', 1);
model.component('comp1').geom('geom1').runPre('rot1');
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
model.component('comp1').geom('geom1').feature('blk2').set('size', [0.2 0.2 0.2]);
model.component('comp1').geom('geom1').feature('blk2').set('base', 'center');
model.component('comp1').geom('geom1').feature('blk2').set('pos', {'head_x' 'head_y' 'head_z'});
model.component('comp1').geom('geom1').run('blk2');
model.component('comp1').geom('geom1').create('mov1', 'Move');
model.component('comp1').geom('geom1').feature('mov1').selection('input').set({'rot1'});
model.component('comp1').geom('geom1').feature('mov1').set('displx', 'head_x');
model.component('comp1').geom('geom1').feature('mov1').set('disply', 'head_y');
model.component('comp1').geom('geom1').feature('mov1').set('displz', 'head_z');
model.component('comp1').geom('geom1').run('mov1');
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
model.component('comp1').geom('geom1').create('sel_C1X', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C1X').label('Contact 1');
model.component('comp1').geom('geom1').feature('sel_C1X').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C1X').selection('selection').set('fin', 12);
model.component('comp1').geom('geom1').create('sel_C2A', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C2A').label('Contact 2A');
model.component('comp1').geom('geom1').feature('sel_C2A').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C2A').selection('selection').set('fin', 23);
model.component('comp1').geom('geom1').create('sel_C2C', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C2C').label('Contact 2C');
model.component('comp1').geom('geom1').feature('sel_C2C').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C2C').selection('selection').set('fin', 15);
model.component('comp1').geom('geom1').create('sel_C2B', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C2B').label('Contact 2B');
model.component('comp1').geom('geom1').feature('sel_C2B').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C2B').selection('selection').set('fin', 55);
model.component('comp1').geom('geom1').create('sel_C3A', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C3A').label('Contact 3A');
model.component('comp1').geom('geom1').feature('sel_C3A').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C3A').selection('selection').set('fin', 38);
model.component('comp1').geom('geom1').create('sel_C3C', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C3C').label('Contact 3C');
model.component('comp1').geom('geom1').feature('sel_C3C').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C3C').selection('selection').set('fin', 26);
model.component('comp1').geom('geom1').create('sel_C3B', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C3B').label('Contact 3B');
model.component('comp1').geom('geom1').feature('sel_C3B').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C3B').selection('selection').set('fin', 64);
model.component('comp1').geom('geom1').create('sel_C4X', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C4X').label('Contact 4');
model.component('comp1').geom('geom1').feature('sel_C4X').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C4X').selection('selection').set('fin', 41);
model.component('comp1').geom('geom1').create('sel9', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel9').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel9').label('All Contacts');
model.component('comp1').geom('geom1').feature('sel9').selection('selection').set('fin', [12 15 23 26 38 41 55 64]);
model.component('comp1').geom('geom1').create('sel10', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel10').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel10').selection('selection').set('fin', [5 7 8 11 12 13 17 18 19 21]);
model.component('comp1').geom('geom1').feature('sel10').label('LeadNoContacts');
model.component('comp1').geom('geom1').create('sel11', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel11').selection('selection').set('fin', 2);
model.component('comp1').geom('geom1').feature('sel11').label('InhomBox');
model.component('comp1').geom('geom1').run;

model.component('comp1').physics('ec').feature('cucn1').setIndex('minput_temperature_src', 'userdef', 0);
model.component('comp1').physics('ec').feature('cucn1').set('sigma_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn1').set('sigma', [0.1 0 0 0 0.1 0 0 0 0.1]);

model.func.create('int1', 'Interpolation');
model.func('int1').set('source', 'file');
model.func('int1').set('filename', 'C:\Users\annfr888\Documents\DBS\code\TuneStim\MNI\conductivity_map_sin_mni.csv');
model.func('int1').setIndex('funcs', 'sigma_brain', 0, 0);
model.func('int1').importData;
model.func('int1').set('interp', 'neighbor');
model.func('int1').set('extrap', 'value');
model.func('int1').set('extrapvalue', 0.1);
model.func('int1').set('argunit', 'm,m,m');
model.func('int1').set('fununit', 'S/m');

model.component('comp1').physics('ec').selection.set([1 2 3 22]);
model.component('comp1').physics('ec').feature('cucn1').label('Bulk brain inhomogeneous');
model.component('comp1').physics('ec').feature('cucn1').set('sigma', {'sigma_brain(root.x,root.y,root.z)' '0' '0' '0' 'sigma_brain(root.x,root.y,root.z)' '0' '0' '0' 'sigma_brain(root.x,root.y,root.z)'});
model.component('comp1').physics('ec').feature('cucn1').set('epsilonr_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn1').set('epsilonr', [1380000 0 0 0 1380000 0 0 0 1380000]);
model.component('comp1').physics('ec').create('cucn2', 'CurrentConservation', 3);
model.component('comp1').physics('ec').feature('cucn2').label('Bulk brain homogeneous');
model.component('comp1').physics('ec').feature('cucn2').selection.set([1]);
model.component('comp1').physics('ec').feature('cucn2').set('epsilonr_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn2').set('epsilonr', [1380000 0 0 0 1380000 0 0 0 1380000]);
model.component('comp1').physics('ec').feature('cucn2').set('sigma_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn2').set('sigma', [0.1 0 0 0 0.1 0 0 0 0.1]);
model.component('comp1').physics('ec').create('cucn3', 'CurrentConservation', 3);
model.component('comp1').physics('ec').feature('cucn3').label('Encapsulation');
model.component('comp1').physics('ec').feature('cucn3').selection.set([3 22]);
model.component('comp1').physics('ec').feature('cucn3').setIndex('minput_temperature_src', 'userdef', 0);
model.component('comp1').physics('ec').feature('cucn3').set('sigma_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn3').set('sigma', [0.18 0 0 0 0.18 0 0 0 0.18]);
model.component('comp1').physics('ec').feature('cucn3').set('epsilonr_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn3').set('epsilonr', [1380000 0 0 0 1380000 0 0 0 1380000]);
model.component('comp1').physics('ec').create('gnd1', 'Ground', 2);
model.component('comp1').physics('ec').feature('gnd1').selection.set([1 2 3 4 5 81]);
model.component('comp1').physics('ec').feature('gnd1').label('Ground External');
model.component('comp1').physics('ec').create('fp1', 'FloatingPotential', 2);
model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel9');
model.component('comp1').physics('ec').feature('fp1').set('Group', true);
model.component('comp1').physics('ec').feature('fp1').active(false);
model.component('comp1').physics('ec').create('gnd2', 'Ground', 2);
model.component('comp1').physics('ec').feature('gnd2').label('Ground Contacts');
model.component('comp1').physics('ec').feature('gnd2').selection.named('geom1_sel9');
model.component('comp1').physics('ec').feature('gnd2').active(false);

model.component('comp1').probe.create('bnd1', 'Boundary');
model.component('comp1').probe('bnd1').set('intsurface', true);
model.component('comp1').probe('bnd1').label('Contact 1 V');
model.component('comp1').probe('bnd1').selection.named('geom1_sel_C1X');
model.component('comp1').probe.create('bnd2', 'Boundary');
model.component('comp1').probe('bnd2').set('intsurface', true);
model.component('comp1').probe('bnd2').label('Contact 2A V');
model.component('comp1').probe('bnd2').selection.named('geom1_sel_C2A');
model.component('comp1').probe.create('bnd3', 'Boundary');
model.component('comp1').probe('bnd3').set('intsurface', true);
model.component('comp1').probe('bnd3').label('Contact 2C V');
model.component('comp1').probe('bnd3').selection.named('geom1_sel_C2C');
model.component('comp1').probe.create('bnd4', 'Boundary');
model.component('comp1').probe('bnd4').set('intsurface', true);
model.component('comp1').probe('bnd4').label('Contact 2B V');
model.component('comp1').probe('bnd4').selection.named('geom1_sel_C2B');
model.component('comp1').probe.create('bnd5', 'Boundary');
model.component('comp1').probe('bnd5').set('intsurface', true);
model.component('comp1').probe('bnd5').label('Contact 3A V');
model.component('comp1').probe('bnd5').selection.named('geom1_sel_C3A');
model.component('comp1').probe.create('bnd6', 'Boundary');
model.component('comp1').probe('bnd6').set('intsurface', true);
model.component('comp1').probe('bnd6').label('Contact 3C V');
model.component('comp1').probe('bnd6').selection.named('geom1_sel_C3C');
model.component('comp1').probe.create('bnd7', 'Boundary');
model.component('comp1').probe('bnd7').set('intsurface', true);
model.component('comp1').probe('bnd7').label('Contact 3B V');
model.component('comp1').probe('bnd7').selection.named('geom1_sel_C3B');
model.component('comp1').probe.create('bnd8', 'Boundary');
model.component('comp1').probe('bnd8').set('intsurface', true);
model.component('comp1').probe('bnd8').label('Contact 4 V');
model.component('comp1').probe('bnd8').selection.named('geom1_sel_C4X');
model.component('comp1').probe('bnd1').genResult('none');
model.component('comp1').probe('bnd2').genResult('none');
model.component('comp1').probe('bnd3').genResult('none');
model.component('comp1').probe('bnd4').genResult('none');
model.component('comp1').probe('bnd5').genResult('none');
model.component('comp1').probe('bnd6').genResult('none');
model.component('comp1').probe('bnd7').genResult('none');
model.component('comp1').probe('bnd8').genResult('none');

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

model.component('comp1').probe('bnd1').genResult('none');
model.component('comp1').probe('bnd2').genResult('none');
model.component('comp1').probe('bnd3').genResult('none');
model.component('comp1').probe('bnd4').genResult('none');
model.component('comp1').probe('bnd5').genResult('none');
model.component('comp1').probe('bnd6').genResult('none');
model.component('comp1').probe('bnd7').genResult('none');
model.component('comp1').probe('bnd8').genResult('none');

model.component('comp1').physics('ec').create('term1', 'Terminal', 2);
model.component('comp1').physics('ec').feature('fp1').active(true);
model.component('comp1').physics('ec').feature('term1').set('I0', 'I0');
model.component('comp1').physics('ec').feature('term1').selection.named('geom1_sel_C1X');

model.result.create('pg2', 'PlotGroup3D');
model.result('pg2').set('edges', false);
model.result('pg2').label('StimulationSpread');
model.result('pg2').create('surf1', 'Surface');
model.result('pg2').feature('surf1').set('expr', '1');
model.result('pg2').feature('surf1').set('coloring', 'uniform');
model.result('pg2').feature('surf1').set('color', 'black');
model.result('pg2').feature('surf1').create('sel1', 'Selection');
model.result('pg2').feature('surf1').feature('sel1').selection.named('geom1_sel9');
model.result('pg2').create('surf2', 'Surface');
model.result('pg2').feature('surf2').set('expr', '1');
model.result('pg2').feature('surf2').set('coloring', 'uniform');
model.result('pg2').feature('surf2').set('color', 'gray');
model.result('pg2').feature('surf2').create('sel1', 'Selection');
model.result('pg2').feature('surf2').feature('sel1').selection.named('geom1_sel10');
model.result('pg2').create('iso1', 'Isosurface');
model.result('pg2').feature('iso1').set('expr', 'ec.normE');
model.result('pg2').feature('iso1').set('levelmethod', 'levels');
model.result('pg2').feature('iso1').set('levels', 200);
model.result('pg2').feature('iso1').set('coloring', 'uniform');
model.result('pg2').feature('iso1').set('color', 'cyan');
model.result('pg2').set('showhiddenobjects', true);
model.result('pg2').feature('iso1').set('data', 'dset2');
model.result('pg2').run;

model.sol('sol1').runAll;

model.label('bostonsctf_simulationTerminal.mph');
model.label('bostonsctf_simulationTerminal.mph');

model.component('comp1').geom('geom1').feature('sel10').selection('selection').set('fin', [7 8 11 12 13 17 18 19 21]);

model.component('comp1').view('view1').hideObjects.create('hide1');
model.component('comp1').view('view1').hideObjects('hide1').init(3);
model.component('comp1').view('view1').hideObjects('hide1').add('fin', [1]);

model.component('comp1').geom('geom1').feature('sel10').selection('selection').set('fin', [11 12 13 17 18 19 21]);

model.component('comp1').view('view1').hideObjects('hide1').add('fin', [2]);
model.component('comp1').view('view1').hideObjects('hide1').add('fin', [3]);

model.component('comp1').geom('geom1').feature('sel10').selection('selection').set('fin', [11 13 17 18 19 20 21 28 33 35 51 54 67 68]);

model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;

model.component('comp1').probe('bnd1').genResult('none');
model.component('comp1').probe('bnd2').genResult('none');
model.component('comp1').probe('bnd3').genResult('none');
model.component('comp1').probe('bnd4').genResult('none');
model.component('comp1').probe('bnd5').genResult('none');
model.component('comp1').probe('bnd6').genResult('none');
model.component('comp1').probe('bnd7').genResult('none');
model.component('comp1').probe('bnd8').genResult('none');

model.sol('sol1').runAll;

model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').set('showhiddenobjects', false);
model.result('pg2').run;
model.result('pg2').set('showhiddenobjects', true);
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').feature('surf2').active(false);
model.result('pg2').run;
model.result('pg2').feature.move('surf2', 0);
model.result('pg2').feature('surf2').active(true);
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;

model.component('comp1').geom('geom1').feature('sel10').selection('selection').clear('fin');
model.component('comp1').geom('geom1').feature('sel10').selection('selection').set('fin', [13 17 20 28 33 35 51 54 67 68]);
model.component('comp1').geom('geom1').run('sel10');
model.component('comp1').geom('geom1').run('sel11');

model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').feature('surf1').active(false);
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').feature('surf2').active(false);
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').feature('surf1').active(true);
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').feature('surf2').active(true);
model.result('pg2').run;
model.result('pg2').feature('surf2').set('data', 'dset2');
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;

model.component('comp1').geom('geom1').feature('sel10').selection('selection').clear('fin');
model.component('comp1').geom('geom1').feature('sel10').selection('selection').set('fin', [13 17 20 28 33 35 51 54 67 68]);
model.component('comp1').geom('geom1').run('sel10');
model.component('comp1').geom('geom1').run('sel11');

model.component('comp1').probe('bnd1').genResult('none');
model.component('comp1').probe('bnd2').genResult('none');
model.component('comp1').probe('bnd3').genResult('none');
model.component('comp1').probe('bnd4').genResult('none');
model.component('comp1').probe('bnd5').genResult('none');
model.component('comp1').probe('bnd6').genResult('none');
model.component('comp1').probe('bnd7').genResult('none');
model.component('comp1').probe('bnd8').genResult('none');

model.sol('sol1').runAll;

model.result('pg2').run;

model.label('medtronic3887_simulationTerminal.mph');

model.result('pg2').run;

model.component('comp1').geom('geom1').feature('imp1').set('filename', 'C:\Users\annfr888\Documents\DBS\code\TuneStim\Comsol\Leads\Medtronics3387_lead.mphbin');
model.component('comp1').geom('geom1').feature('imp1').importData;
model.component('comp1').geom('geom1').feature.remove('sel_C2C');
model.component('comp1').geom('geom1').feature.remove('sel_C2B');
model.component('comp1').geom('geom1').feature.remove('sel_C3C');
model.component('comp1').geom('geom1').feature.remove('sel_C3B');
model.component('comp1').geom('geom1').run('sel11');
model.component('comp1').geom('geom1').run('sel11');

model.component('comp1').view('view1').hideObjects.clear;

model.component('comp1').physics('ec').feature('cucn2').selection.set([1]);
model.component('comp1').physics('ec').feature('gnd1').selection.set([1 2 3 4 5 48]);

model.component('comp1').view('view1').hideEntities.create('hide1');
model.component('comp1').view('view1').hideEntities('hide1').geom(3);
model.component('comp1').view('view1').hideEntities('hide1').add([1]);
model.component('comp1').view('view1').hideEntities('hide1').add([2]);

model.component('comp1').physics('ec').feature('cucn3').selection.set([3 13]);

model.component('comp1').view('view1').hideEntities('hide1').add([3]);
model.component('comp1').view('view1').hideEntities('hide1').add([13]);

model.component('comp1').geom('geom1').feature('sel_C2A').label('Contact 2');
model.component('comp1').geom('geom1').feature('sel_C3A').label('Contact 3');

model.component('comp1').view('view1').hideObjects.create('hide1');
model.component('comp1').view('view1').hideObjects('hide1').init(3);
model.component('comp1').view('view1').hideObjects('hide1').add('fin', [1]);
model.component('comp1').view('view1').hideObjects('hide1').add('fin', [2]);
model.component('comp1').view('view1').hideObjects('hide1').add('fin', [3]);

model.component('comp1').geom('geom1').feature('sel_C1X').selection('selection').set('fin', 16);
model.component('comp1').geom('geom1').run('sel_C3A');
model.component('comp1').geom('geom1').feature('sel_C2A').selection('selection').set('fin', 22);
model.component('comp1').geom('geom1').run('sel_C2A');
model.component('comp1').geom('geom1').feature('sel_C3A').selection('selection').set('fin', 28);
model.component('comp1').geom('geom1').run('sel_C3A');
model.component('comp1').geom('geom1').feature('sel_C4X').selection('selection').set('fin', 32);
model.component('comp1').geom('geom1').run('sel_C4X');
model.component('comp1').geom('geom1').feature('sel9').selection('selection').set('fin', [16 22 28 32]);
model.component('comp1').geom('geom1').run('sel9');
model.component('comp1').geom('geom1').feature('sel10').selection('selection').set('fin', [15 18 26 30 35]);
model.component('comp1').geom('geom1').run('sel10');
model.component('comp1').geom('geom1').feature('sel11').selection('selection').clear('fin');

model.component('comp1').view('view1').hideObjects.clear;
model.component('comp1').view('view1').hideObjects.create('hide1');
model.component('comp1').view('view1').hideObjects('hide1').init(3);
model.component('comp1').view('view1').hideObjects('hide1').add('fin', [1]);

model.component('comp1').geom('geom1').feature('sel11').selection('selection').set('fin', 2);

model.component('comp1').view('view1').hideObjects('hide1').add('fin', [2]);

model.component('comp1').geom('geom1').run('sel11');

model.component('comp1').view('view1').hideObjects('hide1').add('fin', [3]);
model.component('comp1').view('view1').hideObjects.clear;
model.component('comp1').view('view1').hideEntities.clear;
model.component('comp1').view('view1').hideMesh.clear;

model.component('comp1').physics('ec').selection.set([1]);

model.component('comp1').view('view1').hideEntities.create('hide1');
model.component('comp1').view('view1').hideEntities('hide1').geom(3);
model.component('comp1').view('view1').hideEntities('hide1').add([1]);

model.component('comp1').physics('ec').selection.set([1 2]);

model.component('comp1').view('view1').hideEntities('hide1').add([2]);

model.component('comp1').physics('ec').selection.set([1 2 3 13]);

model.component('comp1').view('view1').hideEntities('hide1').add([3]);

model.label('medtronic3887_simulationTerminal.mph');

mphsave(model,'medtronic3887_simulationTerminal.m')

out = model;
