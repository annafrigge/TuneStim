function J=fcost(alpha,EFnorm,EFobj)
    % Returns cost of a stimulation scaled with the factor alpha.
    % Input arguments:
    % EFnorm = 1xM struct. The struct contains eight field i.e. one for each 
    %      contact. Thus for each of the M points, the Ex,Ey and Ez component
    %      are given for each contact (other contacts grounded during
    %      computation).
    % EFobj = threshold value (electric field norm), (e.g. 200 V/m).
   J=0;
    if alpha(1)<=0 || alpha(1)>15
        J=1e30;
    else
        
      % J is the accumulated cost for a specific value of alpha        
        
        n_points=size(EFnorm); % go through all points


        EFtest = alpha*EFnorm;

        for k = 1:n_points(1)
            diff = EFobj - EFtest(k);
            J = J + (diff < 0) * diff^2 + (diff >= 0) * diff;
        end

    end