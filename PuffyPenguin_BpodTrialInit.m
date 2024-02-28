% PuffyPenguin_BpodTrialInit

%% move signal to analog module
chanIdx = [1:2,7:8]; %only send auditory and optogenetic stimuli to analog output module
for iChans = 1 : length(chanIdx)
    cSignal = Signal(chanIdx(iChans),:);
%     if round(sum(cSignal)) > 0
        W.loadWaveform(iChans,cSignal); % load current channel to analog output module
%     else
%         W.loadWaveform(iChans,0); % load current channel to analog output module
%     end
    W.BpodEvents{iChans} = 'On';
end

%% set bpdod state information for current trial
CamTrig = 'Tup';
if S.WaitForCam > 0 %check whether cameraa72 trigger is required to trigger trial and stimulus presentation
    CamTrig = 'BNC1High';
end

leftTarget = TrialSidesList(iTrials) == 0; %target is left;
if BpodSystem.ProtocolSettings.contingencyReversal
    leftTarget = ~leftTarget; %animal should respond on opposite side from target to get reward
end

if leftTarget %target is left
    LeftPortAction = 'CheckReward';
    pLeftPortAction = 'CheckReward';
    cLeftPortAction = 'Reward';
    moveRewardOut = 103; %move right spout out if animal chooses left
    movePunishOut = 106; %move both spouts out if animal chooses right
    RightPortAction = 'CheckPunish';
    cRightPortAction = 'CheckPunish';
    pRightPortAction = 'HardPunish';
    RewardValve = 1; %left-hand port represents port
    rewardValveTime = LeftValveTime;
    correctSide = 1;
    cSide = 'Left'; wSide = 'Right';
    pinchCloseByte = 50;
    pinchOpenByte = 52;
else
    LeftPortAction = 'CheckPunish';
    cLeftPortAction = 'CheckPunish';
    pLeftPortAction = 'HardPunish';
    moveRewardOut = 102; %move left spout out if animal chooses right
    movePunishOut = 106; %move both spouts out if animal chooses left
    RightPortAction = 'CheckReward';
    pRightPortAction = 'CheckReward';
    cRightPortAction = 'Reward';
    RewardValve = 2; %right-hand port represents port#2
    rewardValveTime = RightValveTime;
    correctSide = 2;
    cSide = 'Right'; wSide = 'Left';
    pinchCloseByte = 51;
    pinchOpenByte = 53;
end
