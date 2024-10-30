function distance_contacts_to_target(Vol_target,head,tail)
% Inputs:
% target_points: Coordinates of target structure
% head and tail: lead coordinates
% lead type: ONLY works for short Abbott directed and short Boston Scientific
% directed

%% Step 0: Compute centroid of target
centro = polygonCentroid3d(Vol_target(:,1:3));
%scatter3(centro(1),centro(2),centro(3),20,'filled','MarkerFaceColor','red')
%hold on 
%scatter3(Vol_target(:,1),Vol_target(:,2),Vol_target(:,3),5,'filled')

%% Step 1: Compute distance target centroid - middelpoint of contact row

lead_vector = (tail-head)/norm(tail-head);

% mid contact coordinates, when lowest contact row is placed at head
% coordinates. Due to nonlinear warp from native to MNI space, contact
% positions in MNI space to not necessarily match
mid_contact_coord = [head; head+1.5e-3*lead_vector; head+3e-3*lead_vector; head+4.5e-3*lead_vector;];
% scatter3(head(1),head(2),head(3),20,'filled','MarkerFaceColor','r')
% hold on
% scatter3(tail(1),tail(2),tail(3),20,'filled','MarkerFaceColor','b')
% hold on
% scatter3(mid_contact_coord(2:4,1),mid_contact_coord(2:4,2),mid_contact_coord(2:4,3),20,'filled','MarkerFaceColor','green')
% hold on

dists = vecnorm(mid_contact_coord-centro,2,2);
[min_dist, contact_row] = min(dists);
disp(['Contact row ',num2str(contact_row),' has shortest distance (',...
      num2str(min_dist*1e3), ' mm) from target centroid.'])

% Step 2: Compute distance target centroid - potential segmented contacts?


end