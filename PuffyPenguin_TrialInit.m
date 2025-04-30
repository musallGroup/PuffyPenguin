%PuffyPenguin_TrialInit

BpodSystem.ProtocolSettings.cTrial = iTrials; %log current trial ID in bpod object
BpodSystem.Data.cTrial = iTrials; %log current trial ID in bpod object
S = BpodSystem.ProtocolSettings; %update settings for this trial

% set analog input lines to zero at black indicator
A.setZero()

%% update valve times
LeftValveTime = GetValveTimes(S.leftRewardVolume, 1);
RightValveTime = GetValveTimes(S.rightRewardVolume, 2);

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
%         SideDiff = BpodSystem.Data.rPerformance(iTrials-1)-BpodSystem.Data.lPerformance(iTrials-1); %performance difference
        SideDiff = 0;
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

% instead of using scale and shape for gamma distribution, ITI_scale refers
% to the mean ITI and shape refers to standard deviation. This is to make
% using these variables easier. Shape shold always be 1 by default and we
% will limit the max ITI to 30 seconds.
ITIjitter = 0;
while ITIjitter < 0.1*S.ITI_scale || ITIjitter > 10*S.ITI_scale
    k = (S.ITI_scale/S.ITI_shape)^2;
    theta = S.ITI_shape^2/S.ITI_scale;
    ITIjitter = gamrnd(k, theta);
end

