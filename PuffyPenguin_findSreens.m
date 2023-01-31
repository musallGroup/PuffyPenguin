
Ports = FindSerialPorts; % get available serial com ports
for i = 1 : length(Ports)
    try
        A = BpodAnalogIn(Ports{i});
        break
    end
end

%%

x = 2;
Screen('Preference', 'SkipSyncTests', 1);
window = Screen('OpenWindow', x, 0); %open ptb window and save handle in pSettings
[xScr, yScr] = Screen('WindowSize', window); %open ptb window and save handle in pSettings
%%
A.setZero();
A.Thresholds = [0.06 0.06 0.02 0.02 1 1 1 1]; %set thresholds for photodiode
A.ResetVoltages = [0.02 0.02 0.06 0.06 0 0 0 0]; %set thresholds for reset
A.InputRange = {'-2.5V:2.5V'  '-2.5V:2.5V'  '-2.5V:2.5V'  '-2.5V:2.5V' '-2.5V:2.5V' '-2.5V:2.5V' '-2.5V:2.5V' '-2.5V:2.5V'};
A.SMeventsEnabled(1:4) = true;

%% PRESENT TRIGGERS
nrPulses = 5;
%A.startLogging()
for xx = 1 : nrPulses
    Screen('FillRect', window, 255, [xScr-100 yScr-100 xScr yScr]);
    Screen('FillRect', window, 255, [0 yScr-100 100 yScr]);
    Screen('Flip', window); pause(0.05);
    Screen('FillRect', window, 0, [xScr-100 yScr-100 xScr yScr]);
    Screen('FillRect', window, 0, [0 yScr-100 100 yScr]);
    Screen('Flip', window); pause(0.05);
end
%%
A.stopLogging();
Data = A.getData();

%% check INPUT channels
find(sum(diff(Data.y > 0.5, [], 2) == 1,2) == nrPulses)
    
