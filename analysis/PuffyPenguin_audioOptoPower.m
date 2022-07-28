%% compute detection performance with bilateral during different task episodes from handle to response period
% only use mice that also have parietal data
% bhv = selectBehaviorTrials(bhv,ismember(bhv.AnimalID, unique(bhv.AnimalID(bhv.stimLocation == 2))));

fiberLocations = 'ALM';
groupnames = {'CStr' 'EMX'};
cPath = '\\naskampa\data\BpodBehavior\';



%% go through groups if needed
for x = 1 : length(groupnames)

    h = figure('name', groupnames{x}, 'renderer', 'painters');
    
    % load data
    bhv = PuffyPenguin_loadDetectionBhv(groupnames{x}, cPath, true, 0.6);
    nrMice = length(bhv.Animals);
    
    %% compute performance
    optoTrials = bhv.optoPower1 > 0 & bhv.optoAmp1 == bhv.optoAmp2 & bhv.optoDur == 1.5 & ...
        bhv.optoType == 1 & strcmpi(bhv.optoLocation, fiberLocation); %select trials of interest
    
    
    hold on;
    for iAnimals = unique(bhv.AnimalID)
        allData = PuffPenguin_optoPowerCurve(bhv, optoTrials & ismember(bhv.AnimalID,iAnimals)); % get task episode data, low power
        cPerf = [allData.Detect, allData.optoDetect];
        plot(allData.optoPowers, cPerf, 'Color', ones(1,3)*0.75);
    end
    
    allData = PuffPenguin_optoPowerCurve(bhv, optoTrials); %compute performance for current selection
    cPerf = [allData.Detect, allData.optoDetect];
    cPerfUp = [allData.detectUp, allData.optoDetectUp];
    cPerfLow = [allData.detectLow, allData.optoDetectLow];
    cLine = errorbar(allData.optoPowers, cPerf, cPerf - cPerfLow, cPerfUp - cPerf, '-o', 'linewidth' ,4, 'color', 'k', 'MarkerFaceColor','w', 'MarkerSize', 10);
   
    
    xlim([-0.5 cLine(1).XData(end)+0.5]);
    ylim([0.4 1]);
    nhline(0.5, '--', 'lineWidth',4, 'Color', [0.5 0.5 0.5]);
    axis square;
    hold off
    
    cLine(1).Parent.XTick = allData.optoPowers;
    grid on;  
    xLabels = cLine(1).Parent.XTickLabel;
    trialCnt = [allData.trialCnt, allData.optoTrialCnt];
    cLine(1).Parent.XTickLabel = arrayfun(@(y) sprintf('%s mW - %i trials', xLabels{y}, trialCnt(y)), 1:length(xLabels), 'UniformOutput',false);
    
    title([groupnames{x}]);
    ylabel('Detection performance');
    set(h,'PaperOrientation','landscape','PaperPositionMode','auto');
    niceFigure(gca)
    legend(cLine, fiberLocations);
    
end