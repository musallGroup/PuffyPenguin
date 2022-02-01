function PuffyPenguin_checkTrialTiming(bhv)
%code to show timing of a behavioral file, created with the puffy pengiun
%paradigm.

figure('renderer', 'painters', 'name', [bhv.SettingsFile.SubjectName '; ' datestr(bhv.TrialStartTimestamp(1))]);

%% show trial durations
subplot(2,3,1);
trialDur = NaN(1, length(bhv.Rewarded));
for x = 1 : length(trialDur)
    trialDur(x) = bhv.RawEvents.Trial{x}.States.TrialEnd(end);
end
plot(trialDur, 'k', 'linewidth', 1);
axis square; xlabel('Trials'); ylabel('Trial durations (s)');
title('Trial duration');

%% show stimulus onset, relative to trialstart
stimOn = NaN(1, length(bhv.Rewarded));
stimDur = NaN(1, length(bhv.Rewarded));
for x = 1 : length(stimOn)
    try
        stimOn(x) = bhv.RawEvents.Trial{x}.States.PlayStimulus(1);
        stimDur(x) = bhv.RawEvents.Trial{x}.States.DelayPeriod(1) - bhv.RawEvents.Trial{x}.States.PlayStimulus(1);
    end
end

subplot(2,3,2);
histogram(stimOn, 100);
axis square; ylabel('Trials'); xlabel('Stimulus onset (s)');
title('Stimulus onset');

subplot(2,3,3);
histogram(stimDur, 100);
axis square; ylabel('Trials'); xlabel('Stimulus duration (s)');
title('Stimulus duration');

%% show response time, relative to trialstart
delayDur = NaN(1, length(bhv.Rewarded));
responseTime = NaN(1, length(bhv.Rewarded));
for x = 1 : length(stimOn)
    try
        delayDur(x) = diff(bhv.RawEvents.Trial{x}.States.DelayPeriod);
        responseTime(x) = bhv.RawEvents.Trial{x}.States.MoveSpout(1);
    end
end
subplot(2,3,4);
histogram(delayDur, 100);
axis square; ylabel('Trials'); xlabel('Delay duration (s)');
title('Delay duration');


subplot(2,3,5);
histogram(responseTime-stimOn, 100);
axis square; ylabel('Trials'); xlabel('Response period after stimulus (s)');
title('Response onset');

%% show time between trials
subplot(2,3,6);
histogram(diff(bhv.TrialStartTimestamp)-trialDur(1:end-1));
axis square; xlabel('Inter-trial interval (s)'); ylabel('trials');
title('ITI duration');
