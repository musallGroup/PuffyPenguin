% function PuffyPenguin_checkPerformance
% make learning curve plot for current animal

modColors = [0 0 0; 0 1 0; 1 0 0.5; 1 0 0; 0.5 0.5 0; 0 0.5 1];
modLabels = {'Vision' 'Audio' 'AudioVisual' 'Tactile' 'VisuoTactile' 'AudioTactile'};
modIdx = [1 2 4 5]; %modalities to check (as identified by modlabels above)         

try %make sure this doesnt cause an error
    
cAnimal = BpodSystem.ProtocolSettings.SubjectName;

cPath = [BpodSystem.ProtocolSettings.serverPath cAnimal ...
    '\PuffyPenguin\Session Data'];

recs = dir(cPath);
recs = recs([recs.isdir]);
recs = {recs(3:end).name};

clear perf perfTrialCnt allTrialCnt
Cnt = 0;
for iRecs = 1 : length(recs)
    try
        cRec = [cPath filesep recs{iRecs} filesep];
        cFile = dir([cRec '*' recs{iRecs} '.mat']);

        load([cRec cFile.name]);
        bhv = SessionData;
        if sum(bhv.Assisted) > 25
            Cnt = Cnt + 1;
            for iMods = 1 : length(modIdx)
                allTrialCnt(iMods,Cnt) = sum(bhv.StimType == modIdx(iMods));
                cIdx = bhv.StimType == modIdx(iMods) & bhv.Assisted & ~bhv.DidNotChoose & bhv.distFrac == 0;
                perf(iMods,Cnt) = sum(bhv.Rewarded(cIdx)) / sum(cIdx);
                perfTrialCnt(iMods,Cnt) = sum(cIdx);
            end
        end
    end
end

%% make figure
h = figure('renderer','painters','name', datestr(clock));
for x = 1 : length(modIdx)
    if nansum(perf(x,:)) > 0
        ax = plot(perf(x,:), 'o-', 'Color', modColors(modIdx(x),:), ...
            'MarkerFaceColor', modColors(modIdx(x),:), 'MarkerEdgeColor', 'k'); hold on;
    
        disp('============');
        disp(['Animal: ' cAnimal]);
        disp(['Modality: ' modLabels{modIdx(x)}]);
        disp(['Performance / session: ' num2str(round(perf(x,:),2))]);
        disp(['Total trials / session: ' num2str(allTrialCnt(x,:))]);
        disp(['Perf. trials / session: ' num2str(perfTrialCnt(x,:))]);
        disp('============');
    end
end

plot(ax(1).Parent.XLim,[0.5 0.5], 'k--'); ylabel('performance'); xlabel('Sessions');
legend(modLabels(modIdx(nansum(perf, 2) > 0)),'location','northwest'); axis square;
title(cAnimal);
ax = gca;
ax.TickLength = [0 0];
ax.YLim = [min([ax.YLim 0.4]) 1];
    
%% save figure on server
savefig(h, fullfile(fileparts(cPath), 'VisuoTactile-LearningCurve.fig'))
saveas(h, fullfile(fileparts(cPath), 'VisuoTactile-LearningCurve.jpg'))
close(h);

catch ME
    disp('Error occurred when creating learning curve figures.')
    disp(ME.message)
end
