function volume_outside = remove_lead_volume2(pat,V,head,tail)
% A function that generates a matrix with coordinates outside a lead, defined by the head and tail, lead radius and length
% first, the rotation matrix to get to the lead coordinate system is
% generated. Using this matrix a point in V is rotated from the coordinate
% system of the lead, to the standard coordinate system. By checking the
% cylindrical coordinates of the point in this systeme it can be
% determined whether it is inside or outside the lead.

%Parameters
%----------
% V = nx3 matrix of x,y,z points
% head = 1x3,the lead head coordinates
% tail = 1x3, the leadd tail coordinates

%Output
%------
%volume_outside = mx3 matrix of x,y,z points outside the lead

leadvector=(tail-head)/norm(head-tail);
vlead0=[0,0,1];
r = vrrotvec(vlead0,leadvector);
Rotation = vrrotvec2mat(r);

if strcmp(pat.lead,'Boston Scientific Vercise Directional 2202')
    translation_factor =  head - 0.75*1e-3 * leadvector;
    R_cyl=0.5*1.3*1e-3;
elseif strcmp(pat.lead,'Abbott Infinity Directed (short)')
    translation_factor =  head - 2.25e-3 * leadvector;
    R_cyl=0.5*1.27*1e-3; %((0.00127/2)+0.0005);
elseif strcmp(pat.lead,'Boston Scientific Vercise Standard 2201')
    translation_factor =  head - 2.25e-3 * leadvector;
    R_cyl=0.5*1.3*1e-3;
elseif strcmp(pat.lead,'Medtronic 3887')
    translation_factor =  head - 2.25e-3 * leadvector;
    R_cyl=0.5*1.27*1e-3;
end

z_cyl = 0.1;

i=1;
j=1;
volume_inside = [];
volume_outside = [];
for row=1:length(V(:,1))
    P = (Rotation'*(V(row,1:3)- translation_factor)')';
    [theta,rho,z] = cart2pol(P(1),P(2),P(3));
    
    if rho <= R_cyl && z <= z_cyl && z >= 0
        volume_inside(i,:) = V(row,:);
        i=i+1;
    else
        volume_outside(j,:)=V(row,:);
        j=j+1;
    end

end

assert(length(volume_outside)>3);

%plot inside points and cylinder
% try
% figure(2)
% scatter3(volume_inside(:,1),volume_inside(:,2),volume_inside(:,3),'filled');
% hold on
% scatter3(volume_outside(:,1),volume_outside(:,2),volume_outside(:,3));
% 
% axis equal
% hold on
% end




end