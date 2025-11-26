% Define patient cohort directory

cohort.folder = 'C:\Users\annfr888\Documents\DBS\patient_data\lead_v3\PipelineStudy';


cohort.patNames = {'sub-DBS104';'sub-DBS128';'sub-DBS133';'sub-DBS139';'sub-DBS167';...
             'sub-DBS168';'sub-DBS171';'sub-DBS185';'sub-DBS199';'sub-DBS204'};
cohort.leads = {'Abbott Infinity Directed (short)';'Boston Scientific Vercise Directional 2202'; 'Abbott Infinity Directed (short)';...
         'Abbott Infinity Directed (short)';'Boston Scientific Vercise Directional 2202';'Abbott Infinity Directed (short)';...
         'Boston Scientific Vercise Directional 2202';'Abbott Infinity Directed (short)';...
         'Boston Scientific Vercise Directional 2202';'Boston Scientific Vercise Directional 2202'};
cohort.leadOrientations = {-55.7, 81.6; -111.4, -74.2; -170.5,-62.3; 19.4,157.6; 97.5,14.2; 72.7,21.2;...
              -145.6,115.5; -157.7,-175.9; 14.4 NaN; -52,35.6};
cohort.atlas = 'DBS Tractography Atlas (Middlebrooks 2020)';% 'DISTAL Minimal (Ewert 2017)'; %%'Human Dysfunctome Atlas (Hollunder 2024)';%
cohort.targets = {'STN_motor_tract.mat'};%{'STN_motor.nii.gz'}; %{'Sweet_Streamline_PD.nii'};%
cohort.constraints = {'STN_limbic_tract.mat','STN_associative_tract.mat'};%{'STN_limbic.nii','STN_associative.nii'};%

cohort.threads = 0;
cohort.plotoption = 0;
cohort.rebuild = 1;

cohort.simulationSettings.tractActivation = 'pointwise';%'fiberwise'; % 
cohort.simulationSettings.includeAnisotropy = 0;

cohort.omega = '1,1,0';
cohort.optischeme = 'Linear'; % 'MILP';% 'Nonlinear'; % 'LP'; %
cohort.simulationSettings.encapsulationThickness = 0.1*1e-3;
cohort.simulationSettings.LeadDBSVersion = 3.1;
cohort.EThreshold = 200;
cohort.CThreshold = 100;
cohort.space = 'MNI';
cohort.unit = '1mA';
cohort.compareSettings = 0;
cohort.computeDice = 0;
cohort.computeTargetCoverage = 0;
cohort.optimize = 1;
cohort.includeSpill = 0;
cohort.simulationSettings.downsample = 1;
cohort.simulationSettings.VoxelFilterSize = 0.95*1e-3;

% Option 1
cohort.simulationSettings.activationMetric = 'EF_norm';

% Option 2
% cohort.simulationSettings.activationMetric = 'AF_from_E';
% cohort.simulationSettings.fiberDirectionSource = 'from_fibers';

% Option 3
% cohort.simulationSettings.activationMetric = 'AF_from_V';
% cohort.simulationSettings.fiberDirectionSource = 'from_DTI';

% Run! 
main2(cohort)


