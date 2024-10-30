function [c,ceq] = stimConstraint(alpha,Enorm,Eobj,relaxation)

% Constraint function for a specific value of the scaling factor alpha. 
% Input:
% alpha     = current scaling factor
% Enorm     = Enorm of constraint areas for unit pulse
% EFobjL    = target values (x,y,z,E-field) for the points in EFL          
% Output:
% c(x)      = array of nonlinear inequality constraints at x. fmincon 
%             attempts to satisfy c(x)<=0 for all entries of c.
% ceq(x)    = array of nonlinear equality constraints at x.

Escaled = alpha*Enorm;

diffs = Escaled-Eobj;

% sort the differences between scaled E-field and target E-field
diffs = sort(diffs);

n = length(diffs);
if relaxation == 0
    relaxation = 0.03;
end
nindex = floor(n*relaxation/100); % floor rounds toward negative infinity
                               % e.g. floor(3.4) = 3, floor(-10,1) = -11

% use the (almost) largest difference as basis for constraint 
c = [diffs(end-nindex) -alpha alpha-15];

ceq = [];