function create_structure_file(pat,cohort)
disp('create .mat file to store target data')
if ~isfile([pat.path,'atlases',filesep,cohort.atlas,filesep,'neurostructures.mat'])
    
    %mkdir([pat.path,'atlases']);
    mkdir(append(pat.path,'atlases/',cohort.atlas));

    name = 'neurostructures';
    extention='.mat';
    destination = append(pat.path,'atlases/',cohort.atlas);
    matname = fullfile(destination, [name extention]);
    
    region.warped={};
    save(matname,'region')

end