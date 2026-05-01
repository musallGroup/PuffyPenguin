%PuffyPenguin_DispalyTrialData

% display some stimulus information
cModality = {'Vision only' 'Audio only' 'AudioVisual' 'Somatosensory' 'SomatoVisual' 'SomatoAudio' 'AllMixed'};
disp(['Trial ' int2str(iTrials) ' - ' cModality{StimType} '; DecisionGap: ' num2str(cDecisionGap)]);
disp(['Target: ' num2str(S.StimRate) ' Hz - ' cSide, ' - Dist. Fraction: ' num2str(distFrac) ' - ' wSide, ' | SingleSpout: = ' int2str(SingleSpout)]);

try
    BpodSystem.GUIHandles.PuffyPenguin.prepareTrial(TrialSidesList);
catch
    disp('Could not update performance plots.')
end