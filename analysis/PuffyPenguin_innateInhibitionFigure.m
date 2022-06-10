%% compute detection performance during innate task and optogenetic stimulation

xLabels =  {'EarlyStim' 'LateStim' 'Delay' 'Response'};
fiberLocations = {'A1' 'ALM'};
fiberColors = {[0 0 1] [1 0 0]};

groupnames = {'CStr', 'EMX'};
cPath = '\\naskampa\data\BpodBehavior\';
optoType = [1 4 2 3];

normPerf = cell(1, length(groupnames));
optoPerf = cell(1, length(groupnames));
for x = 1 : length(groupnames)
    
    [bhv{x}, Performance{x}] = PuffyPenguin_loadInnateBhv(groupnames{x}, cPath, true);
    nrMice = length(bhv{x}.Animals);
    
    %%
    for iAnimals = unique(bhv{x}.AnimalID)
        
        normIdx = bhv{x}.optoDur == 0 & ~bhv{x}.DidNotChoose & ~bhv{x}.SingleSpout & bhv{x}.AnimalID == iAnimals;
        optoIdx = bhv{x}.optoDur > 0 & ~bhv{x}.SingleSpout & ~bhv{x}.DidNotChoose & bhv{x}.AnimalID == iAnimals;
        
        normCnt = sum(bhv{x}.Rewarded(normIdx));
        optoCnt = sum(bhv{x}.Rewarded(optoIdx));
        
        normPerf{x}(1,iAnimals) = normCnt / sum(normIdx);
        optoPerf{x}(1,iAnimals) = optoCnt / sum(optoIdx);
        
        [normPerf{x}(2, iAnimals), normPerf{x}(3, iAnimals)] = Behavior_wilsonError(normCnt, sum(normIdx)); %error
        [optoPerf{x}(2, iAnimals), optoPerf{x}(3, iAnimals)] = Behavior_wilsonError(optoCnt, sum(optoIdx)); %error
        
        % keep track of number of trials in each condition/mouse
        normPerf{x}(4,iAnimals) = normCnt;
        optoPerf{x}(4,iAnimals) = optoCnt;
        
    end
end

%% make a figure
for iGroups = 1 : length(groupnames)
    h = figure('renderer' ,'painters'); hold on;
    nrMice = size(normPerf{iGroups},2);
    
    nPerf = normPerf{iGroups};
    oPerf = optoPerf{iGroups};
    
    cLine(1) = errorbar(1:nrMice, nPerf(1,:), nPerf(1,:) - nPerf(3,:), nPerf(2,:) - nPerf(1,:), '-o', 'linewidth' ,4, 'color', 'k' ,'MarkerFaceColor','w', 'MarkerSize', 10);
    cLine(2) = errorbar(1:nrMice, oPerf(1,:), oPerf(1,:) - oPerf(3,:), oPerf(2,:) - oPerf(1,:), '-o', 'linewidth' ,4, 'color', 'b' ,'MarkerFaceColor','w', 'MarkerSize', 10);

    ax = h.Children(1); %current axis
    xlim(ax, [cLine(1).XData(1)-0.5 cLine(1).XData(end)+0.5]);
    ax.XTick = 1:nrMice;
    ax.XTickLabel = bhv{iGroups}.Animals;
    ax.XTickLabelRotation = 45;
    
    nhline(0.5, '--', 'lineWidth',4, 'Color', [0.5 0.5 0.5]);
    axis square;  
    ylim([0.45 1]);
    title(groupnames{iGroups});

    grid on; 
    ylabel('Detection performance');
    set(h,'PaperOrientation','landscape','PaperPositionMode','auto');
    niceFigure(gca);
    
    cLine(1).LineWidth = 4;
    cLine(2).LineWidth = 4;
    
    legend(cLine, {'control' 'opto'});
end