function PuffyPenguin_testLED(chanID, ledPower, duration)

% chanID = 3;
% ledPower = 1:5;
% duration = 5;

if ledPower > 5; ledPower = 5; disp('LED power cant be larger than 5V!!'); end

% check for analog module by finding a serial device that can create a waveplayer object
W = [];
Ports = FindSerialPorts; % get available serial com ports

for i = 1 : length(Ports)
    try
        W = BpodWavePlayer(Ports{i});
        S.wavePort = Ports{i};
        fprintf('Analog output module found on port %s\n.', Ports{i})
        break
    end
end

W.OutputRange = '-5V:5V'; % make sure output range is correct
W.TriggerProfileEnable = 'On'; % use trigger profiles to produce different waveforms across channels
W.TriggerProfiles(1, :) = 1:4; %when triggering first row, ch1-4 will play waveforms 1-4
W.TriggerMode = 'Master'; %output can be interrupted by new stimulus triggers

for iPower = 1 : length(ledPower)
    W.loadWaveform(10,ones(1, W.SamplingRate * duration) .* ledPower(iPower));
    W.TriggerProfiles(10, chanID) = 10; %this will generate a square wave on channel 'chanID'
    W.play(10)
    disp(['Current power: ' num2str(ledPower(iPower)) 'V on channel ' num2str(chanID)]);
    pause(2+duration);
end

W.loadWaveform(10,zeros(1, 10));
W.TriggerProfiles(10, chanID) = 10; %this will generate a square wave on channel 'chanID'
W.play(10); %make sure LED returns to zero
pause(0.1);
clear W
