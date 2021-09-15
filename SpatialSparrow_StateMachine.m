%SpatialSparrow_StateMachine

%% Build state matrix
sma = NewStateMatrix();

trialstart_stateout = {'BNCState',1};

if S.TrialStartCue
    trialstart_stateout = [trialstart_stateout,'WavePlayer1',['P' 8]]; % this will play the trial start cue
end

sma = AddState(sma, 'Name', 'TrialStart', ... %trigger to signal trialstart to attached hardware. Only works when using 'WaitForCam'.
    'Timer', 0.1, ...
    'StateChangeConditions', {'Tup','PreStimulus'},... %wait for imager before producing barcode sequence
    'OutputActions', trialstart_stateout); % BNC 1 is high, all others are low, sends message to scan image

sma = AddState(sma, 'Name', 'PreStimulus', ... %wait before starting the stimulus
    'Timer', S.preStimDelay, ...
    'StateChangeConditions', {'Tup','PlayStimulus'},...
    'OutputActions', {});

sma = AddState(sma, 'Name', 'PlayStimulus', ... %present stimulus for the set stimulus duration.
    'Timer', stimDur, ... %waitDur is the duration the animal has to wait before moving to next state
    'StateChangeConditions', {'Tup','DelayPeriod'},...
    'OutputActions', {'WavePlayer1',['P' 0], 'TouchShaker1', 77}); %start stimulus presentation + stimulus trigger

sma = AddState(sma, 'Name', 'DelayPeriod', ... %Add gap after stimulus presentation
    'Timer', cDecisionGap, ...
    'StateChangeConditions', {'Tup','MoveSpout'},...
    'OutputActions', {});

if (S.AutoReward || GiveReward) && SingleSpout % then give the reward right away
    movespout_cond =  {'Tup','Reward','TouchShaker1_14','Reward'};
else % check the animal response
    movespout_cond = {'Tup','WaitForResponse','TouchShaker1_14','WaitForResponse'};
end

sma = AddState(sma, 'Name', 'MoveSpout', ... %move spouts towards the animal so it can report its choice
    'Timer', 0.1, ...
    'StateChangeConditions', movespout_cond,...
    'OutputActions', {'TouchShaker1', 101}); % trigger to moves spouts in


sma = AddState(sma, 'Name', 'WaitForResponse', ... %wait for animal response after stimulus was presented
    'Timer', S.TimeToChoose, ...
    'StateChangeConditions', {'TouchShaker1_1', LeftPortAction, 'TouchShaker1_2', RightPortAction, 'Tup', 'DidNotChoose'},...
    'OutputActions',{});

sma = AddState(sma, 'Name', 'CheckReward', ... %wait for second lick to confirm decision.
    'Timer', S.TimeToConfirm, ...
    'StateChangeConditions', {'TouchShaker1_1', cLeftPortAction, 'TouchShaker1_2', cRightPortAction, 'Tup', 'WaitForResponse'},...
    'OutputActions',{});

sma = AddState(sma, 'Name', 'CheckPunish', ... %wait for second lick to confirm decision.
    'Timer', S.TimeToConfirm, ...
    'StateChangeConditions', {'TouchShaker1_1', pLeftPortAction, 'TouchShaker1_2', pRightPortAction, 'Tup', 'WaitForResponse'},...
    'OutputActions',{});

sma = AddState(sma, 'Name', 'Reward', ... %reward for correct response
    'Timer', rewardValveTime,...
    'StateChangeConditions', {'Tup','HappyTime'},...
    'OutputActions', {'ValveState', RewardValve, 'WavePlayer1',['P' 10], 'TouchShaker1', moveRewardOut}); %open reward valve and play reward click (don't act if reward was given already)

sma = AddState(sma, 'Name', 'HappyTime', ... %wait for a moment to collect water
    'Timer', S.happyTime, ...
    'StateChangeConditions', {'Tup', 'TrialEnd'}, ...
    'OutputActions', {});

outaction = {'TouchShaker1', movePunishOut};
if S.PunishSoundDur > 0
    outaction = [outaction,'WavePlayer1',['P' 11]];
end

sma = AddState(sma, 'Name', 'HardPunish', ... %punish for incorrect response - timeout + punish sound
    'Timer', S.TimeOut,...
    'StateChangeConditions', {'Tup','TrialEnd'},...% 'TouchShaker1_14','TrialEnd'},...
    'OutputActions', outaction); %play punish sound

sma = AddState(sma, 'Name', 'DidNotChoose', ... %if animal did not respond move on to next trial
    'Timer', 0.01, ...
    'StateChangeConditions', {'Tup', 'TrialEnd'}, ...
    'OutputActions', {});

sma = AddState(sma, 'Name', 'TrialEnd', ... %move to next trials after a randomly varying waiting period.
    'Timer', 0, ...
    'StateChangeConditions', {'Tup', 'exit', 'TouchShaker1_14','exit'}, ...
    'OutputActions', {'WavePlayer1', 'X', 'TouchShaker1', 105});  %make sure all stimuli are off and move handles out


%% send state machine to bpod
SendStateMachine(sma);
pause(0.1); %This prevents issue with overflow of touch bytes from teensy between trials
