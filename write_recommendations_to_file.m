function write_recommendations_to_file(cohort, pat, head, tail, InitialSolution_cell, target_lst, constraint_lst)
    %% Handle different optimization schemes
    
    % Check if using LP/MILP schemes
    if strcmp(cohort.optischeme, 'MILP') || strcmp(cohort.optischeme, 'LP')
        write_LP_MILP_results_to_file(cohort, pat);
        return;  % Exit after writing LP/MILP results
    end
    
    %% Original code for Linear/Nonlinear/mincov schemes
    disp('Computing volume of tissue activated...')
    
    if contains(cohort.targets{1,1}, 'tract') && strcmp(cohort.simulationSettings.tractActivation, 'fiberwise')
        % Compute target activation and spill
        disp("Computing target activation")
        [pAct_target, pSpill_target, VTA] = ...
            computing_volumes(pat, head, tail, pat.VqTarget, target_lst, cohort);
        
        % Compute constraint activation and spill
        disp('Computing constraint activation')
        [pAct_constraint, pSpill_constraint, VTA] = ...
            computing_volumes(pat, head, tail, pat.VqConstraint, constraint_lst, cohort);
    else
        % Compute target activation and spill
        disp("Computing target activation")
        [pAct_target, pSpill_target, VTA] = ...
            computing_volumes(pat, head, tail, InitialSolution_cell, target_lst, cohort);
        
        % Compute constraint activation and spill
        disp('Computing constraint activation')
        [pAct_constraint, pSpill_constraint, VTA] = ...
            computing_volumes(pat, head, tail, InitialSolution_cell, constraint_lst, cohort);
    end
    
    %% Write array of recommendations
    wt = cohort.omega(1);
    wc = cohort.omega(2);
    ws = cohort.omega(3);
    scores = wt * pAct_target * 100 - wc * pAct_constraint * 100 - ws * pSpill_target * 100;
    
    [~, idx] = sort(scores, 'descend');
    
    % Write results to .txt
    filename = sprintf('Suggestions_%s_%s_%s_%d_%s.txt', ...
        pat.space, pat.hand, cohort.optischeme, pat.rel, ...
        cohort.simulationSettings.tractActivation);
    fid = fopen(fullfile(pat.outputPath, filename), 'w+');
    
    fprintf(fid, 'Contacts \t Target activation %s \t Constraint activation %s \t Spill %s \t Alpha \t VTA \t Score\n\n', '%', '%', '%');
    
    a = cell(length(idx), 7);
    for j = 1:length(idx)
        in = idx(j);
        a{j,1} = erase(pat.contactNames{in}, '.csv');
        a{j,2} = [9 num2str(round(pAct_target(in) * 100, 2))];
        a{j,3} = num2str(round(pAct_constraint(in) * 100, 2));
        a{j,4} = num2str(round(pSpill_target(in) * 100, 2));
        a{j,5} = num2str(round(pat.results.(cohort.optischeme).alpha(in), 2));
        a{j,6} = num2str(round(VTA(in), 2));
        a{j,7} = num2str(round(scores(in), 2));
        
        fprintf(fid, ' %s \t %s \t\t\t %s \t\t\t %s \t\t %s \t %s \t\t\t %s \n', ...
            a{j,1}, a{j,2}, a{j,3}, a{j,4}, a{j,5}, a{j,6}, a{j,7});
    end
    fclose(fid);
    
    %% Top suggestions for all relaxations
    top_filename = sprintf('Top_Suggestions_%s_%s_%s_%s.txt', ...
        pat.space, convertStringsToChars(pat.hand), cohort.optischeme, ...
        cohort.simulationSettings.tractActivation);
    fid = fopen(fullfile(pat.outputPath, top_filename), 'a');
    fprintf(fid, ' %s \t %s \t %s \t %s\t %s \t %s \t %s \n', ...
        a{1,1}, a{1,2}, a{1,3}, a{1,4}, a{1,5}, a{1,6}, a{1,7});
    fclose(fid);
    
    [bestScore, bestIdx] = max(str2double({a{:,7}}));
    if ~isfield(cohort, cohort.optischeme) || ~isfield(cohort.(cohort.optischeme), 'bestSolution')
        cohort.(cohort.optischeme).bestSolution = a(bestIdx, :);
    elseif bestScore > str2double(cohort.(cohort.optischeme).bestSolution{1,7})
        cohort.(cohort.optischeme).bestSolution = a(bestIdx, :);
    end
end

function write_LP_MILP_results_to_file(cohort, pat)
    %% Write LP/MILP results to file
    
    scheme = cohort.optischeme;  % 'LP' or 'MILP'
    hand_idx = find(strcmp({'sin', 'dx'}, pat.hand));
    
    fprintf('Writing %s results to file...\n', scheme);
    
    % Get results from cohort structure
    status = cohort.(scheme).status{pat.patientNo, hand_idx};
    
    % Main results file
    main_filename = sprintf('%s_Results_%s_%s_%s.txt', ...
        scheme, pat.space, pat.hand, cohort.simulationSettings.tractActivation);
    fid = fopen(fullfile(pat.outputPath, main_filename), 'w');
    
    % Write header
    fprintf(fid, '========================================\n');
    fprintf(fid, '%s OPTIMIZATION RESULTS\n', scheme);
    fprintf(fid, '========================================\n');
    fprintf(fid, 'Patient: %s\n', pat.name);
    fprintf(fid, 'Hemisphere: %s\n', pat.hand);
    fprintf(fid, 'Space: %s\n', pat.space);
    fprintf(fid, 'EThreshold: %.1f V/m\n', cohort.EThreshold);
    fprintf(fid, 'CThreshold: %.1f V/m\n', cohort.CThreshold);
    fprintf(fid, 'Status: %s\n', status);
    fprintf(fid, '========================================\n\n');
    
    if strcmp(status, 'INFEASIBLE')
        fprintf(fid, 'Problem is INFEASIBLE.\n');
        fprintf(fid, 'No solution found that satisfies all constraints.\n');
        fprintf(fid, 'Consider:\n');
        fprintf(fid, '  - Relaxing constraints (increase CThreshold or decrease EThreshold)\n');
        fprintf(fid, '  - Adjusting current limits (Imax_single, Imax_total)\n');
        fprintf(fid, '  - Checking if target is reachable\n\n');
        
        if strcmp(scheme, 'MILP')
            fprintf(fid, 'Unreachable target points: %s\n', cohort.MILP.Nunreachable{pat.patientNo, hand_idx});
            fprintf(fid, 'Total target points (Non): %d\n', cohort.MILP.Non{pat.patientNo, hand_idx});
            fprintf(fid, 'Total constraint points (Noff): %d\n', cohort.MILP.Noff{pat.patientNo, hand_idx});
        elseif strcmp(scheme, 'LP')
            fprintf(fid, 'Unreachable target points: %s\n', cohort.LP.Nunreachable{pat.patientNo, hand_idx});
        end
        
        fclose(fid);
        return;
    end
    
    %% Write feasible/optimal solution
    if strcmp(scheme, 'MILP')
        write_MILP_solution(fid, cohort, pat, hand_idx);
    elseif strcmp(scheme, 'LP')
        write_LP_solution(fid, cohort, pat, hand_idx);
    end
    
    fclose(fid);
    
    %% Write summary to top suggestions file
    top_filename = sprintf('Top_Suggestions_%s_%s_%s_%s.txt', ...
        pat.space, pat.hand, scheme, cohort.simulationSettings.tractActivation);
    
    fid_top = fopen(fullfile(pat.outputPath, top_filename), 'a');
    
    if strcmp(scheme, 'MILP')
        write_MILP_summary(fid_top, cohort, pat, hand_idx);
    elseif strcmp(scheme, 'LP')
        write_LP_summary(fid_top, cohort, pat, hand_idx);
    end
    
    fclose(fid_top);
    
    fprintf('%s results written successfully.\n', scheme);
end

function write_MILP_solution(fid, cohort, pat, hand_idx)
    %% Write MILP solution details
    
    result = cohort.MILP.results{pat.patientNo, hand_idx};
    x_opt = cohort.MILP.x{pat.patientNo, hand_idx};
    
    % Extract contact currents (first Ncontacts elements)
    Ncontacts = length(pat.contactNames);
    contact_currents = x_opt(1:Ncontacts);
    
    % Determine active contacts
    active_threshold = 0.01;  % mA threshold for considering contact active
    active_contacts = find(contact_currents > active_threshold);
    
    fprintf(fid, 'OPTIMAL STIMULATION PARAMETERS:\n');
    fprintf(fid, '----------------------------------------\n');
    fprintf(fid, 'Objective value: %.4f\n', result.objval);
    fprintf(fid, 'Total current: %.3f mA\n', sum(contact_currents));
    fprintf(fid, 'Number of active contacts: %d\n\n', length(active_contacts));
    
    fprintf(fid, 'CONTACT CONFIGURATION:\n');
    fprintf(fid, '%-20s %10s\n', 'Contact', 'Current (mA)');
    fprintf(fid, '----------------------------------------\n');
    
    for i = 1:Ncontacts
        if contact_currents(i) > active_threshold
            contact_name = erase(pat.contactNames{i}, '.csv');
            fprintf(fid, '%-20s %10.3f\n', contact_name, contact_currents(i));
        end
    end
    fprintf(fid, '\n');
    
    % Performance metrics
    Non = cohort.MILP.Non{pat.patientNo, hand_idx};
    Noff = cohort.MILP.Noff{pat.patientNo, hand_idx};
    Nude = cohort.MILP.Nude{pat.patientNo, hand_idx};
    Nmde = cohort.MILP.Nmde{pat.patientNo, hand_idx};
    focality = cohort.MILP.focality{pat.patientNo, hand_idx};
    inconsistency = cohort.MILP.inconsistency{pat.patientNo, hand_idx};
    
    fprintf(fid, 'PERFORMANCE METRICS:\n');
    fprintf(fid, '----------------------------------------\n');
    fprintf(fid, 'Target points (Non): %d\n', Non);
    fprintf(fid, 'Constraint points (Noff): %d\n', Noff);
    fprintf(fid, 'Missed target points (Nmde): %d (%.1f%%)\n', Nmde, 100 * Nmde / Non);
    fprintf(fid, 'Undesired activations (Nude): %d (%.1f%%)\n', Nude, 100 * Nude / Noff);
    fprintf(fid, 'Focality: %.3f\n', focality);
    fprintf(fid, 'Inconsistency: %.3f\n', inconsistency);
    fprintf(fid, 'Unreachable points: %s\n', cohort.MILP.Nunreachable{pat.patientNo, hand_idx});
    fprintf(fid, '\n');
    
    % Additional solver info
    if isfield(result, 'runtime')
        fprintf(fid, 'Solver runtime: %.2f seconds\n', result.runtime);
    end
    if isfield(result, 'itercount')
        fprintf(fid, 'Iterations: %d\n', result.itercount);
    end
end

function write_LP_solution(fid, cohort, pat, hand_idx)
    %% Write LP solution details
    
    result = cohort.LP.results{pat.patientNo, hand_idx};
    x_opt = cohort.LP.x{pat.patientNo, hand_idx};
    
    Ncontacts = length(pat.contactNames);
    
    % Determine active contacts
    active_threshold = 0.01;
    active_contacts = find(x_opt > active_threshold);
    
    fprintf(fid, 'OPTIMAL STIMULATION PARAMETERS:\n');
    fprintf(fid, '----------------------------------------\n');
    fprintf(fid, 'Objective value: %.4f\n', result.objval);
    fprintf(fid, 'Total current: %.3f mA\n', sum(x_opt));
    fprintf(fid, 'Number of active contacts: %d\n\n', length(active_contacts));
    
    fprintf(fid, 'CONTACT CONFIGURATION:\n');
    fprintf(fid, '%-20s %10s\n', 'Contact', 'Current (mA)');
    fprintf(fid, '----------------------------------------\n');
    
    for i = 1:Ncontacts
        if x_opt(i) > active_threshold
            contact_name = erase(pat.contactNames{i}, '.csv');
            fprintf(fid, '%-20s %10.3f\n', contact_name, x_opt(i));
        end
    end
    fprintf(fid, '\n');
    
    fprintf(fid, 'Unreachable target points: %s\n', cohort.LP.Nunreachable{pat.patientNo, hand_idx});
    fprintf(fid, '\n');
    
    % Additional solver info
    if isfield(result, 'runtime')
        fprintf(fid, 'Solver runtime: %.2f seconds\n', result.runtime);
    end
end

function write_MILP_summary(fid, cohort, pat, hand_idx)
    %% Write MILP summary line to top suggestions file
    
    status = cohort.MILP.status{pat.patientNo, hand_idx};
    
    if strcmp(status, 'INFEASIBLE')
        fprintf(fid, 'INFEASIBLE\t-\t-\t-\t-\t-\t-\n');
        return;
    end
    
    x_opt = cohort.MILP.x{pat.patientNo, hand_idx};
    Ncontacts = length(pat.contactNames);
    contact_currents = x_opt(1:Ncontacts);
    
    % Find active contacts
    active_threshold = 0.01;
    active_contacts = find(contact_currents > active_threshold);
    
    % Create contact string
    contact_str = '';
    for i = 1:length(active_contacts)
        idx = active_contacts(i);
        contact_name = erase(pat.contactNames{idx}, '.csv');
        if i > 1
            contact_str = [contact_str, '+'];
        end
        contact_str = [contact_str, contact_name, sprintf('(%.2f)', contact_currents(idx))];
    end
    
    % Get metrics
    Non = cohort.MILP.Non{pat.patientNo, hand_idx};
    Noff = cohort.MILP.Noff{pat.patientNo, hand_idx};
    Nmde = cohort.MILP.Nmde{pat.patientNo, hand_idx};
    Nude = cohort.MILP.Nude{pat.patientNo, hand_idx};
    focality = cohort.MILP.focality{pat.patientNo, hand_idx};
    inconsistency = cohort.MILP.inconsistency{pat.patientNo, hand_idx};
    
    target_coverage = 100 * (1 - Nmde / Non);
    constraint_violation = 100 * Nude / Noff;
    
    % Write summary line
    fprintf(fid, '%s\t%.1f\t%.1f\t-\t%.3f\t%.3f\t%.3f\n', ...
        contact_str, target_coverage, constraint_violation, ...
        sum(contact_currents), focality, inconsistency);
end

function write_LP_summary(fid, cohort, pat, hand_idx)
    %% Write LP summary line to top suggestions file
    
    status = cohort.LP.status{pat.patientNo, hand_idx};
    
    if strcmp(status, 'INFEASIBLE')
        fprintf(fid, 'INFEASIBLE\t-\t-\t-\t-\t-\n');
        return;
    end
    
    x_opt = cohort.LP.x{pat.patientNo, hand_idx};
    Ncontacts = length(pat.contactNames);
    
    % Find active contacts
    active_threshold = 0.01;
    active_contacts = find(x_opt > active_threshold);
    
    % Create contact string
    contact_str = '';
    for i = 1:length(active_contacts)
        idx = active_contacts(i);
        contact_name = erase(pat.contactNames{idx}, '.csv');
        if i > 1
            contact_str = [contact_str, '+'];
        end
        contact_str = [contact_str, contact_name, sprintf('(%.2f)', x_opt(idx))];
    end
    
    result = cohort.LP.results{pat.patientNo, hand_idx};
    
    % Write summary line
    fprintf(fid, '%s\t%.4f\t-\t-\t%.3f\t-\t-\n', ...
        contact_str, result.objval, sum(x_opt));
end