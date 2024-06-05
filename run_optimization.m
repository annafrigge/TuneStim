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
    Enorm_obj_target = [target_coord; ones(length(target_coord),1)*EFobj_target];
    Enorm_obj_constraint = [constraint_coord; ones(length(target_coord),1)*EFobj_target];

    options = optimset('Display','off','LargeScale','off','MaxFunEvals',100,'PlotFcns',@optimplotfval);
    alpha0 = 1; % initial scaling factor
    
    for m=1:length(alpha)
    [alpha(m),J(m)]=fmincon(@(x)fcost_simple_v2_alpha(x,...
                              EnormTarget,Enorm_obj_target,alpha(m,:)'),...
                              alpha0,[],[],[],[],[],[],...
                              @(x)stimConstraint(x,EnormConstraint,...
                              Enorm_obj_constraint,alpha(m,:)'),options); 
    end
if strcmp(optischeme,'Ruben2')
    % Relaxation adjusts E-field threshold for constraints
    for m=1:length(alpha)
        b = EFobj_constraint*(1+relaxation/100);
        sort_EF_constraint = sort(EnormConstraint{m});
        nindex = length(sort_EF_constraint);

        A = sort_EF_constraint(nindex);

        f = -sum(EnormTarget{m});

        [alpha(m),J(m)] = linprog(f,A,b,[],[],lower_bound,upper_bound,options);
    end


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

        [alpha(m),J(m)] = linprog(f,A,b,[],[],lower_bound,upper_bound,options);
    end
end

end