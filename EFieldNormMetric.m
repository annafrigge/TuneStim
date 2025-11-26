% EFieldNormMetric.m
classdef EFieldNormMetric < ActivationMetric
    
    methods
        function obj = EFieldNormMetric(target_thresh, constraint_thresh)
            % Constructor with both thresholds
            obj.name = 'EF_norm';
            obj.target_threshold = target_thresh;      % EThreshold
            obj.constraint_threshold = constraint_thresh; % CThreshold
        end
        
        function values = compute(obj, solution_data, ~)
            % Use column 8 (existing E-field norm)
            % Returns raw values - thresholding done elsewhere
            values = solution_data(:, 8);
        end
        
        function fields = get_required_solution_fields(obj)
            fields = {'coordinates', 'E_norm'};  % columns 1-3, 8
        end
    end
end