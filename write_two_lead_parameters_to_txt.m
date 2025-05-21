function write_two_lead_parameters_to_txt(pat,params,hands)
fileID = fopen(append(pat.TuneSderivativesPath,...
               'lead_parameters_',pat.space, '_both_hands.txt'),'w');
for i=1:length(hands)

    fprintf(fileID,'%6s  %9.7f\r\n',['head_x_',hands{i}],params(hands{i}).head(1));
    fprintf(fileID,'%6s  %9.7f\r\n',['head_y_',hands{i}],params(hands{i}).head(2));
    fprintf(fileID,'%6s  %9.7f\r\n',['head_z_',hands{i}],params(hands{i}).head(3));
    fprintf(fileID,'%6s  %9.7f\r\n',['tail_x_',hands{i}],params(hands{i}).tail(1));
    fprintf(fileID,'%6s  %9.7f\r\n',['tail_y_',hands{i}],params(hands{i}).tail(2));
    fprintf(fileID,'%6s  %9.7f\r\n',['tail_z_',hands{i}],params(hands{i}).tail(3));
    fprintf(fileID,'%6s  %9.7f\r\n',['rot_axis_x_',hands{i}],params(hands{i}).axis(1));
    fprintf(fileID,'%6s  %9.7f\r\n',['rot_axis_y_',hands{i}],params(hands{i}).axis(2));
    fprintf(fileID,'%6s  %9.7f\r\n',['rot_axis_z_',hands{i}],params(hands{i}).axis(3));
    fprintf(fileID,'%6s  %9.7f\r\n',['rot_angle_',hands{i}],params(hands{i}).alpha);


    if isfield(pat,'orientation')
        fprintf(fileID,'%10s %9.7f\r\n',['orientation_',hands{i}],pat.orientation(i));
    else
        fprintf(fileID,'%10s %9.7f\r\n',['orientation_',hands{i}],0);
    end

end
fclose(fileID);