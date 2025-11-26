function [pAct,pSpill,VTA] = ...
      computing_volumes(pat,head,tail,Vq,roi_lst,cohort)
% Compute coverage and spill of rois

% Input Arguments
% --------------
% head : 1x3 double representing the x y z lead head coordiantes
% tail : 1x3 double representing the x y z lead tail coordiantes
% VEFStjude : struct containing the comsol-model generated E-field for
% different contacts (one active, rest grounded)
% 
alpha = pat.results.(cohort.optischeme).alpha;
leadvector = (tail-head)/norm(head-tail);
vlead0=[0,0,1];    
r = vrrotvec(vlead0,leadvector);
R = vrrotvec2mat(r);

pAct = zeros(length(alpha),1);
pSpill = zeros(length(alpha),1);
VTA = zeros(length(alpha),1);


if contains(cohort.targets{1,1},'tract') & strcmp(cohort.simulationSettings.tractActivation,'fiberwise')
    for m=1:length(alpha)
        pAct(m) = sum(Vq{m,1}*alpha(m) > cohort.EThreshold)/length(Vq{m,1});
        pSpill(m) = 0;
        VTA(m) = NaN;
    end
else
    for m=1:length(alpha)
        EF = scaleEF(Vq{m},alpha(m));
        [pAct(m),pSpill(m),VTA(m)] = volume_of_tissue_activated(EF,roi_lst,R,head,leadvector,cohort.EThreshold);
    end
end

end


