function [stim,events,binSeq] = PuffyPenguin_BinnedStimSequence(useChannels, stimDur, targSide, distFraction)
% Usage: [stim,events] = PuffyPenguin_BinnedStimSequence(useChannels, stimDur, targSide, distFraction)
% Function to generate stimulus waveforms for the SpatialDisc paradigm.
global BpodSystem

S = BpodSystem.ProtocolSettings;
sRate = BpodSystem.ProtocolSettings.sRate;

stimIntensities = [S.StimLoudness S.StimBrightness S.BuzzStrength; S.StimLoudness S.StimBrightness S.BuzzStrength];
stimIntensities(~useChannels) = 0;

stimRates = repmat(S.StimRate,2,3);
stimRates(~useChannels) = 0;

coherence = S.StimCoherence;
noiseStim = S.UseNoise;

%% Generate individual event waveforms
%auditory stimuli (multifrequency convolved click)
tt = -pi:2*pi*1000/(sRate*S.BeepDuration):pi;tt=tt(1:end-1);
beep = (1+cos(tt)).*(sin(2*tt)+sin(4*tt)+sin(6*tt)+sin(8*tt)+sin(16*tt));
sBeep(1,:) = beep*stimIntensities(1)/max(beep);
sBeep(2,:) = beep*stimIntensities(2)/max(beep);

%stim event for somatosensory stimulator
puff = ones(1, sRate * S.BuzzDuration / 1000);

% stim event for visual stimulator (this is just a placeholder for visualization)
flash = ones(1, sRate * S.FlashDuration / 1000);

%% Generate poisson-distributed events
events = cell(1,6); %timestamps of stimulus event onset
binSeq = cell(1,6); %sequence for bins
stimDuration = [S.BeepDuration/1000 S.FlashDuration/1000 S.BuzzDuration/1000]; %number of used bin due to stimDuration.
stimDuration = [stimDuration;stimDuration];

for x = 1:6
    if stimRates(x) > 0
        if (coherence == 1 && (x > 2 && x < 5) && stimRates(x) > 0 && any(stimRates(1:2) > 0)) || ... %use same event times in visual as set for auditory.
                (coherence == 1 && x > 4 && any(stimRates(3:4) > 0)) %use same event times in somatosensory as set for visual.
            events{x} = events{x-2};
            binSeq{x} = binSeq{x-2};
            
        elseif coherence == 1 && x > 4 && any(stimRates(1:2) > 0) %use same event times in somatosensory as set for auditory.
            events{x} = events{x-4};
            binSeq{x} = binSeq{x-4};
            
        else
            binCnt = stimDur * stimRates(x);
            if rem(x, 2) ~= targSide %this is true if the current case IS on the targSide. Confusing, I know, sorry.
                binSeq{x} = rand(1,binCnt) < S.TargFractions(1);
            else
                binSeq{x} = rand(1,binCnt) < distFraction;
            end
            
            events{x} = ((0 : 1 / stimRates(x) : stimDur - 1 / stimRates(x)) + S.BinPos); %event start times for all bins
            events{x} = events{x}(binSeq{x}); %only keep selected events
            
        end
    end
end

%% check if more events ended up on distrator side by chance and flip sides for that case
%auditory
if (length(events{1}) < length(events{2}) && targSide == 0) || ...
   (length(events{2}) < length(events{1}) && targSide == 1)

    events([1 2]) = events([2 1]);
    binSeq([1 2]) = binSeq([2 1]);
end

%vision
if (length(events{3}) < length(events{4}) && targSide == 0) || ...
   (length(events{4}) < length(events{3}) && targSide == 1)

    events([3 4]) = events([4 3]);
    binSeq([3 4]) = binSeq([4 3]);
end

%tactile
if (length(events{5}) < length(events{6}) && targSide == 0) || ...
   (length(events{6}) < length(events{5}) && targSide == 1)

    events([5 6]) = events([6 5]);
    binSeq([5 6]) = binSeq([6 5]);
end

%% convert stimEvents into analog trace
stim = zeros(8,round(sRate*stimDur)); %preallocate stimulus sequence

for x = 1:length(events)
    for y = 1:length(events{x})
        cEvent = round(events{x}(y)*sRate);
        if x < 3 %auditory stimulus, x > 2 are visual
            stim(x,cEvent+1:cEvent+size(sBeep,2)) = sBeep(x,:);
        elseif x > 2 && x < 5
            stim(x,cEvent+1:cEvent+size(flash,2)) = flash;
        elseif x > 4
            stim(x,cEvent+1:cEvent+size(puff,2)) = puff;
        end
    end
end

%check for auditory noise
if noiseStim > 0
    stim(1:2,:) = bsxfun(@plus,stim(1:2,:),((rand(1,size(stim,2))-0.5)*noiseStim));
end
