%SpatialSparrow_DispalyTrialData

% display some stimulus information
cModality = {'Vision only' 'Audio only' 'AudioVisual' 'Somatosensory' 'SomatoVisual' 'SomatoAudio' 'AllMixed'};
disp(['Trial ' int2str(iTrials) ' - ' cModality{StimType} '; DecisionGap: ' num2str(cDecisionGap)]);
disp(['Target: ' num2str(TargStim) ' Hz - ' cSide, ' - Dist. Fraction: ' num2str(DistStim) ' - ' wSide, ' | SingleSpout: = ' int2str(SingleSpout)]);

try
    BpodSystem.GUIHandles.SpatialSparrow.prepareTrial(TrialSidesList);
catch
    disp('Could not update performance plots.')
end

% a = min(min(Signal));b = max(max(Signal));
% plotoffset = b - a ;
% plot(BpodSystem.GUIHandles.SpatialSparrow_Control.StimulusPlot, linspace(0,length(Signal)/sRate,length(Signal)), Signal(1,:), 'r'); %update stimulus plot - audio1
% hold(BpodSystem.GUIHandles.SpatialSparrow_Control.StimulusPlot,'on')
% plot(BpodSystem.GUIHandles.SpatialSparrow_Control.StimulusPlot, linspace(0,length(Signal)/sRate,length(Signal)), Signal(2,:), 'k'); %update stimulus plot - audio2
% plot(BpodSystem.GUIHandles.SpatialSparrow_Control.StimulusPlot, linspace(0,length(Signal)/sRate,length(Signal)), plotoffset + Signal(3,:), 'r'); %update stimulus plot - vision1
% plot(BpodSystem.GUIHandles.SpatialSparrow_Control.StimulusPlot, linspace(0,length(Signal)/sRate,length(Signal)), plotoffset + Signal(4,:), 'k'); %update stimulus plot - vision2
% plot(BpodSystem.GUIHandles.SpatialSparrow_Control.StimulusPlot, linspace(0,length(Signal)/sRate,length(Signal)), 2*plotoffset + Signal(5,:), 'r'); %update stimulus plot - somatosensory1
% plot(BpodSystem.GUIHandles.SpatialSparrow_Control.StimulusPlot, linspace(0,length(Signal)/sRate,length(Signal)), 2*plotoffset + Signal(6,:), 'k'); %update stimulus plot - somatosensory1
% hold(BpodSystem.GUIHandles.SpatialSparrow_Control.StimulusPlot,'off')
% %         ylim(BpodSystem.GUIHandles.SpatialSparrow_Control.StimulusPlot,[a-a/5 b+b/5]);
% ylim(BpodSystem.GUIHandles.SpatialSparrow_Control.StimulusPlot,[a 3*plotoffset]);
% xlim(BpodSystem.GUIHandles.SpatialSparrow_Control.StimulusPlot,[0 stimDur]);
% set(BpodSystem.GUIHandles.SpatialSparrow_Control.StimulusPlot,'ytick',[0,1,2].*plotoffset,'yticklabel', {'Aud','Vis','Som'});
% line([waitDur waitDur],get(BpodSystem.GUIHandles.SpatialSparrow_Control.StimulusPlot,'YLim'),'Color','r','Parent',BpodSystem.GUIHandles.SpatialSparrow_Control.StimulusPlot,'linewidth',2);
% set(BpodSystem.GUIHandles.SpatialSparrow_Control.StimulusPlot, 'box', 'off');
