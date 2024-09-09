%clear all
set(0,'defaulttextinterpreter','latex')
set(0, 'DefaultAxesFontSize', 18);


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
optischeme = 'conservative';%'mincov';%
atlas = 'DISTAL Minimal (Ewert 2017)';
target_names = {'STN_motor.nii.gz'};
constraint_names = {'STN_associative.nii.gz','STN_limbic.nii.gz'};
space = 'MNI';
EThreshold = 200;
relaxation = 0:10:90;
scoretype = 'score2';


%% Dice scores for STN tracts
diceScoresInhomTracts = [0.70 0.70; 0.62,0.94; 0.70,0.88;0.67,0.88;...
                    0.80,0.88;0.74,0.97;0.72,0.50;0.87,0.87;...
                    NaN,0.90;0.55,0.42];
bar(diceScoresInhomTracts)
colororder("earth")
leg = legend('Sin','Dx');
leg.Location = 'southeast';
ylabel('DSC')
xlabel('Patient ID')
ylim([0,1])
title('Inhomogeneous Tissue')
f=gcf;
exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\DiceScoresInhomSTNTracts.png','Resolution',300)
% Check if scores stem from normal distribution:
% kstest([leftScores;rightScores]) --> rejected i.e. not normally
% distributed

% All leads median score: 0.78, iqr 0.1525 ( The range between the first
% quartile (25th percentile) and the third quartile (75th percentile).)

diceScoresTargetTracts = [0.81, 0.64; 0.63,0.94;0.81,0.81;0.52,0.76;...
                    0.83,0.82;0.61,0.90;0.84,0.10;0.82,0.95;...
                    NaN,0.90;0.00,0.38];
figure()
bar(diceScoresTargetTracts)
colororder("earth")
leg = legend('Sin','Dx');
leg.Location = 'southeast';
ylabel('DSC')
xlabel('Patient ID')
title('Target')
ylim([0,1])
f=gcf;
exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\DiceScoresTargetsSTNTracts.png','Resolution',300)


diceScoresConstraintTracts = [0.01, 0.20;0.43,0.88;0.10,0.12;0.00,0.00;...
                        0.34,0.63;0.00,0.00;0.00,0.00;0.72,0.50;...
                        NaN,0.74;0.00,0.34];
figure()
bar(diceScoresConstraintTracts)
colororder("earth")
leg = legend('Sin','Dx');
leg.Location = 'southeast';
xlabel('Patient ID')
ylabel('DSC')
title('Constraint')
ylim([0,1])
f=gcf;
exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\DiceScoresConstraintsSTNTracts.png','Resolution',300)


%% Dice scores for targeting STN motor, limbic and associative as
% constraints
diceScoresInhomSTN = [0.97,0.88; 0.59,0.79; 0.78,0.69; 0.91, 0.73;...
                      0.82,0.67; 0.83,0.84; 0.52,0.67; 0.83,0.77;...
                      NaN,0.73; 0.49,0.85];
figure()
bar(diceScoresInhomSTN)
colororder("earth")
leg = legend('Sin','Dx');
leg.Location = 'southeast';
ylabel('DSC')
xlabel('Patient ID')
title('Inhomogeneous Tissue')
ylim([0,1])
diceScoresTargetSTN = [0.96,0.97; 0.34,0.96; 0.88,0.85; 0.88,0.40; ...
                       0.94,0.73; 0.72,0.83; 0.63,0.27; 0.80,0.83; ...
                       NaN,0.97; 0,0.78];
f=gcf;
exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\DiceScoresInhomSTNSubs.png','Resolution',300)

figure()
bar(diceScoresTargetSTN)
colororder("earth")
leg = legend('Sin','Dx');
leg.Location = 'southeast';
ylabel('DSC')
xlabel('Patient ID')
title('Target')
ylim([0,1])

f=gcf;
exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\DiceScoresTargetSTNSubs.png','Resolution',300)

diceScoresConstraintSTN = [0.75,0.73; 0.39,0.64; 0.52,0.45; 0.59, 0.24;...
                           0.78,0.49; 0.29,0.55; 0.39, 0.07; 0.63,0.74;...
                           NaN, 0.39; 0,0.62];
figure()
bar(diceScoresConstraintSTN)
colororder("earth")
leg = legend('Sin','Dx');
leg.Location = 'southeast';
ylabel('DSC')
xlabel('Patient ID')
title('Constraint')
ylim([0,1])
f=gcf;
exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\DiceScoresConstraintSTNSubs.png','Resolution',300)


%% Coverages STN subdivisions clinical
CovTargetSTNsubsClinical = [60.92,97.06; 16.05,94.41; 86.52,84.99;...
                            67.99,26.97; 79.15,62.97; 48.05,64.14;...
                            58.00,11.82; 58.68,68.35; NaN,94.20; NaN,13.13];
CovTargetSTNsubs = [63.93,90.47; 80.16,94.58; 70.32,96.12;...
                    87.19,95.29; 90.68,88.86; 85.92,92.35;...
                    80.28,97.42; 82.52,95.04; NaN,87.90; NaN,12.51];

SpillSTNsubsClinical = [67.96,70.78; 60.91,75.57; 62.98,58.16;...
                        48.23,90.19; 55.75,56.56; 33.50,97.12;...
                        67.37,97.02; 45.15,79.58; NaN,70.94; NaN,75.89];
SpillSTNsubs = [67.64,63.58; 71.69,67.65; 45.70,34.91;...
                51.70,82.37; 68.54,41.67; 43.82,96.01;...
                48.43,96.50; 28.29,68.39; NaN,52.9; NaN,75.1];


CovConstraintSTNsubsClinical = [42.65,35.28; 6.7,22.33; 59.42,40.40;...
                                11.33,1.88; 5.35,14.14; 1.40,10.04;...
                                20.69,0.69; 13.11,37.56; NaN,30.04; NaN,15.82];
CovConstraintSTNsubs = [24.41,21.26; 34.46,13.14; 20.31,17.40;...
                        7.57,15.14; 7.95,14.02; 5.51,16.19;...
                        9.89,20.49; 7.25,48.25; NaN,6.70; NaN,7.93];










%% Plotting
hands = {'sin','dx'};
cm = parula(10);
CT = orderedcolors('gem12');
Markers = {'+','o','*','x','v','d','^','s','>','<'};
lineStyles = {'-', '--', ':', '-.', '-', '--', ':', '-.', '-', '--'};
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
        
        fileName = append(pat_path,'Suggestions',filesep,'STN_motor_tract',...
            filesep,optischeme,filesep,'S-1-1-0',...
            filesep,'Top_Suggestions_',space,'_',...
            hand,'_',optischeme,'_','.txt');
        opts = detectImportOptions(fileName); % Initial detection
        opts.VariableNamesLine = 1; % Set variable names line

        T = readtable(fileName,opts);

        %plot(relaxation,T.Score,'Marker',Markers(i),'LineStyle',':',...
        %     'Color', CT(i,:),'MarkerSize',10,'LineWidth',2)
        plot(relaxation,T.Target,'Marker',Markers(i),'LineStyle',':',...
            'Color', CT(i,:) ,'MarkerSize',10,'LineWidth',2) %cm(i,:)
        hold on
        %plot3(relaxation,T.Alpha,T.Target,'Marker','x','LineStyle',':',...
        %    'Color', cm(i,:),'MarkerSize',10,'LineWidth',1)

        fileNameC = append(pat_path,'Clinical',filesep,...
            'EF_',space,'_',hand,'_clinical','.txt');
        clinicalScore = 2*CovTargetSTNsubsClinical(i,side_nr)-...
                        CovConstraintSTNsubsClinical(i,side_nr)-...
                        SpillSTNsubsClinical(i,side_nr);
        %plot(amplitudes{1,i}(side_nr),clinicalScore,'Marker','*','LineStyle',':',...
        %    'Color', cm(i,:),'MarkerSize',10,'LineWidth',1)

        grid on
        hold on
    end

end
addpath('C:\Users\annfr888\Documents\MATLAB\toolboxes\legendflex-pkg\legendflex')
addpath('C:\Users\annfr888\Documents\MATLAB\toolboxes\legendflex-pkg\setgetpos_V1.2')
%[hleg,icons,plots]= legend('01','02','03','04','05','06','07','08','09','10','Location','eastoutside');
[leg,att] = legendflex(gca, {'01','02 ','03 ','04 ','05 ','06 ','07 ','08 ','09 ','10 '}, 'title', 'Patient ID','anchor',  [5 5], 'buffer', [-10 10],'Interpreter','latex');
%set(findall(leg, 'string', 'my title'), 'fontweight', 'bold','Interpreter','latex');

xlabel('Relaxation [\%]')
%xlabel('Minimum target coverage [\%]')
%ylabel('Amplitude [mA]')
ylabel('Target Coverage [\%]')
ylim([0,100])
%ylabel('Score')
set(gca,'TickLabelInterpreter','latex')

f = gcf;
set(f, 'Position',  [100, 100, 950, 700])
exportgraphics(f,[cohort_path,filesep,'STNTractRelaxationVsTargetCoverage.png'],'Resolution',300)

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
