function write_recommendations_to_file(cohort,pat,head,tail,InitialSolution_cell,target_lst,constraint_lst)

%% Compute VTA
disp('Computing volume of tissue activated...')

%compute target activation and spill
disp("Computing target activation")
[pAct_target,pSpill_target,VTA] = ...
    computing_volumes(pat,head,tail,InitialSolution_cell,target_lst,cohort);


%compute constraint activation and spill
disp('Computing constraint activation')
[pAct_constraint,pSpill_constraint,VTA] = ...
    computing_volumes(pat,head,tail,InitialSolution_cell,constraint_lst,cohort);

%% write array of recommendations
wt= cohort.omega(1);% scores need to be normalized for meaningful comparison across a dataset of patients?
wc = cohort.omega(2);
ws = cohort.omega(3);
scores = wt*pAct_target*100-wc*pAct_constraint*100-ws*pSpill_target*100;
%scores = (relaxation/100-pSpill_target*100)^2;

[~,idx] = sort(scores, 'descend');

% write results to .txt
fid=fopen(append(pat.outputPath,filesep,'Suggestions_',pat.space,'_',pat.hand,'_',cohort.optischeme,'_',num2str(pat.rel),'.txt'),'w+');
fprintf(fid,'Contacts \t Target activation %s \t Constraint activation %s \t Spill %s \t Alpha \t VTA \t Score\n\n','%','%','%');

a = cell(length(idx),7);
for j = 1:length(idx)
    in = idx(j);
    a{j,1} = erase(pat.contactNames{in},'.csv');
    a{j,2} = [9 num2str( round(pAct_target(in)*100,2))];
    a{j,3} = num2str( round(pAct_constraint(in)*100,2));
    a{j,4} = num2str( round(pSpill_target(in)*100,2));
    a{j,5} = num2str( round(pat.results.(cohort.optischeme).alpha(in),2));
    a{j,6} = num2str( round(VTA(in),2) );
    a{j,7} = num2str( round(scores(in),2));

    fprintf(fid,' %s \t %s \t\t\t %s \t\t\t %s \t\t %s \t %s \t\t\t %s \n', a{j,1},a{j,2},a{j,3},a{j,4},a{j,5},a{j,6},a{j,7});
end

fclose(fid);

%% Top suggestions for all relaxations
fid = fopen(append(pat.outputPath,filesep,'Top_Suggestions_',pat.space,'_',convertStringsToChars(pat.hand),'_',cohort.optischeme,'_','.txt'),'a');
fprintf(fid,' %s \t %s \t %s \t %s\t %s \t %s \t %s \n',a{1,1},a{1,2},a{1,3},a{1,4},a{1,5},a{1,6},a{1,7});
fclose(fid);
[bestScore, bestIdx] =  max(str2double({a{:,7}}));
if ~exist('bestSolution','var')
    cohort.(cohort.optischeme).bestSolution = a(bestIdx,:);
elseif bestScore > str2double(cohort.(cohort.optischeme).bestSolution{1,7})
    cohort.(cohort.optischeme).bestSolution= a(bestIdx,:);
end

end