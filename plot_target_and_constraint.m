function plot_target_and_constraint(pat)

% plots the targets, constraints and lead in native pat.space by using the
% leadDBS-generated ROI-data. The lead cylinder is also plotted.

% Input Arguments
% ---------------
% pat.path : str, path to patient directory where the atlases are stored
%
% atlas : str, name of the atlas from which the target and constraint were taken
% 
% areas : cell, names of the constraints and target files used
%
% hand : str, dx or sin, corresponding to the right or left hemisphere
% respecitively
%
% head : 1x3 double, lead head coordinates
%
% tail: 1x3 double, lead tail coordinates
    


for i=1:length(pat.Targets)
    plot(alphaShape(pat.Targets{i,1}(:,1:3)),'LineStyle','none','FaceAlpha',0.2,'FaceColor',"#0072BD")
    hold on
end
for i=1:length(pat.Constraints)
    plot(alphaShape(pat.Constraints{i,1}(:,1:3)),'LineStyle','none','FaceAlpha',0.2,'FaceColor',"#d95319")
    hold on
end

    %scatter3(pat.TargetPoints(:,1), pat.TargetPoints(:,2),pat.TargetPoints(:,3), 30, 'MarkerEdgeColor','k',... 
    %    'MarkerFaceColor',"#0072BD",'MarkerFaceAlpha',0.25,'MarkerEdgeAlpha',0.25); %'#446330'
    scatter3sph(pat.TargetPoints(:,1), pat.TargetPoints(:,2), pat.TargetPoints(:,3), 'size',1.5e-4, ...
        'color',repmat(hex2rgb('0072BD'),length(pat.TargetPoints(:,1)),1),'transparency',0.5);
    hold on
    %scatter3(pat.ConstraintPoints(:,1), pat.ConstraintPoints(:,2), pat.ConstraintPoints(:,3), 30, 'MarkerEdgeColor','k',...
    %        'MarkerFaceColor',"#D95319",'MarkerFaceAlpha',0.25);
    scatter3sph(pat.ConstraintPoints(:,1), pat.ConstraintPoints(:,2), pat.ConstraintPoints(:,3), 'size',1.5e-4, ...
        'color',repmat(hex2rgb('D95319'),length(pat.ConstraintPoints(:,1)),1),'transparency',0.5);

    %legend('STN motor','STN limbic','STN associative','Interpreter','latex')
    %title('')


    % load(append(pat.path,'atlases/',atlas,'/neurostructures.mat'),'region')
    % 
    % if strcmp(pat.space,'native')
    %     region = region.native;
    % else
    %     region=region.MNI;
    % end
    % 
    % n = length(region.name);
    % 
    % CM = lines(n);%hsv(n); 
    % 
    % 
    % for i=1:n
    %     try
    %         if any( strcmp( areas,(region.name{i,side})) )
    %             coords = region.coords{i,side};
    % 
    %             if contains(region.name{i,side},'tract')
    % 
    % 
    %                 %option for fiber tracts
    %                 for k=1:max(coords(:,4))
    %                     fib = coords(coords(:,4)==k,:);
    %                     fib_vec=zeros(length(fib)-1,4);
    %                     for j=1:length(fib)-1
    %                         fib_vec(j,:) = fib(j+1,:)-fib(j,:);
    %                     end
    %                     X = fib(1:end-1,1);
    %                     Y = fib(1:end-1,2);
    %                     Z = fib(1:end-1,3);
    %                     quiver3(X,Y,Z,fib_vec(:,1),fib_vec(:,2),fib_vec(:,3),'off','Color',CM(i,:),'LineWidth',1,'ShowArrowHead','off') %[0.60000, 0.00000, 0.00000]
    %                     %scatter3(fib(:,1), fib(:,2), fib(:,3), 1, CM(i,:), 'filled')
    %                     hold on
    %                 end
    %             else
    %                 C = convhull(coords(:,1),coords(:,2),coords(:,3));
    % 
    %                 shp = alphaShape(coords(:,1),coords(:,2),coords(:,3));
    %                 name = erase(region.name{i,side},'.nii.gz');
    %                 name = strjoin(strsplit(name,'_'),' ') ;
    % 
    %                 %trisurf(C,coords(:,1),coords(:,2),coords(:,3),'FaceColor',CM(i,:),'EdgeColor','none','FaceAlpha',0.6,'DisplayName',name,'Parent',VTAfig);
    % 
    %                 plot(shp,'FaceColor',CM(i,:),'EdgeColor','none','FaceAlpha',0.6,'DisplayName',name,'Parent',VTAfig)
    % 
    %                 hold(VTAfig,'on')
    %             end
    % 
    %         end
    %     catch ME
    %         disp(ME)
    %     end
    % 
    % end
   
function rgb = hex2rgb(hexString)
	if size(hexString,2) ~= 6
		error('invalid input: not 6 characters');
	else
		r = double(hex2dec(hexString(1:2)))/255;
		g = double(hex2dec(hexString(3:4)))/255;
		b = double(hex2dec(hexString(5:6)))/255;
		rgb = [r, g, b];
	end
end
end

