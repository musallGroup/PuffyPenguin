%% connect to ao
W = BpodWavePlayer('COM7');
%%
W.OutputRange = '-5V:5V'; % make sure output range is correct
W.TriggerProfileEnable = 'Off'; % use trigger profiles to produce different waveforms across channels
% W.TriggerProfiles(1, :) = 1:8; %when triggering first row, ch1-8 will play waveforms 1-8
% W.TriggerMode = 'Master'; %output can be interrupted by new stimulus triggers
% W.LoopDuration(1:8) = 0; %keep on for a up to 10 minutes
W.SamplingRate = 20000; %adjust sampling rate
%%
% addpath('Bpod_Gen2\Functions\Internal Functions\GenerateSineWave.m')
sound = GenerateSineWave(W.SamplingRate, 9000, 0.1) / 2;
%sound = ((rand(1,W.SamplingRate*0.5) * 5) - 2.5)/10;
% W.TriggerProfiles(10, 1:2) = 10;
%

sound
W.loadWaveform(14,sound); % load signal to waveform object
W.play([1,2],14)