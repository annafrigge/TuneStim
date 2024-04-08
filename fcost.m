function J=fcost(alpha,EFnorm,EFobj,cou)
    % Returns cost of a stimulation scaled with the factor alpha.
    % Input arguments:
    % EF = 1xM struct. The struct contains eight field i.e. one for each 
    %      contact. Thus for each of the M points, the Ex,Ey and Ez component
    %      are given for each contact (other contacts grounded during
    %      computation).
    % EFobj = threshold value (electric field norm), (e.g. 200 V/m).
   


      % J is the accumulated cost for a specific value of alpha        
        J=0;
        n_points=size(EFnorm); % go through all points


        EFtest = alpha*EFnorm;
        
        for k = 1:n_points(1) 
              if EFobj < EFtest(k)
                J = J + (EFobj-EFtest(k))^2; 
              else
                J = J + (EFobj-EFtest(k));
              end
        end
        
end