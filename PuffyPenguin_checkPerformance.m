% function PuffyPenguin_checkPerformance
% make learning curve plot for current animal

try %make sure this doesnt cause an error
    
cAnimal = BpodSystem.ProtocolSettings.SubjectName;

cPath = [BpodSystem.ProtocolSettings.serverPath cAnimal ...
    '\PuffyPenguin\Session Data'];

recs = dir(cPath);
recs = recs([recs.isdir]);
recs = {recs(3:end).name};

clear perf
Cnt = 0;
for iRecs = 1 : length(recs)
    try
        cRec = [cPath filesep recs{iRecs} filesep];
        cFile = dir([cRec '*' recs{iRecs} '.mat']);

        load([cRec cFile.name]);
        bhv = SessionData;
        if sum(bhv.Assisted) > 50
            Cnt = Cnt + 1;
            visIdx = bhv.StimType == 1 & bhv.Assisted & ~bhv.DidNotChoose;
            perf(1,Cnt) = sum(bhv.Rewarded(visIdx)) / sum(visIdx);

            tacIdx = bhv.StimType == 4 & bhv.Assisted & ~bhv.DidNotChoose;
            perf(2,Cnt) = sum(bhv.Rewarded(tacIdx)) / sum(tacIdx);

            msIdx = bhv.StimType == 5 & bhv.Assisted & ~bhv.DidNotChoose;
            perf(3,Cnt) = sum(bhv.Rewarded(msIdx)) / sum(msIdx);
        end
    end
end

%% make figure
h = figure('renderer','painters','name', datestr(clock));
plot(perf', 'x-');
nhline(0.5, 'k--'); ylabel('performance'); xlabel('Sessions');
legend('vision','tactile','multisensory','location','northwest'); axis square; niceFigure
title(cAnimal);
ax = gca;
ax.TickLength = [0 0];

%% save figure on server
savefig(h, fullfile(fileparts(cPath), 'VisuoTactile-LearningCurve.fig'))
saveas(h, fullfile(fileparts(cPath), 'VisuoTactile-LearningCurve.jpg'))
close(h);

catch ME
    disp('Error occurred when creating learning curve figures.')
    disp(ME.message)
end
