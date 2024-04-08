function MNI7T_to_native(pat_path,rebuild)

% Summary
% ----------
% Maps 7T MNI template to native space using the leadDBS function
% ea_applynormtofile_menu(). The function will generate the mapped Nifti
% file wt1.nii
%
% Input Arguments
% ---------------
% pat_path      : (str) path to the patient folder. Must end with a '/' 
% rebuild       : (bool) 0 or 1. Signifies if operations should be re-run 


% -------------------------------------------------------------------------

    
    
    lead path;
    map_path = which('MNI_ICBM_2009b_NLIN_ASYM/t1.nii');

    if ~isfile(fullfile(pat_path, 'wt1.nii')) || rebuild == 1
        disp('Map from MNI to native space...')

        forwardvars = { % Specify patient folder(s) on which to base normalizations here.
                       {pat_path}
                       1
                       0
                       0
                       0
                       }';
        forwardvars=[forwardvars,{map_path}]; % Specify nifti file to map here. A full path to the file indicates the same file
        %     will be used in each patient. A local path (e.g. 'anat_t2.nii' indicates a filename inside each
        %     patient folder will be used.
        
        ea_applynormtofile_menu([],[],forwardvars{:}); % execute command.
        disp('Mapping from 7T MNI to anchor modality done')
    end

    
end
