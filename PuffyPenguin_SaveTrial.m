%PuffyPenguin_SaveTrial
% Save events and data

if length(fieldnames(RawEvents)) > 1

    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); %collect trialdata
    BpodSystem.Data.Punished(iTrials) = ~isnan(BpodSystem.Data.RawEvents.Trial{1,iTrials}.States.HardPunish(1)); %False choice
    BpodSystem.Data.DidNotChoose(iTrials) = ~isnan(BpodSystem.Data.RawEvents.Trial{1,iTrials}.States.DidNotChoose(1)); %No choice

    % then it is autoreward, check if the mouse licked to the correct right side
    if (BpodSystem.ProtocolSettings.AutoReward && SingleSpout)
        BpodSystem.Data.Rewarded(iTrials) = 0;
        if correctSide == 1
            if isfield(BpodSystem.Data.RawEvents.Trial{1,iTrials}.Events,'TouchShaker1_1')
               if length(BpodSystem.Data.RawEvents.Trial{1,iTrials}.Events.TouchShaker1_1)>2
                    BpodSystem.Data.Rewarded(iTrials) = 1;
               else
                    BpodSystem.Data.DidNotChoose(iTrials) = 1;
               end
            end
        else
            if isfield(BpodSystem.Data.RawEvents.Trial{1,iTrials}.Events,'TouchShaker1_2')
               if length(BpodSystem.Data.RawEvents.Trial{1,iTrials}.Events.TouchShaker1_2)>2
                    BpodSystem.Data.Rewarded(iTrials) = 1;
               else
                    BpodSystem.Data.DidNotChoose(iTrials) = 1;
               end
            end
        end
    else
        BpodSystem.Data.Rewarded(iTrials) = ~isnan(BpodSystem.Data.RawEvents.Trial{1,iTrials}.States.Reward(1)); %Correct choice
    end
    
    BpodSystem.Data.stimRate(iTrials) = S.StimRate; %Stimulus rate in Hz
    BpodSystem.Data.targFrac(iTrials) = S.TargFractions(1); %fraction of used bins on target side
    BpodSystem.Data.distFrac(iTrials) = distFrac; %fraction of used bins on distractor side
    BpodSystem.Data.ITIjitter(iTrials) = ITIjitter; %duration of jitter between trials
    BpodSystem.Data.CorrectSide(iTrials) = correctSide; % 1 means left, 2 means right side
    BpodSystem.Data.StimType(iTrials) = StimType; % 1 means vision is rewarded, 2 means audio is rewarded
    BpodSystem.Data.stimEvents{iTrials} = stimEvents; % timestamps for individual events on each channel. Order is AL,AR,VL,VR, timestamps are in s, relative to stimulus onset (use stimOn to be more precise).
    BpodSystem.Data.TrialSettings(iTrials) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
    BpodSystem.Data.TrialStartTime(iTrials) = RawEvents.TrialStartTimestamp(end); %keep absolute start time of each trial
    BpodSystem.Data.stimDur(iTrials) = stimDur; %stimulus duration of current trial
    BpodSystem.Data.decisionGap(iTrials) = cDecisionGap; %duration of gap between stimulus and decision in current trial
    BpodSystem.Data.stimOn(iTrials) = cStimOn; %variability in stim onset relative to lever grab. Creates an additional baseline before stimulus events.
    BpodSystem.Data.optoSide(iTrials) = optoSide; %side to which an optogenetic stimulus gets presented. 1 = left, 2 = right.
    BpodSystem.Data.optoType(iTrials) = optoType; %%time of optogenetic stimulus (1 = Stimulus, 2 = Delay')
    BpodSystem.Data.optoDur(iTrials) = optoDur; %%duration of optogenetic stimulus (s)

    if correctSide == 1
        BpodSystem.Data.StimSideValues([1,2],iTrials) =  [max(cellfun(@length, stimEvents(1:2:6))), max(cellfun(@length, stimEvents(2:2:6)))];
    else
        BpodSystem.Data.StimSideValues([2,1],iTrials) =  [max(cellfun(@length, stimEvents(1:2:6))), max(cellfun(@length, stimEvents(2:2:6)))];
    end
    
    % get ambient data if present
    if ~isempty(S.ambientPort)
        vals = AB.getMeasurements;
        cFields = fieldnames(vals);
        for iFields = 1 : length(cFields)
            BpodSystem.Data.(cFields{iFields})(iTrials) = vals.(cFields{iFields});
        end
    end
    
    % get wheel data if present
    if ~isempty(S.rotaryEncoderPort)
        BpodSystem.Data.wheelPos(iTrials) = R.getLoggedData(); % get position data from rotary encoder module
    end
    
    if BpodSystem.Data.Punished(iTrials)
        pause(S.TimeOut); %punishment pause
    end

    % collect performance in OutcomeRecord variable (used for performance plot)
    if BpodSystem.Data.DidNotChoose(iTrials)
        OutcomeRecord(iTrials) = 3;
    else
        OutcomeRecord(iTrials) = BpodSystem.Data.Rewarded(iTrials);
    end
    AssistRecord(iTrials) = ~any([GiveReward SingleSpout S.AutoReward]); %identify fully animal-performed trials.
    BpodSystem.Data.Assisted(iTrials) = AssistRecord(iTrials);
    BpodSystem.Data.SingleSpout(iTrials) = SingleSpout;
    BpodSystem.Data.AutoReward(iTrials) = any([GiveReward S.AutoReward]);
    BpodSystem.Data.Modality(iTrials) = TrialType; % 1 means detection trial, 2 means discrimination trial, 3 means delayed detection trial

    if OutcomeRecord(iTrials) < 3 %if the subject responded
        if (correctSide==1 && BpodSystem.Data.Rewarded(iTrials)) || (correctSide==2 && ~BpodSystem.Data.Rewarded(iTrials))
            BpodSystem.Data.ResponseSide(iTrials) = 1; %left side
        elseif ((correctSide==1) && ~BpodSystem.Data.Rewarded(iTrials)) || ((correctSide==2) && BpodSystem.Data.Rewarded(iTrials))
            BpodSystem.Data.ResponseSide(iTrials) = 2; %right side
        end
    else
        BpodSystem.Data.ResponseSide(iTrials) = NaN; %no response
    end
    
    %print things to screen
    fprintf('Initiated: %d | Completed: %d | Rewards: %d\n', iTrials, ...
        nansum(OutcomeRecord==0|OutcomeRecord==1), ...
        nansum(OutcomeRecord==1))
end

% Create the folder if it does not exist already.
[sessionpath, bhvFile] = fileparts(BpodSystem.Path.CurrentDataFile);
if ~exist(sessionpath,'dir'),mkdir(sessionpath),end
SaveBpodSessionData; % Saves the field BpodSystem.Data to the current data file

if S.SaveSettings %if current settings should be saved to file
    ProtocolSettings = BpodSystem.ProtocolSettings;
    fname = BpodSystem.GUIData.SettingsFileName;
    save(fname, 'ProtocolSettings');
end            

