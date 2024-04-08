function [Vpoint,Epoint,Epointnorm]=EV_point(EFnear,rownames,point,noise,tol,method)
    % uses method of fundamental solutions to approximate the E-field on the
    % target points, given the atlas model E-field.To prevent singular
    % matrices, values under a certain threshold are removed in a singular
    % value decompositon. 
    %
    % Inputs
    % ------
    % EFnear = contains 8 different fields, which correspond to the different 
    %          contacts. Each field consists of a 24x8 double. 
    %          - 24 points, which are closest to target point 
    %          - 8 different values = x,y,z,V,Ex,Ey,Ez,Enorm 
    % rownames = different contact names corresponding to a simulation with
    %            one active contact and the remaining grounded
    % noise = some noise corresponding to a random deviation in the simulation
    % tol = tolerance indicating how small singular numbers can be accepted
    % point = coordinates of a specific point in the target area
    
    % Outputs
    % -------
    % Vpoint = electric potential at target point
    % Epoint = Ex, Ey and Ez at target point (used later on!)
    % Epointnorm = norm of E-field at target point 
    
    switch method
        
        case 'MFS'
            [Vpoint,Epoint,Epointnorm] = MFS(EFnear,rownames,point,noise,tol);
        case 'NNB'
            
            [Vpoint,Epoint,Epointnorm] = NNB_interpolation(EFnear,rownames);
    end
end

function [Vpoint,Epoint,Epointnorm] = NNB_interpolation(EFnear,rownames)
    for i =1:length(rownames)
        Vpoint.(rownames{i}) = EFnear{i}(1,4);
        Epoint.(rownames{i}) = EFnear{i}(1,5:7);
        Epointnorm.(rownames{i}) = EFnear{i}(1,8);
    end
end
