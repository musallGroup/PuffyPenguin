%% compute detection performance with bilateral during different task episodes from handle to response period
% only use mice that also have parietal data
% bhv = selectBehaviorTrials(bhv,ismember(bhv.AnimalID, unique(bhv.AnimalID(bhv.stimLocation == 2))));

fiberLocation = 'ALM';
groupnames = {'CStr'};
cPath = '\\naskampa\data\BpodBehavior\';


%% go through groups if needed
for x = 1 : length(groupnames)
   
    % load data
    bhv = PuffyPenguin_loadDetectionBhv(groupnames{x}, cPath, false, 0.7);
    nrMice = length(bhv.Animals);
    
    %% compute performance
    h = figure('name', groupnames{x}, 'renderer', 'painters');
    optoTrials = bhv.optoSide < 3 & bhv.optoDur >= 1.5 & strcmpi(bhv.optoLocation, fiberLocation); %select trials of interest
    
    hold on;
%     for iAnimals = unique(bhv.AnimalID)
%         cInd = optoTrials & ismember(bhv.AnimalID,iAnimals);
%         if sum(cInd) > 0
%         allData = PuffPenguin_optoPowerCurve(bhv, cInd); % get task episode data, low power
%         cPerf = allData.optoDetect - allData.ctrlDetect;
%         plot(allData.optoPowers(2:end), cPerf, 'Color', ones(1,3)*0.75);
%         end
%     end
    
    for yy = 1:3
        cInd =  ismember(bhv.AnimalID,1:3);
        if yy == 1
            allData = PuffPenguin_optoPowerCurve(bhv, cInd & optoTrials); %compute performance for current selection
            cColor = 'k';
        elseif yy == 2 %ipsi
            allData = PuffPenguin_optoPowerCurve(bhv,  cInd & optoTrials & bhv.optoSide == bhv.CorrectSide); %compute performance for current selection
            cColor = 'g';
        elseif yy == 3 %contra
            allData = PuffPenguin_optoPowerCurve(bhv,  cInd & optoTrials & bhv.optoSide ~= bhv.CorrectSide); %compute performance for current selection
            cColor = 'r';
        end
        cPerf = allData.optoDetect - allData.ctrlDetect;
        cPerfUp = allData.optoDetectUp - allData.ctrlDetect;
        cPerfLow = allData.optoDetectLow - allData.ctrlDetect;
        cLine = errorbar(allData.optoPowers(2:end), cPerf, cPerf - cPerfLow, cPerfUp - cPerf, '-o', 'linewidth' ,4, 'color', cColor, 'MarkerFaceColor','w', 'MarkerSize', 10);
    end
    
    
    xlim([-0.5 cLine(1).XData(end)+0.5]);
    ylim([-0.5 0.1]);
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
    legend(cLine, fiberLocation);
    
    
    
end