function create_structure_file(pat_path,atlas)
disp('create .mat file to store target data')
if ~isfile([pat_path,'atlases',filesep,atlas,filesep,'neurostructures.mat'])
    
    %mkdir([pat_path,'atlases']);
    mkdir(append(pat_path,'atlases/',atlas));

    name = 'neurostructures';
    extention='.mat';
    destination = append(pat_path,'atlases/',atlas);
    matname = fullfile(destination, [name extention]);
    
    region.warped={};
    save(matname,'region')

end