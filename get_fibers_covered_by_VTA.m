function [afibs,Pafibs] = get_fibers_covered_by_VTA(fibs,Enorm_fibs,EThresh)


% if Nsamples <max(fibs(:,4))
%     indices = randperm(max(fibs(:,4)), Nsamples); % Randomly select N indices
%     sampled_fibs = fibs(ismember(fibs(:, 4), indices), :);
% else
%     sampled_fibs = fibs;
% end

%Enorm_fibs = mphinterp(model,'ec.normE','coord',sampled_fibs(:,1:3)','dataset','dset1');
afibs = unique(fibs(Enorm_fibs>=EThresh,4));
Pafibs = 100*numel(afibs)/max(fibs(:,4)); % Percent activated fibers
end