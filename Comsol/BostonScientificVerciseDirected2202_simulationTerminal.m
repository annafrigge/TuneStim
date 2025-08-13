function out = model
%
% BostonScientificVerciseDirected2202_simulationTerminal.m
%
% Model exported on May 28 2025, 20:52 by COMSOL 6.3.0.290.

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
model.component('comp1').geom('geom1').feature('sel11').selection('selection').set('fin', [2 3 22]);
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
model.result('pg2').feature('iso1').set('data', 'dset1');
model.result('pg2').run;

model.sol('sol1').runAll;

model.result.dataset('dset1').set('frametype', 'mesh');

model.label('bostonsctf_simulationTerminal.mph');
model.label('bostonsctf_simulationTerminal.mph');

model.result('pg2').run;
model.result('pg2').run;

model.sol('sol1').runAll;

model.result('pg2').run;
model.result('pg2').run;

model.component('comp1').view('view1').hideEntities.create('hide1');
model.component('comp1').view('view1').hideEntities('hide1').geom(3);
model.component('comp1').view('view1').hideEntities('hide1').add([1]);
model.component('comp1').view('view1').hideEntities('hide1').add([2]);
model.component('comp1').view('view1').hideEntities('hide1').add([3]);

model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').feature('surf2').feature('sel1').selection.set([13 17 20 28 33 35 51 54 67 68]);

model.label('bostonsctf_simulationTerminal_v2.mph');

model.result('pg2').run;

model.component('comp1').geom('geom1').feature('imp1').set('filename', 'C:\Users\annfr888\Documents\DBS\code\TuneStim\Comsol\Leads\BostonScientific2202_lead_no_encapsualtion.mphbin');
model.component('comp1').geom('geom1').run('');
model.component('comp1').geom('geom1').feature('imp1').set('filename', 'C:\Users\annfr888\Documents\DBS\code\TuneStim\Comsol\Leads\BostonScientific2202_lead_no_encapsulation.mphbin');
model.component('comp1').geom('geom1').run('imp1');
model.component('comp1').geom('geom1').run('sel11');

model.component('comp1').view('view1').hideObjects.create('hide1');
model.component('comp1').view('view1').hideObjects('hide1').init(3);
model.component('comp1').view('view1').hideObjects('hide1').add('fin', [1]);
model.component('comp1').view('view1').hideObjects('hide1').add('fin', [2]);

model.component('comp1').geom('geom1').feature('sel_C1X').selection('selection').set('fin', 11);
model.component('comp1').geom('geom1').runPre('sel_C2C');
model.component('comp1').geom('geom1').feature('sel_C2C').selection('selection').set('fin', 22);
model.component('comp1').geom('geom1').feature('sel_C2A').selection('selection').set('fin', 54);
model.component('comp1').geom('geom1').runPre('sel_C2B');
model.component('comp1').geom('geom1').feature('sel_C2B').selection('selection').set('fin', 14);
model.component('comp1').geom('geom1').runPre('sel_C3A');
model.component('comp1').geom('geom1').feature('sel_C3A').selection('selection').set('fin', 63);
model.component('comp1').geom('geom1').runPre('sel_C3C');
model.component('comp1').geom('geom1').feature('sel_C3C').selection('selection').set('fin', 37);
model.component('comp1').geom('geom1').runPre('sel_C4X');
model.component('comp1').geom('geom1').feature('sel_C4X').selection('selection').set('fin', 25);
model.component('comp1').geom('geom1').feature('sel_C3B').selection('selection').set('fin', 25);
model.component('comp1').geom('geom1').runPre('sel_C4X');
model.component('comp1').geom('geom1').feature('sel_C4X').selection('selection').set('fin', 40);
model.component('comp1').geom('geom1').runPre('sel9');
model.component('comp1').geom('geom1').feature('sel9').selection('selection').set('fin', [11 14 22 25 37 40 54 63]);
model.component('comp1').geom('geom1').runPre('sel10');
model.component('comp1').geom('geom1').feature('sel10').selection('selection').clear('fin');
model.component('comp1').geom('geom1').feature('sel10').selection('selection').set('fin', [12 16 19 27 32 34 50 53 66 67]);
model.component('comp1').geom('geom1').run('sel11');
model.component('comp1').geom('geom1').feature('sel11').selection('selection').clear('fin');

model.component('comp1').view('view1').hideObjects.clear;
model.component('comp1').view('view1').hideObjects.create('hide1');
model.component('comp1').view('view1').hideObjects('hide1').init(3);
model.component('comp1').view('view1').hideObjects('hide1').add('fin', [1]);

model.component('comp1').geom('geom1').feature('sel11').selection('selection').set('fin', 2);

model.component('comp1').view('view1').hideObjects('hide1').add('fin', [2]);

model.component('comp1').geom('geom1').run;

model.component('comp1').physics('ec').feature('cucn3').active(false);

model.component('comp1').mesh('mesh1').run;

model.sol('sol1').runAll;

model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').feature('iso1').active(false);
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').create('slc1', 'Slice');
model.result('pg2').feature('slc1').set('expr', 'ec.normE');
model.result('pg2').feature('slc1').set('quickxmethod', 'number');
model.result('pg2').feature('slc1').set('quickxnumber', 1);
model.result('pg2').feature('slc1').set('quickplane', 'xy');
model.result('pg2').feature('slc1').set('quickznumber', 1);
model.result('pg2').run;

model.component('comp1').physics('ec').feature('term1').set('I0', 'I0*2');

model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').feature('slc1').set('quickplane', 'yz');
model.result('pg2').run;
model.result('pg2').feature('slc1').set('quickplane', 'xy');
model.result('pg2').run;

model.component('comp1').physics('ec').feature('term1').selection.set([14 22 54]);

model.sol('sol1').runAll;

model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').feature('slc1').set('planetype', 'general');
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_x', 0, 0);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_y', 0, 1);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_z', 0, 2);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_z+2e-3', 0, 2);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_x', 1, 0);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_y', 1, 1);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_z+2e-3', 1, 2);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_y+1e-3', 1, 1);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_y+1e-3', 2, 1);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_z+2e-3', 2, 2);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_x+1e-3', 2, 0);
model.result('pg2').run;
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_x-1e-3', 2, 0);
model.result('pg2').run;
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_y-1e-3', 2, 1);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_x', 2, 0);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_z+1e-3', 2, 2);
model.result('pg2').run;
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_z+2e-3', 2, 2);
model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_x+1e-3', 2, 0);
model.result('pg2').run;
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_y', 2, 1);
model.result('pg2').run;
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_z+1e-3', 2, 2);
model.result('pg2').run;
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_x', 2, 0);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_y-1e-3', 2, 1);
model.result('pg2').run;
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_y', 1, 1);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_x+1e-3', 1, 0);
model.result('pg2').run;

model.component('comp1').geom('geom1').feature('rot2').active(false);
model.component('comp1').geom('geom1').run('rot2');
model.component('comp1').geom('geom1').run;

model.component('comp1').mesh('mesh1').run;

model.sol('sol1').runAll;

model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_x', 1, 0);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_y', 2, 1);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_z+2e-3', 2, 2);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_y+1e-3', 1, 1);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_x+1-e3', 2, 0);
model.result('pg2').feature('slc1').setIndex('genpoints', 'head_x+1e3', 2, 0);
model.result('pg2').run;
model.result('pg2').feature('slc1').set('rangecoloractive', true);
model.result('pg2').feature('slc1').set('rangedataactive', true);
model.result('pg2').feature('slc1').set('rangedatamax', 850.012479020157);
model.result('pg2').run;
model.result('pg2').feature('slc1').set('rangedatamax', 6550.01247902016);
model.result('pg2').feature('slc1').set('rangecolormax', 1000.012479020157);
model.result('pg2').run;
model.result('pg2').feature('slc1').set('rangecolormax', 1500.012479020157);
model.result('pg2').run;
model.result('pg2').feature('slc1').set('rangecolormax', 2000);
model.result.table.create('evl3', 'Table');
model.result.table('evl3').comments('Interactive 3D values');
model.result.table('evl3').label('Evaluation 3D');
model.result.table('evl3').addRow([0.01004069140781886 0.01000011921782306 0.009251500507330479 1], [0 0 0 0]);
model.result.table('evl3').addRow([0.008244111183989537 0.00906464836787509 0.012000000000000025 682.9501903504589], [0 0 0 0]);

model.component('comp1').view('view1').hideObjects.clear;
model.component('comp1').view('view1').hideEntities.clear;
model.component('comp1').view('view1').hideMesh.clear;
model.component('comp1').view('view1').hideEntities.create('hide1');
model.component('comp1').view('view1').hideEntities('hide1').geom(3);
model.component('comp1').view('view1').hideEntities('hide1').add([1]);
model.component('comp1').view('view1').hideEntities('hide1').add([2]);

model.component('comp1').physics('ec').feature('term1').selection.set([67]);
model.component('comp1').physics('ec').feature('term1').set('I0', 'I0');

model.sol('sol1').runAll;

model.result('pg2').run;

model.component('comp1').physics('ec').feature('term1').selection.set([14]);

model.sol('sol1').runAll;

model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').feature('slc1').set('rangedatamax', 12816.5668635358);
model.result('pg2').run;
model.result.table('evl3').addRow([0.009610441701529852 0.005264032617115086 0.011999999999999983 26.830879436303107], [0 0 0 0]);

model.component('comp1').physics('ec').feature('term1').selection.set([38]);

model.sol('sol1').runAll;

model.result('pg2').run;

model.component('comp1').physics('ec').feature('term1').selection.set([67]);

model.sol('sol1').runAll;

model.result('pg2').run;
model.result.table('evl3').addRow([0.009575480236423097 0.011206045112695726 0.011999999999999983 204.37138349109554], [0 0 0 0]);

model.component('comp1').view('view1').camera.setIndex('position', 'head_x', 0);
model.component('comp1').view('view1').camera.setIndex('target', 'head_x', 0);
model.component('comp1').view('view1').camera.setIndex('position', 'head_y', 1);
model.component('comp1').view('view1').camera.setIndex('target', 'head_y', 1);
model.component('comp1').view('view1').camera.setIndex('rotationpoint', 0, 0);
model.component('comp1').view('view1').camera.setIndex('rotationpoint', '0.0', 1);
model.component('comp1').view('view1').camera.set('rotationpoint', {'0' '0.0' '0'});
model.component('comp1').view('view1').camera.set('up', [0 0 1]);
model.component('comp1').view('view1').camera.setIndex('position', 'head_z+2e-3', 2);
model.component('comp1').view('view1').camera.setIndex('target', 'head_z+2e-3', 2);
model.component('comp1').view('view1').camera.setIndex('viewoffset', 0, 0);
model.component('comp1').view('view1').camera.set('viewoffset', {'10e-3' '10e-3'});
model.component('comp1').view('view1').camera.setIndex('viewoffset', -0.009999999776482582, 0);
model.component('comp1').view('view1').camera.setIndex('viewoffset', 1, 0);
model.component('comp1').view('view1').camera.set('viewoffset', [1 1]);

model.component('comp1').physics('ec').feature('term1').selection.set([14]);

model.sol('sol1').runAll;

model.result('pg2').run;

model.component('comp1').view.create('view2', 'geom1');
model.component('comp1').view('view2').set('locked', false);

model.result('pg2').run;

model.component('comp1').view('view2').set('locked', true);
model.component('comp1').view('view2').set('rotcenlocked', true);
model.component('comp1').view('view2').set('locked', false);
model.component('comp1').view('view2').set('rotcenlocked', false);
model.component('comp1').view('view2').set('locked', true);
model.component('comp1').view('view2').set('rotcenlocked', true);

model.component('comp1').physics('ec').feature('term1').selection.set([67]);

model.sol('sol1').runAll;

model.result('pg2').run;

model.component('comp1').physics('ec').feature('term1').selection.set([38]);

model.sol('sol1').runAll;

model.result('pg2').run;

model.component('comp1').physics('ec').feature('term1').selection.set([14 38 67]);

model.sol('sol1').runAll;

model.result('pg2').run;

model.component('comp1').physics('ec').feature('term1').set('I0', 'I0*2');
model.component('comp1').physics('ec').feature('term1').selection.set([14]);
model.component('comp1').physics('ec').feature('term1').set('I0', 'I0');
%model.component('comp1').physics('ec').feature.duplicate('term2', 'term1');
%model.component('comp1').physics('ec').feature('term2').selection.set([38]);
%model.component('comp1').physics('ec').feature('term2').set('I0', '0.5*I0');
%model.component('comp1').physics('ec').feature.duplicate('term3', 'term2');
%model.component('comp1').physics('ec').feature('term3').selection.set([67]);

model.sol('sol1').runAll;

model.result('pg2').run;

model.label('bostonsctf_simulationTerminal_v2.mph');

model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').run;

model.param.set('encR', '1e-3');

model.component('comp1').geom('geom1').create('cyl1', 'Cylinder');
model.component('comp1').geom('geom1').feature('cyl1').set('r', '6.5e-4+encR');
model.component('comp1').geom('geom1').run('cyl1');
model.component('comp1').geom('geom1').create('elp1', 'Ellipsoid');
model.component('comp1').geom('geom1').feature('elp1').set('semiaxes', {'6.5*1e-3+encR' '1' '1'});
model.component('comp1').geom('geom1').feature('elp1').setIndex('semiaxes', '6.5*1e-3+encR', 1);
model.component('comp1').geom('geom1').feature('elp1').setIndex('semiaxes', '0.75*1e-3+encR', 2);
model.component('comp1').geom('geom1').feature('elp1').setIndex('semiaxes', '6.5*1e-4+encR', 1);
model.component('comp1').geom('geom1').feature('elp1').setIndex('semiaxes', '6.5*1e-34encR', 0);
model.component('comp1').geom('geom1').feature('elp1').setIndex('semiaxes', '6.5*1e-4encR', 0);
model.component('comp1').geom('geom1').run('cyl1');
model.component('comp1').geom('geom1').feature('elp1').setIndex('semiaxes', '6.5*1e-4+encR', 0);
model.component('comp1').geom('geom1').run('elp1');

model.component('comp1').view('view1').hideObjects.create('hide1');
model.component('comp1').view('view1').hideObjects('hide1').init(3);
model.component('comp1').view('view1').hideObjects('hide1').add('blk2', [1]);

model.component('comp1').geom('geom1').feature('cyl1').set('pos', {'head_x' 'head_z' '0'});
model.component('comp1').geom('geom1').feature('cyl1').setIndex('pos', 'head_z', 2);
model.component('comp1').geom('geom1').feature('cyl1').set('rot', 0);
model.component('comp1').geom('geom1').feature('cyl1').set('h', 0.0885);
model.component('comp1').geom('geom1').run('cyl1');
model.component('comp1').geom('geom1').run('elp1');

model.component('comp1').view('view1').hideObjects('hide1').add('blk2', [1]);
model.component('comp1').view('view1').hideObjects('hide1').add('blk1', [1]);

model.component('comp1').geom('geom1').feature('elp1').set('pos', {'head_x' 'head_y' '0'});
model.component('comp1').geom('geom1').feature('elp1').setIndex('pos', 'head_z', 2);
model.component('comp1').geom('geom1').run('elp1');
model.component('comp1').geom('geom1').create('uni1', 'Union');
model.component('comp1').geom('geom1').feature('uni1').selection('input').set({'cyl1' 'elp1'});
model.component('comp1').geom('geom1').feature('uni1').set('intbnd', false);
model.component('comp1').geom('geom1').run('uni1');
model.component('comp1').geom('geom1').run('sel11');
model.component('comp1').geom('geom1').create('ige1', 'IgnoreEdges');

model.component('comp1').view('view1').hideObjects.clear;
model.component('comp1').view('view1').hideObjects.create('hide1');
model.component('comp1').view('view1').hideObjects('hide1').init(3);
model.component('comp1').view('view1').hideObjects('hide1').add('fin', [1]);
model.component('comp1').view('view1').hideObjects('hide1').add('fin', [2]);

model.component('comp1').geom('geom1').feature('ige1').selection('input').set('fin', [17 18 19 20 21 22 23 72 73 74 75 76 78 79 94 95 96 97 113 114]);
model.component('comp1').geom('geom1').run('ige1');
model.component('comp1').geom('geom1').create('cmd1', 'CompositeDomains');
model.component('comp1').geom('geom1').feature('cmd1').selection('input').set('ige1', [3 4]);
model.component('comp1').geom('geom1').run('cmd1');

model.component('comp1').view('view1').hideObjects.clear;
model.component('comp1').view('view1').hideEntities.clear;
model.component('comp1').view('view1').hideEntities.create('hide1');
model.component('comp1').view('view1').hideEntities('hide1').geom(3);
model.component('comp1').view('view1').hideEntities('hide1').add([1]);
model.component('comp1').view('view1').hideEntities('hide1').add([2]);
model.component('comp1').view('view1').hideEntities('hide1').add([3]);

model.component('comp1').mesh('mesh1').run;

model.component('comp1').physics('ec').feature('cucn3').active(true);

model.component('comp1').view('view1').hideObjects.clear;
model.component('comp1').view('view1').hideEntities.clear;
model.component('comp1').view('view1').hideEntities.create('hide1');
model.component('comp1').view('view1').hideEntities('hide1').geom(3);
model.component('comp1').view('view1').hideEntities('hide1').add([1]);
model.component('comp1').view('view1').hideEntities('hide1').add([2]);

model.component('comp1').physics('ec').feature('cucn3').selection.set([3]);

model.component('comp1').view('view1').hideEntities.create('hide2');
model.component('comp1').view('view1').hideEntities('hide2').geom(2);
model.component('comp1').view('view1').hideEntities('hide2').add([11]);

model.sol('sol1').runAll;

model.result('pg2').run;

model.component('comp1').geom('geom1').feature.move('cyl1', 2);
model.component('comp1').geom('geom1').feature.move('elp1', 3);
model.component('comp1').geom('geom1').feature('elp1').setIndex('pos', 0, 0);
model.component('comp1').geom('geom1').feature('elp1').set('pos', [0 0 0]);
model.component('comp1').geom('geom1').feature.move('cyl1', 1);
model.component('comp1').geom('geom1').feature.move('elp1', 2);
model.component('comp1').geom('geom1').feature.move('uni1', 3);

model.param.set('encR', '0.1*1e-3');

model.component('comp1').geom('geom1').run('elp1');
model.component('comp1').geom('geom1').feature('cyl1').setIndex('pos', 0, 0);
model.component('comp1').geom('geom1').feature('cyl1').set('pos', [0 0 0]);
model.component('comp1').geom('geom1').run('cyl1');
model.component('comp1').geom('geom1').run('elp1');
model.component('comp1').geom('geom1').run('uni1');
model.component('comp1').geom('geom1').feature('rot1').selection('input').set({'imp1' 'uni1'});
model.component('comp1').geom('geom1').run('rot1');
model.component('comp1').geom('geom1').feature.move('mov1', 5);
model.component('comp1').geom('geom1').run('mov1');
model.component('comp1').geom('geom1').run('blk1');
model.component('comp1').geom('geom1').run('blk2');
model.component('comp1').geom('geom1').run('fin');
model.component('comp1').geom('geom1').run('cmd1');

model.component('comp1').view('view1').hideObjects.create('hide1');
model.component('comp1').view('view1').hideObjects('hide1').init(3);
model.component('comp1').view('view1').hideObjects('hide1').add('cmd1', [1]);
model.component('comp1').view('view1').hideObjects('hide1').add('cmd1', [2]);
model.component('comp1').view('view1').hideObjects('hide1').add('cmd1', [3]);

model.component('comp1').geom('geom1').runPre('sel_C1X');
model.component('comp1').geom('geom1').runPre('sel_C2A');
model.component('comp1').geom('geom1').feature('sel_C2A').selection('selection').clear('fin');
model.component('comp1').geom('geom1').feature('sel_C2A').selection('selection').set('fin', 48);
model.component('comp1').geom('geom1').runPre('sel_C2C');
model.component('comp1').geom('geom1').runPre('sel_C2B');
model.component('comp1').geom('geom1').feature('sel_C2C').selection('selection').clear('fin');
model.component('comp1').geom('geom1').feature('sel_C2C').selection('selection').set('fin', 22);
model.component('comp1').geom('geom1').runPre('sel_C2B');
model.component('comp1').geom('geom1').feature('sel_C2B').selection('selection').clear('fin');
model.component('comp1').geom('geom1').feature('sel_C2B').selection('selection').set('fin', 83);
model.component('comp1').geom('geom1').runPre('sel_C3A');
model.component('comp1').geom('geom1').feature('sel_C3A').selection('selection').clear('fin');
model.component('comp1').geom('geom1').feature('sel_C3A').selection('selection').set('fin', 26);
model.component('comp1').geom('geom1').feature('sel_C3A').selection('selection').clear('fin');
model.component('comp1').geom('geom1').feature('sel_C3A').selection('selection').set('fin', 52);
model.component('comp1').geom('geom1').runPre('sel_C3C');
model.component('comp1').geom('geom1').feature('sel_C3C').selection('selection').clear('fin');
model.component('comp1').geom('geom1').feature('sel_C3C').selection('selection').set('fin', 26);
model.component('comp1').geom('geom1').runPre('sel_C3B');
model.component('comp1').geom('geom1').feature('sel_C3B').selection('selection').clear('fin');
model.component('comp1').geom('geom1').feature('sel_C3B').selection('selection').set('fin', 84);
model.component('comp1').geom('geom1').runPre('sel_C4X');
model.component('comp1').geom('geom1').runPre('sel9');
model.component('comp1').geom('geom1').runPre('sel10');
model.component('comp1').geom('geom1').runPre('sel11');

model.component('comp1').view('view1').set('hidestatus', 'hide');
model.component('comp1').view('view1').hideObjects.clear;
model.component('comp1').view('view1').hideObjects.create('hide1');
model.component('comp1').view('view1').hideObjects('hide1').init(3);
model.component('comp1').view('view1').hideObjects('hide1').add('fin', [1]);
model.component('comp1').view('view1').hideObjects('hide1').add('fin', [2]);

model.component('comp1').geom('geom1').run('ige1');
model.component('comp1').geom('geom1').run('cmd1');

model.label('BostonScientificVerciseDirected2202_simulationTerminal.mph');

model.component('comp1').geom('geom1').feature('cyl1').set('r', '6.5e-4+encapsulationThickness');

model.param.rename('encR', 'encapsulationThickness');

model.component('comp1').geom('geom1').feature('elp1').setIndex('semiaxes', '6.5*1e-4+encapsulationThickness', 0);
model.component('comp1').geom('geom1').feature('elp1').setIndex('semiaxes', '6.5*1e-4+encapsulationThickness', 1);
model.component('comp1').geom('geom1').feature('elp1').setIndex('semiaxes', '0.75*1e-3+encapsulationThickness', 2);
model.component('comp1').geom('geom1').run('cmd1');

model.component('comp1').view('view1').hideObjects('hide1').add('cmd1', [3]);

model.component('comp1').geom('geom1').runPre('sel_C4X');
model.component('comp1').geom('geom1').feature.move('sel_C2B', 12);
model.component('comp1').geom('geom1').runPre('sel_C2C');
model.component('comp1').geom('geom1').runPre('sel_C3A');
model.component('comp1').geom('geom1').run('sel_C3C');
model.component('comp1').geom('geom1').runPre('sel_C4X');
model.component('comp1').geom('geom1').runPre('sel10');
model.component('comp1').geom('geom1').run('sel11');
model.component('comp1').geom('geom1').run('sel11');
model.component('comp1').geom('geom1').run;
model.component('comp1').geom('geom1').feature.create('rmd1', 'RemoveDetails');
model.component('comp1').geom('geom1').feature('rmd1').set('detailsizetype', 'absolute');
model.component('comp1').geom('geom1').feature('rmd1').set('maxabssize', '1.2E-4');
model.component('comp1').geom('geom1').run('rmd1');
model.component('comp1').geom('geom1').feature.remove('rmd1');

model.component('comp1').mesh('mesh1').run;

model.component('comp1').physics('ec').selection.set([]);

model.component('comp1').view('view1').hideObjects.clear;
model.component('comp1').view('view1').hideEntities.clear;

model.component('comp1').physics('ec').selection.set([1]);

model.component('comp1').view('view1').hideEntities.create('hide1');
model.component('comp1').view('view1').hideEntities('hide1').geom(3);
model.component('comp1').view('view1').hideEntities('hide1').add([1]);

model.component('comp1').physics('ec').selection.set([1 2]);

model.component('comp1').view('view1').hideEntities('hide1').add([2]);

model.component('comp1').physics('ec').selection.set([1 2 3]);

model.component('comp1').mesh('mesh1').feature('ftet1').selection.set([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23]);
model.component('comp1').mesh('mesh1').feature('ftet1').selection.all;
model.component('comp1').mesh('mesh1').feature('ftet1').selection.set([]);
model.component('comp1').mesh('mesh1').feature('ftet1').selection.all;
model.component('comp1').mesh('mesh1').run('ftet1');
model.component('comp1').mesh('mesh1').feature('ftet1').feature('size2').selection.set([1]);
model.component('comp1').mesh('mesh1').feature('ftet1').feature('size1').selection.set([2 3 11 12 13]);
model.component('comp1').mesh('mesh1').run;

model.component('comp1').view('view1').hideObjects.clear;
model.component('comp1').view('view1').hideEntities.clear;
model.component('comp1').view('view1').hideEntities.create('hide1');
model.component('comp1').view('view1').hideEntities('hide1').geom(3);
model.component('comp1').view('view1').hideEntities('hide1').add([1]);

model.component('comp1').mesh('mesh1').feature('ftet1').feature('size2').set('hauto', 2);
model.component('comp1').mesh('mesh1').run('size');
model.component('comp1').mesh('mesh1').feature('ftet1').feature('size2').set('hauto', 3);
model.component('comp1').mesh('mesh1').run('ftet1');
model.component('comp1').mesh('mesh1').run;

model.component('comp1').view('view1').hideEntities('hide1').add([2]);
model.component('comp1').view('view1').hideObjects.clear;
model.component('comp1').view('view1').hideEntities.clear;
model.component('comp1').view('view1').set('transparency', true);
model.component('comp1').view('view1').hideEntities.create('hide1');
model.component('comp1').view('view1').hideEntities('hide1').geom(3);
model.component('comp1').view('view1').hideEntities('hide1').add([1]);

model.component('comp1').mesh('mesh1').feature('ftet1').feature('size1').set('hauto', 1);
model.component('comp1').mesh('mesh1').run('size');
model.component('comp1').mesh('mesh1').run;

model.result('pg2').run;
model.result('pg2').run;
model.result('pg2').feature('surf2').feature('sel1').selection.named('geom1_sel10');
model.result('pg2').run;
model.result('pg2').run;

model.study('std1').createAutoSequences('all');

model.sol('sol1').runAll;

model.result('pg2').run;

mphsave('Comsol/BostonScientificVerciseDirected2202_simulationTerminal.mph')

out = model;
