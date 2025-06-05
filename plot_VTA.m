function plot_VTA(cohort,pat)
     

if strcmp(cohort.optischeme,'MILP') | strcmp(cohort.optischeme,'LP')
    x = pat.results.(cohort.optischeme).(pat.hand).x(1:length(pat.contactNames));
    %VqTarget =  cell2mat(pat.VqTarget');
    %VqConstraint = cell2mat(pat.VqConstraint');
    F =  cell2mat(cellfun(@(x) x(:,8)', pat.InitialSolution_cell, 'UniformOutput', false))';
    y =  F*x;
    VTA = pat.FEMCoordinates(y>=cohort.EThreshold,:);
    plot(alphaShape(VTA(:,1:3)),'LineStyle','none','FaceAlpha',0.2,'FaceColor','r')
end

end
