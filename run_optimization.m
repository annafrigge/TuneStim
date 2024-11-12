function [alpha, J] = run_optimization(cohort,EnormTarget,EnormConstraint, relaxation,cou)

alpha      = zeros(1,size(cou,1));
J           = zeros(1,size(cou,1));


disp('Optimizing with constraints...')
options = optimoptions('linprog','Display','none');

%find optimal solution for each contact configuration
lower_bound = 0;
upper_bound = 10;

if strcmp(cohort.optischeme,'Nonlinear')
    %% Assigning target values for STN_motor, STN_limbic and internal capsule
    %Enorm_obj_target = [target_coord; ones(length(target_coord),1)*EFobj_target];
    %Enorm_obj_constraint = [constraint_coord; ones(length(target_coord),1)*EFobj_target];

    options = optimset('Display','off','LargeScale','off','MaxFunEvals',100,'PlotFcns',@optimplotfval);
    alpha0 = 1; % initial scaling factor
    for m=1:length(alpha)    
    [alpha(m),J(m)]=fmincon(@(x)fcost(x,...
                              EnormTarget{m},cohort.EThreshold),...
                              alpha0,[],[],[],[],[],[],...
                              @(x)stimConstraint(x,EnormConstraint{m},...
                              cohort.CThreshold,relaxation),options); 
    end

elseif strcmp(cohort.optischeme,'Linear')
    % Relaxation percentage of points are allowed to exceed the threshold
    for m=1:length(alpha)

        b = cohort.CThreshold;

        sort_EF_constraint = sort(EnormConstraint{m});
        n = length(sort_EF_constraint);
        pConstraint = 1-relaxation/100;
        nindex = floor(n*pConstraint);
        A = sort_EF_constraint(nindex);

        f = -sum(EnormTarget{m});

        [alpha(m),J(m)] = linprog(f,A,b,[],[],lower_bound,upper_bound,options);
    end

elseif strcmp(cohort.optischeme,'mincov')
    for m=(1:length(alpha))
        b = -cohort.EThreshold;
        sort_EF_target = sort(EnormTarget{m},'descend');
        n = length(sort_EF_target);
        pTarget = relaxation/100; % how much of target points covered
        nindex = floor(n*pTarget);
        A = -sort_EF_target(nindex);
        f = sum(EnormConstraint{m}); % minimizing constraint coverage
        try
            [alpha(m),J(m)] = linprog(f,A,b,[],[],lower_bound,upper_bound,options);
        catch ME
            %if(strcmp(ME.identifier,'MATLAB:matrix:singleSubscriptNumelMismatch'))
            %    disp(append('Optimization not solvable for relaxations larger than ', num2str(relaxation)))
            %end
            alpha(m) = NaN;
            J(m) = NaN;
            continue
        end

    end
elseif strcmp(cohort.optischeme,'simple')
    %find optimal solution for each contact configuration

    lower_bound = 0;
    upper_bound = 1;
    b = cohort.CThreshold; 
    sort_EF_constraint = sort(EnormConstraint{m});
    n = length(sort_EF_constraint);
    pConstraint = 1-relaxation/100;
    nindex = floor(n*pConstraint);
    %A = [sort_EF_constraint(nindex); %  

    %f = -[
    [alpha(m),J(m)] = linprog(f,A,b,[],[],lower_bound,upper_bound,options);

end

end

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
end


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
end

