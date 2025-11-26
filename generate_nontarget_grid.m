function pat = generate_nontarget_grid(pat, cohort)
% GENERATE_NONTARGET_GRID - Simple 3D grid generation
%
% Creates uniform 3D grid within bounding box defined by pat.minPoint and
% pat.maxPoint with spacing from cohort.simulationSettings.VoxelFilterSize
%
% Inputs:
%   pat - Patient structure with fields:
%         pat.minPoint - [x_min, y_min, z_min] in m
%         pat.maxPoint - [x_max, y_max, z_max] in m
%   cohort - Cohort structure with field:
%            cohort.simulationSettings.VoxelFilterSize - spacing in mm
%
% Output:
%   gridPoints - Nx3 matrix of [x, y, z] coordinates in m


%% Validate inputs
if ~isfield(pat, 'minPoint') || ~isfield(pat, 'maxPoint')
    error('pat.minPoint and pat.maxPoint must be defined');
end

if ~isfield(cohort, 'simulationSettings') || ...
   ~isfield(cohort.simulationSettings, 'VoxelFilterSize')
    error('cohort.simulationSettings.VoxelFilterSize must be defined');
end

%% Extract parameters
minPt = pat.minPoint;
maxPt = pat.maxPoint;
voxelSize = cohort.simulationSettings.VoxelFilterSize;

%% Generate uniform 3D grid
[X, Y, Z] = meshgrid(minPt(1):voxelSize:maxPt(1), ...
                     minPt(2):voxelSize:maxPt(2), ...
                     minPt(3):voxelSize:maxPt(3));

%% Flatten to Nx3 matrix
pat.NonTargetPoints = [X(:), Y(:), Z(:)];

% %% Display info
% fprintf('Non-target grid generated:\n');
% fprintf('  Bounding box: [%.1f, %.1f, %.1f] to [%.1f, %.1f, %.1f] mm\n', ...
%     minPt, maxPt);
% fprintf('  Voxel size: %.2f mm\n', voxelSize);
% fprintf('  Grid points: %d\n', size(gridPoints, 1));

end