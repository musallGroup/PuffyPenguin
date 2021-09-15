% SpatialSparrow_BpodTrialInit

%% move signal to analog module
for iChans = 1 : size(Signal,1)
    W.loadWaveform(iChans,Signal(iChans,:)); % load current channel to analog output module
    W.BpodEvents{iChans} = 'On';
end

%% set bpdod state information for current trial
CamTrig = 'Tup';
if S.WaitForCam > 0 %check whether camera trigger is required to trigger trial and stimulus presentation
    CamTrig = 'BNC1High';
end

if TrialSidesList(iTrials) == 0 %target is left
    LeftPortAction = 'CheckReward';
    pLeftPortAction = 'CheckReward';
    cLeftPortAction = 'Reward';
    moveRewardOut = 103; %move right spout out if animal chooses left
    movePunishOut = 106; %move both spouts out if animal chooses right
    RightPortAction = 'CheckPunish';
    cRightPortAction = 'CheckPunish';
    pRightPortAction = 'HardPunish';
    RewardValve = LeftPortValveState; %left-hand port represents port#0, therefore valve value is 2^0
    rewardValveTime = LeftValveTime;
    correctSide = 1;
    cSide = 'Left'; wSide = 'Right';
else
    LeftPortAction = 'CheckPunish';
    cLeftPortAction = 'CheckPunish';
    pLeftPortAction = 'HardPunish';
    moveRewardOut = 102; %move left spout out if animal chooses right
    movePunishOut = 106; %move both spouts out if animal chooses left
    RightPortAction = 'CheckReward';
    pRightPortAction = 'CheckReward';
    cRightPortAction = 'Reward';
    RewardValve = RightPortValveState; %right-hand port represents port#2, therefore valve value is 2^2
    rewardValveTime = RightValveTime;
    correctSide = 2;
    cSide = 'Right'; wSide = 'Left';
end

%% send trial information to arduino
% LeftIn = round(S.lInnerLim,2) - BpodSystem.ProtocolSettings.ServoPos(1); %left inner position - bias offset
% RightIn = round(S.rInnerLim,2) - BpodSystem.ProtocolSettings.ServoPos(2); %right inner position - bias offset
% LeftOut = LeftIn - S.spoutOffset; %left outer position
% RightOut = RightIn - S.spoutOffset; %right outer position
% 
% if SingleSpout
%     if correctSide == 1 %correct side is left
%         RightIn = RightOut - abs(RightIn - RightOut); %move right spout in opposite direction
%     else
%         LeftIn = LeftOut - abs(LeftIn - LeftOut); %move left spout in opposite direction
%     end
% end
% 
% % convert to strings and combine as teensy output
% LeftIn = num2str(LeftIn); RightIn = num2str(RightIn);
% LeftOut = num2str(LeftOut); RightOut = num2str(RightOut);
% LeverIn = num2str(BpodSystem.ProtocolSettings.LeverIn);
% LeverOut = num2str(BpodSystem.ProtocolSettings.LeverOut);
% 
% cVal = [length(LeftIn) length(RightIn) length(LeftOut) length(RightOut) length(LeverIn) length(LeverOut) ...
%     LeftIn RightIn LeftOut RightOut LeverIn LeverOut];
% 
% % send trial information to teensy and move spouts/lever to outer position
% try BpodSystem.StartModuleRelay('TouchShaker1'); java.lang.Thread.sleep(10); end % Start relaying bytes from teensy
% teensyWrite([70 cVal]);% send spout/lever information to teensy at trial start
% teensyWrite(102); % Move left spout to outer position
% teensyWrite(103); % Move right spout to outer position
% teensyWrite(105); % Move handles to outer position
% BpodSystem.StopModuleRelay('TouchShaker1'); % Stop relaying bytes from teensy to allow communication with state machine

%disp("SET POSITION")