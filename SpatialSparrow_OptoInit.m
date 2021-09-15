%SpatialSparrow_OptoInit

%% check if optogenetic stimulus should be presented
optoDur = 0; %duration of optogenetic stimulus
optoSide = NaN; %side to which an optogenetic stimulus gets presented. 1 = left, 2 = right.
optoType = NaN; % time of optogenetic stimulus
% (1 = Stimulus, 2 = Delay, 3 = Response, 4 = Late Stimulus (Computed from stimulus end instead of start),
%  5 = Handle period. Starts right with stimulus onset. Use varStimOn to ensure this doesnt come up during the stimulus.)

if rand < S.optoProb
    % determine time of opto stimulus
    if strcmpi(S.optoTimes,'Stimulus')
        optoType = 1;
    elseif strcmpi(S.optoTimes,'Delay')
        optoType = 2;
    elseif strcmpi(S.optoTimes,'Stimulus/Delay')
        if rand > 0.5
            optoType = 1;
        else
            optoType = 2;
        end
    elseif strcmpi(S.optoTimes,'Response')
        optoType = 3;
    elseif strcmpi(S.optoTimes,'LateStimulus')
        optoType = 4;
    elseif strcmpi(S.optoTimes,'Handle')
        optoType = 5;
    elseif strcmpi(S.optoTimes,'AllTimes')
        coin = rand;
        if coin < 0.2
            optoType = 1;
        elseif coin >= 0.2 && coin < 0.4
            optoType = 2;
        elseif coin >= 0.4 && coin < 0.6
            optoType = 3;
        elseif coin >= 0.6 && coin < 0.8
            optoType = 4;
        elseif coin >= 0.8
            optoType = 5;
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
    elseif isinf(S.optoDur) && optoType == 5
        optoDur = S.varStimOn(1); % shouldnt be longer as minimum time before stimulus onset.
    else
        optoDur = S.optoDur;
    end

    % create opto stim sequence
    pulse = ones(1, round(optoDur * sRate));
    pulse(end-round(S.optoRamp * sRate)+1:end) = 1-1/round(S.optoRamp * sRate) : -1/round(S.optoRamp * sRate) : 0;
    pulse(end) = 0; %make sure this goes back to 0

    Signal(7:8,:) = zeros(2,size(Signal,2)); % make sure these channels are empty
    stimDur = size(Signal,2) / sRate; %adjust stimulus duration based on analog signal
    if optoType == 1 %find stimulus onset (stimulus period)
        optoStart = ceil(cStimOn*sRate);
    elseif optoType == 2 %find stimulus offset (delay period)
        optoStart = size(Signal,2)+1;
    elseif optoType == 3 %find stimulus offset and add delay time (response period)
        optoStart = size(Signal,2) + round(cDecisionGap*sRate);
    elseif optoType == 4 %find stimulus offset and subtract optogenetic stimulation time (late stimulus period)
        optoStart = size(Signal,2) - length(pulse);
    elseif optoType == 5 %start with signal presentation. This should occur during the varStimOn time (Handle period).
        optoStart = 1;
        if S.varStimOn(1) == 0
            warning(['!!! varStimOn(1) = 0. Handle inactivation might affect stimulus period. OptoDur = ' num2str(optoDur) '!!!']);
        end
    else
        optoSide = NaN;
        warning('Unknown optoType. No opto stimulus created !!!');
    end

    if optoStart < 1; optoStart = 1; end %should not be negative

    if optoSide == 1
        Signal(7, optoStart : optoStart + length(pulse) - 1) = pulse; %stimulate left HS
    elseif optoSide == 2
        Signal(8, optoStart : optoStart + length(pulse) - 1) = pulse; %stimulate right HS
    elseif optoSide == 3
        Signal(7:8, optoStart : optoStart + length(pulse) - 1) = repmat(pulse,2,1); %stimulate both HS
    end
end
