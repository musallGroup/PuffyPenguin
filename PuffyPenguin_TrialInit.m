%PuffyPenguin_TrialInit

BpodSystem.ProtocolSettings.cTrial = iTrials; %log current trial ID in bpod object
BpodSystem.Data.cTrial = iTrials; %log current trial ID in bpod object
S = BpodSystem.ProtocolSettings; %update settings for this trial

%% create sounds - recreate if loudness has changed
if iTrials == 1 || PrevStimLoudness ~= S.StimLoudness
    sRate = BpodSystem.ProtocolSettings.sRate;
    PunishSound = ((rand(1,int32(sRate*S.PunishSoundDur)) * 5) - 2.5) * S.StimLoudness / 2; %white noise for punishment
    if isempty(PunishSound); PunishSound = zeros(1,sRate/1000); end

    RewardSound = zeros(1,sRate*0.02); 
    RewardSound(1:int32(sRate*0.01)) = 1; %20ms click sound for reward
    RewardSound = RewardSound * S.StimLoudness;    
    trialStartSound = GenerateSineWave(sRate, 4000, 0.05) * S.StimLoudness; %0.05s pure tone to indicate start of the current trial
    
    W.loadWaveform(10,trialStartSound); % load signal to waveform object
    W.loadWaveform(11,RewardSound); % load signal to waveform object
    W.loadWaveform(12,PunishSound); % load signal to waveform object
    PrevStimLoudness = S.StimLoudness;
    W.TriggerProfiles(10, 1:2) = 10; %this will play waveform 11 (trialStart) on ch1+2
    W.TriggerProfiles(11, 1:2) = 11; %this will play waveform 11 (rewardSound) on ch1+2
    W.TriggerProfiles(12, 1:2) = 12; %this will play waveform 12 (punishSound) on ch1+2
end

%% update valve times
LeftValveTime = GetValveTimes(S.leftRewardVolume, 1);
RightValveTime = GetValveTimes(S.rightRewardVolume, 3);

% if stimulus probability has changed, compute a new sidelist and re-initate outcome plot
if PrevProbRight ~= S.ProbRight
    PrevProbRight = S.ProbRight;
    TrialSidesList = [TrialSidesList(1:iTrials) double(rand(1,5000-iTrials) < S.ProbRight)];
end

% if the same side was repeated more than 'biasSeqLength'
% THIS PREVENTS MORE THAN biasSeqLength STIM DISPLAYED ON THE SAME SIDE
if iTrials > S.biasSeqLength
    if S.biasSeqLength ~= 0
        if length(unique(TrialSidesList(iTrials-S.biasSeqLength:iTrials))) == 1
            if rand > 0.5
                TrialSidesList(iTrials) = double(~logical(TrialSidesList(iTrials))); %flip to the other side
            end
        end
    end
end

%% Move servo based on difference between left and right performance
if S.UseAntiBias
    temp = TrialSidesList(LastBias:end); %get sides for all trials since the last check
    temp = temp(AssistRecord(LastBias:end)); %get sides for all performed trials
    
    if sum(temp == 0) > 5 && sum(temp == 1) > 5 %if more than 5 trials were performed on both sides
        LastBias = iTrials;
        SideDiff = BpodSystem.Data.rPerformance(iTrials-1)-BpodSystem.Data.lPerformance(iTrials-1); %performance difference
        if abs(SideDiff) > 0.2 && abs(SideDiff) < 0.5 %small correction
            cMove = 1;
        elseif abs(SideDiff) >=  0.5 && abs(SideDiff) < 1 %medium correction
            cMove = 3;
        elseif abs(SideDiff) == 1 %large correction
            cMove = 5;
        else
            cMove = 0; %no correction
        end
        
        if SideDiff < 0 %stronger left performance
            cInd = [1 2]; %create index to modify right values in ServoPos
            lim(1) = S.lInnerLim; %get inner and outer limit for biased spout
            lim(2) = S.lOuterLim;
        else
            cInd = [2 1]; %stronger right performance
            lim(1) = S.rInnerLim;
            lim(2) = S.rOuterLim;
        end
        
        if BpodSystem.ProtocolSettings.ServoPos(cInd(2)) > 0 %if 'weak' spout is not at its inner limit
            if BpodSystem.ProtocolSettings.ServoPos(cInd(2)) < cMove
                BpodSystem.ProtocolSettings.ServoPos(cInd(2)) = 0; %move weak spout to its inner limit
            else
                BpodSystem.ProtocolSettings.ServoPos(cInd(2)) = BpodSystem.ProtocolSettings.ServoPos(cInd(2)) - cMove; %move weak spout closer again
            end
        else
            if lim(1) - BpodSystem.ProtocolSettings.ServoPos(cInd(1)) - cMove > lim(2) %if 'strong' spout can be moved closer without going below the outer limit
                BpodSystem.ProtocolSettings.ServoPos(cInd(1)) = BpodSystem.ProtocolSettings.ServoPos(cInd(1)) + cMove; %move 'strong' spout further away
            else
                if round(BpodSystem.ProtocolSettings.ServoPos(cInd(1)),2) < round(lim(1)-lim(2),2) %if spout is not at its outer limit
                    BpodSystem.ProtocolSettings.ServoPos(cInd(1)) = lim(1)-lim(2); %move spout to its outer limit
                end
            end
        end
        %limit the max bias
        for i = 1:length(BpodSystem.ProtocolSettings.ServoPos)
            if BpodSystem.ProtocolSettings.ServoPos(i) > BpodSystem.ProtocolSettings.maxServoPos(i)
                BpodSystem.ProtocolSettings.ServoPos(i) = BpodSystem.ProtocolSettings.maxServoPos(i);
            end
        end
        
    end
else
    BpodSystem.ProtocolSettings.ServoPos(:) = 0;
end

%% Determine the inter-trial interval (soft interval) from a gamma dist
ITIjitter = 0;
while ITIjitter < 0.33*S.ITI_shape || ITIjitter > 3*S.ITI_shape
    ITIjitter = gamrnd(S.ITI_shape,S.ITI_scale);
end
