function out = model
%
% AbbottStJude1331_simulationTerminal.m
%
% Model exported on Nov 10 2025, 16:35 by COMSOL 6.3.0.290.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('C:\Users\annfr888\Documents\DBS\code\TuneStim\Comsol');

model.component.create('comp1', true);

model.component('comp1').geom.create('geom1', 3);

model.component('comp1').geom('geom1').geomRep('comsol');

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
model.param.set('encapsulationThickness', '0.2*1e-3');


model.component('comp1').geom('geom1').create('imp1', 'Import');
model.component('comp1').geom('geom1').feature('imp1').set('type', 'native');
model.component('comp1').geom('geom1').feature('imp1').set('filename', 'C:\Users\annfr888\Documents\DBS\code\TuneStim\Comsol\Leads\BostonScientific2202_lead_no_encapsulation.mphbin');
model.component('comp1').geom('geom1').feature('imp1').importData;
model.component('comp1').geom('geom1').run('imp1');
model.component('comp1').geom('geom1').create('cyl1', 'Cylinder');
model.component('comp1').geom('geom1').feature('cyl1').set('r', '6.35*1e-3+encapsulationThickness');
model.component('comp1').geom('geom1').feature('cyl1').set('h', 0.10075);
model.component('comp1').geom('geom1').run('cyl1');

model.component('comp1').geom('geom1').create('elp1', 'Ellipsoid');
model.component('comp1').geom('geom1').feature('elp1').set('semiaxes', {'6.35*1e-4+encapsulationThickness' '1' '1'});
model.component('comp1').geom('geom1').feature('elp1').setIndex('semiaxes', '6.35*1e-4+encapsulationThickness', 1);
model.component('comp1').geom('geom1').feature('elp1').setIndex('semiaxes', '0.0005', 2);
model.component('comp1').geom('geom1').feature('elp1').setIndex('semiaxes', '5e-4+encapsulationThickness', 2);
model.component('comp1').geom('geom1').run('elp1');
model.component('comp1').geom('geom1').create('uni1', 'Union');
model.component('comp1').geom('geom1').feature('cyl1').set('r', '6.35*1e-4+encapsulationThickness');
model.component('comp1').geom('geom1').run('cyl1');
model.component('comp1').geom('geom1').feature('cyl1').set('pos', {'head_x' 'head_y' '0'});
model.component('comp1').geom('geom1').feature('cyl1').setIndex('pos', 'head_z', 2);
model.component('comp1').geom('geom1').run('cyl1');
model.component('comp1').geom('geom1').feature('cyl1').setIndex('pos', 0, 0);
model.component('comp1').geom('geom1').feature('cyl1').set('pos', [0 0 0]);
model.component('comp1').geom('geom1').run('cyl1');
model.component('comp1').geom('geom1').run('cyl1');
model.component('comp1').geom('geom1').feature('imp1').importData;
model.component('comp1').geom('geom1').feature('imp1').importData;
model.component('comp1').geom('geom1').run('cyl1');
model.component('comp1').geom('geom1').feature('cyl1').set('pos', {'0' '0' '-0.75*1e-3'});
model.component('comp1').geom('geom1').run('cyl1');
model.component('comp1').geom('geom1').feature('elp1').set('pos', {'0' '0' '-0.75*1e-3'});
model.component('comp1').geom('geom1').run('elp1');
model.component('comp1').geom('geom1').feature('uni1').selection('input').set({'cyl1' 'elp1'});
model.component('comp1').geom('geom1').feature('uni1').set('intbnd', false);
model.component('comp1').geom('geom1').run('uni1');


model.component('comp1').geom('geom1').create('rot1', 'Rotate');
model.component('comp1').geom('geom1').runPre('rot1');
model.component('comp1').geom('geom1').feature('rot1').selection('input').set({'imp1' 'uni1'});
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
model.component('comp1').geom('geom1').feature('sel_C1X').selection('selection').set('fin', 15);
model.component('comp1').geom('geom1').create('sel_C2A', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C2A').label('Contact 2A');
model.component('comp1').geom('geom1').feature('sel_C2A').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C2A').selection('selection').set('fin', 26);
model.component('comp1').geom('geom1').create('sel_C2C', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C2C').label('Contact 2C');
model.component('comp1').geom('geom1').feature('sel_C2C').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C2C').selection('selection').set('fin', 18);
model.component('comp1').geom('geom1').create('sel_C2B', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C2B').label('Contact 2B');
model.component('comp1').geom('geom1').feature('sel_C2B').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C2B').selection('selection').set('fin', 62);
model.component('comp1').geom('geom1').create('sel_C3A', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C3A').label('Contact 3A');
model.component('comp1').geom('geom1').feature('sel_C3A').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C3A').selection('selection').set('fin', 45);
model.component('comp1').geom('geom1').create('sel_C3C', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C3C').label('Contact 3C');
model.component('comp1').geom('geom1').feature('sel_C3C').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C3C').selection('selection').set('fin', 29);
model.component('comp1').geom('geom1').create('sel_C3B', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C3B').label('Contact 3B');
model.component('comp1').geom('geom1').feature('sel_C3B').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C3B').selection('selection').set('fin', 71);
model.component('comp1').geom('geom1').create('sel_C4X', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel_C4X').label('Contact 4');
model.component('comp1').geom('geom1').feature('sel_C4X').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel_C4X').selection('selection').set('fin', 48);
model.component('comp1').geom('geom1').create('sel9', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel9').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel9').label('All Contacts');
model.component('comp1').geom('geom1').feature('sel9').selection('selection').set('fin', [15 26 18 62 45 29 71 48]);
model.component('comp1').geom('geom1').create('sel10', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel10').selection('selection').init(2);
model.component('comp1').geom('geom1').feature('sel10').selection('selection').set('fin', [16 , 20, 23, 33, 40, 42, 58, 61, 74, 75]); 
model.component('comp1').geom('geom1').feature('sel10').label('LeadNoContacts');
model.component('comp1').geom('geom1').create('sel11', 'ExplicitSelection');
model.component('comp1').geom('geom1').feature('sel11').selection('selection').set('fin', [2 3]);
model.component('comp1').geom('geom1').feature('sel11').label('InhomBox');
model.component('comp1').geom('geom1').run('sel11');
model.component('comp1').geom('geom1').create('cmd1', 'CompositeDomains');
model.component('comp1').geom('geom1').feature('cmd1').selection('input').set('fin', [3]);
model.component('comp1').geom('geom1').create('ige1', 'IgnoreEdges');
model.component('comp1').geom('geom1').feature('ige1').selection('input').set('cmd1', [17 18 19 20 34 35 36 40 41 42 43 89 99 103 105 106]); 
model.component('comp1').geom('geom1').run('ige1');
model.component('comp1').geom('geom1').runAll;

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


model.func.duplicate('int3', 'int1');
model.func('int3').setEntry('funcnames', 'col4', 'sigma_xx');
model.func('int3').discardData;
model.func('int3').set('filename', 'C:\Users\annfr888\Documents\DBS\code\TuneStim\MNI\sigma_xx_map_full_mni.csv');
model.func('int3').importData;
model.func.duplicate('int4', 'int3');
model.func('int4').setEntry('funcnames', 'col4', 'sigma_yy');
model.func('int4').discardData;
model.func('int4').set('filename', 'C:\Users\annfr888\Documents\DBS\code\TuneStim\MNI\sigma_yy_map_full_mni.csv');
model.func('int4').importData;
model.func.duplicate('int5', 'int4');
model.func('int5').setEntry('funcnames', 'col4', 'sigma_zz');
model.func('int5').discardData;
model.func('int5').set('filename', 'C:\Users\annfr888\Documents\DBS\code\TuneStim\MNI\sigma_zz_map_full_mni.csv');
model.func('int5').importData;
model.func.duplicate('int6', 'int5');
model.func('int6').setEntry('funcnames', 'col4', 'sigma_xy');
model.func('int6').discardData;
model.func('int6').set('filename', 'C:\Users\annfr888\Documents\DBS\code\TuneStim\MNI\sigma_xy_map_full_mni.csv');
model.func('int6').importData;
model.func.duplicate('int7', 'int6');
model.func('int7').discardData;
model.func('int7').set('filename', 'C:\Users\annfr888\Documents\DBS\code\TuneStim\MNI\sigma_xz_map_full_mni.csv');
model.func('int7').importData;
model.func('int7').setEntry('funcnames', 'col4', 'sigma_xz');
model.func.duplicate('int8', 'int7');
model.func('int8').setEntry('funcnames', 'col4', 'sigma_yz');
model.func('int8').discardData;
model.func('int8').set('filename', 'C:\Users\annfr888\Documents\DBS\code\TuneStim\MNI\sigma_yz_map_full_mni.csv');
model.func('int8').importData;

model.component('comp1').physics('ec').selection.set([1 2 3]);
model.component('comp1').physics('ec').feature('cucn1').label('Bulk brain inhomogeneous');
model.component('comp1').physics('ec').feature('cucn1').set('sigma', {'sigma_xx(root.x,root.y,root.z)' 'sigma_xy(root.x,root.y,root.z)' 'sigma_xz(root.x,root.y,root.z)' 'sigma_xy(root.x,root.y,root.z)' 'sigma_yy(root.x,root.y,root.z)' 'sigma_yz(root.x,root.y,root.z)' 'sigma_xz(root.x,root.y,root.z)' 'sigma_yz(root.x,root.y,root.z)' 'sigma_zz(root.x,root.y,root.z)'});
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
model.component('comp1').physics('ec').feature('cucn3').selection.set([3]);
model.component('comp1').physics('ec').feature('cucn3').setIndex('minput_temperature_src', 'userdef', 0);
model.component('comp1').physics('ec').feature('cucn3').set('sigma_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn3').set('sigma', [0.18 0 0 0 0.18 0 0 0 0.18]);
model.component('comp1').physics('ec').feature('cucn3').set('epsilonr_mat', 'userdef');
model.component('comp1').physics('ec').feature('cucn3').set('epsilonr', [1380000 0 0 0 1380000 0 0 0 1380000]);
model.component('comp1').physics('ec').create('gnd1', 'Ground', 2);
model.component('comp1').physics('ec').feature('gnd1').selection.set([1 2 3 4 5 76]);
model.component('comp1').physics('ec').feature('gnd1').label('Ground External');
model.component('comp1').physics('ec').create('fp1', 'FloatingPotential', 2);
model.component('comp1').physics('ec').feature('fp1').selection.named('geom1_sel9');
model.component('comp1').physics('ec').feature('fp1').set('Group', true);
model.component('comp1').physics('ec').feature('fp1').active(false);
model.component('comp1').physics('ec').create('gnd2', 'Ground', 2);
model.component('comp1').physics('ec').feature('gnd2').label('Ground Contacts');
model.component('comp1').physics('ec').feature('gnd2').selection.named('geom1_sel9');
model.component('comp1').physics('ec').feature('gnd2').active(false);

model.component('comp1').physics('ec').create('term1', 'Terminal', 2);
model.component('comp1').physics('ec').feature('fp1').active(true);
model.component('comp1').physics('ec').feature('term1').set('I0', 'I0');
model.component('comp1').physics('ec').feature('term1').selection.named('geom1_sel_C1X');


model.component('comp1').mesh('mesh1').automatic(false);
model.component('comp1').mesh('mesh1').feature('ftet1').selection.set([1 2 3]);
model.component('comp1').mesh('mesh1').feature('size').set('custom', true);
model.component('comp1').mesh('mesh1').feature('size').set('hmax', '0.0008');
model.component('comp1').mesh('mesh1').feature('size').set('hmin', 1.4E-6);
model.component('comp1').mesh('mesh1').feature('size').set('hgrad', 1.3);
model.component('comp1').mesh('mesh1').feature('size').set('hcurve', 0.2);
model.component('comp1').mesh('mesh1').feature('size').set('hnarrow', 1);
model.component('comp1').mesh('mesh1').feature('ftet1').create('size1', 'Size');
model.component('comp1').mesh('mesh1').feature('ftet1').feature('size1').selection.set([2,3]);
model.component('comp1').mesh('mesh1').feature('ftet1').feature('size1').set('hauto', 1);
model.component('comp1').mesh('mesh1').feature('ftet1').create('size2', 'Size');
model.component('comp1').mesh('mesh1').feature('ftet1').feature('size2').set('hauto', 4);
model.component('comp1').mesh('mesh1').feature('ftet1').feature('size2').selection.set([1]);
model.component('comp1').mesh('mesh1').feature('ftet1').selection.set([1 2 3]);
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


model.result.dataset('dset1').set('frametype', 'mesh');


model.label('BostonScientificVerciseDirected2202.mph');

model.sol('sol1').runAll;

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
%model.result('pg2').feature('iso1').active(false);

model.result('pg2').run;

mphsave('BostonScientificVerciseDirected2202Anisotropy.mph')
out = model;