function [head,tail] = get_two_lead_parameters(pat,hands)

if strcmp(pat.lead,'Abbott Infinity Directed (short)')
    pat.orientation = pat.orientation + 175;
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
    %if ~exist('pat.orientation','var') == 0 && isnan(pat.orientation(i)) 
    %     continue
    %end
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
    
    
    params(hands{i}).head = h;
    params(hands{i}).tail = t;
    params(hands{i}).axis = axis;
    params(hands{i}).alpha = alpha;

end
    % write parameters to .txt file
    write_two_lead_parameters_to_txt(pat,params,hands{i});

disp('Parameters written to file.')
end