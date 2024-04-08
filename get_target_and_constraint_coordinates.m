function [target,constraint,atlas_struct] = get_target_and_constraint_coordinates(path,target_name,constraint_name,hand,max,min)

if strcmp(hand,'rh')
    side = 1;
elseif strcmp(hand,'lh')
    side = 2;
end

%get all niftis and mat files in folder
niftis = dir(fullfile(path,'*.nii'));
tracts = dir(fullfile(path,'*.mat'));

S = vertcat(niftis,tracts);

%initialise cells in which target and constraint are stored
target = cell(length(target_name),1);
constraint = cell(length(constraint_name),1);

t=0;
c=0;
for k = 1:numel(S)

    if any(strcmp(S(k).name,target_name)) | any(strcmp(S(k).name,constraint_name))
        
        fnm = fullfile(path,S(k).name);

        if contains(S(k).name,'.nii')
            name=append(S(k).name,'.gz');

            volumeInfo=spm_vol(fnm);
            [intensityValues,xyzCoordinates ]=spm_read_vols(volumeInfo);
        
            % change units from mm to m
            
            xyzCoordinates = xyzCoordinates * 1e-3;
        
            Npoints = length(xyzCoordinates);
        
            region = [xyzCoordinates' reshape(intensityValues,Npoints,1)];
        elseif contains(S(k).name,'.mat')

            name = S(k).name;
            load([S(k).folder,filesep, S(k).name],'fibers');

            % change units from mm to m
            xyzCoordinates = double(fibers(:,1:3)*1e-3);

            %set intensityvalue to 1 for every fibre point
            intensityValues = ones(size(fibers,1),1);
            Npoints = length(xyzCoordinates);
            region = [xyzCoordinates reshape(intensityValues,Npoints,1)];
        end
            
      
           if any(strcmp(S(k).name,target_name))
               
                r = region(region(:,4)>=1e-3,:);
                
                %remove rows not within max-min-interval
                logx = (r(:,1) <= max(1)) & (r(:,1) >= min(1));
                logy = (r(:,2) <= max(2)) & (r(:,2) >= min(2));
                logz = (r(:,3) <= max(3)) & (r(:,3) >= min(3));
                roi = r(logx & logy & logz,1:3); 
                
                
                if ~isempty(r)
                     t = t+1;
                     target{t} = roi(:,1:3);
                end
                

           end
           if any(strcmp(S(k).name,constraint_name))
                
               
                r =  region(region(:,4)>=1e-3,:);

                %remove rows not within max-min-interval
                logx = (r(:,1) <= max(1)) & (r(:,1) >= min(1));
                logy = (r(:,2) <= max(2)) & (r(:,2) >= min(2));
                logz = (r(:,3) <= max(3)) & (r(:,3) >= min(3));
                roi = r(logx & logy & logz,1:3);
                
                if ~isempty(r)
                     c = c+1;
                     constraint{c} = roi(:,1:3);
                end
                
           end

           if t+c > 0
               
               atlas_struct.name{t+c,side} = name;
               atlas_struct.roi{t+c,side} = double(roi);
               atlas_struct.coords{t+c,side} = double(r);
           end

    end      
end

end
