% ActivatingFunctionMetric.m
classdef ActivatingFunctionMetric < ActivationMetric
    
    properties
        method  % 'from_E' or 'from_V'
    end
    
    methods
        function obj = ActivatingFunctionMetric(target_thresh, constraint_thresh, method)
            % Constructor with both thresholds
            obj.name = 'AF_tan';
            obj.target_threshold = target_thresh;      % For targets
            obj.constraint_threshold = constraint_thresh; % For constraints
            obj.method = method;
            if nargin < 3
                obj.method = 'from_E';  % Default
            end
        end
        
        function values = compute(obj, solution_data, fiber_directions)
            % Returns absolute value of AF
            % Thresholding applied separately for targets vs constraints
            
            if strcmp(obj.method, 'from_E')
                values = obj.compute_AF_from_E(solution_data, fiber_directions);
            else
                values = obj.compute_AF_from_V(solution_data, fiber_directions);
            end
            
            % Return absolute value (both positive and negative AF can activate)
            values = abs(values);
        end
        
        function fields = get_required_solution_fields(obj)
            if strcmp(obj.method, 'from_E')
                fields = {'coordinates', 'Ex', 'Ey', 'Ez'};
            else
                fields = {'coordinates', 'Vxx', 'Vyy', 'Vzz', 'Vxy', 'Vxz', 'Vyz'};
            end
        end
        
        function AF = compute_AF_from_E(obj, solution_data, fiber_dirs)
            % Compute AF from E-field components
            coords = solution_data(:, 1:3);
            Ex = solution_data(:, 4);
            Ey = solution_data(:, 5);
            Ez = solution_data(:, 6);
            
            nx = fiber_dirs(:, 1);
            ny = fiber_dirs(:, 2);
            nz = fiber_dirs(:, 3);
            
            AF = obj.compute_directional_derivative(coords, Ex, Ey, Ez, nx, ny, nz);
        end
        
        function AF = compute_AF_from_V(obj, solution_data, fiber_dirs)
            % Compute AF from Hessian: AF = -n^T * H * n
            Vxx = solution_data(:, 9);
            Vyy = solution_data(:, 10);
            Vzz = solution_data(:, 11);
            Vxy = solution_data(:, 12);
            Vxz = solution_data(:, 13);
            Vyz = solution_data(:, 14);
            
            nx = fiber_dirs(:, 1);
            ny = fiber_dirs(:, 2);
            nz = fiber_dirs(:, 3);
            
            AF = -(nx.^2 .* Vxx + ny.^2 .* Vyy + nz.^2 .* Vzz + ...
                   2*nx.*ny .* Vxy + 2*nx.*nz .* Vxz + 2*ny.*nz .* Vyz);
        end
        
        function dF = compute_directional_derivative(obj, coords, Ex, Ey, Ez, nx, ny, nz)
            % Numerical differentiation of E-field
            h = 1e-6;  % Step size
            
            Fx = scatteredInterpolant(coords, Ex, 'linear', 'none');
            Fy = scatteredInterpolant(coords, Ey, 'linear', 'none');
            Fz = scatteredInterpolant(coords, Ez, 'linear', 'none');
            
            % Compute directional derivative along fiber
            dEx_ds = (Fx(coords + h*[nx, zeros(size(nx)), zeros(size(nx))]) - ...
                      Fx(coords - h*[nx, zeros(size(nx)), zeros(size(nx))])) / (2*h);
            dEy_ds = (Fy(coords + h*[zeros(size(ny)), ny, zeros(size(ny))]) - ...
                      Fy(coords - h*[zeros(size(ny)), ny, zeros(size(ny))])) / (2*h);
            dEz_ds = (Fz(coords + h*[zeros(size(nz)), zeros(size(nz)), nz]) - ...
                      Fz(coords - h*[zeros(size(nz)), zeros(size(nz)), nz])) / (2*h);
            
            dF = -(nx .* dEx_ds + ny .* dEy_ds + nz .* dEz_ds);
        end
    end
end