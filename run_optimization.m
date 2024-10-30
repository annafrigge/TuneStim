function [alpha, J] = run_optimization(optischeme,EFobj_target,EnormTarget,...
                          EFobj_constraint,EnormConstraint, relaxation,cou)

alpha      = zeros(1,size(cou,1));
J           = zeros(1,size(cou,1));


disp('Optimizing with constraints...')
options = optimoptions('linprog','Display','none');

%find optimal solution for each contact configuration
lower_bound = 0;
upper_bound = 10;

if strcmp(optischeme,'Ruben')
    %% Assigning target values for STN_motor, STN_limbic and internal capsule
    %Enorm_obj_target = [target_coord; ones(length(target_coord),1)*EFobj_target];
    %Enorm_obj_constraint = [constraint_coord; ones(length(target_coord),1)*EFobj_target];

    options = optimset('Display','off','LargeScale','off','MaxFunEvals',100,'PlotFcns',@optimplotfval);
    alpha0 = 1; % initial scaling factor
    for m=1:length(alpha)    
    [alpha(m),J(m)]=fmincon(@(x)fcost(x,...
                              EnormTarget{m},EFobj_target),...
                              alpha0,[],[],[],[],[],[],...
                              @(x)stimConstraint(x,EnormConstraint{m},...
                              EFobj_constraint,relaxation),options); 
    end
elseif strcmp(optischeme,'tt')
        % Initial guess for lambda
    alpha0 = 1; % You can start with a value of 1 for scaling factor lambda.
    TargetCoords = EnormTarget{1,2};
    ConstraintCoords = EnormConstraint{1,2};
    % Optimization options
    %options = optimset('Display', 'iter', 'Algorithm', 'interior-point');
    options = optimset('Display','off','LargeScale','off','MaxFunEvals',100,'PlotFcns',@optimplotfval);
    for m=(1:length(alpha))
        [alpha(m), J(m)] = patternsearch(@(x)fcost_tt(x, EnormTarget{m},TargetCoords, EFobj_target), ...
                                alpha0, [], [], [], [], lower_bound, upper_bound, ... % Bound lambda between 0 and 15
                                @(x)xstimconstraint_tt(x, EnormConstraint{m}, ConstraintCoords, EFobj_constraint,relaxation));
    end

    % Ill-posed problem, neither linear, quadratic, nor convex!!!
elseif strcmp(optischeme,'conservative')
    % Relaxation percentage of points are allowed to exceed the threshold
    for m=1:length(alpha)

        b = EFobj_constraint;

        sort_EF_constraint = sort(EnormConstraint{m});
        n = length(sort_EF_constraint);
        pConstraint = 1-relaxation/100;
        nindex = floor(n*pConstraint);
        A = sort_EF_constraint(nindex);

        f = -sum(EnormTarget{m});

        [alpha(m),J(m)] = linprog(f,A,b,[],[],lower_bound,upper_bound,options);
    end

elseif strcmp(optischeme,'mincov')
    for m=(1:length(alpha))
        b = -EFobj_target;
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
elseif strcmp(optischeme,'simple')
    %find optimal solution for each contact configuration

    lower_bound = 0;
    upper_bound = 1;
    b = EFobj_constraint; 
    sort_EF_constraint = sort(EnormConstraint{m});
    n = length(sort_EF_constraint);
    pConstraint = 1-relaxation/100;
    nindex = floor(n*pConstraint);
    %A = [sort_EF_constraint(nindex); %  

    %f = -[
    [alpha(m),J(m)] = linprog(f,A,b,[],[],lower_bound,upper_bound,options);

end

end

function J = fcost_tt(alpha, E_target,TargetCoords, E_thresh)

Nt = max(TargetCoords(:,4));  % Number of fibers in the target tract
f_k = zeros(Nt, 1);     % Binary values for each fiber

% Loop over all fibers in the target fiber tract
for k = 1:Nt
    % Check if any point in the fiber exceeds the threshold
    idx = TargetCoords(:,4)==k;
    if any(alpha * E_target(idx) > E_thresh)
        f_k(k) = 1;  % Activate fiber
    end
end

% Since we are maximizing, the cost is negative of the sum of activated fibers
J = -sum(f_k);  % fmincon minimizes, so we use -sum(f_k) to maximize
end

function [c, ceq] = xstimconstraint_tt(alpha, E_constraint, ConstraintCoords, E_thresh,relaxation)
    Nc = max(ConstraintCoords(:,4));  % Number of fibers in the constraint tract
    f_c = zeros(Nc, 1);     % Binary values for each fiber
    
    % Loop over all fibers in the target fiber tract
    for k = 1:Nc
        % Check if any point in the fiber exceeds the threshold
        idx = ConstraintCoords(:,4)==k;
        if any(alpha * E_constraint(idx) > E_thresh)
            f_c(k) = 1;  % Activate fiber
        end
    end
    
    c = sum(f_c) - 0.2 * floor(Nc);  % Inequality constraint: activated_points <= 0.5 * Nc
    ceq = [];  % No equality constraints
end
