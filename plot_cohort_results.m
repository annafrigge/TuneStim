function plot_cohort_results(Ncontacts,cohort,scheme,saveImage)

if ~strcmp(scheme,'MILP') || strcmp(scheme,'LP')
    thetas = getfield(cohort,scheme,'thetas');
    figure
    tiledlayout(3,2, 'Padding', 'none', 'TileSpacing', 'compact'); 
    for k=1:length(thetas)
        nexttile
        M{k} = zeros(Ncontacts, 2*length(cohort.pat_names));
        results = getfield(cohort, scheme,'x');
        for i = 1:length(cohort.pat_names)
            for j = 1:2
                idx = (i-1)*2 + j;  % Index in the matrix columns
                cellData = results{i, j,k};  % Extract cell content
                if isempty(cellData)
                    M{k}(:, idx) = 0;  % Fill with zeros if empty
                else
                    M{k}(:, idx) = padarray(cellData(1:min(Ncontacts, end))', Ncontacts - min(Ncontacts, length(cellData)), 0, 'post'); % Truncate or pad to 8 elements
                end
            end
        end
        M{k} = M{k} ./ sum(M{k}, 1);
        set(0,'defaulttextinterpreter','latex')
        set(0, 'DefaultAxesFontSize', 24);
        %subplot(3,2,k)
        imagesc(flipud(M{k}),'XData', 1/2)

        xticks = 1:2:20;  % Define tick positions (every other value)
        xticklabels = 1:length(xticks);  % Define labels that increase as 1,2,3,4...
        Contact_labels = {'4 ','3C','3B','3A','2C','2B','2A','1 '};
        yticks = 1:1:length(Contact_labels);
        xlabel('Patient ID (sin/dx)')

        % Apply xticks and xticklabels to the plot
        set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);
        set(gca, 'YTick', yticks, 'YTickLabel', Contact_labels);
        colorbar
        clim([0 1])
        % colormap(parula(10))
        colormap(sky)

        title(['$\theta = ',num2str(thetas(k)),'$'])
        set(gca,'TickLabelInterpreter','latex')
        axis tight
        axis equal
    end
    f = gcf;
    %set(f, 'Position',  [100, 0, 1620, 1280])
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    if saveImage
        exportgraphics(f,[cohort.path,filesep,'MILP_results',filesep,scheme,'_results_cohort.png'],'Resolution',300)
    end
end

if strcmp(scheme,'MILP') || strcmp(scheme,'LP')
    M = zeros(Ncontacts, 2*length(cohort.pat_names));
    results = getfield(cohort, scheme,'x');

    for i = 1:length(cohort.pat_names)
        for j = 1:2
            idx = (i-1)*2 + j;  % Index in the matrix columns
            cellData = results{i, j};  % Extract cell content
            if isempty(cellData)
                M(:, idx) = 0;  % Fill with zeros if empty
            else
                M(:, idx) = padarray(cellData(1:min(Ncontacts, end))', Ncontacts - min(Ncontacts, length(cellData)), 0, 'post'); % Truncate or pad to 8 elements
            end
        end
    end
    M = M ./ sum(M, 1);  % Normalize columns of M

    set(0,'defaulttextinterpreter','latex')
    set(0, 'DefaultAxesFontSize', 18);
    figure
    imagesc(flipud(M),'XData', 1/2)

    xticks = 1:2:20;  % Define tick positions (every other value)
    xticklabels = 1:length(xticks);  % Define labels that increase as 1,2,3,4...
    Contact_labels = {'4 ','3C','3B','3A','2C','2B','2A','1 '};
    yticks = 1:1:length(Contact_labels);
    xlabel('Patient ID (sin/dx)')

    % Apply xticks and xticklabels to the plot
    set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);
    set(gca, 'YTick', yticks, 'YTickLabel', Contact_labels);
    colorbar
    clim([0 1])
    % colormap(parula(10))
    colormap(sky)

    %title(['\textbf{',scheme,'}'])
    set(gca,'TickLabelInterpreter','latex')
    axis tight
    axis equal
    f = gcf;
    %set(f, 'Position',  [100, 100, 950, 700])
    if saveImage
        exportgraphics(f,[cohort.path,filesep,'MILP_results',filesep,scheme,'_results_cohort.png'],'Resolution',300)
    end
end
end
