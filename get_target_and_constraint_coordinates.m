function [target,constraint,atlas_struct] = get_target_and_constraint_coordinates(search_paths,target_name,constraint_name,hand,pat)

if strcmp(hand,'lh')
    side = 1;
elseif strcmp(hand,'rh')
    side = 2;
end

% %get all niftis and mat files in folder
% niftis = dir(fullfile(path,'*.nii'));
% tracts = dir(fullfile(path,'*.mat'));
% 
% S = vertcat(niftis,tracts);


% Initialize file list
S = [];

% Loop over each folder in search_paths to collect .nii and .mat files
for i = 1:length(search_paths)
    curr_path = search_paths{i};

    if isfolder(curr_path)
        files = [ ...
            dir(fullfile(curr_path, '*.nii')); ...
            dir(fullfile(curr_path, '*.mat')) ...
        ];

        % Add full path to each file entry
        for j = 1:length(files)
            files(j).fullpath = fullfile(files(j).folder, files(j).name);
        end

        S = [S; files];
    end
end


%initialise cells in which target and constraint are stored
target = cell(length(target_name),1);
constraint = cell(length(constraint_name),1);

t=0;
c=0;
for k = 1:numel(S)

    if any(strcmp(S(k).name,target_name)) | any(strcmp(S(k).name,constraint_name))
        
        %fnm = fullfile(path,S(k).name);
        fnm = S(k).fullpath;

        if contains(S(k).name,'.nii')
            name=S(k).name;%append(S(k).name,'.gz');

            volumeInfo=spm_vol(fnm);
            [intensityValues,xyzCoordinates ] = spm_read_vols(volumeInfo);
        
            % change units from mm to m
            
            xyzCoordinates = xyzCoordinates * 1e-3;
        
            Npoints = length(xyzCoordinates);
        
            region = [xyzCoordinates' reshape(intensityValues,Npoints,1)];
        elseif contains(S(k).name,'.mat')

            name = S(k).name;

            % load([S(k).folder,filesep, S(k).name],'fibers');
            % change units from mm to m
            % xyzCoordinates =  double(fibers(:,1:3)*1e-3);
            % intensityValues = double(fibers(:,4));%ones(size(fibers,1),1);
            % Npoints = length(xyzCoordinates);
            %region = [xyzCoordinates reshape(intensityValues,Npoints,1)];

            tmp = load([S(k).folder,filesep, S(k).name]);
            if isfield(tmp,'fibcell')
            fibers = tmp.fibcell{side};
            region = [];
            for f = 1:numel(fibers)
                coords = fibers{f}*1e-3;  % N2 x 3 matrix of coordinates
                region = [region; coords ones(length(coords),1)*tmp.usedidx{1,1}(f)];
            end

            elseif isfield(tmp,'fibers')
                fibers = tmp.fibers;
                xyzCoordinates =  double(fibers(:,1:3)*1e-3);
                intensityValues = double(fibers(:,4));%ones(size(fibers,1),1);
                Npoints = length(xyzCoordinates);
                region = [xyzCoordinates reshape(intensityValues,Npoints,1)];
            else
                error('No fibers identified in file. Check if tract struct includes a field fibcell or fibers.')
            end
            
        end
      
        zCorr = 0;
           if any(strcmp(S(k).name,target_name))
               
                r = region(region(:,4)>=1e-3,:);
                
                % remove rows not within max-min-interval
                logx = (r(:,1) <= pat.maxPoint(1)) & (r(:,1) >= pat.minPoint(1));
                logy = (r(:,2) <= pat.maxPoint(2)) & (r(:,2) >= pat.minPoint(2));
                logz = (r(:,3) <= pat.maxPoint(3)-zCorr) & (r(:,3) >= pat.minPoint(3));
                roi = r(logx & logy & logz,:); 
                
                
                if ~isempty(r)
                     t = t+1;
                     target{t} = roi(:,:);
                end
                

           end
           if any(strcmp(S(k).name,constraint_name))
                
               
                r =  region(region(:,4)>=1e-3,:);

                %remove rows not within max-min-interval
                logx = (r(:,1) <= pat.maxPoint(1)) & (r(:,1) >= pat.minPoint(1));
                logy = (r(:,2) <= pat.maxPoint(2)) & (r(:,2) >= pat.minPoint(2));
                logz = (r(:,3) <= pat.maxPoint(3))-zCorr & (r(:,3) >= pat.minPoint(3));
                roi = r(logx & logy & logz,:);
                
                if ~isempty(r)
                     c = c+1;
                     constraint{c} = roi(:,:);
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
