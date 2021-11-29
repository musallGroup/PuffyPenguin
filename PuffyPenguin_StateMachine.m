%PuffyPenguin_StateMachine

%% Build state matrix
sma = NewStateMatrix();

startOut = {'BNCState',1};
if ~isempty(S.rotaryEncoderPort)
    startOut = [startOut, {'RotaryEncoder1', 'L'}];
end

sma = AddState(sma, 'Name', 'TrialStart', ... %trigger to signal trialstart to attached hardware.
    'Timer', 0.1, ...
    'StateChangeConditions', {'Tup','TriggerDowntime'},... %wait for imager before producing barcode sequence
    'OutputActions', startOut); % BNC 1 is high, all others are low, sends message to scan image

sma = AddState(sma, 'Name', 'TriggerDowntime', ... %give a 50ms downtime of the trigger before sending the barcode. Might help with to ensure that data is correctly recorded.
    'Timer', 0.05, ...
    'StateChangeConditions', {'Tup','trialCode1'},...
    'OutputActions', {}); % all outpouts are low

% generate barcode to identify trialNr on adjacent hardware
Cnt = 0;
code = encode2of5(iTrials);
codeModuleDurs = [0.0025 0.0055]; %Durations for each module of the trial code sent over the TTL line

for iCode = 1:size(code,2)
    Cnt = Cnt+1;
    stateName = ['trialCode' num2str(Cnt)];
    nextState = [stateName 'Low'];
    
    sma = AddState(sma, 'Name', stateName, ... %produce high state
        'Timer', codeModuleDurs(code(1,iCode)), ...
        'StateChangeConditions', {'Tup',nextState},... %move to next low state
        'OutputActions',{'BNCState',1}); %send output to BNC1 to send barcode to adjacent hardware
    
    stateName = nextState;
    if iCode == size(code,2)
        nextState = 'StartTrigger';
    else
        nextState = ['trialCode' num2str(Cnt + 1)];
    end
    
    sma = AddState(sma, 'Name', stateName, ... %produce low state
        'Timer', codeModuleDurs(code(2, iCode)), ...
        'StateChangeConditions', {'Tup',nextState},... %move to next low state
        'OutputActions',{});
end

% check for trialstart trigger
if S.TrialStartCue
    startTrigger = {'WavePlayer1',['P' 9]}; % this will play the trial start cue
else
    startTrigger = {}; % this will play the trial start cue
end

sma = AddState(sma, 'Name', 'StartTrigger', ... %trialstart trigger
    'Timer', 0, ...
    'StateChangeConditions', {'Tup','PreStimulus'},...
    'OutputActions', startTrigger);

% check if visual will get presented and add trigger state if needed
if ismember(StimType, [1 3 5 7])
    nextState = 'VisualStim';
else
    nextState = 'PlayStimulus';
end

sma = AddState(sma, 'Name', 'PreStimulus', ... %wait before starting the stimulus
    'Timer', S.preStimDelay + cStimOn, ...
    'StateChangeConditions', {'Tup', nextState},...
    'OutputActions', {});

sma = AddState(sma, 'Name', 'VisualStim', ... %start visual stimulation, wait for feedback from photodiodes
    'Timer', 5, ...
    'StateChangeConditions', {'Tup','PlayStimulus', 'AnalogIn1_1','PlayStimulus', 'AnalogIn1_2','PlayStimulus'},...
    'OutputActions', {'SoftCode', 1});

if isempty(tacSide)
    nextState = 'DelayPeriod';
else
    nextState = 'Puff_1';
end

sma = AddState(sma, 'Name', 'PlayStimulus', ... %present stimulus for the set stimulus duration.
    'Timer', stimStateDur, ... %waitDur is the duration the animal has to wait before moving to next state
    'StateChangeConditions', {'Tup', nextState},...
    'OutputActions', {'WavePlayer1',['P' 0], 'TouchShaker1', 77, 'BNCState', 2}); %start stimulus presentation + stimulus trigger from touchshaker and BNC2
    
% add air puff states, if needed
if ~isempty(tacSide)
    
    %time to spend between states. need one puff state and a subsequent waiting state
    puffDur = S.BuzzDuration / 1000;
    interPuff = diff(tacEvents) - puffDur;
    interPuff(end + 1) = stimDur - (tacEvents(end) + puffDur);
    
    for iPuff = 1 : length(tacSide)

        if iPuff == 1
            nextState = {'ValveState', tacSide(iPuff), 'BNCState', 2};
        else
            nextState = {'ValveState', tacSide(iPuff)};
        end
        
        % air puff state
        sma = AddState(sma, 'Name', ['Puff_' num2str(iPuff)], ... %present stimulus for the set stimulus duration.
            'Timer', puffDur, ... %duration of air puff
            'StateChangeConditions', {'Tup', ['PuffWait_' num2str(iPuff)]},...
            'OutputActions', nextState); %start stimulus presentation + stimulus trigger
            
        % check if this is the last event
        if iPuff == length(tacSide)
            nextState = 'DelayPeriod';
        else
            nextState = ['Puff_' num2str(iPuff+1)];
        end
        
        % inter-puff state
        sma = AddState(sma, 'Name', ['PuffWait_' num2str(iPuff)], ... %present stimulus for the set stimulus duration.
            'Timer', interPuff(iPuff), ... %duration of air puff
            'StateChangeConditions', {'Tup', nextState},...
            'OutputActions', {}); %start stimulus presentation + stimulus trigger
        
    end
end

sma = AddState(sma, 'Name', 'DelayPeriod', ... %Add gap after stimulus presentation
    'Timer', cDecisionGap, ...
    'StateChangeConditions', {'Tup','MoveSpout'},...
    'OutputActions', {});

if (S.AutoReward || GiveReward) % give some auto reward
    movespout_cond =  {'Tup','AutoReward','TouchShaker1_14','AutoReward'};
else % check the animal response
    movespout_cond = {'Tup','WaitForResponse','TouchShaker1_14','WaitForResponse'};
end

sma = AddState(sma, 'Name', 'MoveSpout', ... %move spouts towards the animal so it can report its choice
    'Timer', 0.1, ...
    'StateChangeConditions', movespout_cond,...
    'OutputActions', {'TouchShaker1', 101}); % trigger to moves spouts in

sma = AddState(sma, 'Name', 'AutoReward', ... %autoreward on correct side
    'Timer', rewardValveTime,...
    'StateChangeConditions', {'Tup','WaitForResponse'},...
    'OutputActions', {'ValveState', RewardValve}); %open reward valve

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

endOut = {'WavePlayer1', 'X', 'TouchShaker1', 105}; %make sure all stimuli are off and move handles out
if ~isempty(S.rotaryEncoderPort)
    endOut = [endOut, {'RotaryEncoder1', 'F'}]; %stop logging motion data
end

sma = AddState(sma, 'Name', 'TrialEnd', ... %move to next trials after a randomly varying waiting period.
    'Timer', 0, ...
    'StateChangeConditions', {'Tup', 'exit', 'TouchShaker1_14','exit'}, ...
    'OutputActions', endOut);


%% send state machine to bpod
SendStateMachine(sma);
pause(0.1); %This prevents issue with overflow of touch bytes from teensy between trials
