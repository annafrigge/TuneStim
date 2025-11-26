function msg = main2(cohort)
% MAIN - Optimal DBS stimulation parameter finder
%
% Finds optimal stimulation parameters given pre-processed neuroimages.
% Stimulation targets and constraints are defined by file names in the
% Lead-DBS atlas directory.
%
% Input Arguments:
%   cohort - Structure containing all configuration parameters
%
% Output:
%   msg - Status message indicating completion

%% ========================================================================
%  INITIALIZATION
%  ========================================================================
tic;
settings;
warning('off', 'MATLAB:dispatcher:nameConflict');

% Initialize default settings
cohort = initialize_cohort_defaults(cohort);

% Setup relaxation parameters based on optimization scheme
relaxation = get_relaxation_parameters(cohort.optischeme);

%% ========================================================================
%  MAIN PATIENT LOOP
%  ========================================================================

for patient = 1%:length(cohort.patNames)
    fprintf('\n=== Processing Patient %s ===\n', cohort.patNames{patient});
    
    % Initialize patient structure
    pat = initialize_patient_structure(cohort, patient);
    
    % Setup paths
    pat = setup_patient_paths(pat, cohort, patient);
    
    % Load patient-specific parameters
    pat = load_patient_parameters(pat, cohort, patient);
    
    % Setup environment
    setup_environment();
    
    % Initialize parallel computing if requested
    initialize_parallel_computing(cohort);
    
    %% ==================================================================
    %  LEAD RECONSTRUCTION
    %  ==================================================================
    hands = {"sin", "dx"};
    [pat.heads, pat.tails] = get_lead_parameters(pat, hands);
    
    %% ==================================================================
    %  CONDUCTIVITY MAPS
    %  ==================================================================
    if strcmp(pat.space, 'native')
        compute_conductivity_maps(pat, cohort, hands);
    end
    
    %% ==================================================================
    %  TARGET AND CONSTRAINT LOADING
    %  ==================================================================
    targets_and_constraints = [cohort.targets, cohort.constraints];
    create_structure_file(pat, cohort);
    
    if strcmp(pat.space, 'native')
        warp_structures_to_native(pat, cohort, targets_and_constraints);
    end
    
    %% ==================================================================
    %  PROCESS EACH HEMISPHERE
    %  ==================================================================
    for i = 1:length(hands)
        pat.hand = hands{i};
        fprintf('\n--- Processing hemisphere: %s ---\n', pat.hand);
        
        % Get lead parameters for this hemisphere
        [head, tail] = get_hemisphere_lead_params(pat);
        
        % Run COMSOL simulations if needed
        if cohort.rebuild
            run_comsol_terminal(pat,cohort.threads)
        end
        
        % Load COMSOL solution
        InitialSolution = load_comsol_solution(pat);
        pat.contactNames = fieldnames(InitialSolution);
        
        % Get coordinate bounds
        [pat.maxPoint, pat.minPoint] = get_coordinate_bounds(InitialSolution, pat.contactNames{1});
        
        % Load and process regions of interest
        pat = load_atlas_roi(pat, cohort);
        
        % Generate nontarget region (homogeneous grid, target and
        % constraint are not removed)
        pat = generate_nontarget_grid(pat, cohort);
        
        % Remove points within lead volume
        pat = remove_lead_volume_from_rois(...
            pat, head, tail);
        
        % Validate sufficient points
        validate_roi_points(pat);
        
        %% ==============================================================
        %  OPTIMIZATION
        %  ==============================================================
        if cohort.optimize == 1
            % Setup output file
            setup_optimization_output_file(pat, cohort);
            
            % Prepare interpolation data
            pat = prepare_interpolation_data(pat, InitialSolution);
            
            % Interpolate fields at target/constraint points
            pat = interpolate_fields_at_rois(...
                pat, cohort, InitialSolution, head, tail);

            % Run optimization for each relaxation parameter
            for k = 1:length(relaxation)
                pat.rel = relaxation(k);
                cou = eye(length(pat.contactNames));
                [cohort, pat] = run_optimization(cohort, pat, pat.rel, cou, i);
                
                % Write results if not using MILP/LP
                if ~ismember(cohort.optischeme, {'MILP', 'LP'})
                    write_recommendations_to_file(cohort, pat, head, tail, ...
                        pat.InitialSolution_cell, pat.Targets, pat.Constraints);
                end
            end
            
            % Save results
            save_patient_results(pat, cohort);
        end
        
        %% ==============================================================
        %  VISUALIZATION
        %  ==============================================================
        if cohort.plotoption
            create_visualization(pat, cohort, head);
        end
        
        %% ==============================================================
        %  COMPARISON WITH CLINICAL SETTINGS
        %  ==============================================================
        if cohort.compareSettings
            out = compare_suggested_2_clinical_settings(pat, pat.hand, ...
                head, tail, cohort, Vol_target, Vol_constraint);
            msg = 'Done comparing settings.';
        end
    end
end

%% ========================================================================
%  CLEANUP
%  ========================================================================
cleanup_parallel_pool();

msg = 'Computations finished.';
fprintf('\nTotal elapsed time: %.2f seconds\n', toc);

end

%% ========================================================================
%  HELPER FUNCTIONS
%  ========================================================================

function cohort = initialize_cohort_defaults(cohort)
    % Set default simulation settings
    if ~isfield(cohort.simulationSettings, 'tractActivation')
        cohort.simulationSettings.tractActivation = 'pointwise';
    end

    if ~isfield(cohort.simulationSettings, 'activationMetric')
        cohort.simulationSettings.activationMetric = 'EF_norm';  % Default
    end
    if ~isfield(cohort.simulationSettings, 'fiberDirectionSource')
        cohort.simulationSettings.fiberDirectionSource = 'from_fibers';  % or 'from_DTI'
    end

    % Parse omega parameter
    cohort.omega = str2num(replace(cohort.omega, '-', ' '));
end

function relaxation = get_relaxation_parameters(optischeme)
    % Determine relaxation parameters based on optimization scheme
    switch optischeme
        case {'Linear', 'Nonlinear'}
            relaxation = 0:10:90;
        case 'mincov'
            relaxation = 10:10:90;
        case {'MILP', 'LP'}
            relaxation = 1;
        otherwise
            relaxation = 0:10:90; % Default
    end
end

function pat = initialize_patient_structure(cohort, patient)
    % Initialize patient structure with basic info
    pat.patientNo = patient;
    pat.encapsulationThickness = cohort.simulationSettings.encapsulationThickness;
    pat.space = cohort.space;
    pat.unit = cohort.unit;
    pat.includeAnisotropy = cohort.simulationSettings.includeAnisotropy;
    pat.activationMetric = cohort.simulationSettings.activationMetric;
end

function pat = setup_patient_paths(pat, cohort, patient)
    % Setup all necessary paths for patient
    
    if cohort.simulationSettings.LeadDBSVersion < 3.0
        % Legacy path structure
        pat.path = fullfile(cohort.folder, cohort.patNames{patient}, filesep);
        pat.TuneSderivativesPath = pat.path;
        pat.outputPath = build_legacy_output_path(pat, cohort);
    else
        % Modern Lead-DBS v3+ path structure
        pat.path = fullfile(cohort.folder, 'derivatives', 'leaddbs', ...
            cohort.patNames{patient}, filesep);
        pat.TuneSderivativesPath = fullfile(cohort.folder, 'derivatives', ...
            'TuneS', cohort.patNames{patient}, filesep);
        pat.outputPath = build_modern_output_path(pat, cohort);
    end
    
    % Create output directory
    if ~exist(pat.outputPath, 'dir')
        mkdir(pat.outputPath);
    end
    
    % Extract patient name from path
    strArray = strsplit(pat.path, filesep);
    pat.name = strArray{end-1};
end

function outputPath = build_legacy_output_path(pat, cohort)
    % Build output path for legacy Lead-DBS versions
    targetName = extractBefore(cohort.targets{1,1}, '.');
    outputPath = fullfile(pat.path, 'Suggestions', targetName, ...
        cohort.optischeme, num2str(cohort.CThreshold), ...
        sprintf('S-%d-%d-%d', cohort.omega(1), cohort.omega(2), cohort.omega(3)));
end

function outputPath = build_modern_output_path(pat, cohort)
    % Build output path for modern Lead-DBS versions
    
    if ismember(cohort.optischeme, {'MILP', 'LP'})
        % Simplified path for MILP/LP
        targetName = extractBefore(cohort.targets{1,1}, '.');
        outputPath = fullfile(pat.TuneSderivativesPath, 'Suggestions', ...
            targetName, cohort.optischeme, ...
            sprintf('%d-%d', cohort.EThreshold, cohort.CThreshold));
    else
        % Full path with targets and constraints
        allTargets = cellfun(@(x) extractBefore(x, '.'), ...
            cohort.targets(1,:), 'UniformOutput', false);
        targetsStr = strjoin(allTargets, '_');
        
        allConstraints = cellfun(@(x) extractBefore(x, '.'), ...
            cohort.constraints(1,:), 'UniformOutput', false);
        constraintsStr = strjoin(allConstraints, '_');
        
        outputPath = fullfile(pat.TuneSderivativesPath, 'Suggestions', ...
            sprintf('%s__%s', targetsStr, constraintsStr), ...
            cohort.optischeme, num2str(cohort.CThreshold), ...
            sprintf('S-%d-%d-%d', cohort.omega(1), cohort.omega(2), cohort.omega(3)));
    end
end

function pat = load_patient_parameters(pat, cohort, patient)
    % Load patient-specific parameters
    
    % Lead orientations
    pat.orientation.sin = cohort.leadOrientations{patient, 1};
    pat.orientation.dx = cohort.leadOrientations{patient, 2};
    
    % Lead type
    pat.lead = cohort.leads{patient, 1};
    
    % Assign coupling combinations
    pat = assign_coupl_combos(pat, cohort);
end

function setup_environment()
    % Setup MATLAB environment and paths
    
    if exist('lead', 'dir') == 0
        % Add Lead-DBS paths if not already in path
        leadPath = '/castor/project/proj_nobackup/MATLAB/lead';
        spmPath = '/castor/project/proj_nobackup/MATLAB/spm12';
        
        if exist(leadPath, 'dir')
            addpath(genpath(leadPath));
        end
        if exist(spmPath, 'dir')
            addpath(genpath(spmPath));
        end
    end
end

function initialize_parallel_computing(cohort)
    % Initialize parallel computing pool if requested
    
    if cohort.threads > 1
        try
            % Check if pool already exists
            poolobj = gcp('nocreate');
            if isempty(poolobj)
                parpool(cohort.threads);
                fprintf('Parallel pool created with %d workers\n', cohort.threads);
            else
                fprintf('Using existing parallel pool with %d workers\n', poolobj.NumWorkers);
            end
        catch ME
            warning('Failed to create parallel pool: %s', ME.message);
            cohort.threads = 0;
        end
    else
        cohort.threads = 0;
    end
end

function compute_conductivity_maps(pat, cohort, hands)
    % Compute conductivity maps in native space
    
    % Warp from high resolution images
    MNI7T_to_native(pat.path(1:end-1), cohort.rebuild);
    
    % Segment the warped image
    segment_wt1_job(pat.path, cohort.rebuild, pat.space);
    
    % Construct conductivity maps for each hemisphere
    for i = 1:length(hands)
        assign_conductivites(pat);
    end
    
    fprintf('Conductivity maps computed in native space.\n');
end

function warp_structures_to_native(pat, cohort, targets_and_constraints)
    % Warp structures of interest to native space
    
    for i = 1:length(targets_and_constraints)
        warp_structures_to_subject(pat, cohort, targets_and_constraints{1,i});
    end
    fprintf('Structures warped to native space.\n');
end

function [head, tail] = get_hemisphere_lead_params(pat)
    % Get head and tail coordinates for specified hemisphere 
    head = pat.heads.(pat.hand);
    tail = pat.tails.(pat.hand);
end


function [maxPoint, minPoint] = get_coordinate_bounds(InitialSolution, contactName)
    % Get max and min coordinate bounds from solution    
    coords = InitialSolution.(contactName)(:, 1:3);
    maxPoint = max(coords, [], 1);
    minPoint = min(coords, [], 1);
end

function pat = remove_lead_volume_from_rois(pat, head, tail)
    % Remove points that lie within lead volume from ROIs
    
    mask_Target = remove_lead_volume2(pat, pat.TargetPoints, head, tail);
    pat.Vol_target = pat.TargetPoints(mask_Target, :);
    
    mask_Constraint = remove_lead_volume2(pat, pat.ConstraintPoints, head, tail);
    pat.Vol_constraint = pat.ConstraintPoints(mask_Constraint, :);

    mask_NonTarget = remove_lead_volume2(pat, pat.NonTargetPoints, head, tail);
    pat.Vol_nontarget = pat.NonTargetPoints(mask_NonTarget,:);
end

function validate_roi_points(pat)
    % Validate that ROIs have sufficient points
    
    MIN_POINTS = 100;
    
    if size(pat.Vol_target, 1) < MIN_POINTS
        warning('Number of target points (%d) is less than %d', ...
            size(pat.Vol_target, 1), MIN_POINTS);
    end
    
    if size(pat.Vol_constraint, 1) < MIN_POINTS
        warning('Number of constraint points (%d) is less than %d', ...
            size(pat.Vol_constraint, 1), MIN_POINTS);
    end
end

function setup_optimization_output_file(pat, cohort)
    % Setup output file for optimization results
    
    filename = sprintf('Top_Suggestions_%s_%s_%s_%s.txt', ...
        pat.space, pat.hand, cohort.optischeme, ...
        cohort.simulationSettings.tractActivation);
    
    filepath = fullfile(pat.outputPath, filename);
    fid = fopen(filepath, 'w');
    fprintf(fid, 'Contacts \t Target \t Constraint \t Spill \t Alpha \t VTA \t Score\n\n');
    fclose(fid);
end

function pat = prepare_interpolation_data(pat, InitialSolution)
    % Prepare data structures for interpolation
    
    pat.InitialSolution_cell = struct2cell(InitialSolution);
    pat.FEMCoordinates = InitialSolution.(pat.contactNames{1})(:, 1:3);
end


function pat = interpolate_fields_at_rois(...
    pat, cohort, InitialSolution, head, tail)
    
    ActiveContactsCombos = fieldnames(InitialSolution);
    
    % CREATE ACTIVATION METRIC OBJECT
    metric = create_activation_metric(cohort);
    
    % Check if using fiber tracts
    use_fibertracts = contains(cohort.targets{1,1}, 'tract') && ...
        strcmp(cohort.simulationSettings.tractActivation, 'fiberwise');
    
    if use_fibertracts
        [VqTarget, VqConstraint, VqNonTarget, VqTargetCoords, VqConstraintCoords] = ...
            interpolate_fibertracts_with_metric(pat, cohort, InitialSolution, ...
            ActiveContactsCombos, head, tail, metric);
        
        pat.VqTargetCoords = VqTargetCoords;
        pat.VqConstraintCoords = VqConstraintCoords;
    else
        [VqTarget, VqConstraint, VqNonTarget] = interpolate_volumes_with_metric(...
            InitialSolution, ActiveContactsCombos, pat, cohort, metric);
    end
    
    pat.VqTarget = VqTarget;
    pat.VqConstraint = VqConstraint;
    pat.VqNonTarget = VqNonTarget;
end

% In main_refactored.m or as separate file: create_activation_metric.m

function metric = create_activation_metric(cohort)
    % Factory function to create appropriate metric
    % Uses cohort.EThreshold for targets and cohort.CThreshold for constraints
    
    metric_type = cohort.simulationSettings.activationMetric;
    
    % Get thresholds - KEEP YOUR NAMING!
    E_thresh = cohort.EThreshold;  % Target activation threshold
    C_thresh = cohort.CThreshold;  % Constraint avoidance threshold
    
    switch metric_type
        case 'EF_norm'
            metric = EFieldNormMetric(E_thresh, C_thresh);
            
        case 'AF_from_E'
            metric = ActivatingFunctionMetric(E_thresh, C_thresh, 'from_E');
            
        case 'AF_from_V'
            metric = ActivatingFunctionMetric(E_thresh, C_thresh, 'from_V');
            
        otherwise
            warning('Unknown metric type: %s, using EF_norm', metric_type);
            metric = EFieldNormMetric(E_thresh, C_thresh);
    end
    
    fprintf('Created %s metric with EThreshold=%.1f, CThreshold=%.1f\n', ...
        metric.name, E_thresh, C_thresh);
end

function [VqTarget, VqConstraint, VqNonTarget, VqTargetCoords, VqConstraintCoords] = ...
    interpolate_fibertracts_with_metric(pat, cohort, InitialSolution, ...
    ActiveContactsCombos, head, tail, metric)
% INTERPOLATE_FIBERTRACTS_WITH_METRIC - Interpolate E-fields along fiber tracts
%
% Uses metric system to compute activation values along fiber tracts.
% Extracts maximum activation along each fiber.
%
% Inputs:
%   pat - Patient structure
%   cohort - Cohort structure with targets, constraints
%   InitialSolution - Structure with E-field solutions
%   ActiveContactsCombos - Cell array of contact configuration names
%   head - Lead head position
%   tail - Lead tail position
%   metric - Activation metric object (e.g., EFieldNormMetric, ActivatingFunctionMetric)
%
% Outputs:
%   VqTarget - Cell array of max activation per target fiber
%   VqConstraint - Cell array of max activation per constraint fiber
%   VqNonTarget - Cell array of non-target activation (empty for fiberwise)
%   VqTargetCoords - Cell array of coordinates where max occurs (target)
%   VqConstraintCoords - Cell array of coordinates where max occurs (constraint)

    %% Load fiber tracts from atlas
    atlas_path = fullfile(pat.path, 'atlases', cohort.atlas, 'neurostructures.mat');
    load(atlas_path, 'region');
    
    % Concatenate target and constraint fiber tracts
    Targetfibs = concat_fibertracts(region, pat, cohort.targets, pat.hand);
    Constraintfibs = concat_fibertracts(region, pat, cohort.constraints, pat.hand);
    
    %% Remove points in lead volume
    mask_Targetfibs = remove_lead_volume2(pat, Targetfibs(:,1:3), head, tail);
    Targetfibs = Targetfibs(mask_Targetfibs, :);
    
    mask_Constraintfibs = remove_lead_volume2(pat, Constraintfibs(:,1:3), head, tail);
    Constraintfibs = Constraintfibs(mask_Constraintfibs, :);
    
    fprintf('  Fiber tracts after lead volume removal:\n');
    fprintf('    Target fibers: %d points\n', size(Targetfibs, 1));
    fprintf('    Constraint fibers: %d points\n', size(Constraintfibs, 1));
    
    %% Initialize output cells
    n_configs = length(ActiveContactsCombos);
    VqTarget = cell(n_configs, 1);
    VqConstraint = cell(n_configs, 1);
    VqTargetCoords = cell(n_configs, 1);
    VqConstraintCoords = cell(n_configs, 1);
    
    %% Get fiber directions if needed for Activating Function
    if isa(metric, 'ActivatingFunctionMetric')
        fprintf('  Getting fiber directions for AF metric...\n');
        
        % Get fiber directions (pass coordinates directly or as struct depending on provider)
        % Try to determine what FiberDirectionProvider expects
        try
            % Try passing as struct first
            Vol_targetfibs = struct('pos', Targetfibs(:, 1:3));
            fiber_dirs_target = FiberDirectionProvider.get_fiber_directions(...
                cohort.simulationSettings.fiberDirectionSource, ...
                Vol_targetfibs, pat, cohort);
            
            Vol_constraintfibs = struct('pos', Constraintfibs(:, 1:3));
            fiber_dirs_constraint = FiberDirectionProvider.get_fiber_directions(...
                cohort.simulationSettings.fiberDirectionSource, ...
                Vol_constraintfibs, pat, cohort);
        catch
            % If that fails, fiber directions might come from the fiber tract data itself
            % Use tangent vectors along fibers or default to zeros
            warning('Could not get fiber directions, using default');
            fiber_dirs_target = [];
            fiber_dirs_constraint = [];
        end
    else
        fiber_dirs_target = [];
        fiber_dirs_constraint = [];
    end
    
    %% Get required columns for this metric
    cols = get_required_columns(metric);
    
    %% Interpolate for each contact configuration
    fprintf('  Interpolating fields for %d configurations...\n', n_configs);
    
    for k = 1:n_configs
        field = ActiveContactsCombos{k};
        sol = InitialSolution.(field);
        
        % Interpolate solution to fiber points (pass coordinates directly)
        sol_target = interpolate_solution(sol, Targetfibs(:, 1:3), cols);
        sol_constraint = interpolate_solution(sol, Constraintfibs(:, 1:3), cols);
        
        % Compute activation metric at all fiber points
        activation_target = metric.compute(sol_target, fiber_dirs_target);
        activation_constraint = metric.compute(sol_constraint, fiber_dirs_constraint);
        
        % Extract maximum value along each fiber
        % Targetfibs/Constraintfibs have fiber IDs in column 4
        [VqTarget{k}, VqTargetCoords{k}] = extract_max_per_fiber(...
            Targetfibs, activation_target);
        [VqConstraint{k}, VqConstraintCoords{k}] = extract_max_per_fiber(...
            Constraintfibs, activation_constraint);
    end
    
    % Non-target is not used for fiberwise activation
    VqNonTarget = cell(n_configs, 1);
    for k = 1:n_configs
        VqNonTarget{k} = [];
    end
    
    fprintf('  Fiberwise interpolation complete.\n');
    fprintf('    Target: %d fibers per config\n', length(VqTarget{1}));
    fprintf('    Constraint: %d fibers per config\n', length(VqConstraint{1}));
end


function [Vq_max, Vq_coords] = extract_max_per_fiber(fibers, Vq_values)
    % Extract maximum value along each fiber
    
    fiber_ids = unique(fibers(:,4));
    n_fibers = length(fiber_ids);
    
    Vq_max = zeros(n_fibers, 1);
    Vq_coords = zeros(n_fibers, 4);
    
    for i = 1:n_fibers
        fiber_id = fiber_ids(i);
        idx = (fibers(:,4) == fiber_id);
        
        [max_val, max_idx_rel] = max(Vq_values(idx));
        idx_abs = find(idx);
        max_idx_abs = idx_abs(max_idx_rel);
        
        Vq_max(i) = max_val;
        Vq_coords(i,:) = [fibers(max_idx_abs, 1:3), fiber_id];
    end
end


function [VqTarget, VqConstraint, VqNonTarget] = interpolate_volumes_with_metric(...
    InitialSolution, ActiveContactsCombos, ...
    pat, cohort, metric)

    
    n_configs = length(ActiveContactsCombos);
    VqTarget = cell(n_configs, 1);
    VqConstraint = cell(n_configs, 1);
    VqNonTarget = cell(n_configs, 1);
    
    % Get fiber directions if needed for AF
    if isa(metric, 'ActivatingFunctionMetric')
        fiber_dirs_target = FiberDirectionProvider.get_fiber_directions(...
            cohort.simulationSettings.fiberDirectionSource, ...
            pat.Vol_target, pat, cohort);
        
        fiber_dirs_constraint = FiberDirectionProvider.get_fiber_directions(...
            cohort.simulationSettings.fiberDirectionSource, ...
            pat.Vol_constraint, pat, cohort);
    else
        fiber_dirs_target = [];
        fiber_dirs_constraint = [];
    end
    cols = get_required_columns(metric);
    for k = 1:n_configs
        field = ActiveContactsCombos{k};
        sol = InitialSolution.(field);
        
        % Interpolate solution to points
        sol_target = interpolate_solution(sol, pat.Vol_target,cols);
        sol_constraint = interpolate_solution(sol, pat.Vol_constraint,cols);
        sol_nontarget = interpolate_solution(sol, pat.Vol_nontarget,cols);
        
        % Compute activation metric (returns raw values)
        VqTarget{k} = metric.compute(sol_target, fiber_dirs_target);
        VqConstraint{k} = metric.compute(sol_constraint, fiber_dirs_constraint);
        VqNonTarget{k} = metric.compute(sol_nontarget, fiber_dirs_constraint);
    end
    
    % NOTE: Thresholding happens in optimization using:
    % - metric.target_threshold (EThreshold) for targets
    % - metric.constraint_threshold (CThreshold) for constraints
end

function cols = get_required_columns(metric)
    % Determine which columns to interpolate based on metric type
    
    if isa(metric, 'EFieldNormMetric')
        % Only need E-field norm (column 8)
        cols = 8;
        
    elseif isa(metric, 'ActivatingFunctionMetric')
        if strcmp(metric.method, 'from_E')
            % Need Ex, Ey, Ez (columns 4, 5, 6)
            cols = [4, 5, 6];
        else
            % Need Hessian components (columns 9-14)
            cols = [9, 10, 11, 12, 13, 14];
        end
    else
        % Default: E-field norm
        cols = 8;
    end
end

function sol_interp = interpolate_solution(sol, query_points,cols)
    % Interpolate all required solution fields to query points
    
    coords = sol(:, 1:3);
    n_fields = size(sol, 2);
    n_query = size(query_points, 1);
    
    sol_interp = zeros(n_query, n_fields);
    sol_interp(:, 1:3) = query_points;  % Coordinates
    
    % Interpolate each field
    for n = 1:length(cols)
        i= cols(n);
        F = scatteredInterpolant(coords(:,1), coords(:,2), coords(:,3), ...
            sol(:,i), 'natural', 'none');
        sol_interp(:, i) = F(query_points(:,1), query_points(:,2), query_points(:,3));
    end
end



function save_patient_results(pat, cohort)
    % Save patient results to file
    
    filename = sprintf('%s_suggestions.mat', pat.hand);
    filepath = fullfile(pat.outputPath, filename);
    save(filepath, 'pat', 'cohort');
    fprintf('Results saved to: %s\n', filepath);
end

function create_visualization(pat, cohort, head)
    % Create visualization of results
    
    fprintf('Creating visualization...\n');
    
    % Plot lead
    plot_lead(pat);
    hold on;
    
    % Plot target and constraint regions
    plot_target_and_constraint(pat);
    
    % Plot VTA
    plot_VTA(cohort, pat);
    
    % Adjust figure properties
    axis off;
    light("Style", "infinite", "Position", [0 10 0]);
    
    % Set axis limits
    margin = 10e-3; % 10 mm margin
    xlim([head(1) - margin, head(1) + margin]);
    ylim([head(2) - margin, head(2) + margin]);
    zlim([head(3) - margin, head(3) + margin]);
    
    title(pat.hand);
    camzoom(1.2);
    
    % Save figure
    fig_basename = sprintf('%s_DBS_scenario', pat.hand);
    savefig(fullfile(pat.outputPath, [fig_basename '.fig']));
    exportgraphics(gcf, fullfile(pat.outputPath, [fig_basename '.png']), ...
        'Resolution', 300);
    
    fprintf('Visualization saved.\n');
end

function cleanup_parallel_pool()
    % Clean up parallel computing pool
    
    poolobj = gcp('nocreate');
    if ~isempty(poolobj)
        delete(poolobj);
        fprintf('Parallel pool closed.\n');
    end
end