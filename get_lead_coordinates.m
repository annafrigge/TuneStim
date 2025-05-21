function [head,tail] = get_lead_coordinates(pat,side_nr)
% returns native head and tail coordinates of the reconstructed lead in [m]
% Input parameters:
% pat.path = directory with Lead DBS results
% pat.space = mni or native pat.space

try
    load(append(pat.path,'reconstruction',filesep,pat.name,'_desc-reconstruction.mat'))
catch ME
    load(append(pat.path,'ea_reconstruction.mat'))
end

disp(['Retrieving coordinates in ', pat.space, ' space.'])
if strcmp(pat.space,'MNI')
    head = [reco.mni.markers(side_nr).head]*1e-3;
    tail = [reco.mni.markers(side_nr).tail]*1e-3;

    
elseif (strcmp(pat.space,'native') || strcmp(pat.space,'Native'))
    head = [reco.native.markers(side_nr).head]*1e-3;
    tail = [reco.native.markers(side_nr).tail]*1e-3;

   
end