clear all
set(0,'defaulttextinterpreter','latex')
set(0, 'DefaultAxesFontSize', 18);


cohort_path = 'C:\Users\annfr888\Documents\DBS\patient_data\lead_v3\PipelineStudy';
pat_names = ['DBS104';'DBS128';'DBS133';'DBS139';'DBS167';...
    'DBS168';'DBS171';'DBS185';'DBS199';'DBS204'];
cohort.leads = {'Abbott Infinity Directed (short)','Boston Scientific Vercise Directional 2202', 'Abbott Infinity Directed (short)',...
         'Abbott Infinity Directed (short)','Boston Scientific Vercise Directional 2202','Abbott Infinity Directed (short)'...
         'Boston Scientific Vercise Directional 2202','Abbott Infinity Directed (short)',...
         'Boston Scientific Vercise Directional 2202','Boston Scientific Vercise Directional 2202'};
orientations = {[-55.7,81.6],[-111.4,-74.2],[-170.5,-62.3],[19.4,157.6],[97.5,14.2],[72.7,21.2],...
               [-145.6,115.5],[-157.7,-175.9],14.4,[-52,35.6]};

amplitudes = {[3,2.85],[4.6,1.5],[3.4,4.6],[2.6,2],[1.7,2.6],[3.2,1.5],[1.2,3],[4.4,3.3],[3.8,0],[1,2.4]};
cohort.optischeme = 'Linear';%'mincov';%% 'Linear';%
cohort.atlas = 'DISTAL Minimal (Ewert 2017)';
cohort.targets = {'STN_motor.nii.gz'};
cohort.constraints = {'STN_associative.nii.gz','STN_limbic.nii.gz'};
target = 'STN_motor_tract'; % 'STN_motor'; %
constraint = 'STN_associative_tract_STN_limbic_tract'; % 'STN_limbic_STN_associative'; %
pat.space = 'MNI';
cohort.EThreshold = 200;
relaxation = 0:10:90;
cohort.activation = 'pointwise'; %''; %'fiberwise'; %

%% Plotting
hands = {'sin','dx'};
CT = orderedcolors('gem12');
Markers = {'+','o','*','x','v','d','^','s','>','<'};
lineStyles = {'-', '--', ':', '-.', '-', '--', ':', '-.', '-', '--'};
h = gobjects(length(pat_names),1); % preallocate graphics handles
for j=1:2
    hand = convertStringsToChars(hands{j});
    if strcmp(hand,'dx')
        side_nr =1;
    else
        side_nr = 2;
    end
    for i=1:length(pat_names)
        disp(append(pat_names(i,:),' ',hand))
        pat.path = append(cohort_path,filesep,'derivatives',filesep,...
            'TuneS',filesep,'sub-',pat_names(i,:),filesep);
        if strcmp(pat_names(i,:),'DBS199') && strcmp(hand,'sin')
            %hand = {"dx"};
            continue
        end

        fileName = append(pat.path,'Suggestions_old',filesep, target,...
            '__',constraint,filesep,cohort.optischeme,filesep,'100',filesep,'S-1-1-0',...
            filesep,'Top_Suggestions_',pat.space,'_',...
            hand,'_',cohort.optischeme,'_',cohort.activation,'.txt');
        % fileName = append(pat.path,'Suggestions',filesep, target,...
        %     filesep,cohort.optischeme,filesep,'100',filesep,'S-1-1-0',...
        %     filesep,'Top_Suggestions_',pat.space,'_',...
        %     hand,'_',cohort.optischeme,'_','.txt');
        opts = detectImportOptions(fileName); % Initial detection
        opts.VariableNamesLine = 1; % Set variable names line

        T = readtable(fileName,opts);

        h(i)=plot(relaxation,T.Score,'Marker',Markers(i),'LineStyle',':',...
             'Color', CT(i,:),'MarkerSize',10,'LineWidth',2);
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
labels = {'01','02','03','04','05','06','07','08','09','10'};

%[leg,att] = legendflex(gca, {'','','','','','','','','','01','02 ','03 ','04 ','05 ','06 ','07 ',...
%            '08 ','09 ','10 '}, 'title', 'Patient ID','anchor',  [5 5], 'buffer', [-10 10],'Interpreter','latex');


xlabel('Relaxation [\%]')
%xlabel('Minimum target coverage [\%]')
%ylabel('Amplitude [mA]')
ylabel('Score')
%ylabel('Target Coverage [\%]')
ylim([0,100])
%ylim([0,50])
xlim([0,92])
if strcmp(target,'STN_motor')
    title('\textbf{STN Subdivisions}')
elseif strcmp(target,'STN_motor_tract') & strcmp(cohort.activation,'fiberwise')
    title('\textbf{STN Streamlines trajectory-wise}')
elseif strcmp(target,'STN_motor_tract') & strcmp(cohort.activation,'pointwise')
    title('\textbf{STN Streamlines point-wise}')
end



f = gcf;
set(f, 'Position',  [100, 100, 950, 700])
lgd = legend(h, labels, 'Location','southeast', 'Interpreter','latex');
lgd.Title.String = 'Patient ID';
lgd.Title.Interpreter = 'latex';    % if you want LaTeX rendering
lgd.Title.FontWeight = 'bold';  
set(gca,'TickLabelInterpreter','latex')

exportgraphics(f,[cohort_path,filesep,'derivatives',filesep,'TuneS',filesep,...
    'figs',filesep,cohort.optischeme,'_',target,'RelaxationVsScore_',cohort.activation,'.png'],'Resolution',300)


%% Clinical Dice
hands = {'sin','dx'};
DiceVTA = zeros(length(pat_names),2);
DiceTarget = zeros(length(pat_names),2);
DiceConstraint = zeros(length(pat_names),2);
s=0;
row = 2; % 2-Nonlinear STN subs,3-Linear STN subs, 4-Nonlinear STN tracts, 5-Linear STN tracts
for j=1:2
    hand = convertStringsToChars(hands{j});
    if strcmp(hand,'dx')
        side_nr =1;
    else
        side_nr = 2;
    end
    for i=1:length(pat_names)
        s=s+1;
        pat.path = append(cohort_path,filesep,'derivatives',filesep,...
            'TuneS',filesep,'sub-',pat_names(i,:),filesep);
        if strcmp(pat_names(i,:),'DBS199') && strcmp(hand,'sin')
            continue
        end

       fileName = append(pat.path,'Suggestions_old',filesep, target,...
            '__',constraint,filesep,'Dice_',pat.space,'_',hand,'_',cohort.activation,'.txt');
        % fileName = append(pat.path,'Suggestions',filesep, target,...
        %     filesep,'DiceScores',filesep,'Dice_',pat.space,'_',hand,'.txt');
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

figure
bar(DiceVTA)
colororder("earth")
leg = legend('Sin','Dx');
leg.Location = 'southeast';
ylabel('Dice-S{\o}rensen coefficient')
xlabel('Patient ID')
ylim([0,1])
title('Entire VTA')
f=gcf;
%exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\ConservativeSTNSubsDiceVTAClinicalAmplitude.png','Resolution',300)

figure
bar(DiceTarget)
colororder("earth")
leg = legend('Sin','Dx');
leg.Location = 'southeast';
ylabel('Dice-S{\o}rensen coefficient')
xlabel('Patient ID')
ylim([0,1])
title('Target')
f=gcf;
%exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\ConservativeSTNSubsDiceTargetClinicalAmplitude.png','Resolution',300)

figure
bar(DiceConstraint)
colororder("earth")
leg = legend('Sin','Dx');
leg.Location = 'southeast';
ylabel('Dice-S{\o}rensen coefficient')
xlabel('Patient ID')
ylim([0,1])
title('Constraint')
f=gcf;
%exportgraphics(f,'C:\Users\annfr888\Documents\DBS\patient_data\Pipeline_study\ConservativeSTNSubsDiceConstraintClinicalAmplitude.png','Resolution',300)

%% Clinical Coverages
hands = {'sin','dx'};

s=0;
row = 1; % 1 - clinical settings, 2-conservative STN subs,3-conservative STN tracts, 4-Ruben STN subs, 5-Ruben STN tracts
targets = {'STN_motor';'STN_motor_tract';'STN_motor_tract'};
constraints = {'STN_limbic_STN_associative'; 'STN_associative_tract_STN_limbic_tract';  'STN_associative_tract_STN_limbic_tract'};
activations = {'_pointwise';'_pointwise';'_fiberwise'};

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
        pat.path = append(cohort_path,filesep,'derivatives',filesep,...
            'TuneS',filesep,'sub-',pat_names(i,:),filesep);
        if strcmp(pat_names(i,:),'DBS199') && strcmp(hand,'sin')
            continue
        end
        
        fileName = append(pat.path,'Suggestions_old',filesep,targets{k},'__',constraints{k},...
            filesep,'Coverages',filesep,'Coverages_',pat.space,'_',hand,activations{k},'.txt');

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
title('Target') 

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
title('Constraint') 
%sgtitle('\textbf{STN subdivisions}')

f=gcf;
set(gcf, 'Position',  [100, 100, 550, 250])
% --- Shared main title ---

 sgtitle('\textbf{STN Subdivisions}')  % centered over both



exportgraphics(f,[cohort_path,filesep,'derivatives',filesep,'TuneS',filesep,...
    'figs',filesep,'Clinical_',targets{k},'_CoveragePointWise.png'],'Resolution',300); 
elseif k==2
    %TargetPercents = TargetPercents*0.01;
    %ConstraintPercents = ConstraintPercents*0.01;
    figure
    set(0, 'DefaultAxesFontSize', 12);
    subplot(1,2,1)
    colororder("earth")
    bar(TargetPercents)
    xtickangle(0)
    leg = legend('Sin','Dx');
    leg.Location = 'northeast';
    %ylabel('Fibers activated [\%]')
    ylabel('Points activated [\%]')
    xlabel('Patient ID')
    title('Target VTA')
    ylim([0,100])

    subplot(1,2,2)
    bar(ConstraintPercents)
    colororder("earth")
    xtickangle(0)
    leg = legend('Sin','Dx');
    leg.Location = 'northeast';
    %ylabel('Fibers activated [\%]')
    ylabel('Points activated [\%]')
    xlabel('Patient ID')
    ylim([0,100])
    title('Constraint VTA')
    %sgtitle('\textbf{STN tracts}')
    set(gcf, 'Position',  [100, 100, 550, 250])
    f= gcf;

    % --- Shared main title ---
    sgtitle('\textbf{STN Streamlines point-wise }')

    exportgraphics(f,[cohort_path,filesep,'derivatives',filesep,'TuneS',filesep,...
        'figs',filesep,'Clinical_',targets{k},'_CoveragePointWise.png'],'Resolution',300);
    elseif k==3
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
    %ylabel('Fibers activated [\%]')
    ylabel('Streamlines activated [\%]')
    xlabel('Patient ID')
    title('Target VTA')
    ylim([0,100])

    subplot(1,2,2)
    bar(ConstraintPercents)
    colororder("earth")
    xtickangle(0)
    leg = legend('Sin','Dx');
    leg.Location = 'northeast';
    %ylabel('Fibers activated [\%]')
    ylabel('Streamlines activated [\%]')
    xlabel('Patient ID')
    ylim([0,100])
    title('Constraint VTA')
    %sgtitle('\textbf{STN tracts}')
    set(gcf, 'Position',  [100, 100, 550, 250])
    f= gcf;

    % --- Shared main title ---
    sgtitle('\textbf{STN Streamlines trajectory-wise }')

    exportgraphics(f,[cohort_path,filesep,'derivatives',filesep,'TuneS',filesep,...
        'figs',filesep,'Clinical_',targets{k},'_CoverageFiberWise.png'],'Resolution',300);
end

end
%% Clinical VTA alphaShapes
% How much of the VTA volume is spend on target or constraint coverage?
hands = {'sin','dx'};

s=0;
row = 1; % 1 - clinical settings, 2 - Nonlinear STN subs, 3 - linear STN subs, 4 - Nonlinear STN tracts, 5 - Linear STN tracts, 6 - Linear STN tracts fiberwise, 7- Nonlinear STN tracts fiberwise
targets = {'STN_motor';'STN_motor_tract';'STN_motor_tract'};
constraints = {'STN_limbic_STN_associative'; 'STN_associative_tract_STN_limbic_tract';  'STN_associative_tract_STN_limbic_tract'};
activations = {'pointwise';'pointwise';'fiberwise'};
for k=1:2%length(targets)
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
        pat.path = append(cohort_path,filesep,'derivatives',filesep,...
            'TuneS',filesep,'sub-',pat_names(i,:),filesep);
        if strcmp(pat_names(i,:),'DBS199') && strcmp(hand,'sin')
            TargetPercents(i,j)= NaN;
            ConstraintPercents(i,j) = NaN;
            continue
        end
         fileName = append(pat.path,'Suggestions_old',filesep, targets{k},...
            '__',constraints{k},filesep,'alphaShapeCoverages',filesep,'alphaShapeCoverages_',pat.space,'_',hand,'_',activations{k},'.txt');
        % fileName = append(pat.path,'Suggestions',filesep,targets{k},...
        %     filesep,'alphaShapeCoverages',filesep,'alphaShapeCoverages_',pat.space,'_',hand,'.txt');
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
xlim([0,60.2])
xticks([0,10,20,30, 40, 50, 60])
ylim([0,12.2])
set(0, 'DefaultAxesFontSize', 18);
title('\textbf{STN subdivisions}')

% % Fit straight line using Least Squares
% bin_centers = (h.BinEdges(1:end-1) + h.BinEdges(2:end)) / 2;
% bin_heights = h.Values;
% p = polyfit(bin_centers,bin_heights,0);
% hold on
% x_values = linspace(0, 36, 100);
% plot(x_values, p*ones(100,1), 'r-', 'LineWidth', 2);
% fit splines
bin_centers = (h.BinEdges(1:end-1) + h.BinEdges(2:end)) / 2;
bin_heights = h.Values;
x_values = linspace(min(TargetPercents), max(TargetPercents), 100);
spline_curve = spline(bin_centers, bin_heights, x_values);
hold on
plot(x_values, spline_curve, 'r-', 'LineWidth', 2);


%figure
set(0, 'DefaultAxesFontSize', 12);
subplot(2,2,3)
colororder("earth")
histogram(ConstraintPercents,6,'FaceAlpha',1);
ylabel('Count')
xlabel('Constraint VTA [\%]')
ylim([0,15.2])
xlim([0,22.2])
xticks([0,5,10])




elseif k==2
subplot(2,2,2)
colororder("earth")
h=histogram(TargetPercents,6,'FaceAlpha',1);
%ylabel('Count')
xlabel('Target VTA [\%]')
xlim([0,65.2])
ylim([0,10.2])
xticks([0,10,20,30,40,50,60])
set(0, 'DefaultAxesFontSize', 18);
title('\textbf{STN streamlines}')


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
ylim([0,16.2])
xlim([0,12.2])
xticks([0,10,20])
%title('\textbf{STN tracts}')

elseif k==3
subplot(2,3,3)
colororder("earth")
h=histogram(TargetPercents,6,'FaceAlpha',1);
%ylabel('Count')
xlabel('Target VTA [\%]')
xlim([0,70])
ylim([0,9.2])
xticks([0,10,20,30,40,50,60,70])
set(0, 'DefaultAxesFontSize', 18);
title('\textbf{STN streamlines}')
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

subplot(2,3,6)
colororder("earth")
set(0, 'DefaultAxesFontSize', 16);
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
exportgraphics(f,[cohort_path,filesep,'derivatives',filesep,'TuneS',filesep,...
    'figs',filesep,'ClinicalVTAAlphaShapeDistributions.png'],'Resolution',300)
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
        pat.path = append(cohort_path,filesep,'derivatives',filesep,...
            'TuneS',filesep,'sub-',pat_names(i,:),filesep);
        if strcmp(pat_names(i,:),'DBS199') && strcmp(hand,'sin')
            %hand = {"dx"};
            continue
        end
        fileName = append(pat.path,'Suggestions_old',filesep, target,...
            '__',constraint,filesep,cohort.optischeme,filesep,'100',filesep,'S-1-1-0',...
            filesep,'Top_Suggestions_',pat.space,'_',...
            hand,'_',cohort.optischeme,'_',cohort.activation,'.txt');

            % fileName = append(pat.path,'Suggestions',filesep,target,...
            % filesep,cohort.optischeme,filesep,'100',filesep,'S-1-1-0',...
            % filesep,'Top_Suggestions_',pat.space,'_',...
            % hand,'_',cohort.optischeme,'_','.txt');
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
%colormap(parula(10))
colormap(sky(10))
%clim([0 10]);
if strcmp(target,'STN_motor')
    title('\textbf{STN Subdivisions}','FontSize',22)
elseif strcmp(target,'STN_motor_tract') & strcmp(cohort.activation,'fiberwise')
    title('\textbf{STN Streamlines trajectory-wise}','FontSize',22)
elseif strcmp(target,'STN_motor_tract') & strcmp(cohort.activation,'pointwise')
    title('\textbf{STN Streamlines point-wise}','FontSize',22)
end


set(gca,'TickLabelInterpreter','latex')
axis tight
axis equal
f = gcf;
set(f, 'Position',  [100, 100, 950, 700])
exportgraphics(f,[cohort_path,filesep,'derivatives',filesep,'TuneS',filesep,...
    'figs',filesep,cohort.optischeme,'_',target,'Counts_',cohort.activation,'.png'],'Resolution',300)


%% Cohort level comparison - clinical coverages vs optimized
set(0,'defaulttextinterpreter','latex')
set(0, 'DefaultAxesFontSize', 18);

hands = {'sin','dx'};

s=0;
rows = 3; % 1 - clinical settings, 2 - linear STN subs,3- nonlinear STN subs, 4 - linear STN tracts, 6 - Ruben STN subs, 5-Ruben STN tracts
targets = {'STN_motor';'STN_motor_tract';'STN_motor_tract'};
constraints = {'STN_limbic_STN_associative'; 'STN_associative_tract_STN_limbic_tract';  'STN_associative_tract_STN_limbic_tract'};
activations = {'_pointwise';'_pointwise';'_fiberwise'};
lrows = [1 2 3];
TargetAll = nan(length(pat_names)*2, rows);
ConstraintAll = nan(length(pat_names)*2, rows);
for k = 1%1:length(targets)
for l = 1:rows
    row = lrows(l);
    s = 0;
        for j = 1:2
            hand = convertStringsToChars(hands{j});
            for i = 1:length(pat_names)
                s = s+1;
                pat.path = append(cohort_path,filesep,'derivatives',filesep, ...
                                  'TuneS',filesep,'sub-',pat_names(i,:),filesep);
                if strcmp(pat_names(i,:),'DBS199') && strcmp(hand,'sin')
                    TargetAll(s,row) = NaN;
                    ConstraintAll(s,row) = NaN;
                    continue
                end

                fileName = append(pat.path,'Suggestions_old',filesep, ...
                                  targets{k},'__',constraints{k}, ...
                                  filesep,'Coverages',filesep, ...
                                  'Coverages_',pat.space,'_',hand,activations{k},'.txt');

                opts = detectImportOptions(fileName);
                opts.VariableNamesLine = 1;
                T = readtable(fileName,opts);
                T.Properties.VariableNames = ["Contacts","Amplitude","PW","Ethresh","TargetCoverage","Spill","ConstraintCoverage"];
                if k <3
                    TargetAll(s,l) = T.TargetCoverage(row)*100;
                    ConstraintAll(s,l) = T.ConstraintCoverage(row)*100;
                else
                    TargetAll(s,l) = T.TargetCoverage(row);
                    ConstraintAll(s,l) = T.ConstraintCoverage(row);
                end
            end
        end
end

v = TargetAll(:,end);
TargetAll(:,end) = TargetAll(:,end-1);
TargetAll(:,end-1) = v;

v = ConstraintAll(:,end);
ConstraintAll(:,end) = ConstraintAll(:,end-1);
ConstraintAll(:,end-1) = v;
clear v

% Plot Target Coverage
% Define colors for each row
colors = lines(rows);

%t = tiledlayout(2,1,'TileSpacing','compact','Padding','none'); 
figure
%hold on
% --- Plot colored boxcharts ---
ax1 = axes('Position',[0.1 0.58 0.75 0.35]); % [left bottom width height]
hold(ax1,'on')

spacing = 0.6; % distance between groups
xpos = (1:rows) * spacing; % new compact x positions

for r = 1:rows
    yvals = TargetAll(:,r);
    yvals = yvals(~isnan(yvals));
    b = boxchart(repmat(xpos(r),size(yvals)), yvals, 'BoxFaceColor', colors(r,:), 'MarkerStyle','none','BoxWidth', 0.35);
    b.BoxFaceAlpha = 0.5;  % semi-transparent
end

% --- Overlay scatter (compact swarm) ---
for r = 1:rows
    yvals = TargetAll(~isnan(TargetAll(:,r)), r);
    xvals = xpos(r) + 0.05*randn(size(yvals)); % small jitter
    scatter(xvals, yvals, 60, 'filled', 'MarkerFaceColor', colors(r,:), 'MarkerFaceAlpha',0.6, 'MarkerEdgeColor','k');
end

ylim(ax1,[0 101])
xlim(ax1,[min(xpos)-0.5*spacing, max(xpos)+0.5*spacing])
xticks(ax1, xpos)
xticklabels(ax1,{''})
ylabel(ax1,'Target Coverage (\%)','FontSize',22)
%xticklabels({'Clinical','STN subdivisions linear','STN subdivisions nonlinear', ...
%             'STN streamlines linear point-wise','STN streamlines linear trajectory-wise',...
%             'STN streamlines nonlinear trajectory-wise','STN streamlines nonlinear trajectory-wise'})

ax2 = axes('Position',[0.1 0.20 0.75 0.35]); % move closer to top axes
hold(ax2,'on')
% --- Plot colored boxcharts ---
for r = 1:rows
    yvals = ConstraintAll(:,r);
    yvals = yvals(~isnan(yvals));
    b = boxchart(repmat(xpos(r),size(yvals)), yvals, 'BoxFaceColor', colors(r,:), 'MarkerStyle','none','BoxWidth', 0.35);
    b.BoxFaceAlpha = 0.5;  % semi-transparent
end

% --- Overlay scatter (compact swarm) ---
for r = 1:rows
    yvals = ConstraintAll(~isnan(ConstraintAll(:,r)), r);
    xvals = xpos(r)  + 0.05*randn(size(yvals)); % small jitter
    scatter(xvals, yvals, 60, 'filled', 'MarkerFaceColor', colors(r,:), 'MarkerFaceAlpha',0.6, 'MarkerEdgeColor','k');
end

ylim(ax2,[0 101])
xlim(ax2,[min(xpos)-0.5*spacing, max(xpos)+0.5*spacing])
xticks(ax2,xpos)
%xticklabels(ax2,{'Clinical','Subdivisions linear','Subdivisions nonlinear', ...
%             'Streamlines linear point-wise','Streamlines linear trajectory-wise',...
%             'Streamlines linear trajectory-wise','Streamlines nonlinear trajectory-wise'})
xticklabels(ax2,{'Clinical','Linear','Nonlinear',})
ylabel(ax2,'Constraint Coverage (\%)','FontSize',22)


if k==1
    sgtitle('\textbf{STN Subdivisions}','FontSize',24)
elseif k==2
    sgtitle('\textbf{STN Streamlines point-wise}','FontSize',24)
elseif k==3
    sgtitle('\textbf{STN Streamlines trajectory-wise}','FontSize',24)
end

set([ax1 ax2],'FontSize',22,'TickLabelInterpreter','latex')
hold off
f = gcf;
set(f, 'Position',  [100, 100, 940, 900])

exportgraphics(gcf,[cohort_path,filesep,'derivatives',filesep,'TuneS',filesep,...
    'figs',filesep,'cohort_',targets{k},activations{k},'short.png'],'Resolution',300)

end
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
        pat.path = append(cohort_path,filesep,'derivatives',filesep,...
            'TuneS',filesep,'sub-',pat_names(i,:),filesep);
        if strcmp(pat_names(i,:),'DBS199') && strcmp(hand,'sin')
            %hand = {"dx"};
            continue
        end
                fileName = append(pat.path,'Suggestions_old',filesep, target,...
            '__',constraint,filesep,cohort.optischeme,filesep,'100',filesep,'S-1-1-0',...
            filesep,'Top_Suggestions_',pat.space,'_',...
            hand,'_',cohort.optischeme,'_',cohort.activation,'.txt');
        % fileName = append(pat.path,'Suggestions',filesep,target,...
        %     filesep,cohort.optischeme,filesep,'100',filesep,'S-1-1-0',...
        %     filesep,'Top_Suggestions_',pat.space,'_',...
        %     hand,'_',cohort.optischeme,'_','.txt');
        opts = detectImportOptions(fileName); % Initial detection
        opts.VariableNamesLine = 1; % Set variable names line

        T = readtable(fileName,opts);
        [~,idx] = max(T.Score);
        M.(hand)(i) = T.Contacts(idx);
        M.(append('A_',hand))(i) = T.Alpha(idx);
    end
end

M