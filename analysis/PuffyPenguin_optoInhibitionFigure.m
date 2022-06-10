%% compute detection performance with bilateral during different task episodes from handle to response period
% only use mice that also have parietal data
% bhv = selectBehaviorTrials(bhv,ismember(bhv.AnimalID, unique(bhv.AnimalID(bhv.stimLocation == 2))));

xLabels =  {'EarlyStim' 'LateStim' 'Delay' 'Response'};
fiberLocations = { 'A1' 'ALM'};
fiberColors = {[0 0 1] [1 0 0]};

groupnames = {'EMX'};
cPath = '\\naskampa\data\BpodBehavior\';
optoType = [1 4 2 3];

for x = 1 : length(groupnames)
    
    bhv{x} = PuffyPenguin_loadDetectionBhv(groupnames{x}, cPath, true);
    nrMice = length(bhv{x}.Animals);
    
    %%
    optoTrials = bhv{x}.optoPower1 > 0 |bhv{x}.optoPower2 > 0;
    allData = PuffyPenguin_taskEpisodesOpto(bhv{x}, optoTrials); % get task episode data, low power
    nGroups = size(allData.optoDetect,2);
    nrLocations = size(allData.optoDetect,3);
    allP = NaN(nGroups, size(allData.optoDetect,3), nrMice); %times x locations x animals
    
    h = figure('name', groupnames{x}); hold on
    for x = 1 : nrLocations
        for iAnimals = unique(bhv{x}.AnimalID)
            allData = PuffyPenguin_taskEpisodesOpto(bhv{x}, optoTrials & ismember(bhv{x}.AnimalID,iAnimals)); % get task episode data, low power
            allData.animal =bhv{x}.Animals{iAnimals};
            dOut.allTimes{x,iAnimals} = allData; %keep for output
            
            control = allData.detect(3) - 0.5;
            allP(:,x,iAnimals) = (control - (allData.optoDetect(3,:,x)-0.5)) ./ control; %difference between control and stimulation trials
            plot(squeeze(allP(:,x,iAnimals))*100, 'Color', [fiberColors{x} 0.2]);
            %         disp(bhv.Animals{iAnimals}); pause;
        end
        allData = PuffyPenguin_taskEpisodesOpto(bhv{x}, optoTrials); % get task episode data, low power
        dOut.allTimes{x,iAnimals + 1} = allData; %keep for output
        
        control = allData.detect(3) - 0.5;
        cData = [allData.optoDetect(3,:,x); allData.optoDetectUp(3,:,x); allData.optoDetectLow(3,:,x)];
        pChange = ((control - (cData-0.5)) ./ control)*100; %difference between control and stimulation trials
        changeOut{x} = pChange;
        
        %     pChange = allData.detect(3) - [allData.optoDetect(3,:,x); allData.optoDetectUp(3,:,x); allData.optoDetectLow(3,:,x)];
        cLine(x) = errorbar(1:nGroups, pChange(1,:), pChange(1,:) - pChange(2,:), pChange(3,:) - pChange(1,:), '-o', 'linewidth' ,4, 'color', fiberColors{x},'MarkerFaceColor','w', 'MarkerSize', 10);
    end
    
    xlim([0.5 cLine(1).XData(end)+0.5]);
    nhline(nanmean(0), '--', 'lineWidth',4, 'Color', [0.5 0.5 0.5]);
    axis square;
    ylim([-100 200]);
    
    cLine(1).Parent.XTick = 1:nGroups;
    grid on;  cLine(1).Parent.XTickLabel = arrayfun(@(y) sprintf('%s - %i', xLabels{y}, allData.optoCnt(y,x)), 1:length(xLabels), 'UniformOutput',false);
    title([groupnames{x}]);
    ylabel('Detection impairment (%)');
    set(h,'PaperOrientation','landscape','PaperPositionMode','auto');
    niceFigure(gca)
    legend(cLine, fiberLocations);
end