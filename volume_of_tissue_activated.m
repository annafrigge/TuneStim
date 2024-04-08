function [p_act,p_spill,VTA] = volume_of_tissue_activated(EF,roi_lst,Rotation,head,leadvector,isolevel)

% Summary
% --------
% volume_of_tissue_activated computes the VTA for the entire domain, aswell
% as the VTA for certain structres of interest. The lead volume inside the
% VTA is removed. The VTA for each target structure is computed separately
% and then added together.
%
% Input:
% ------
% EF            :       compositioned electric field for optimal scaling factor alpha
% roi_lst       :       cell array with the target/constraint structures of
%                       interest
% Rotation      :       rotation matrix for lead orientation
% leadvector    :       head coordinate of lead
% head          :       the lead head coordinates
% isolevel      :       activation threshold * safetyMargin

% Output:
% ------
% pAact     :       percentage of activated target volume
% pSpill    :       percentage of spilled volume i.e. percentage of total volume
%                   activated that was not initially intended to be activated
% VTA       :       volume of tissue activated






%% Get total number of activated points 
% EF_activated contains all point with E-field larger than activation 
% threshold * safetyMargin

is_activated = (EF(:,8)>isolevel & ~isnan(EF(:,8)));
EF_activated = EF(is_activated,1:3);

% if there are fewer than 6 activated points, consider tissue to be
% completely unactivated

try
    [~,V_activated] = convhulln(EF_activated);
catch
    V_activated=0;
end

volActivatedMinusLead = volume_remove_lead(EF_activated,V_activated,Rotation,head,leadvector);


%% get activated points inside target

%target volume
Vol_total_target = 0;
VolActivatedTarget = 0;

for m=1:length(roi_lst)
    Vpoints =roi_lst{m};
    try
        [~,Vol_target]=convhull(Vpoints(:,1:3));  
    catch
        Vol_target=0;
    end

    VolTargetMinusLead = volume_remove_lead(Vpoints,Vol_target,Rotation,head,leadvector);
    

    is_in_target=inhull(EF_activated,Vpoints(:,1:3));
    A_in_target = EF_activated(is_in_target,:);
    

    try
    [~,Vol_A_target]=convhull(A_in_target);
    catch
    Vol_A_target = 0;
    end

   
    volumeActivatedTargetMinusLead = volume_remove_lead(A_in_target,Vol_A_target,Rotation,head,leadvector);
    
        
    VolActivatedTarget = VolActivatedTarget+volumeActivatedTargetMinusLead;
    Vol_total_target = Vol_total_target + VolTargetMinusLead;


end



%% compute activation percentages
%percentage of target activation
p_act = ( VolActivatedTarget/Vol_total_target );
p_spill = ( volActivatedMinusLead - VolActivatedTarget )/volActivatedMinusLead;

VTA = volActivatedMinusLead*10^9;
end


function vol_minus_lead = volume_remove_lead(Vpoints,volume,Rotation,head,leadvector)
    % lead stuff
    R_cyl= 0.00127/2;
    z_cyl=0.12;
    translation_factor = head - 2.25e-3 * leadvector;

    %overlapping cylinder points
    j=1;
    
    for row=1:size(Vpoints,1)
        P = (Rotation'*(Vpoints(row,1:3)- translation_factor)')';
        [theta,rho,z] = cart2pol(P(1),P(2),P(3));
        
        if rho <= R_cyl && z <= z_cyl && z >= 0
            overlapping_points(j,:) = Vpoints(row,1:3);
            j=j+1;
        end
    end
    
    try
        [~,volCyl]=convhull(overlapping_points);
    catch
        volCyl=0;
    end
    
    vol_minus_lead = volume-volCyl;


end

