%PuffyPenguin_OptoInit

%% check if sequence mode is active and whether this should change the probability of an optogenetic trial.
if S.optoSeqActive && iTrials > 1 && S.optoSeqTrials > 0 && S.optoSeqInterval > 0
    
    runOptoSeq = false; %flag to check if optoSeq should run
    
    % get elapsed time after end of first trial
    elapsed = (BpodSystem.Data.TrialStartTime(end) - BpodSystem.Data.TrialStartTime(1))/60;
    
    % first optogenetic sequence after start time has been reached
    if optoSeqStartTime == 0 && elapsed > S.optoSeqStartTime
        runOptoSeq = true;
        
    elseif optoSeqStartTime > 0 && (elapsed-optoSeqStartTime) > S.optoSeqInterval
        runOptoSeq = true;
        optoSeqLastSide = ~optoSeqLastSide; %flip to other side for next time
    end
    
    if runOptoSeq
        disp(['Opto sequence ACTIVE. Elapsed time from last sequence: ' num2str(elapsed-optoSeqStartTime, 2) ' minutes']);
        disp(['Presenting ' num2str(S.optoSeqTrials) ' optogenetic trials in a row.']);
        if S.optoSeqUnilateral
            cSides = {'LEFT', 'RIGHT'};
            disp(['Performing UNILATERAL stimulation on the ' cSides{double(optoSeqLastSide)+1} ' side.']);
        else
            disp('Performing UNILATERAL stimulation on BOTH sides.');
        end
        optoSeqTrialCnt = 0; %reset opto trial counter
    end
    
    % check number of optogenetic trials and set optoProb  to 1 if
    % counter is below the target number of trials
    optoFractionObj = BpodSystem.GUIHandles.PuffyPenguin.optofractiontrialsEditField;
    optoRightObj = BpodSystem.GUIHandles.PuffyPenguin.optoProbRight;
    optoBothObj = BpodSystem.GUIHandles.PuffyPenguin.optoProbBoth;
    if optoSeqTrialCnt < S.optoSeqTrials
        optoSeqTrialCnt = optoSeqTrialCnt + 1;
        S.optoProb = 1;
        optoFractionObj.Value = 1;
        optoSeqStartTime = elapsed;
        
        if S.optoSeqUnilateral
            S.optoBoth = 0; %use only one side;
            if optoSeqLastSide
                S.optoRight = 1; %present optogenetics on the right side
            else
                S.optoRight = 0; %present optogenetics on the left side
            end
            
        else
            S.optoBoth = 1; %use both sides
            S.optoRight = 0.5; %make sure this is balanced again (although it shouldnt be used)
        end
        
        %update GUI values
        optoRightObj.Value = S.optoRight;
        optoBothObj.Value = S.optoBoth;
    else
        S.optoProb = 0;
        optoFractionObj.Value = 0;
    end
    
     %confirm value changes in GUI
    cCallBack = optoFractionObj.ValueChangedFcn;
    cCallBack(optoFractionObj, []);
    
    cCallBack = optoRightObj.ValueChangedFcn;
    cCallBack(optoRightObj, []);
    
    cCallBack = optoBothObj.ValueChangedFcn;
    cCallBack(optoBothObj, []);    
end

%% check if optogenetic stimulus should be presented
optoDur = 0; %duration of optogenetic stimulus
optoSide = NaN; %side to which an optogenetic stimulus gets presented. 1 = left, 2 = right.
optoType = NaN; % time of optogenetic stimulus
optoPower1 = NaN;
optoPower2 = NaN;
% (1 = Stimulus, 2 = Delay, 3 = Response, 4 = Late Stimulus (Computed from stimulus end instead of start),
%  5 = Handle period. Starts right with stimulus onset. Use varStimOn to ensure this doesnt come up during the stimulus.)

stimEvents = [stimEvents, cell(1,2)]; %add events for optogenetics at the end of stimEvents
triggerOptoStim = false; %flag to check if optogenetic trial should be presented
if ~SingleSpout
    if StimType == 1
        triggerOptoStim = rand < (S.optoProb / S.fractionTrainingVision);
    elseif StimType == 2
        triggerOptoStim = rand < (S.optoProb / S.fractionTrainingAudio);
    elseif StimType == 4
        triggerOptoStim = rand < (S.optoProb / S.fractionTrainingTactile);
    else
        triggerOptoStim = rand < S.optoProb;
    end
end

if triggerOptoStim

    % determine time of opto stimulus
    if strcmpi(S.optoPeriod,'Stimulus')
        optoType = 1;
    elseif strcmpi(S.optoPeriod,'Delay')
        optoType = 2;
    elseif strcmpi(S.optoPeriod,'Stimulus/Delay')
        if rand > 0.5
            optoType = 1;
        else
            optoType = 2;
        end
    elseif strcmpi(S.optoPeriod,'Response')
        optoType = 3;
    elseif strcmpi(S.optoPeriod,'LateStimulus')
        optoType = 4;
    elseif strcmpi(S.optoPeriod,'AllTimes')
        coin = rand;
        if coin < 0.25
            optoType = 1;
        elseif coin >= 0.25 && coin < 0.5
            optoType = 2;
        elseif coin >= 0.5 && coin < 0.75
            optoType = 3;
        elseif coin >= 0.75
            optoType = 4;
        end
    end

    % determinde side of opto stimulus
    if rand > S.optoRight
        optoSide = 1; %left
    else
        optoSide = 2; %right
    end

    if rand <= S.optoBoth
        optoSide = 3; %both sides
    end

    if isinf(S.optoDur) && (optoType == 1 || optoType == 4)
        optoDur = stimDur;
    elseif isinf(S.optoDur) && optoType == 2
        optoDur = cDecisionGap;
    elseif isinf(S.optoDur) && optoType == 3
        optoDur = 1; % shouldnt inactivate for more than 1s if time is set to infinity
    else
        optoDur = S.optoDur;
    end

    %% get control voltage for each opto channel
    optoPower1 = ppval(S.optoFits{3}, S.optoAmp1); %recover control voltage from spline interpolation of calibration curve
    optoPower2 = ppval(S.optoFits{4}, S.optoAmp2); %recover control voltage from spline interpolation of calibration curve
    
    % check if requested optogenetic power is within calibration and not too high
    %left
    if min(S.optoPower{3}(:,2)) > S.optoAmp1
        warning('!!Requested LEFT optoPower (%g mW) is below calibrated values. Extend calibration to ensure accuracy!!', S.optoAmp1)
        if optoPower1 < 0; optoPower1 = 0; end
    elseif optoPower1 > 5
        optoPower1 = 5;
        warning('!!Requested LEFT optoPower (%g mW) is too high. Setting to max. value instead. Check calibration curve to stay within range!!', S.optoAmp1)
    end
    %right
    if min(S.optoPower{4}(:,2)) > S.optoAmp2
        warning('!!Requested RIGHT optoPower (%g mW) is below calibrated values. Extend calibration to ensure accuracy!!', S.optoAmp2)
        if optoPower2 < 0; optoPower2 = 0; end
    elseif optoPower2 > 5
        optoPower2 = 5;
        warning('!!Requested RIGHT optoPower (%g mW) is too high. Setting to max. value instead. Check calibration curve to stay within range!!', S.optoAmp2)
    end

    %% create opto stim sequence
    sRate = BpodSystem.ProtocolSettings.sRate;
    pulse = ones(1, round(optoDur * sRate));
    pulse(end-round(S.optoRamp * sRate)+1:end) = (1-1/round(S.optoRamp * sRate) : -1/round(S.optoRamp * sRate) : 0);
    pulse(end) = 0; %make sure this goes back to 0
    
    Signal(7:8,:) = zeros(2,size(Signal,2)); % make sure these channels are empty
    stimDur = size(Signal,2) / sRate; %adjust stimulus duration based on analog signal
    if optoType == 1 %find stimulus onset (stimulus period)
        optoStart = 1;
    elseif optoType == 2 %find stimulus offset (delay period)
        optoStart = size(Signal,2)+1;
    elseif optoType == 3 %find stimulus offset and add delay time (response period)
        optoStart = size(Signal,2) + round(cDecisionGap*sRate);
    elseif optoType == 4 %find stimulus offset and subtract optogenetic stimulation time (late stimulus period)
        optoStart = size(Signal,2) - length(pulse);
    else
        optoSide = NaN;
        warning('Unknown optoType. No opto stimulus created !!!');
    end

    if optoStart < 1; optoStart = 1; end %should not be negative
    
    pulse1 = pulse .* optoPower1;
    pulse2 = pulse .* optoPower2;
    if optoSide == 1
        Signal(7, optoStart : optoStart + length(pulse) - 1) = pulse1; %stimulate left HS
        stimEvents{end-1} = optoStart / sRate;
    elseif optoSide == 2
        Signal(8, optoStart : optoStart + length(pulse) - 1) = pulse2; %stimulate right HS
        stimEvents{end} = optoStart / sRate;
    elseif optoSide == 3
        Signal(7, optoStart : optoStart + length(pulse) - 1) = pulse1; %stimulate left HS
        Signal(8, optoStart : optoStart + length(pulse) - 1) = pulse2; %stimulate right HS
        stimEvents{end-1} = optoStart / sRate;
        stimEvents{end} = optoStart / sRate;
    end
end

% send signal matrix to GUI
BpodSystem.GUIData.Stimuli = Signal;
BpodSystem.GUIData.TrialEpisodes = [S.preStimDelay+cStimOn, stimDur, cDecisionGap, 2];
