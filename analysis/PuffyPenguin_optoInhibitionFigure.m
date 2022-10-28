%% compute detection performance with bilateral during different task episodes from handle to response period
% only use mice that also have parietal data
% bhv = selectBehaviorTrials(bhv,ismember(bhv.AnimalID, unique(bhv.AnimalID(bhv.stimLocation == 2))));

xLabels =  {'EarlyStim' 'LateStim' 'Delay' 'Response'};
fiberLocations = { 'A1' 'ALM'};
fiberColors = {[0 0 1] [1 0 0]};

groupnames = {'EMX' 'CStr'};
cPath = '\\naskampa\data\BpodBehavior\';
optoType = [1 4 2 3];

%%
for x = 1 : length(groupnames)
    
    h = figure('name', groupnames{x}, 'renderer', 'painters');
    
    bhv = PuffyPenguin_loadDetectionBhv(groupnames{x}, cPath, true, 0.6);
    nrMice = length(bhv.Animals);
    
    %%
    optoTrials = bhv.optoPower1 > 0 | bhv.optoPower2 > 0;
    allData = PuffyPenguin_taskEpisodesOpto(bhv, optoTrials); % get task episode data, low power
    nGroups = size(allData.optoDetect,2);
    nrLocations = size(allData.optoDetect,3);
    allP = NaN(nGroups, size(allData.optoDetect,3), nrMice); %times x locations x animals
    
%     for xx = 1 : nrLocations
    for xx = 1 
        subplot(1,2,1); hold on;
        iAnimals = 0;
        for iAnimals = unique(bhv.AnimalID)
            allData = PuffyPenguin_taskEpisodesOpto(bhv, optoTrials & ismember(bhv.AnimalID,iAnimals)); % get task episode data, low power
            allData.animal =bhv.Animals{iAnimals};
            dOut.allTimes{xx,iAnimals} = allData; %keep for output
            
            control = allData.detect(3) - 0.5;
            allP(:,xx,iAnimals) = (control - (allData.optoDetect(3,:,xx)-0.5)) ./ control; %difference between control and stimulation trials
            plot(squeeze(allP(:,xx,iAnimals))*100, 'Color', [fiberColors{xx} 0.2]);
%                     disp(bhv.Animals{iAnimals}); pause;
        end
        allData = PuffyPenguin_taskEpisodesOpto(bhv, optoTrials & ismember(bhv.AnimalID,[1:4])); % get task episode data, low power
        dOut.allTimes{xx,iAnimals + 1} = allData; %keep for output
        
        control = allData.detect(3) - 0.5;
        cData = [allData.optoDetect(3,:,xx); allData.optoDetectUp(3,:,xx); allData.optoDetectLow(3,:,xx)];
        pChange = ((control - (cData-0.5)) ./ control)*100; %difference between control and stimulation trials
        changeOut{xx} = pChange;
        
        %     pChange = allData.detect(3) - [allData.optoDetect(3,:,x); allData.optoDetectUp(3,:,x); allData.optoDetectLow(3,:,x)];
        cLine(xx) = errorbar(1:nGroups, pChange(1,:), pChange(1,:) - pChange(2,:), pChange(3,:) - pChange(1,:), '-o', 'linewidth' ,4, 'color', fiberColors{x}, 'MarkerFaceColor','w', 'MarkerSize', 10);
    
        %show min. performance with optogenetics
        subplot(1,2,2);
        optoPerf = NaN(1, length(unique(bhv.AnimalID)));
        for iAnimals = unique(bhv.AnimalID)
            optoPerf(iAnimals) = dOut.allTimes{xx,iAnimals}.detect(3); 
        end
        meanData = nanmean(optoPerf); semData = sem(optoPerf);
        bar(meanData);
        hold on; errorbar(meanData, semData, 'k');
        plot(ones(1, length(optoPerf)), optoPerf, 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'MarkerSize', 10);
        hold off;
        
        disp(['Trialcount: ' num2str(allData.optoCnt(:, xx)')]); drawnow;
    end
    
    subplot(1,2,1);
    xlim([0.5 cLine(1).XData(end)+0.5]);
    nhline(nanmean(0), '--', 'lineWidth',4, 'Color', [0.5 0.5 0.5]);
    axis square;
    ylim([-10 60]);
    
    cLine(1).Parent.XTick = 1:nGroups;
    grid on;  cLine(1).Parent.XTickLabel = arrayfun(@(y) sprintf('%s - %i', xLabels{y}, allData.optoCnt(y,xx)), 1:length(xLabels), 'UniformOutput',false);
    title([groupnames{x}]);
    ylabel('Detection impairment (%)');
    set(h,'PaperOrientation','landscape','PaperPositionMode','auto');
    niceFigure(gca)
    legend(cLine, fiberLocations(1:xx));
    
    subplot(1,2,2);
    axis square; niceFigure;xlim([0 2]); ylim([0.5 1]); grid on
end