function [EF_nearest,test_point] = nearest_EF(VEF,EF_coords,point)

% Abstract
% -------------
% The function nearest_EF finds the (n+1) nearest neighbors among the
% points in EF_coords to a point, and then returns the corresponding
% electric data for different FEM-simulations saved in the cell array VEF.
%
% Input arguments
% ---------------
% VEF:          cell array with cells corresponding to each mono-contact generated
%               electrical field
%
% EF_coords:    the grid coordinates of the FEM-generated solution
%
% 
%
% point:        1x3 array with the coordinates to the point the closest VEF-points
%               are obtained

% Outputs
% -------
% EF_nearest :  struct with 8 fields corresponding to each contact. Each
%               field consists of a 24x8 array: 24 closest points andd their
%               corresponding x,y,z,Ex,Ey,Ez,Enorm and V
% test_point :   the (n+1)th closest neighbor to point, used to verify that
%               MFS is not making 'too' errorenous approximations
    
    n=24;
    N = length(EF_coords);
    point_array = repmat(point,N,1);

    % get distance between point and each point in EF_coords
    EF_dist=sqrt(sum((EF_coords-point_array).^2,2));  
    
    % get 24 shortest distances and the corresponding index
    [distances,indices] = mink(EF_dist,n+1);
    
    MFS_indices = indices(1:n);
    test_index=indices(n+1);
    
    % initialise EF_nearest and test_point
    EF_nearest=cell(length(VEF),1);
    test_point=cell(length(VEF),1);

    for k=1:length(VEF)
            EF_nearest{k}(1:n,:) = VEF{k}(MFS_indices,:);
            test_point{k}(1,:) = VEF{k}(test_index,:); 
    end
    
    
end