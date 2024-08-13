clear all

cohort_path = 'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study';
pat_names = ['DBS_104';'DBS_128';'DBS_133';'DBS_139';'DBS_167';...
    'DBS_168';'DBS_171';'DBS_185';'DBS_199';'DBS_204'];
leads = {'S:t Jude 1331','Boston Scientific 2202', 'S:t Jude 1331',...
         'S:t Jude 1331','Boston Scientific 2202','S:t Jude 1331'...
         'Boston Scientific 2202','S:t Jude 1331',...
         'Boston Scientific 2202','Boston Scientific 2202'};
orientations = {[293,314],[249,288],[12,302],[25,153],[98,193],[52,345],...
               [32,116],[202,184],16.4,[308,38]};

amplitudes = {[3,2.85],[4.6,1.5],[3.4,4.6],[2.6,2],[1.7,2.6],[3.2,1.5],[1.2,3],[4.4,3.3],[3.8,0],[1,2.4]};
optischeme = 'conservative';
atlas = 'DISTAL Minimal (Ewert 2017)';
target_names = {'STN_motor.nii.gz'};
constraint_names = {'STN_associative.nii.gz','STN_limbic.nii.gz'};
space = 'MNI';
EThreshold = 200;
relaxation = 0:10:90;
scoretype = 'score2';


% Dice scores for STN tracts
diceScoresInhomTracts = [0.97 0.88; 0.80,0.80; 0.78,0.70;0.91,0.74;...
                    0.83,0.67;0.83,0.84;0.53,0.57;0.80,0.77;...
                    NaN,0.74;0.66,0.52];
bar(diceScoresInhomTracts)
colororder("earth")
legend('Sin','Dx')
ylabel('DSC')
xlabel('Patient ID')
title('Inhomogeneous Tissue')
f=gcf;
exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\DiceScoresInhomSTNTracts.png','Resolution',300)
% Check if scores stem from normal distribution:
% kstest([leftScores;rightScores]) --> rejected i.e. not normally
% distributed

% All leads median score: 0.78, iqr 0.1525 ( The range between the first
% quartile (25th percentile) and the third quartile (75th percentile).)

diceScoresTargetTracts = [0.96, 0.97; 0.55,0.98;0.89,0.87;0.88,0.41;...
                    0.95,0.75;0.74,0.84;0.65,0.16;0.82,0.84;...
                    NaN,0.97;0.01,0.28];
figure()
bar(diceScoresTargetTracts)
colororder("earth")
legend('Sin','Dx')
ylabel('DSC')
xlabel('Patient ID')
title('Target')
f=gcf;
exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\DiceScoresTargetsSTNTracts.png','Resolution',300)


diceScoresConstraintTracts = [0.77, 0.74;0.53,0.52;0.54,0.46;0.60,0.24;...
                        0.76,0.51;0.46,0.57;0.41,0.01;0.46,0.75;...
                        NaN,0.40;0.10,0.36];
figure()
bar(diceScoresConstraintTracts)
colororder("earth")
legend('Sin','Dx')
xlabel('Patient ID')
ylabel('DSC')
title('Constraint')
f=gcf;
exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\DiceScoresConstraintsSTNTracts.png','Resolution',300)


% Dice scores for targeting STN motor, limbic and associative as
% constraints
diceScoresInhomSTN = [0.97,0.88; 0.59,0.79; 0.78,0.69; 0.91, 0.73;...
                      0.82,0.67; NaN,NaN; 0.52,0.67; 0.83,0.77;...
                      NaN,0.73; 0.49,0.85];
figure()
bar(diceScoresInhomSTN)
colororder("earth")
legend('Sin','Dx')
ylabel('DSC')
xlabel('Patient ID')
title('Inhomogeneous Tissue')
diceScoresTargetSTN = [0.96,0.97; 0.34,0.96; 0.88,0.85; 0.88,0.40; ...
                       0.94,0.73; NaN,NaN; 0.63,0.27; 0.80,0.83; ...
                       NaN,0.97; 0,0.78];
f=gcf;
exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\DiceScoresInhomSTNSubs.png','Resolution',300)

figure()
bar(diceScoresTargetSTN)
colororder("earth")
legend('Sin','Dx')
ylabel('DSC')
xlabel('Patient ID')
title('Target')

f=gcf;
exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\DiceScoresTargetSTNSubs.png','Resolution',300)

diceScoresConstraintSTN = [0.75,0.73; 0.39,0.64; 0.52,0.45; 0.59, 0.24;...
                           0.78,0.49; NaN,NaN; 0.39, 0.07; 0.63,0.74;...
                           NaN, 0.39; 0,0.62];
figure()
bar(diceScoresConstraintSTN)
colororder("earth")
legend('Sin','Dx')
ylabel('DSC')
xlabel('Patient ID')
title('Constraint')
f=gcf;
exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\DiceScoresConstraintSTNSubs.png','Resolution',300)





%covTarget = {[66.76]}     % in [%]
%covConstraint = {[                      ]}
hands = {"dx","sin",};
leftScores = zeros(length(diceScoresInhom),1);
rightScores = zeros(length(diceScoresInhom),1);
for i =1:length(diceScoresInhom)
    leftScores(i) = diceScoresInhom{1,i}(1);
    rightScores(i) = diceScoresInhom{1,i}(2);
    plot(i,diceScoresInhom{1,i}(1),'Marker','*','LineStyle','none','Color','blue')
    hold on
    plot(i,diceScoresInhom{1,i}(2),'Marker','*','LineStyle','none','Color','red')
end
ylim([0,1])
legend('Left','Right')

%% Plotting
cm = parula(10);
Markers = {'+','o','*','x','v','d','^','s','>','<'};
for j=1:2
    hand = convertStringsToChars(hands{j});
    if strcmp(hand,'dx')
        side_nr =1;
    else
        side_nr = 2;
    end
    for i=1:length(pat_names)
        disp(append(pat_names(i,:),' ',hand))
        pat_path = append(cohort_path,filesep,pat_names(i,:),filesep);
        if strcmp(pat_names(i,:),'DBS_199') && strcmp(hand,'sin')
            %hand = {"dx"};
            continue
        end
        
        fileName = append(pat_path,'Suggestions',filesep,scoretype,...
            filesep,'Top_Suggestions_',space,'_',...
            hand,'_',optischeme,'_','.txt');
        opts = detectImportOptions(fileName); % Initial detection
        opts.VariableNamesLine = 1; % Set variable names line

        T = readtable(fileName,opts);

        % plot(relaxation,T.Score,'Marker',Markers(i),'LineStyle',':',...
        %     'Color', cm(i,:),'MarkerSize',10,'LineWidth',1)
        plot(T.Alpha,T.Score,'Marker','x','LineStyle',':',...
            'Color', cm(i,:),'MarkerSize',10,'LineWidth',1)
        hold on
        %plot3(relaxation,T.Alpha,T.Target,'Marker','x','LineStyle',':',...
        %    'Color', cm(i,:),'MarkerSize',10,'LineWidth',1)

        fileNameC = append(pat_path,'Clinical',filesep,...
            'EF_',space,'_',hand,'_clinical','.txt');
        EF = readmatrix(fileNameC);
        lead_orientation = orientations{1,i};
        lead = leads{1,i};

        [head,tail] = get_lead_coordinates(pat_path,space,side_nr);
        leadvector=(tail-head)/norm(head-tail);
        vlead0=[0,0,1];
        r = vrrotvec(vlead0,leadvector);
        R = vrrotvec2mat(r);
        maxPoint = max(EF(:,1:3));
        minPoint = min(EF(:,1:3));

        [target_roi,constraint_roi,target_lst,constraint_lst] = load_atlas_roi_2(hand,space,pat_path,atlas,target_names,constraint_names,maxPoint,minPoint);
        disp('Target:')
        [pActTarget,pActSpill,VTA] = volume_of_tissue_activated(EF,target_lst,R,head,leadvector,EThreshold);
        disp('Constraint:')
        [pActConstraint,~,~] = volume_of_tissue_activated(EF,constraint_lst,R,head,leadvector,EThreshold);
        
        %plot(amplitudes{1,i},2*pActTarget*100-pActConstraint*100-pActSpill*100,'Marker','*','LineStyle',':',...
        %    'Color', cm(i,:),'MarkerSize',10,'LineWidth',1)
    

        grid on
        hold on
    end

end
addpath('C:\Users\annfr888\Documents\MATLAB\toolboxes\legendflex-pkg\legendflex')
addpath('C:\Users\annfr888\Documents\MATLAB\toolboxes\legendflex-pkg\setgetpos_V1.2')
%[hleg,icons,plots]= legend('01','02','03','04','05','06','07','08','09','10','Location','eastoutside');
[leg,att] = legendflex(gca, {'01','02 ','03 ','04 ','05 ','06 ','07 ','08 ','09 ','10 '}, 'title', 'Patient ID','anchor',  [5 5], 'buffer', [-10 10]);
set(findall(leg, 'string', 'my title'), 'fontweight', 'bold');

%xlabel('Relaxation [%]')
ylabel('Amplitude [mA]')
%ylabel('Target Coverage [%]')
ylabel('Score')

f = gcf;

%exportgraphics(f,[cohort_path,filesep,'RelaxationVsAmplitude.png'],'Resolution',300)

%% Clinical
for j=1:2
    hand = convertStringsToChars(hands{j});
    if strcmp(hand,'dx')
        side_nr =1;
    else
        side_nr = 2;
    end
    for i=1:length(pat_names)
        pat_path = append(cohort_path,filesep,pat_names(i,:),filesep);
        if strcmp(pat_names(i,:),'DBS_199') && strcmp(hand,'sin')
            %hand = {"dx"};
            continue
        end
        % if strcmp(leads{1,i},'Boston Scientific 2202')
        %     continue
        % end
        disp(append(pat_names(i,:),' ',hand))
        fileNameC = append(pat_path,'Clinical',filesep,...
            'EF_',space,'_',hand,'_clinical','.txt');
        EF = readmatrix(fileNameC);
        lead_orientation = orientations{1,i};
        lead = leads{1,i};

        [head,tail] = get_lead_coordinates(pat_path,space,side_nr);
        leadvector=(tail-head)/norm(head-tail);
        vlead0=[0,0,1];
        r = vrrotvec(vlead0,leadvector);
        R = vrrotvec2mat(r);
        maxPoint = max(EF(:,1:3));
        minPoint = min(EF(:,1:3));

        [target_roi,constraint_roi,target_lst,constraint_lst] = load_atlas_roi_2(hand,space,pat_path,atlas,target_names,constraint_names,maxPoint,minPoint);
        disp('Target:')
        [pActTarget,pActSpill,VTA] = volume_of_tissue_activated(EF,target_lst,R,head,leadvector,EThreshold);
        disp('Constraint:')
        [pActConstraint,~,~] = volume_of_tissue_activated(EF,constraint_lst,R,head,leadvector,EThreshold);
    end
end
