function [] = write_lead_parameters_to_txt(pat, A_shell_tot,...
                                           A_shell_seg, head, orientation,...
                                           tail, axis, alpha,V0,I0,hand)

%head_z_displ = head(3)-2.25e-3;

fileID = fopen(append(pat.path,...
               'lead_parameters_',pat.space, '_', hand,'.txt'),'w');

fprintf(fileID,'%11s  %9.7f\r\n','A_shell_tot',A_shell_tot);
fprintf(fileID,'%11s  %9.7f\r\n','A_shell_seg',A_shell_seg);
fprintf(fileID,'%6s  %9.7f\r\n','head_x',head(1));
fprintf(fileID,'%6s  %9.7f\r\n','head_y',head(2));
fprintf(fileID,'%6s  %9.7f\r\n','head_z',head(3));
fprintf(fileID,'%10s %9.7f\r\n','orientation',orientation);
fprintf(fileID,'%6s  %9.7f\r\n','tail_x',tail(1));
fprintf(fileID,'%6s  %9.7f\r\n','tail_y',tail(2));
fprintf(fileID,'%6s  %9.7f\r\n','tail_z',tail(3));
fprintf(fileID,'%10s %9.7f\r\n','rot_axis_x',axis(1));
fprintf(fileID,'%10s %9.7f\r\n','rot_axis_y',axis(2));
fprintf(fileID,'%10s %9.7f\r\n','rot_axis_z',axis(3));
fprintf(fileID,'%9s  %9.7f\r\n','rot_angle',alpha);
fprintf(fileID,'%2s  %2.1f\r\n', 'V0',V0);
fprintf(fileID,'%2s  %5.4f\r\n', 'I0',I0);

fclose(fileID);
end