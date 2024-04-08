function [pAct,pSpill,VTA] = ...
      computing_volumes(contactnames,head,tail,VEFStjude,alpha,coustjude,roi_lst,EFisolevel,nThreads)
% Compute coverage and spill of rois

% Input Arguments
% --------------
% head : 1x3 double representing the x y z lead head coordiantes
% tail : 1x3 double representing the x y z lead tail coordiantes
% VEFStjude : struct containing the comsol-model generated E-field for
% different contacts (one active, rest grounded)
% 
leadvector=(tail-head)/norm(head-tail);
vlead0=[0,0,1];    
r = vrrotvec(vlead0,leadvector);
R = vrrotvec2mat(r);

pAct = zeros(length(alpha),1);
pSpill = zeros(length(alpha),1);
VTA = zeros(length(alpha),1);

    parfor(m = 1:length(alpha),nThreads)
        EF = scaleEF(VEFStjude{m},alpha(m));
        [pAct(m),pSpill(m),VTA(m)] = volume_of_tissue_activated(EF,roi_lst,R,head,leadvector,EFisolevel);
       
    end

end


