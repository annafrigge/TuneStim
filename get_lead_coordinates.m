function [head,tail] = get_lead_coordinates(pat_path,space,side_nr)
% returns native head and tail coordinates of the reconstructed lead in [m]
% Input parameters:
% pat_path = directory with Lead DBS results
% space = mni or native space

load(append(pat_path,'ea_reconstruction.mat'))
disp(space)
if strcmp(space,'MNI')
    head = [reco.mni.markers(side_nr).head]*1e-3;
    tail = [reco.mni.markers(side_nr).tail]*1e-3;

    
elseif strcmp(space,'native')
    head = [reco.native.markers(side_nr).head]*1e-3;
    tail = [reco.native.markers(side_nr).tail]*1e-3;

   
end