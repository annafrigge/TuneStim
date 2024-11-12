function [head,tail] = get_lead_parameters(pat,hands)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ABSTRACT                                                                %
% Determine how the lead model trajectory needs to be rotated            %
% to fit the marker coordinates, obtained from LeadDBS.                   %
% 1. Lead is shifted (within Comsol), so that the head marker coordinates %
%    are aligned.                                                         %      
% 2. Determine angle between current head-tail trajectory and desired     %
%    head-tail trajectory using dot product.                              %  
% 3. Determine rotation axis by using cross product.                      %
% 4. Write all required parameters to .txt file. Can directly be imported %
%    to COMSOL.                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if strcmp(pat.lead,'S:t Jude 1331')
    % surface area of contacts S:t Jude short
    A_shell_tot = 5.9768E-6;
    A_shell_seg = 1.2453E-6;
    pat.orientation = pat.orientation + 175;
elseif strcmp(pat.lead,'Boston Scientific 2202')
    %surface ara of contacts Boston Scientific
    A_shell_tot = 6.0E-6;
    A_shell_seg = 1.5E-6;
elseif strcmp(pat.lead,'Boston Scientific Vercise Cartesia')
    A_shell_tot = 6.0E-6;
    A_shell_seg = 0;
end

% initial head and tail coordinates from comsol model
head_i = [0 0 0];
tail_i = [0 0 6e-3];

% loading reconstructed marker coordinates - desired coordinates
for i=1:length(hands)
    if strcmp(hands{i},'dx')
        side_nr = 1;
    else
        side_nr = 2;

    end
    if isnan(pat.orientation(i))
         continue
    end
    [h,t] = get_lead_coordinates(pat,side_nr);
    disp('head-tail (dx, sin) distance is:')
    disp(append(num2str(norm(h-t)),' m'))
    
    tail_i_hand = tail_i - head_i + h;
    head_i_hand = h;
    
    alpha = acos(dot(tail_i_hand-head_i_hand, t-h)/...
           (norm(tail_i_hand-head_i_hand)*norm(t-h)));

    alpha = rad2deg(alpha);
    
    axis = cross(tail_i_hand-head_i_hand, t-h)/...
               (norm(tail_i_hand-head_i_hand)*norm(t-h));

    V0 = 1;         % unit stimulus 1V     
    I0 = 1e-3;      % unit stimulus 1mA
    
    % write parameters to .txt file
    write_lead_parameters_to_txt(pat, A_shell_tot,A_shell_seg,...
                             h,pat.orientation(i), t, axis,...
                             alpha,V0,I0,hands{i});

    head.(hands{i}) = h;
    tail.(hands{i}) = t;

end

disp('Parameters written to file.')
end



