function [c,ceq] = stimConstraint(alpha,EF_constraint,EFobj_constraint,cou)

% Constraint function for a specific value of the scaling factor alpha. 

% Input Arguments:
% ----------------
% alpha     = current scaling factor
% EFL       = coordinates of constraint areas (limbic and internal capsule) 
% EFobjL    = target values (x,y,z,E-field) for the points in EFL
% cou       = couplings constants to composition E-field from E-fields 
%             computed with all but one contact grounded                    
% Output:
% -------
% c(x)      = array of nonlinear inequality constraints at x. fmincon 
%             attempts to satisfy c(x)<=0 for all entries of c.
% ceq(x)    = array of nonlinear equality constraints at x.

%EFscaled = zeros(length(EF_constraint),8);
cs = zeros(length(EF_constraint),1);
contactnames = fieldnames(EF_constraint);
EFscaled = zeros(length(EF_constraint),4);
for k=1:length(EF_constraint)
    EFscaled(k,:) = scale_EF(EF_constraint(k),cou,alpha,contactnames);
    cs(k) = EFscaled(k,4) - EFobj_constraint;    % compare electric field (here 
                                            % column 4 corresponds to EF)
end


cs = sort(cs);

n = length(cs);
pConstraint = 0.9;
nindex = floor(n*pConstraint); % floor rounds toward negative infinity

% use the (almost) largest difference as basis for constraint 
c = cs(1:nindex);

ceq = [];

end