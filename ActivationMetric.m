% ActivationMetric.m
classdef ActivationMetric
    % Abstract class for different activation metrics
    
    properties
        name
        target_threshold      % For target activation (was EThreshold)
        constraint_threshold  % For constraint avoidance (was CThreshold)
    end
    
    methods (Abstract)
        % Must be implemented by subclasses
        values = compute(obj, solution_data, fiber_directions)
        required_fields = get_required_solution_fields(obj)
    end
    
    methods
        % Convenience methods to get appropriate threshold
        function thresh = get_target_threshold(obj)
            thresh = obj.target_threshold;
        end
        
        function thresh = get_constraint_threshold(obj)
            thresh = obj.constraint_threshold;
        end
    end
end