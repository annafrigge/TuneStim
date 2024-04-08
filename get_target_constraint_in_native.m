function get_target_constraint_in_native(options,names)

% Based on lead-dbs function ea_ptspecific_atl, this function warps the
% targets and constraints, defined in names, to native space


troot=[options.earoot,'templates',filesep]; %template root
aroot=[ea_space(options,'atlases'),options.atlasset,filesep]; %atlas root
proot=[options.patientname,filesep]; %patient root

load([proot,'atlases',filesep,options.atlasset,filesep,'neurostructures.mat'],'region'); 
warped_names = region.warped;
i=0;

for n=1:length(names)
    if ~any(strcmp(names{n},warped_names))
        i=i+1;
        to_be_warped{i} = names{n};
    end
end

if i>0
   
    ea_warp_atlas_to_native(troot,aroot,proot,0,options,to_be_warped)
            
    load([proot,'atlases',filesep,options.atlasset,filesep,'atlas_index.mat'],'atlases'); 
    
    region.warped = {region.warped{:}, to_be_warped{:}};
   
    destination = append(proot,'atlases',filesep,options.atlasset);
    matname = fullfile(destination, 'neurostructures.mat');
    save(matname, 'region','-append');

    options.atl.can=0;
    options.atl.ptnative=1;
    %ea_genatlastable_2(atlases,[proot,'atlases',filesep],options,to_be_warped);
  

end


function ea_warp_atlas_to_native(troot,aroot,proot,force,options,names)

sroot = ea_space(options,'space');

if ~exist([aroot,'atlas_index.mat'],'file')
    ea_error('Please visualize this atlas in MNI space once before visualizing the atlas in native space.');
else
    load([aroot,'atlas_index.mat']);
end

if ~exist([proot,'atlases'], 'dir')
    mkdir([proot,'atlases']);
end

%copyfile(aroot, [proot,'atlases',filesep,options.atlasset]);

%copy atlas_index.mat to folder
destination = append(proot,'atlases/',options.atlasset);
mkdir(destination)
source = append(aroot,'atlas_index.mat');
copyfile(source,destination);

type = atlases.types(1);
switch type
    case 1
        mkdir(append(proot,'atlases/',options.atlasset,'/lh'));
    case 2
        mkdir(append(proot,'atlases/',options.atlasset,'/rh'));
    case 3
        mkdir(append(proot,'atlases/',options.atlasset,'/rh'));
        mkdir(append(proot,'atlases/',options.atlasset,'/lh'));
    case 4
        mkdir(append(proot,'atlases/',options.atlasset,'/mixed'));
    case 5
        mkdir(append(proot,'atlases/',options.atlasset,'/midline'));
end


for n = 1:length(names)
    name =names{n};
    switch type
        case 1
            destination = append(proot,'atlases/',options.atlasset,'/lh');
            source = append(aroot,'lh/',name);
            copyfile(source,destination);
        case 2
            destination = append(proot,'atlases/',options.atlasset,'/rh');
            source = append(aroot,'rh/',name);
            copyfile(source,destination);
        case 3
            destination = append(proot,'atlases/',options.atlasset,'/rh');
            source = append(aroot,'rh/',name);
            copyfile(source,destination);

            destination = append(proot,'atlases/',options.atlasset,'/lh');
            source = append(aroot,'lh/',name);
            copyfile(source,destination);
        case 4
            destination = append(proot,'atlases/',options.atlasset,'/mixed');
            source = append(aroot,'mixed/',name);
            copyfile(source,destination);
        case 5
            destination = append(proot,'atlases/',options.atlasset,'/midline');
            source = append(aroot,'midline/',name);
            copyfile(source,destination);
    end

end

p =load([proot,'atlases',filesep,options.atlasset,filesep,'atlas_index.mat']);
p.atlases.rebuild=1;

save([proot,'atlases',filesep,options.atlasset,filesep,'atlas_index.mat'],'-struct','p');

ea_delete([proot,'atlases',filesep,options.atlasset,filesep,'gm_mask.nii*']);

if ismember(options.prefs.dev.profile,{'se'})
    interp=0;
else
    interp=1;
end


for atlas=1:length(atlases.names)
   if any(strcmp(names,atlases.names{atlas})) || any(strcmp(names,append(atlases.names{atlas},'.gz')))
    switch atlases.types(atlas)
        case 1 % left hemispheric atlas.
            patlf=[proot,'atlases',filesep,options.atlasset,filesep,'lh',filesep];
        case 2 % right hemispheric atlas.
            patlf=[proot,'atlases',filesep,options.atlasset,filesep,'rh',filesep];
        case 3 % both-sides atlas composed of 2 files.
            pratlf=[proot,'atlases',filesep,options.atlasset,filesep,'rh',filesep];

            platlf=[proot,'atlases',filesep,options.atlasset,filesep,'lh',filesep];
        case 4 % mixed atlas (one file with both sides information.
            patlf=[proot,'atlases',filesep,options.atlasset,filesep,'mixed',filesep];
        case 5 % midline atlas (one file with both sides information.
            patlf=[proot,'atlases',filesep,options.atlasset,filesep,'midline',filesep];
    end
    
    if atlases.types(atlas)==3 
        
        %check if tract or nii

        if contains(atlases.names{atlas},'.nii')
            ea_apply_normalization_tofile(options,{ea_niigz([pratlf,atlases.names{atlas}])},{ea_niigz([pratlf,atlases.names{atlas}])},[options.root,options.patientname,filesep],1,interp);
            ea_apply_normalization_tofile(options,{ea_niigz([platlf,atlases.names{atlas}])},{ea_niigz([platlf,atlases.names{atlas}])},[options.root,options.patientname,filesep],1,interp);
            
            ea_crop_nii(ea_niigz([pratlf,atlases.names{atlas}]));
            ea_crop_nii(ea_niigz([platlf,atlases.names{atlas}]));

        elseif contains(atlases.names{atlas},'.mat')
            apply_normalization_to_tract(atlases.names{atlas},pratlf,proot,sroot)
            apply_normalization_to_tract(atlases.names{atlas},platlf,proot,sroot)
        end
    else
        
        if contains(atlases.names{atlas},'.nii')
            ea_apply_normalization_tofile(options,{ea_niigz([patlf,atlases.names{atlas}])},{ea_niigz([patlf,atlases.names{atlas}])},[options.root,options.patientname,filesep],1,interp);
            ea_crop_nii(ea_niigz([patlf,atlases.names{atlas}]));
        elseif contains(atlases.names{atlas},'.mat')
            apply_normalization_to_tract(atlases.names{atlas},patlf,proot,sroot)
        end
    end
   end
end



