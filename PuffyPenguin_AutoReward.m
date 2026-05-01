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

%% Check for side bias using rolling window of recent self-performed trials
% If the animal consistently responds to one side, present a single spout
% on the ignored (correct) side to remind it of the other option.
biasBiasWindow = 10;          % number of recent self-performed, responded trials to assess
biasTriggerThreshold = 0.80;  % fraction to one side required to flag a bias
biasTriggerProb = 0.75;       % probability of triggering a single spout on any qualifying trial

singleSpoutBias = false; % reset flag for this trial

if iTrials > biasBiasWindow && ~SingleSpout
    % get indices of recent self-performed trials where the animal made a choice
    recentIdx = find(AssistRecord(1:iTrials-1) & ~BpodSystem.Data.DidNotChoose(1:iTrials-1));
    recentIdx = recentIdx(max(1, end - biasBiasWindow + 1) : end);

    if length(recentIdx) >= biasBiasWindow
        choiceFrac = sum(BpodSystem.Data.ResponseSide(recentIdx) == 1) / biasBiasWindow;

        if choiceFrac > biasTriggerThreshold && correctSide == 1
            % animal is ignoring left; current trial is a left trial -> remind it
            if rand < biasTriggerProb
                SingleSpout = true;
                singleSpoutBias = true;
            end
        elseif choiceFrac < (1 - biasTriggerThreshold) && correctSide == 2
            % animal is ignoring right; current trial is a right trial -> remind it
            if rand < biasTriggerProb
                SingleSpout = true;
                singleSpoutBias = true;
            end
        end
    end
end

BpodSystem.ProtocolSettings.SingleSpoutTrial = SingleSpout;
