%% compute detection performance with bilateral during different task episodes from handle to response period
% only use mice that also have parietal data
% bhv = selectBehaviorTrials(bhv,ismember(bhv.AnimalID, unique(bhv.AnimalID(bhv.stimLocation == 2))));

fiberLocation = 'ALM';
groupnames = {'EMX'};
cPath = '\\naskampa\data\BpodBehavior\';



%% go through groups if needed
for x = 1 : length(groupnames)
   
    % load data
    bhv = PuffyPenguin_loadDetectionBhv(groupnames{x}, cPath, true, 0.75);
    nrMice = length(bhv.Animals);
    
    %% compute performance
    h = figure('name', groupnames{x}, 'renderer', 'painters');
    optoTrials = bhv.optoPower1 > 0 & bhv.optoAmp1 == bhv.optoAmp2 & bhv.optoDur == 1.5 & ...
        bhv.optoType == 1 & strcmpi(bhv.optoLocation, fiberLocation); %select trials of interest
    
    
    hold on;
    for iAnimals = unique(bhv.AnimalID)
        allData = PuffPenguin_optoPowerCurve(bhv, optoTrials & ismember(bhv.AnimalID,iAnimals)); % get task episode data, low power
%         cPerf = [allData.Detect, allData.optoDetect];
        cPerf = allData.optoDetect - allData.ctrlDetect;
        plot(allData.optoPowers(2:end), cPerf, 'Color', ones(1,3)*0.75);
    end
    
    allData = PuffPenguin_optoPowerCurve(bhv, optoTrials); %compute performance for current selection
    cPerf = allData.optoDetect - allData.ctrlDetect;
    cPerfUp = allData.optoDetectUp - allData.ctrlDetect;
    cPerfLow = allData.optoDetectLow - allData.ctrlDetect;
    cLine = errorbar(allData.optoPowers(2:end), cPerf, cPerf - cPerfLow, cPerfUp - cPerf, '-o', 'linewidth' ,4, 'color', 'k', 'MarkerFaceColor','w', 'MarkerSize', 10);
   
    xlim([-0.5 cLine(1).XData(end)+0.5]);
    ylim([-0.2 0.1]);
    nhline(0, '--', 'lineWidth',4, 'Color', [0.5 0.5 0.5]);
    axis square;
    hold off
    
    cLine(1).Parent.XTick = allData.optoPowers;
    grid on;  
    xLabels = cLine(1).Parent.XTickLabel;
    trialCnt = [allData.trialCnt, allData.optoTrialCnt];
    cLine(1).Parent.XTickLabel = arrayfun(@(y) sprintf('%s mW - %i trials', xLabels{y}, trialCnt(y)), 1:length(xLabels), 'UniformOutput',false);
    cLine(1).Parent.XTickLabelRotation = 45;
    
    title([groupnames{x}]);
    ylabel('Detection performance');
    set(h,'PaperOrientation','landscape','PaperPositionMode','auto');
    niceFigure(gca)
    legend(cLine, fiberLocations);
    
    
    
end