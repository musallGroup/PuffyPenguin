% SpatialSparrow_StimulusInit
W.SamplingRate = BpodSystem.ProtocolSettings.sRate; %adjust sampling rate
sRate = BpodSystem.ProtocolSettings.sRate;

%% Assign stimuli and create output variables
% Determine stimulus presentation
TargStim = Sample(S.TargRate);

% decide over detection vs discrimination
if rand > S.DistProb  % unimodal trial (detection only)
    TrialType = 1; %identifier for detection trial - stimulate only one side
else
    TrialType = 2; %identifier for discrimination trial.
end

if TrialType == 2 % present distractor stimulus
    DistStim = Sample(S.DistFractions); % ASSIGN A DISTRACTOR
    if DistStim < 0 || DistStim > 1
        warning(['Current DistFraction = ' num2str(DistStim) '; Set to 0 instead.']);
        DistStim = 0;
    end
    DistStim = floor(DistStim * TargStim); %convert distractor fraction to rate
else
    DistStim = 0;
end

StimRates = repmat([TargStim;DistStim],1,3);
if TrialSidesList(iTrials) == 1
    StimRates = flipud(StimRates); %first row is left target, second row is right target
end

% add decision gap if required
cDecisionGap = 0;
if any(S.DecisionGap ~= 0) % present decision gap
    if length(S.DecisionGap) == 1 %if only one value is given, window should range between 0 and that value
        S.DecisionGap = [0 abs(S.DecisionGap)];
    end
    if length(S.DecisionGap) == 2 %randomly pick from range of values
        S.DecisionGap = sort(abs(S.DecisionGap)); %make sure values are absoluted and sorted correctly
        cDecisionGap = (diff(S.DecisionGap) * rand) + S.DecisionGap(1); %choose random decision gap value for current trial
    elseif length(S.DecisionGap) > 2 %if more than 2 values are provided, randomly pick one of them
        cDecisionGap = Sample(abs(S.DecisionGap));
    end
    BpodSystem.ProtocolSettings.DecisionGap = sort(abs(S.DecisionGap)); %make potential changes permanent
end

% check rewarded modality.
if strcmpi(S.RewardedModality,'Vision')
    StimType = 1;
    if ~S.useDistVisual
        DistStim = 0;
        TrialType = 1;
    end
elseif strcmpi(S.RewardedModality,'Audio')
    StimType = 2;
    if ~S.useDistAudio
        DistStim = 0;
        TrialType = 1;
    end
elseif strcmpi(S.RewardedModality,'Somatosensory')
    StimType = 4;
    if ~S.useDistPiezo
        DistStim = 0;
        TrialType = 1;
    end
elseif strcmpi(S.RewardedModality,'AudioVisual')
    StimType = 3;
    singleModProb = S.ProbAudio + S.ProbVision; %probability of switchting to single modality
    if rand < singleModProb %switch to single modality
        if rand <= (S.ProbAudio / singleModProb)
            StimType = 2; %switch to audio trial
            if ~S.useDistAudio
                DistStim = 0;
                TrialType = 1;
            end
        else
            StimType = 1; %switch to vision trial
            if ~S.useDistVisual
                DistStim = 0;
                TrialType = 1;
            end
        end
    end
elseif strcmpi(S.RewardedModality,'SomatoVisual')
    StimType = 5;
    singleModProb = S.ProbPiezo + S.ProbVision; %probability of switchting to single modality
    if rand < singleModProb %switch to single modality
        if rand <= (S.ProbPiezo / singleModProb)
            StimType = 4; %switch to somatosensory trial
            if ~S.useDistPiezo
                DistStim = 0;
                TrialType = 1;
            end
        else
            StimType = 1; %switch to vision trial
            if ~S.useDistVisual
                DistStim = 0;
                TrialType = 1;
            end
        end
    end
elseif strcmpi(S.RewardedModality,'SomatoAudio')
    StimType = 6;
    singleModProb = S.ProbPiezo + S.ProbAudio; %probability of switchting to single modality
    if rand < singleModProb %switch to single modality
        if rand <= (S.ProbPiezo / singleModProb)
            StimType = 4; %switch to somatosensory trial
            if ~S.useDistPiezo
                DistStim = 0;
                TrialType = 1;
            end
        else
            StimType = 2; %switch to audio trial
            if ~S.useDistAudio
                DistStim = 0;
                TrialType = 1;
            end
        end
    end
elseif strcmpi(S.RewardedModality,'AllMixed')
    StimType = 7;
    %  ProbAudio and ProbVision can switch trial to single modality if any is larger then 0.
    singleModProb = S.ProbAudio + S.ProbVision + S.ProbPiezo; %probability of switchting to single modality
    if rand < singleModProb %switch to single modality
        coin = rand;
        if coin <= (S.ProbAudio / singleModProb)
            StimType = 2; %switch to audio trial
            if ~S.useDistAudio
                DistStim = 0;
                TrialType = 1;
            end
        elseif coin > (S.ProbAudio / singleModProb) && coin < ((S.ProbAudio + S.ProbVision) / singleModProb)
            StimType = 1; %switch to vision trial
            if ~S.useDistVisual
                DistStim = 0;
                TrialType = 1;
            end
        else
            StimType = 4; %switch to somatosensory trial
            if ~S.useDistPiezo
                DistStim = 0;
                TrialType = 1;
            end
        end
    end
end

%% check for trained modality
if StimType ~= S.TestModality && ismember(S.TestModality, 1:6) %if TestModality is active and current stimType is not selected, switch to detection
    DistStim = 0;
end

UseChannels = zeros(2,3); %1st column auditory, 2nd column visual, 3rd column somatosensory; 1st row left, 2nd row right
% audio
if ismember(StimType,[2 3 6 7]) %if auditory stimulation is required
    if TrialSidesList(iTrials) == 0
        UseChannels(1) = 1; %use left channel
    else
        UseChannels(2) = 1; %use right channel
    end
    if S.useDistAudio
        if DistStim > 0
            UseChannels(:,1) = [1,1]; %use both channels
        end
    end
end
% vision
if ismember(StimType,[1 3 5 7]) %if visual stimulation is required
    if TrialSidesList(iTrials) == 0
        UseChannels(3) = 1; %use left channel
    else
        UseChannels(4) = 1; %use right channel
    end
    if S.useDistVisual
        if DistStim > 0
            UseChannels(:,2) = [1,1]; %use both channels
        end
    end
end
% somatosensory
if ismember(StimType,4:7) %if somatosensory stimulation is required
    if TrialSidesList(iTrials) == 0
        UseChannels(5) = 1; %use left channel
    else
        UseChannels(6) = 1; %use right channel
    end
    if S.useDistPiezo
        if DistStim > 0
            UseChannels(:,3) = [1,1]; %use both channels
        end
    end
end
StimIntensities = [S.StimLoudness S.StimBrightness S.BuzzStrength; S.StimLoudness S.StimBrightness S.BuzzStrength];

% only use selected channels
StimRates(~UseChannels) = 0;
StimIntensities(~UseChannels) = 0;

%% Compute variable stimulus duration if varStimDur is > 0;
if strcmpi(class(S.varStimDur), 'double') && S.varStimDur >= 0
    stimDur = S.StimDuration + rand * S.varStimDur;
else
    S.varStimDur = 0;
    stimDur = S.StimDuration;
end

%check for variable stimulus onset. Has to > 0 seconds. If 2 inputs are
%given, they define an interval from which a random delay is taken.
if length(S.varStimOn) ~= 2
    cStimOn = Sample(abs(S.varStimOn));
else
    cStimOn = min(S.varStimOn) + rand * abs(diff(S.varStimOn));
end
if ~strcmpi(class(cStimOn),'double')
    cStimOn = 0;
    BpodSystem.ProtocolSettings.varStimOn = 0;
    warning('Invalid input for varStimOn. Set to 0 instead.')
end

%% create analog waveforms
[Signal,stimEvents] = SpatialSparrow_GetStimSequence(StimRates, StimIntensities, sRate, stimDur, cStimOn, S); %produce stim sequences and event log
BpodSystem.GUIData.Stimuli = Signal;