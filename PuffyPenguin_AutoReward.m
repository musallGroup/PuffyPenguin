%PuffyPenguin_AutoReward
%% Check training status and set up if auto-reward should be given
GiveReward = false; SingleSpout = false; %make sure trials are not aided by mistake
if S.TrainingMode == 1
    if StimType == 1
        checker = S.fractionTrainingVision;
    elseif StimType == 2
        checker = S.fractionTrainingAudio;
    elseif StimType == 4
        checker = S.fractionTrainingTactile;
    elseif ismember(StimType,[3 5 6 7])
        checker = S.fractionTrainingMixed;
    else
        warning(['Unknown StimType! StimType = ' num2str(StimType)]);
    end

    if rand > checker %checker = 0 means no unassisted trials, 1 is all trials are unassisted.
        SingleSpout = true; %  Use single spouts in the current trial
    end

end

BpodSystem.ProtocolSettings.SingleSpoutTrial = SingleSpout;

%% TODO: SEE IF THIS IS USEFUL WHEN THINGS ARE WORKING
%         % check for additional single spout if animal keeps making mistakes on the same side
%         if singleSpoutBias
%             seqLength = 1;
%         else
%             seqLength = S.biasSeqLength*2;
%         end
%         singleSpoutBias = false;
%         
%         if iTrials > seqLength && S.ProbRight == 0.5
%             %provide single spout if animal is strictly going to one side
%             if length(unique(BpodSystem.Data.ResponseSide(iTrials-seqLength : iTrials - 1))) == 1 %animal always goes to the same side
%                 if (TrialSidesList(iTrials)+1) ~= unique(BpodSystem.Data.ResponseSide(iTrials-seqLength : iTrials - 1)) %current trial is non-preferred side
%                     if rand > 0.75
%                         SingleSpout = true;
%                         singleSpoutBias = true;
%                     end
%                 end
%             end
%             
%             %provide autoreward if animal does not touch lever anymore
%             if sum(ismember(OutcomeRecord(iTrials-seqLength:iTrials-1),4)) == 3
%                 if rand > 0.5
%                     GiveReward = true;
%                 end
%             end
%         end
%         
%         if SingleSpout && ~isnan(optoSide) %dont give optogenetic stimulus in single spout trials
%             optoType = NaN; optoSide = NaN;
%             Signal(7:8,:) = zeros(2,size(Signal,2));
%         end