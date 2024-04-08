function [sphere_points]=spheregen(c,r,Nxy,Nxz,Nyz)
% returns N=Nxy+Nxz+Nyz singularity points, which are place on a sphere 
% of radius r around the centre c of the grid (corresponds to head/tip 
% position of the lead)

if nargin<3
    Nxy=3;
    Nxz=3;
    Nyz=2;
end


% equidistant angles around centre for each direction x,y,z
%to avoid overlapping points, turn each plane pi/3
thetaxy=linspace(0,2*pi,Nxy+1);
thetaxy=thetaxy(1:end-1);

thetayz=linspace(pi/3,2*pi+pi/3,Nyz+1);
thetayz=thetayz(1:end-1);

thetaxz=linspace(2*pi/3,2*pi+2*(pi/3),Nxz+1);
thetaxz=thetaxz(1:end-1);

sphere_points = zeros(Nxy+Nxz+Nyz,3);

% compute points on sphere

  
sphere_points(1:Nxy,1:3) = [r*sin(thetaxy)+c(1);r*cos(thetaxy)+c(2); c(3)*thetaxy.^0]';

sphere_points(1+Nxy:Nxy+Nyz,1:3) = [c(1)*thetayz.^0; r*sin(thetayz)+c(2); r*cos(thetayz)+c(3);]';

sphere_points(Nxy+Nyz+1:Nxz+Nxy+Nyz,1:3) = [r*sin(thetaxz)+c(1); c(2)*thetaxz.^0; r*cos(thetaxz)+c(3);]';

%scatter3(sphere_points(:,1),sphere_points(:,2),sphere_points(:,3))
% for k=1:Nxy
%     sphere_points(k,1)=r*sin(thetaxy(k))+c(1);
%     sphere_points(k,2)=r*cos(thetaxy(k))+c(2);
%     sphere_points(k,3)=c(3);
% end
% 
% for k=1:Nyz
%     sphere_points(k+Nxy,1)=c(1);
%     sphere_points(k+Nxy,2)=r*sin(thetayz(k))+c(2);
%     sphere_points(k+Nxy,3)=r*cos(thetayz(k))+c(3);
% end
% 
% for k=1:Nxz
%     sphere_points(k+Nxy+Nyz,1)=r*sin(thetaxz(k))+c(1);
%     sphere_points(k+Nxy+Nyz,2)=c(2);
%     sphere_points(k+Nxy+Nyz,3)=r*cos(thetaxz(k))+c(3);
% end

