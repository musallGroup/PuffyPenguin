% PuffyPenguin_StimulusInit
W.SamplingRate = BpodSystem.ProtocolSettings.sRate; %update sampling rate

%% add decision gap if required
cDecisionGap = 0;
if any(S.DecisionGap ~= 0) % present decision gap
    if length(S.DecisionGap) == 1 %if only one value is given
        cDecisionGap = abs(S.DecisionGap);
    end
    if length(S.DecisionGap) == 2 %randomly pick from range of 2 values
        S.DecisionGap = sort(abs(S.DecisionGap)); %make sure values are absoluted and sorted correctly
        cDecisionGap = (diff(S.DecisionGap) * rand) + S.DecisionGap(1); %choose random decision gap value for current trial
    elseif length(S.DecisionGap) > 2 %if more than 2 values are provided, randomly pick one of them
        cDecisionGap = Sample(abs(S.DecisionGap));
    end
    BpodSystem.ProtocolSettings.DecisionGap = sort(abs(S.DecisionGap)); %make potential changes permanent
end

%% Assign stimuli and create output variables
% decide over detection vs discrimination
if rand > S.DistProb  % unimodal trial (detection only)
    TrialType = 1; %identifier for detection trial - stimulate only one side
else
    TrialType = 2; %identifier for discrimination trial.
end

% check rewarded modality.
if strcmpi(S.RewardedModality,'Vision')
    StimType = 1;
    if ~S.useDistVisual
        TrialType = 1;
    end
elseif strcmpi(S.RewardedModality,'Audio')
    StimType = 2;
    if ~S.useDistAudio
        TrialType = 1;
    end
elseif strcmpi(S.RewardedModality,'Somatosensory')
    StimType = 4;
    if ~S.useDistTactile
        TrialType = 1;
    end
elseif strcmpi(S.RewardedModality,'AudioVisual')
    StimType = 3;
    singleModProb = S.ProbAudio + S.ProbVision; %probability of switchting to single modality
    if rand < singleModProb %switch to single modality
        if rand <= (S.ProbAudio / singleModProb)
            StimType = 2; %switch to audio trial
            if ~S.useDistAudio
                TrialType = 1;
            end
        else
            StimType = 1; %switch to vision trial
            if ~S.useDistVisual
                TrialType = 1;
            end
        end
    end
elseif strcmpi(S.RewardedModality,'SomatoVisual')
    StimType = 5;
    singleModProb = S.ProbTactile + S.ProbVision; %probability of switchting to single modality
    if rand < singleModProb %switch to single modality
        if rand <= (S.ProbTactile / singleModProb)
            StimType = 4; %switch to somatosensory trial
            if ~S.useDistTactile
                TrialType = 1;
            end
        else
            StimType = 1; %switch to vision trial
            if ~S.useDistVisual
                TrialType = 1;
            end
        end
    end
elseif strcmpi(S.RewardedModality,'SomatoAudio')
    StimType = 6;
    singleModProb = S.ProbTactile + S.ProbAudio; %probability of switchting to single modality
    if rand < singleModProb %switch to single modality
        if rand <= (S.ProbTactile / singleModProb)
            StimType = 4; %switch to somatosensory trial
            if ~S.useDistTactile
                TrialType = 1;
            end
        else
            StimType = 2; %switch to audio trial
            if ~S.useDistAudio
                TrialType = 1;
            end
        end
    end
elseif strcmpi(S.RewardedModality,'AllMixed')
    StimType = 7;
    %  ProbAudio and ProbVision can switch trial to single modality if any is larger then 0.
    singleModProb = S.ProbAudio + S.ProbVision + S.ProbTactile; %probability of switchting to single modality
    if rand < singleModProb %switch to single modality
        coin = rand;
        if coin <= (S.ProbAudio / singleModProb)
            StimType = 2; %switch to audio trial
            if ~S.useDistAudio
                TrialType = 1;
            end
        elseif coin > (S.ProbAudio / singleModProb) && coin < ((S.ProbAudio + S.ProbVision) / singleModProb)
            StimType = 1; %switch to vision trial
            if ~S.useDistVisual
                TrialType = 1;
            end
        else
            StimType = 4; %switch to somatosensory trial
            if ~S.useDistTactile
                TrialType = 1;
            end
        end
    end
end

%% check for trained modality
if StimType ~= S.TestModality && ismember(S.TestModality, 1:6) %if TestModality is active and current stimType is not selected, switch to detection
    TrialType = 1;
end

useChannels = zeros(2,3); %1st column auditory, 2nd column visual, 3rd column somatosensory; 1st row left, 2nd row right
% audio
if ismember(StimType,[2 3 6 7]) %if auditory stimulation is required
    if TrialSidesList(iTrials) == 0
        useChannels(1) = 1; %use left channel
    else
        useChannels(2) = 1; %use right channel
    end
    if S.useDistAudio
        if TrialType == 2
            useChannels(:,1) = [1,1]; %use both channels
        end
    end
end

% vision
if ismember(StimType,[1 3 5 7]) %if visual stimulation is required
    if TrialSidesList(iTrials) == 0
        useChannels(3) = 1; %use left channel
    else
        useChannels(4) = 1; %use right channel
    end
    if S.useDistVisual
        if TrialType == 2
            useChannels(:,2) = [1,1]; %use both channels
        end
    end
end

% somatosensory
if ismember(StimType,4:7) %if somatosensory stimulation is required
    if TrialSidesList(iTrials) == 0
        useChannels(5) = 1; %use left channel
    else
        useChannels(6) = 1; %use right channel
    end
    if S.useDistTactile
        if TrialType == 2
            useChannels(:,3) = [1,1]; %use both channels
        end
    end
end

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

% show all bins for detection trials
if TrialType == 1
    S.TargFractions = 1;
end

% pick fraction for distractor side
distFrac = Sample(S.DistFractions);

%% create analog waveforms
checker = true; %make sure there is an unequal amount of stimuli on both sides
while checker
    
    [Signal,stimEvents,binSeq] = PuffyPenguin_BinnedStimSequence(useChannels, stimDur, TrialSidesList(iTrials), distFrac); %produce stim sequences and event log
    cellfun(@sum,binSeq)
    checker = false;
    
    for x = [1 3 5]
        if sum(binSeq{x}) > 0 && sum(binSeq{x}) == sum(binSeq{x+1}) %equal amount of stimuli on both sides, re-run stimulus code
            checker = true;
        end
    end
end
%% create string for visual stimuli
% vision left - only works for 3s, 2Hz stimuli right now
leftString = 'left_000000';
if length(binSeq{3}) == 6 && S.StimRate == 2 && stimDur == 3
    leftString = ['left_' strrep(num2str(binSeq{3}),' ', '')];
end

% vision right
rightString = 'right_000000';
if length(binSeq{4}) == 6 && S.StimRate == 2 && stimDur == 3
    rightString = ['right_' strrep(num2str(binSeq{4}),' ', '')];
end

% make output string. This is used later to trigger visual stimulation
BpodSystem.Data.visualString{iTrials} = [fullfile(BpodSystem.Path.visualPath, leftString) ';' fullfile(BpodSystem.Path.visualPath, rightString)];

%% create sequence for valve state to generate airpuffs
% get times for all air puffs and sort by time
tacEvents = [stimEvents{5:6}];
tacSide = [ones(1,length(stimEvents{5}))*4, ones(1,length(stimEvents{6}))*8];
[tacEvents, idx] = sort(tacEvents);
tacSide = tacSide(idx);

if ~isempty(tacEvents)    
    % find cases where both valves should be used
    idx = [diff(tacEvents) 1] == 0;
    tacSide(find(idx)+1) = 12;
    tacEvents = tacEvents(~idx);
    tacSide = tacSide(~idx); %which valve. 4 for valve3, 8 for valve4, 12 for valve3+4 (8bit code)
    
    % this is needed to change duration of the 'PlayStimulus' state. Wait until the first tactile event.
    stimStateDur = tacEvents(1);
else
    stimStateDur = stimDur;
end

%% check if visual stim server is needed
startVisServer = ~BpodSystem.ProtocolSettings.blackScreen;

if BpodSystem.ProtocolSettings.blackScreen
    % cant use blackScreen if visual stimulation is requested
    if ismember(StimType, [1 3 5 7])
        sca;
        BpodSystem.ProtocolSettings.blackScreen = false;
        startVisServer = true;
    
    else
        % make sure visual stim server is closed
        if isfield(BpodSystem.PluginObjects, 'udpVisual') && ~isempty(BpodSystem.PluginObjects.udpVisual)
            fwrite(BpodSystem.PluginObjects.udpVisual, 'Close')
        end
        startVisServer = false;
        
        %black screen
        screenNumber = Screen('Screens'); % Draw to the external screen if avaliable
        screenNumber(screenNumber == 0) = [];
        useScreens = BpodSystem.ProtocolSettings.stimScreens;
        
        if sum(ismember(useScreens, screenNumber)) < length(useScreens)
            disp(['Could not use screens ' num2str(useScreens) ' for visual stimulus.'])
            disp(['Only screens ' num2str(screenNumber) ' are available.'])
            useScreens = [];
        end
        
        if ~isempty(BpodSystem.ProtocolSettings.stimScreens)
            Screen('Preference', 'Verbosity', 0);
            Screen('Preference', 'SkipSyncTests',1);
            Screen('Preference', 'VisualDebugLevel',0);
            
            % check open PTB windows
            windowPtrs = Screen('Windows');
            foundScreens = NaN(1, length(windowPtrs));
            for x = 1 : length(windowPtrs)
                foundScreens(x) = Screen('WindowScreenNumber', windowPtrs(x));
            end
            
            % remove screens with open PTB windows
            useScreens(ismember(useScreens, foundScreens)) = [];
            for x = useScreens
                window = Screen('OpenWindow', x, 0); %open ptb window and save handle in pSettings
            end
        end
    end
else
    sca;
end

% check visual stim server status
PuffyPenguin_VisualStimServer;