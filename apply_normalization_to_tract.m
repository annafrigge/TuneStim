function apply_normalization_to_tract(tractname,directory,patdir,sourcedir)
    %load fiber tract
    load([directory, tractname],'ea_fibformat','fibers','fourindex','idx');
    source = [sourcedir,'t1.nii'];
    dest = [patdir,'anat_t1.nii'];
    transform2 = [patdir, 'glanatInverseComposite.nii.gz'];
    transform = [patdir, 'glanatComposite.nii.gz'];
    
    coords = [fibers(:,1:3) ones(size(fibers,1),1)];
    
    nii = ea_load_nii(source);
    coords = nii(1).mat\coords';

    fibers_native = ea_map_coords(coords, source, transform, dest,'ANTS');

    %fibers_native2 = ea_map_coords(coords, source, transform2, dest,'ANTS');
    
    

    fibers_native = [fibers_native', fibers(:,4)];

    % save to .mat file to visualize in LeadDBS (drag .mat file to 3D view)
    clear fibers
    fibers = fibers_native;

    matname = fullfile(directory, tractname);
    save(matname, 'ea_fibformat','fibers','fourindex','idx','-append');
    

 
end


