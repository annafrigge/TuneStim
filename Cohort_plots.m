clear all
set(0,'defaulttextinterpreter','latex')
set(0, 'DefaultAxesFontSize', 18);


cohort_path = 'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study';
pat_names = ['DBS_104';'DBS_128';'DBS_133';'DBS_139';'DBS_167';...
    'DBS_168';'DBS_171';'DBS_185';'DBS_199';'DBS_204'];
cohort.leads = {'S:t Jude 1331','Boston Scientific 2202', 'S:t Jude 1331',...
         'S:t Jude 1331','Boston Scientific 2202','S:t Jude 1331'...
         'Boston Scientific 2202','S:t Jude 1331',...
         'Boston Scientific 2202','Boston Scientific 2202'};
orientations = {[293,314],[249,288],[12,302],[25,153],[98,193],[52,345],...
               [32,116],[202,184],16.4,[308,38]};

amplitudes = {[3,2.85],[4.6,1.5],[3.4,4.6],[2.6,2],[1.7,2.6],[3.2,1.5],[1.2,3],[4.4,3.3],[3.8,0],[1,2.4]};
cohort.optischeme = 'conservative';%'Ruben';%'mincov';%%
cohort.atlas = 'DISTAL Minimal (Ewert 2017)';
cohort.targets = {'STN_motor.nii.gz'};
cohort.constraints = {'STN_associative.nii.gz','STN_limbic.nii.gz'};
pat.space = 'MNI';
cohort.EThreshold = 200;
relaxation = 0:10:90;


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
        pat.path = append(cohort_path,filesep,pat_names(i,:),filesep);
        if strcmp(pat_names(i,:),'DBS_199') && strcmp(hand,'sin')
            %hand = {"dx"};
            continue
        end
        
        fileName = append(pat.path,'Suggestions',filesep,'STN_motor_tract',...
            filesep,cohort.optischeme,filesep,'100',filesep,'S-1-1-0',...
            filesep,'Top_Suggestions_',pat.space,'_',...
            hand,'_',cohort.optischeme,'_','.txt');
        opts = detectImportOptions(fileName); % Initial detection
        opts.VariableNamesLine = 1; % Set variable names line

        T = readtable(fileName,opts);

        plot(relaxation,T.Score,'Marker',Markers(i),'LineStyle',':',...
             'Color', CT(i,:),'MarkerSize',10,'LineWidth',2)
        %plot(relaxation,T.Target,'Marker',Markers(i),'LineStyle',':',...
        %    'Color', CT(i,:) ,'MarkerSize',10,'LineWidth',2) %cm(i,:)
        %plot(relaxation,T.Alpha,'Marker',Markers(i),'LineStyle',':',...
        %     'Color', CT(i,:),'MarkerSize',10,'LineWidth',2)
        %hold on
        %plot3(relaxation,T.Alpha,T.Target,'Marker','x','LineStyle',':',...
        %    'Color', cm(i,:),'MarkerSize',10,'LineWidth',1)

        %fileNameC = append(pat.path,'Clinical',filesep,...
        %    'EF_',pat.space,'_',hand,'_clinical','.txt');
        %clinicalScore = 2*CovTargetSTNsubsClinical(i,side_nr)-...
        %                CovConstraintSTNsubsClinical(i,side_nr)-...
        %                SpillSTNsubsClinical(i,side_nr);
        %plot(amplitudes{1,i}(side_nr),clinicalScore,'Marker','*','LineStyle',':',...
        %    'Color', cm(i,:),'MarkerSize',10,'LineWidth',1)

        grid on
        hold on
    end

end
addpath('C:\Users\annfr888\Documents\MATLAB\toolboxes\legendflex-pkg\legendflex')
addpath('C:\Users\annfr888\Documents\MATLAB\toolboxes\legendflex-pkg\setgetpos_V1.2')
%[hleg,icons,plots]= legend('01','02','03','04','05','06','07','08','09','10','Location','eastoutside');
[leg,att] = legendflex(gca, {'','','','','','','','','','01','02 ','03 ','04 ','05 ','06 ','07 ',...
            '08 ','09 ','10 '}, 'title', 'Patient ID','anchor',  [5 5], 'buffer', [-10 10],'Interpreter','latex');
%set(findall(leg, 'string', 'my title'), 'fontweight', 'bold','Interpreter','latex');

xlabel('Relaxation [\%]')
%xlabel('Minimum target coverage [\%]')
%ylabel('Amplitude [mA]')
ylabel('Score')
%ylabel('Target Coverage [\%]')
%ylim([0,100])
ylim([0,50])
title('\textbf{STN subdivisions}')

set(gca,'TickLabelInterpreter','latex')

f = gcf;
set(f, 'Position',  [100, 100, 950, 700])
exportgraphics(f,[cohort_path,filesep,'RubenSTNSubsRelaxationVsScore.png'],'Resolution',300)

%% Clinical Dice
hands = {'sin','dx'};
DiceVTA = zeros(length(pat_names),2);
DiceTarget = zeros(length(pat_names),2);
DiceConstraint = zeros(length(pat_names),2);
s=0;
row = 2; % 2-conservative STN subs,3-conservative STN tracts, 4-Ruben STN subs, 5-Ruben STN tracts
for j=1:2
    hand = convertStringsToChars(hands{j});
    if strcmp(hand,'dx')
        side_nr =1;
    else
        side_nr = 2;
    end
    for i=1:length(pat_names)
        s=s+1;
        pat.path = append(cohort_path,filesep,pat_names(i,:),filesep);
        if strcmp(pat_names(i,:),'DBS_199') && strcmp(hand,'sin')
            continue
        end
        fileName = append(pat.path,'Suggestions',filesep,'STN_motor',...
            filesep,'DiceScores',filesep,'Dice_',pat.space,'_',hand,'.txt');
        opts = detectImportOptions(fileName); % Initial detection
        opts.VariableNamesLine = 1; % Set variable names line
        T = readtable(fileName,opts);
        T.Properties.VariableNames = ["Contacts","Amplitude","PW","Ethresh","DiceVTA","DiceTarget","DiceConstraint"];
        %[~,idx] = max(T.Score);
        DiceVTA(i,j) = T.DiceVTA(row);
        DiceTarget(i,j) = T.DiceTarget(row);
        DiceConstraint(i,j) = T.DiceConstraint(row);
    end
end

bar(DiceVTA)
colororder("earth")
leg = legend('Sin','Dx');
leg.Location = 'southeast';
ylabel('Dice-S{\o}rensen coefficient')
xlabel('Patient ID')
ylim([0,1])
title('Inhomogeneous tissue')
f=gcf;
exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\ConservativeSTNSubsDiceVTAClinicalAmplitude.png','Resolution',300)

bar(DiceTarget)
colororder("earth")
leg = legend('Sin','Dx');
leg.Location = 'southeast';
ylabel('Dice-S{\o}rensen coefficient')
xlabel('Patient ID')
ylim([0,1])
title('Target')
f=gcf;
exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\ConservativeSTNSubsDiceTargetClinicalAmplitude.png','Resolution',300)

bar(DiceConstraint)
colororder("earth")
leg = legend('Sin','Dx');
leg.Location = 'southeast';
ylabel('Dice-S{\o}rensen coefficient')
xlabel('Patient ID')
ylim([0,1])
title('Constraint')
f=gcf;
exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\ConservativeSTNSubsDiceConstraintClinicalAmplitude.png','Resolution',300)

%% Clinical Coverages
hands = {'sin','dx'};

s=0;
row = 1; % 1 - clinical settings, 2-conservative STN subs,3-conservative STN tracts, 4-Ruben STN subs, 5-Ruben STN tracts
targets = {'STN_motor';'STN_motor_tract'};
for k=1:length(targets)
    TargetPercents = zeros(length(pat_names),2);
ConstraintPercents = zeros(length(pat_names),2);
for j=1:2
    hand = convertStringsToChars(hands{j});
    if strcmp(hand,'dx')
        side_nr =1;
    else
        side_nr = 2;
    end
    for i=1:length(pat_names)
        s=s+1;
        pat.path = append(cohort_path,filesep,pat_names(i,:),filesep);
        if strcmp(pat_names(i,:),'DBS_199') && strcmp(hand,'sin')
            continue
        end

        fileName = append(pat.path,'Suggestions',filesep,targets{k},...
            filesep,'Coverages',filesep,'Coverages_',pat.space,'_',hand,'.txt');
        opts = detectImportOptions(fileName); % Initial detection
        opts.VariableNamesLine = 1; % Set variable names line
        T = readtable(fileName,opts);
        T.Properties.VariableNames = ["Contacts","Amplitude","PW","Ethresh","TargetCoverage","Spill","ConstraintCoverage"];
        %[~,idx] = max(T.Score);
        TargetPercents(i,j) = T.TargetCoverage(row)*100;
        ConstraintPercents(i,j) = T.ConstraintCoverage(row)*100;
    end
end
if k==1
figure
set(0, 'DefaultAxesFontSize', 12);
subplot(1,2,1)
colororder("earth")
bar(TargetPercents)
xtickangle(0)
leg = legend('Sin','Dx');
leg.Location = 'northeast';
ylabel('Points activated [\%]')
xlabel('Patient ID')
ylim([0,100])

%figure
subplot(1,2,2)
bar(ConstraintPercents)
colororder("earth")
leg = legend('Sin','Dx');
leg.Location = 'northeast';
ylabel('Points activated [\%]')
xlabel('Patient ID')
xtickangle(0)
ylim([0,100])
%sgtitle('\textbf{STN subdivisions}')

f=gcf;
set(gcf, 'Position',  [100, 100, 550, 250])
exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\ClinicalSTNSubsCoveragePointWise.png','Resolution',300)
elseif k==2
    TargetPercents = TargetPercents*0.01;
    ConstraintPercents = ConstraintPercents*0.01;
    figure
    set(0, 'DefaultAxesFontSize', 12);
    subplot(1,2,1)
    colororder("earth")
    bar(TargetPercents)
    xtickangle(0)
    leg = legend('Sin','Dx');
    leg.Location = 'northeast';
    ylabel('Fibers activated [\%]')
    xlabel('Patient ID')
    title('Target VTA')
    ylim([0,100])

    subplot(1,2,2)
    bar(ConstraintPercents)
    colororder("earth")
    xtickangle(0)
    leg = legend('Sin','Dx');
    leg.Location = 'northeast';
    ylabel('Fibers activated [\%]')
    xlabel('Patient ID')
    ylim([0,100])
    title('Constraint VTA')
    %sgtitle('\textbf{STN tracts}')
    set(gcf, 'Position',  [100, 100, 550, 250])
    f= gcf;
    exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\ClinicalSTNTractsCoverageFiberWise.png','Resolution',300)
end

end
%% Clinical VTA alphaShapes
% How much of the VTA volume is spend on target or constraint coverage?
hands = {'sin','dx'};

s=0;
row = 1; % 1 - clinical settings, 2-conservative STN subs,3-conservative STN tracts, 4-Ruben STN subs, 5-Ruben STN tracts
targets = {'STN_motor';'STN_motor_tract'};
for k=1:length(targets)
TargetPercents = zeros(length(pat_names),2);
ConstraintPercents = zeros(length(pat_names),2);
for j=1:2
    hand = convertStringsToChars(hands{j});
    if strcmp(hand,'dx')
        side_nr =1;
    else
        side_nr = 2;
    end
    for i=1:length(pat_names)
        s=s+1;
        pat.path = append(cohort_path,filesep,pat_names(i,:),filesep);
        if strcmp(pat_names(i,:),'DBS_199') && strcmp(hand,'sin')
            TargetPercents(i,j)= NaN;
            ConstraintPercents(i,j) = NaN;
            continue
        end

        fileName = append(pat.path,'Suggestions',filesep,targets{k},...
            filesep,'alphaShapeCoverages',filesep,'alphaShapeCoverages_',pat.space,'_',hand,'.txt');
        opts = detectImportOptions(fileName); % Initial detection
        opts.VariableNamesLine = 1; % Set variable names line
        T = readtable(fileName,opts);
        T=rmmissing(T,2);
        T.Properties.VariableNames = ["Contacts","Amplitude","PW","Ethresh","VTAVolume","TargetPercent","ConstraintPercent"];
        %[~,idx] = max(T.Score);
        TargetPercents(i,j) = T.TargetPercent(row);
        ConstraintPercents(i,j) = T.ConstraintPercent(row);
    end
end
TargetPercents = rmmissing(reshape(TargetPercents.',1,[]));
ConstraintPercents = rmmissing(reshape(ConstraintPercents.',1,[]));
if k==1
figure
set(0, 'DefaultAxesFontSize', 12);
subplot(2,2,1)
colororder("earth")
h=histogram(TargetPercents,6,'FaceAlpha',1);
ylabel('Count')
xlabel('Target VTA [\%]')
xlim([0,36])
xticks([0,10,20,30])
ylim([0,7.2])
set(0, 'DefaultAxesFontSize', 18);
title('\textbf{STN subdivisions}')

% Fit straight line using Least Squares
bin_centers = (h.BinEdges(1:end-1) + h.BinEdges(2:end)) / 2;
bin_heights = h.Values;
p = polyfit(bin_centers,bin_heights,0);
hold on
x_values = linspace(0, 36, 100);
plot(x_values, p*ones(100,1), 'r-', 'LineWidth', 2);



%figure
set(0, 'DefaultAxesFontSize', 12);
subplot(2,2,3)
colororder("earth")
histogram(ConstraintPercents,6,'FaceAlpha',1)
ylabel('Count')
xlabel('Constraint VTA [\%]')
ylim([0,7.2])
xlim([0,36])
xticks([0,10,20,30])
%title('\textbf{STN subdivisions}')
%pd = fitdist(ConstraintPercents', 'Lognormal');
%hold on
%x_values = linspace(min(ConstraintPercents), max(ConstraintPercents), 100);
%pdf_values = pdf(pd, x_values);
%plot(x_values, pdf_values * (length(ConstraintPercents) * (max(ConstraintPercents) - min(ConstraintPercents)) / 6), 'r-', 'LineWidth', 2);

elseif k==2
subplot(2,2,2)
colororder("earth")
h=histogram(TargetPercents,6,'FaceAlpha',1);
%ylabel('Count')
xlabel('Target VTA [\%]')
xlim([0,21])
ylim([0,7.2])
xticks([0,10,20])
set(0, 'DefaultAxesFontSize', 18);
title('\textbf{STN tracts}')
% fit lognorm distribution
%pd = fitdist(TargetPercents', 'Lognormal');
%hold on
%x_values = linspace(min(TargetPercents), max(TargetPercents), 100);
%pdf_values = pdf(pd, x_values);
%plot(x_values, pdf_values * (length(TargetPercents) * (max(TargetPercents) - min(TargetPercents)) / 6), 'r-', 'LineWidth', 2);

% fit splines
bin_centers = (h.BinEdges(1:end-1) + h.BinEdges(2:end)) / 2;
bin_heights = h.Values;
x_values = linspace(min(TargetPercents), max(TargetPercents), 100);
spline_curve = spline(bin_centers, bin_heights, x_values);
hold on
plot(x_values, spline_curve, 'r-', 'LineWidth', 2);

subplot(2,2,4)
colororder("earth")
set(0, 'DefaultAxesFontSize', 12);
histogram(ConstraintPercents,6,'FaceAlpha',1)
%ylabel('Count')
xlabel('Constraint VTA [\%]')
ylim([0,12.2])
xlim([0,21])
xticks([0,10,20])
%title('\textbf{STN tracts}')
end
end
f=gcf;
exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\ClinicalVTAAlphaShapeDistributions.png','Resolution',300)
%% Plotting preferred contact combinations
hands = {'sin','dx'};
CT = orderedcolors('gem12');
Contacts = {'C4X','C3C','C3B','C3A','C2C','C2B','C2A','C1X'};
M = zeros(length(Contacts),length(pat_names)*2);
s=0;
for i=1:length(pat_names)
    for j=1:2
        s=s+1;
        hand = convertStringsToChars(hands{j});
        if strcmp(hand,'dx')
            side_nr =1;
        else
            side_nr = 2;
        end

        disp(append(pat_names(i,:),' ',hand))
        pat.path = append(cohort_path,filesep,pat_names(i,:),filesep);
        if strcmp(pat_names(i,:),'DBS_199') && strcmp(hand,'sin')
            %hand = {"dx"};
            continue
        end

        fileName = append(pat.path,'Suggestions',filesep,'STN_motor_tract',...
            filesep,cohort.optischeme,filesep,'100',filesep,'S-1-1-0',...
            filesep,'Top_Suggestions_',pat.space,'_',...
            hand,'_',cohort.optischeme,'_','.txt');
        opts = detectImportOptions(fileName); % Initial detection
        opts.VariableNamesLine = 1; % Set variable names line

        T = readtable(fileName,opts);

        for k = 1:length(Contacts)
            if isnan(T.Alpha)
                continue
            else
            M(k,s)= M(k,s) + sum(contains(T.Contacts,Contacts(k)));
            end
        end
        
        hold on
    end
end

figure
imagesc(M,'XData', 1/2)


xticks = 1:2:20;  % Define tick positions (every other value)
xticklabels = 1:length(xticks);  % Define labels that increase as 1,2,3,4...
Contact_labels = {'4 ','3C','3B','3A','2C','2B','2A','1 '};
yticks = 1:1:length(Contacts);  
xlabel('Patient ID (sin/dx)')

% Apply xticks and xticklabels to the plot
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);
set(gca, 'YTick', yticks, 'YTickLabel', Contact_labels);
%set(gca,'YTickLabel',[]);
colorbar
colormap(parula(10))
clim([0 10]);
title('\textbf{STN tracts}')
set(gca,'TickLabelInterpreter','latex')
axis tight
axis equal
f = gcf;
%set(f, 'Position',  [100, 100, 950, 700])
exportgraphics(f,[cohort_path,filesep,'ConservativeSTNTractCount100.png'],'Resolution',300)

%% Extract Top suggested settings
hands = {'sin','dx'};
M = table;
M.name = pat_names(:,:);
for i=1:length(pat_names)
    for j=1:2
        hand = convertStringsToChars(hands{j});
        if strcmp(hand,'dx')
            side_nr =1;
        else
            side_nr = 2;
        end

        disp(append(pat_names(i,:),' ',hand))
        pat.path = append(cohort_path,filesep,pat_names(i,:),filesep);
        if strcmp(pat_names(i,:),'DBS_199') && strcmp(hand,'sin')
            %hand = {"dx"};
            continue
        end

        fileName = append(pat.path,'Suggestions',filesep,'STN_motor',...
            filesep,cohort.optischeme,filesep,'100',filesep,'S-1-1-0',...
            filesep,'Top_Suggestions_',pat.space,'_',...
            hand,'_',cohort.optischeme,'_','.txt');
        opts = detectImportOptions(fileName); % Initial detection
        opts.VariableNamesLine = 1; % Set variable names line

        T = readtable(fileName,opts);
        [~,idx] = max(T.Score);
        M.(hand)(i) = T.Contacts(idx);
        M.(append('A_',hand))(i) = T.Alpha(idx);
    end
end

