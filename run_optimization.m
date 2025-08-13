function [cohort, pat] = run_optimization(cohort,pat,VqTarget,VqConstraint, relaxation,cou,hand)

alpha      = zeros(1,size(cou,1));
J           = zeros(1,size(cou,1));


disp('Optimizing with constraints...')
options = optimoptions('linprog','Display','none');

%find optimal solution for each contact configuration
lower_bound = 0;
upper_bound = 10;

if strcmp(cohort.optischeme, 'MILP')
    % Transfer matrices for target and constraint points
    VqTarget =  cell2mat(VqTarget');
    VqConstraint = cell2mat(VqConstraint');
    Ncontacts = size(VqTarget,2);

    Non = size(VqTarget,1);
    Noff = size(VqConstraint,1);
    Imax_single = 5;
    Imax_total = 8;
    L = 20*cohort.EThreshold;
    Woff = cohort.omega(2);
    Won  = cohort.omega(1);
    % Remove unreachable points
    % Objective function: we want to maximize VqTarget * x
    % Define it as a handle function to minimize the negative objective.
    idx = ones(length(VqTarget),1);
    Imax_single = 5;
    for i = 1:length(VqTarget)
        % Objective function (linear)
        f = -VqTarget(i,:);  % Maximize VqTarget*x is equivalent to minimizing -VqTarget*x

        % Bounds on variables
        lb = zeros(Ncontacts, 1);  % Lower bounds
        ub = Imax_single * ones(Ncontacts, 1);  % Upper bounds

        linOptions = optimoptions("linprog");
        linOptions.Display = "off";
        % Solve the optimization problem using linprog
        [x_opt, fval] = linprog(f, [], [], [], [], lb, ub,linOptions);

        % Display results
        if -fval < cohort.EThreshold
            idx(i) = 0;

        end
    end

    % Remove points that are unreachable
    Nunreachable = num2str(length(idx)-sum(idx));
    disp(['Removing ', num2str(length(idx)-sum(idx)), ' unreachable points from set of target points.'])
    if sum(idx)==0
        disp(['No targets point within reach under given safety constraints.'])
    else
        VqTarget = VqTarget(logical(idx),:);
    end


    %% Using Gurobi instead of vanilla Matlab intlinprog
    f = [zeros(Ncontacts,1); Won*ones(Non,1)/Non;Woff*ones(Noff,1)/Noff];
    lb = zeros(length(f),1);
    ub = [Imax_single*ones(Ncontacts,1);ones(Non,1);ones(Noff,1)]; % binary slack variables

    % Construct the diagonal matrix
    diagonalBlock = [-L*ones(Non, 1); -L*ones(Noff, 1)];
    D = diag(diagonalBlock);

    % Combine the matrices
    A = [[-VqTarget; VqConstraint], D; ones(1,Ncontacts), zeros(1,Non+Noff)];
    b = [-cohort.EThreshold*ones(Non,1);cohort.CThreshold*ones(Noff,1);Imax_total];

    milpObj.A = sparse(A);  % Sparse matrix for efficiency
    milpObj.obj = f;        % Objective function
    milpObj.rhs = b;        % Right-hand side of constraints
    milpObj.sense = '<';    % All constraints are 'less than or equal to'
    milpObj.lb = lb;        % Lower bounds
    milpObj.ub = ub;        % Upper bounds
    milpObj.vtype = [repmat('C', Ncontacts, 1); repmat('I', Non+Noff, 1)];  % 'C' for continuous, or 'B' for binary/integer
    milpObj.modelsense = 'min';  % Minimize objective

    % Integer variables
    intcon = Ncontacts+1:length(f);
    %milpObj.vtype(intcon) = 'I';  % Set the appropriate variables as integer

    % Set Gurobi parameters
    params.outputflag = 1;  % Display output
    params.timelimit = 1500; % Set time limit [seconds]

    % Solve the optimization problem
    result = gurobi(milpObj, params);


    % Saving to file
    pat.results.MILP.(pat.hand) = result;
    cohort.MILP.status{pat.patientNo,hand} = result.status;
    if strcmp(result.status,'INFEASIBLE')
        % out.status = 'INFEASIBLE';
        cohort.MILP.results{pat.patientNo,hand} = {};
        cohort.MILP.x{pat.patientNo,hand} = {};
        cohort.MILP.Nude{pat.patientNo,hand} = {};
        cohort.MILP.focality{pat.patientNo,hand} = {};
    elseif (strcmp(result.status,'FEASIBLE') || strcmp(result.status,'OPTIMAL') || strcmp(result.status,'TIME_LIMIT'))
        % out.status = result.status;
        % out.x_milp_g = result.x;
        %out.x_elastic = x_elastic;
        %out.fval_g = result.objval;
        cohort.MILP.results{pat.patientNo,hand} = result;
        cohort.MILP.x{pat.patientNo,hand} = result.x;

        % Focality
        Nude = sum(result.x(Ncontacts+Non+1:end)); % Number of undesired excitations
        cohort.MILP.Nude{pat.patientNo,hand} = Nude;
        zeta = 0.5;
        focality = 1-(Nude/Noff)^zeta;
        cohort.MILP.focality{pat.patientNo,hand} = focality ;

        Nmde = sum(result.x(Ncontacts+1:end-Noff));  % Number of missed desired excitations
        cohort.MILP.Nmde{pat.patientNo,hand} = Nmde;
        % Inconsistency beta
        inconsistency = 0.5*(Nmde/Non + Nude/Noff);
        cohort.MILP.inconsistency{pat.patientNo,hand} = inconsistency ;
    end

    cohort.MILP.Nunreachable{pat.patientNo,hand} = num2str(length(idx)-sum(idx));
    cohort.MILP.Non{pat.patientNo,hand} = Non;
    cohort.MILP.Noff{pat.patientNo,hand} = Noff;

elseif strcmp(cohort.optischeme,'LP')
    VqTarget =  cell2mat(VqTarget');
    VqConstraint = cell2mat(VqConstraint');
    Ncontacts = size(VqTarget,2);

    Non = size(VqTarget,1);
    Noff = size(VqConstraint,1);
    Imax_single = 5;
    Imax_total = 8;
    idx = ones(length(VqTarget),1);
    Imax_single = 5;
    for i = 1:length(VqTarget)
        % Objective function (linear)
        f = -VqTarget(i,:);  % Maximize VqTarget*x is equivalent to minimizing -VqTarget*x

        % Bounds on variables
        lb = zeros(Ncontacts, 1);  % Lower bounds
        ub = Imax_single * ones(Ncontacts, 1);  % Upper bounds

        linOptions = optimoptions("linprog");
        linOptions.Display = "off";
        % Solve the optimization problem using linprog
        [x_opt, fval] = linprog(f, [], [], [], [], lb, ub,linOptions);

        % Display results
        if -fval < cohort.EThreshold
            idx(i) = 0;

        end
    end

    % Remove points that are unreachable
    Nunreachable = num2str(length(idx)-sum(idx));
    disp(['Removing ', num2str(length(idx)-sum(idx)), ' unreachable points from set of target points.'])
    if sum(idx)==0
        disp(['No targets point within reach under given safety constraints.'])
    else
        VqTarget = VqTarget(logical(idx),:);
    end

    LPmodel.obj = sum(VqTarget,1);

    % Un-relaxed LP formulation
    LPmodel.A = sparse([VqConstraint;ones(1,Ncontacts)]);
    LPmodel.rhs = [ones(size(LPmodel.A,1)-1,1)*cohort.CThreshold;Imax_total];
    LPmodel.sense = '<';
    LPmodel.modelsense = 'max';
    LPmodel.lb = zeros(Ncontacts,1);
    LPmodel.ub = ones(Ncontacts,1)*Imax_single;

    LPresult = gurobi(LPmodel);

    pat.results.LP.(pat.hand) = LPresult;
    cohort.LP.status{pat.patientNo,hand} = LPresult.status;
    if strcmp(LPresult.status,'INFEASIBLE')
        cohort.LP.results{pat.patientNo,hand} = {};
    elseif strcmp(LPresult.status,'FEASIBLE') || strcmp(LPresult.status,'OPTIMAL')
        cohort.LP.results{pat.patientNo,hand} = LPresult;
        cohort.LP.x{pat.patientNo,hand} = LPresult.x;
    end
    cohort.LP.Nunreachable{pat.patientNo,hand} = num2str(length(idx)-sum(idx));

    % LP problem with relaxation based on slack from unrelaxed solution
    thetas = linspace(0,1,6); % % of points need to fullfill the constraint
    cohort.LPrelaxed.thetas = thetas;
    [~,sortedIdx] = sort(LPresult.slack(1:end-1),'descend');
    VqConstraintSorted = VqConstraint(sortedIdx,:);

    for rel=1:length(thetas)
        VqConstraintRelaxed = VqConstraintSorted(1:floor(thetas(rel)*length(VqConstraintSorted)),:); % Remove constraint points according to relaxation

        LPmodelR.obj = sum(VqTarget,1);
        LPmodelR.A = sparse([VqConstraintRelaxed;ones(1,Ncontacts)]);
        LPmodelR.rhs = [ones(size(LPmodelR.A,1)-1,1)*cohort.CThreshold;Imax_total];
        LPmodelR.sense = '<';
        LPmodelR.modelsense = 'max';
        LPmodelR.lb = zeros(Ncontacts,1);
        LPmodelR.ub = ones(Ncontacts,1)*Imax_single;

        LPresultR = gurobi(LPmodelR);

        cohort.LPrelaxed.status{pat.patientNo,hand,rel} = LPresultR.status;
        if strcmp(LPresultR.status,'INFEASIBLE')
            cohort.LPrelaxed.results{pat.patientNo,hand,rel} = {};
        elseif strcmp(LPresultR.status,'FEASIBLE') || strcmp(LPresultR.status,'OPTIMAL')
            cohort.LPrelaxed.results{pat.patientNo,hand} = LPresultR;
            cohort.LPrelaxed.x{pat.patientNo,rel} = LPresultR.x;
            % Linear programming Nuda, Nmde, Inconsistency
            NudaLP = sum(VqConstraint*LPresultR.x>cohort.CThreshold);
            NmdaLP = sum(VqTarget*LPresultR.x<cohort.EThreshold);
            cohort.LPrelaxed.Nuda{pat.patientNo,hand,rel} = NudaLP;
            cohort.LPrelaxed.Nmda{pat.patientNo,hand,rel} = NmdaLP;
            cohort.LPrelaxed.inconsistency{pat.patientNo,hand,rel} = 0.5*(NmdaLP/Non + NudaLP/Noff);
        end
    end

elseif strcmp(cohort.optischeme,'Nonlinear')
    %% Assigning target values for STN_motor, STN_limbic and internal capsule
    %Enorm_obj_target = [target_coord; ones(length(target_coord),1)*EFobj_target];
    %Enorm_obj_constraint = [constraint_coord; ones(length(target_coord),1)*EFobj_target];

    options = optimset('Display','off','LargeScale','off','MaxFunEvals',100,'PlotFcns',@optimplotfval);
    alpha0 = 1; % initial scaling factor
    for m=1:length(alpha)    
    [alpha(m),J(m)]=fmincon(@(x)fcost(x,...
                              VqTarget{m}',cohort.EThreshold),...
                              alpha0,[],[],[],[],[],[],...
                              @(x)stimConstraint(x,VqConstraint{m},...
                              cohort.CThreshold,relaxation),options); 
    end
    pat.results.Nonlinear.alpha = alpha;
    pat.results.Nonlinear.J = J;
    cohort.results.Nonlinear = pat.results.Nonlinear;
elseif strcmp(cohort.optischeme,'Linear')
    % Relaxation percentage of points are allowed to exceed the threshold
    for m=1:length(alpha)

        b = cohort.CThreshold;

        sort_EF_constraint = sort(VqConstraint{m});
        n = length(sort_EF_constraint);
        pConstraint = 1-relaxation/100;
        nindex = floor(n*pConstraint);
        A = sort_EF_constraint(nindex);

        f = -sum(VqTarget{m}');

        [alpha(m),J(m)] = linprog(f,A,b,[],[],lower_bound,upper_bound,options);
    end
    pat.results.Linear.alpha = alpha;
    pat.results.Linear.J = J;
    cohort.results.Linear = pat.results.Linear;

elseif strcmp(cohort.optischeme,'mincov')
    for m=(1:length(alpha))
        b = -cohort.EThreshold;
        sort_EF_target = sort(VqTarget{m},'descend');
        n = length(sort_EF_target);
        pTarget = relaxation/100; % how much of target points covered
        nindex = floor(n*pTarget);
        A = -sort_EF_target(nindex);
        f = sum(VqConstraint{m}); % minimizing constraint coverage
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
    pat.results.mincov.alpha = alpha;
    pat.results.mincov.J = J;
    cohort.results.mincov = pat.results.mincov;
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
end
