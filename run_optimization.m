function [alpha, J] = run_optimization(optischeme,EFobj_target,EnormTarget,...
                          EFobj_constraint,EnormConstraint, relaxation)

cou = eye(19); % adjust to number of tested configurations!
alpha      = zeros(1,size(cou,1));
J           = zeros(1,size(cou,1));


disp('Optimizing with constraints...')
options = optimoptions('linprog','Display','none');

%find optimal solution for each contact configuration
lower_bound = 0;
upper_bound = 10;


if strcmp(optischeme,'conservative')
    for m=1:length(alpha)

        b = EFobj_constraint;

        sort_EF_constraint = sort(EnormConstraint{m});
        n = length(sort_EF_constraint);
        pConstraint = 1-relaxation/100;
        nindex = floor(n*pConstraint);
        A=sort_EF_constraint(nindex);

        f = -sum(EnormTarget{m});

        [alpha(m),J(m)] = linprog(f,A,b,[],[],lower_bound,upper_bound,options);
    end

elseif strcmp(optischeme,'mincov')
    for m=(1:length(alpha))
        b = -EFobj_target;
        sort_EF_target = sort(EnormTarget{m},'descend');
        n = length(sort_EF_target);
        pTarget = 1-relaxation/100; % how much of target points covered
        nindex = floor(n*pTarget);
        A = -sort_EF_target(nindex);
        f = sum(EnormConstraint{m}); % minimizing constraint coverage

        [alpha(m),J(m)] = linprog(f,A,b,[],[],lower_bound,upper_bound,options);
    end
end

end