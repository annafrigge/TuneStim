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

diceScoresInhom = {[NaN, 0.88], [NaN,0.78]};
diceScoresTarget = {[NaN, 0.97], [NaN,0.89]};
diceScoresConstraint = {[NaN, 0.74],[NaN,0.38};

hands = {"dx","sin",};


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
