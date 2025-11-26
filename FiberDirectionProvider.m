% New file: FiberDirectionProvider.m
classdef FiberDirectionProvider
    % Provides fiber directions from different sources
    
    methods (Static)
        function fiber_dirs = get_fiber_directions(source, coords, pat, cohort)
            % Get fiber directions based on source
            % source: 'from_fibers', 'from_DTI', 'uniform'
            
            switch source
                case 'from_fibers'
                    fiber_dirs = FiberDirectionProvider.from_fiber_tracts(...
                        coords, pat, cohort);
                    
                case 'from_DTI'
                    fiber_dirs = FiberDirectionProvider.from_DTI_data(...
                        coords, pat);
                    
                case 'uniform'
                    % Default: uniform direction (e.g., along z-axis)
                    fiber_dirs = repmat([0, 0, 1], size(coords, 1), 1);
                    
                otherwise
                    error('Unknown fiber direction source: %s', source);
            end
            
            % Normalize
            fiber_dirs = fiber_dirs ./ vecnorm(fiber_dirs, 2, 2);
        end
        
        function fiber_dirs = from_fiber_tracts(coords, pat, cohort)
            % Extract fiber directions from fiber tract data
            
            load(fullfile(pat.path, 'atlases', cohort.atlas, ...
                'neurostructures.mat'), 'region');
            
            fibers = concat_fibertracts(region, pat, cohort.targets, pat.hand);
            
            % Compute tangent vectors along fibers
            fiber_dirs = compute_fiber_tangents(fibers, coords);
        end
        
        function fiber_dirs = from_DTI_data(coords, pat)
            % Load fiber directions from DTI/conductivity data
            
            % Load conductivity tensor (should already be available)
            if isfield(pat, 'conductivity_map')
                sigma_data = pat.conductivity_map;
            else
                % Load from file
                sigma_file = fullfile(pat.path, 'conductivity_tensor.mat');
                if exist(sigma_file, 'file')
                    load(sigma_file, 'sigma_xx', 'sigma_yy', 'sigma_zz', ...
                        'sigma_xy', 'sigma_xz', 'sigma_yz', 'coords_sigma');
                else
                    error('Conductivity data not found');
                end
            end
            
            % Interpolate conductivity to query points
            sigma_xx_interp = interpolate_to_coords(coords_sigma, sigma_xx, coords);
            sigma_yy_interp = interpolate_to_coords(coords_sigma, sigma_yy, coords);
            sigma_zz_interp = interpolate_to_coords(coords_sigma, sigma_zz, coords);
            sigma_xy_interp = interpolate_to_coords(coords_sigma, sigma_xy, coords);
            sigma_xz_interp = interpolate_to_coords(coords_sigma, sigma_xz, coords);
            sigma_yz_interp = interpolate_to_coords(coords_sigma, sigma_yz, coords);
            
            % Compute principal eigenvector (fiber direction)
            fiber_dirs = compute_principal_eigenvector(...
                sigma_xx_interp, sigma_yy_interp, sigma_zz_interp, ...
                sigma_xy_interp, sigma_xz_interp, sigma_yz_interp);
        end
    end
end