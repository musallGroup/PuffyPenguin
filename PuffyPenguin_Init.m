% Initialization of Bpod modules and VIDEO AQUISITION
% BPod Init
BpodSystem.ProtocolSettings.triggerScanbox = false;
BpodSystem.Data.byteLoss = 0; %counter for cases when the teensy didn't send a response byte
BpodSystem.SoftCodeHandlerFunction = 'PuffyPenguin_softCodeHandler';
BpodSystem.Data.Rewarded = logical([]); %needed for GUI to work in first trial

%% Load default settings and update with pre-defined settings if required
defaultFieldParamVals = struct2cell(DefaultSettings);
defaultFieldNames = fieldnames(DefaultSettings);
BpodSystem.ProtocolSettings.ServoPos = [0 0];
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct S
currentFieldNames = fieldnames(S);

if isempty(fieldnames(S)) % If settings file was an empty struct, populate struct with default settings
    S = DefaultSettings;
elseif any(~ismember(defaultFieldNames,currentFieldNames))  %an addition to default settings, update
    differentI = find(~ismember(defaultFieldNames,currentFieldNames)); %find the index
    for ii = 1:numel(differentI)
        thisnewfield = defaultFieldNames{differentI(ii)};
        S.(thisnewfield)=defaultFieldParamVals{differentI(ii)};
    end
end
BpodSystem.ProtocolSettings = S; % Adds the currently used settings to the Bpod struct
BpodSystem.ProtocolSettings.SubjectName = BpodSystem.GUIData.SubjectName; %update subject name
serverPath = [BpodSystem.ProtocolSettings.serverPath filesep BpodSystem.ProtocolSettings.SubjectName filesep ...
    BpodSystem.GUIData.ProtocolName]; %path to data server


%% ensure analog output module is present and set up communication
clear W
try
    W = BpodWavePlayer(S.wavePort); %check if analog module com port is correct
    fprintf('Analog output module found on port %s\n.', S.wavePort)
catch
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
end

if isempty(W)
    warning('No analog output module found. Session aborted.');
    BpodSystem.Status.BeingUsed = 0;
else
    clear W %clear waveplayer object to make sure it uses default values
    W = BpodWavePlayer(S.wavePort);
end

W.OutputRange = '-5V:5V'; % make sure output range is correct
W.TriggerProfileEnable = 'On'; % use trigger profiles to produce different waveforms across channels
W.TriggerProfiles(1, :) = 1:4; %when triggering first row, ch1-4 will play waveforms 1-4
W.TriggerMode = 'Master'; %output can be interrupted by new stimulus triggers
W.LoopDuration(1:4) = 0; %keep on for a up to 10 minutes
W.SamplingRate = BpodSystem.ProtocolSettings.sRate; %adjust sampling rate
RewardSound = zeros(1,BpodSystem.ProtocolSettings.sRate*0.02);
RewardSound(1:int32(BpodSystem.ProtocolSettings.sRate*0.01)) = 1; %20ms click sound for reward
RewardSound = RewardSound*0.5;
W.loadWaveform(11,RewardSound); % load signal to waveform object
W.TriggerProfiles(11, 1:2) = 11; %this will play waveform 11 (rewardSound) on ch1+2

%% check for teensy module (needs no object because it only communicates through Bpod directly)
checker = true;
for i = 1 : length(BpodSystem.Modules.Name)
    if strcmpi(BpodSystem.Modules.Name{i},'TouchShaker1')
        checker = false;
    end
end
if checker
    warning('No teensy module found. Session aborted.');
    BpodSystem.Status.BeingUsed = 0;
end

% check teensy module - this does not work if not connected to the computer
teensyWrite([71 1 '0' 1 '0']); % Move spouts to zero position

% setting thresholds - move to outer
disp('Teensy is setting the thresholds')
pause(0.5);
teensyWrite([71 1 '1' 1 '1']); % Move spouts to most outer position

%set touch threshold
cVal = num2str(BpodSystem.ProtocolSettings.TouchThresh);
teensyWrite([75 length(cVal) cVal]);
pause(2); %give some time for calibration
res = teensyGetTouchThresh();
ii = 0;
while isempty(res)
    res = teensyGetTouchThresh();
    ii = ii+1;
    if ii == 5
        disp('There was an error reading the thresholds from the teensy...')
        break
    end
end
BpodSystem.ProtocolSettings.capacitiveTouchThresholds = res;

%move spouts to inner position
val = BpodSystem.ProtocolSettings.SpoutSpeed; %SpoutSpeed
teensyWrite([73 length(num2str(val)) num2str(val)]); %set spout speed
     
ls = num2str(BpodSystem.ProtocolSettings.lInnerLim);
rs = num2str(BpodSystem.ProtocolSettings.rInnerLim);
teensyWrite([71 length(ls)  ls length(rs)  rs]);

       
%% check for analog input module
clear A
try
    A = BpodAnalogIn(S.analogInPort); %check if analog module com port is correct
catch
    % check for analog module by finding a serial device that can create a waveplayer object
    A = [];
    Ports = FindSerialPorts; % get available serial com ports
    Ports = Ports(~strcmpi(Ports, S.wavePort)); %don't use output module port
    for i = 1 : length(Ports)
        try
            A = BpodAnalogIn(Ports{i});
            S.analogInPort = Ports{i};
            break
        end
    end
end

if isempty(A)
    warning('No analog input module found. Session aborted.');
    BpodSystem.Status.BeingUsed = 0;
else
    A.Thresholds = [0.075 0.075 0.075 0.075 10 10 10 10]; %set thresholds for photodiode
    A.ResetVoltages = [0.02 0.02 0.1 0.1 0 0 0 0]; %set thresholds for reset
    A.SMeventsEnabled(1:4) = true;
    A.startReportingEvents();
end


%% check for rotary encoder module
clear R
try
    R = RotaryEncoderModule(S.rotaryEncoderPort); %check if rotary encoder module com port is correct
    fprintf('Rotary encoder module found on port %s\n.', S.rotaryEncoderPort)
catch
    % check for analog module by finding a serial device that can create a waveplayer object
    clear R
    Ports = FindSerialPorts; % get available serial com ports
    Ports = Ports(~strcmpi(Ports, S.wavePort)); %don't use output module port
    Ports = Ports(~strcmpi(Ports, S.analogInPort)); %don't use input module port
    for i = 1 : length(Ports)
        try
            R = RotaryEncoderModule(Ports{i});
            S.rotaryEncoderPort = Ports{i};
            fprintf('Rotary encoder module found on port %s\n.', Ports{i})
            break
        end
    end
end

if isempty(R)
    S.rotaryEncoderPort = [];
    warning('!!! No rotary encoder module found. Wheel data will not be available in SessionData !!!');
end


%% check for ambient module
clear AB
try
    AB = AmbientModule(S.ambientPort); %check if ambient module com port is correct
catch
    % check for analog module by finding a serial device that can create a waveplayer object
    clear AB
    Ports = FindSerialPorts; % get available serial com ports
    Ports = Ports(~strcmpi(Ports, S.wavePort)); %don't use output module port
    Ports = Ports(~strcmpi(Ports, S.analogInPort)); %don't use input module port
    Ports = Ports(~strcmpi(Ports, S.rotaryEncoderPort)); %don't use rotary encoder port
    for i = 1 : length(Ports)
        try
            AB = AmbientModule(Ports{i});
            S.ambientPort = Ports{i};
            break
        end
    end
end

if ~exist('AB', 'var') || isempty(AB) 
    S.ambientPort = [];
    warning('!!! No ambient module found. Ambient data will not be available in SessionData !!!');
end

%% Stimulus parameters - Create trial types list (single vs double stimuli)
maxTrials = 5000;
TrialSidesList = double(rand(1,maxTrials) < S.ProbRight); % ONE MEANS RIGHT TRIAL
PrevProbRight = S.ProbRight;
BpodSystem.Data.TrialStartTime = [];
[dataPath, bhvFile] = fileparts(BpodSystem.Path.CurrentDataFile);
tmp = strsplit(bhvFile,'_');
dataPath = fullfile(dataPath,[tmp{end-1} '_' tmp{end}]);
BpodSystem.Path.CurrentDataFile = fullfile(dataPath, bhvFile);

%% Initialize camera, control GUI and feedback plots
if BpodSystem.Status.BeingUsed %only run this code if protocol is still active
    %%
    BpodNotebook('init');
  
    BpodSystem.GUIHandles.PuffyPenguin = PuffyPenguin_GUI;
    %BpodSystem.Data.animalWeight = str2double(newid('Enter animal weight (in grams)')); %ask for animal weight and save
    BpodSystem.GUIHandles.PuffyPenguin.getSettingsFromBpod();
    BpodSystem.GUIHandles.PuffyPenguin.init_plots();
    
	%% initialize communication with labcams to get videos
    if isfield(BpodSystem.ProtocolSettings,'labcamsAddress')
        if ~isempty(BpodSystem.ProtocolSettings.labcamsAddress)
            tmp = strsplit(BpodSystem.ProtocolSettings.labcamsAddress,':');
            udpAddress = tmp{1};
            udpPort = str2num(tmp{2});
            udplabcams = udp(udpAddress,udpPort);
            udplabcams.TimeOut = 1;
            fopen(udplabcams);
            
            % check if labcams is connected already.
            fwrite(udplabcams,'ping'); pause(0.05);
            if udplabcams.BytesAvailable > 0
                fgetl(udplabcams);
                disp(' -> labcams connected.');
            else
                %%
                disp(' -> starting labcams');
                if ~isunix
                    labcamsproc=System.Diagnostics.Process.Start('labcams.exe','-w');
                    pause(5); tic;
                    if ~labcamsproc.HasExited
                        while labcamsproc.Responding && toc < 10
                            fwrite(udplabcams,'ping')
                            tmp = fgetl(udplabcams);
                            if ~isempty(tmp)
                                break
                            end
                        end
                    else
                        disp('Labcams is not responding. Are cameras connected and working?')
                        clear udplabcams
                    end
                else
                    % labcams needs to be installed to use system python
                    % for this to work
                    system('LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/:$LD_LIBRARY_PATH export LD_LIBRARY_PATH;gnome-terminal -- labcams -w')
                    for i =  1:100
                        fwrite(udplabcams,'ping')
                        tmp = fgetl(udplabcams);
                        pause(0.1)
                        if ~isempty(tmp)
                            break
                        end
                    end
                    if isempty(tmp)
                        clear udplabcams
                    end
                end
            end
            
            if exist('udplabcams','var')
                fwrite(udplabcams,['expname=' BpodSystem.Path.CurrentDataFile])
                fgetl(udplabcams);
                fwrite(udplabcams,'manualsave=0') % Dont save while adjusting
                fgetl(udplabcams);
                fwrite(udplabcams,'softtrigger=1')
                fgetl(udplabcams);
            end
        end
    end
    
    %% initialize communication with visual stimulation server
    BpodSystem.Path.visualPath = [fullfile(fileparts(BpodSystem.Path.DataFolder(1:end-1)), 'visualStim', 'Stimulus_frames'),filesep];
    
    batPath = [BpodSystem.Path.ProtocolFolder, BpodSystem.ProtocolSettings.paradigmName, filesep, 'VisualStimulusClient.bat'];
    
    system(['"' batPath '" &']); %start visual stimulus client
    pause(3);

    tmp = strsplit(BpodSystem.ProtocolSettings.visualAddress,':');
    udpAddress = tmp{1};
    udpPort = str2num(tmp{2});
    BpodSystem.PluginObjects.udpVisual = udp(udpAddress,udpPort);
    BpodSystem.PluginObjects.udpVisual.TimeOut = 1;
    fopen(BpodSystem.PluginObjects.udpVisual);
    
     % check if stim server is connected
     tic
     while BpodSystem.PluginObjects.udpVisual.BytesAvailable == 0 && toc <10
         fwrite(BpodSystem.PluginObjects.udpVisual,'Ping'); pause(1);
         if BpodSystem.PluginObjects.udpVisual.BytesAvailable > 0
             fgetl(BpodSystem.PluginObjects.udpVisual);
             disp(' -> Stim server connected.');
             break
         end
     end
     
     fwrite(BpodSystem.PluginObjects.udpVisual,'Ping'); pause(0.1);
     if BpodSystem.PluginObjects.udpVisual.BytesAvailable > 0
         fgetl(BpodSystem.PluginObjects.udpVisual);
         disp(' -> Stim server connected.');
     else
         warning('Could not establish connection to visual stimulation server. Visual stimuli wont be available.');
     end
end

%% Initialize some arrays
OutcomeRecord = NaN(1,maxTrials);
AssistRecord = false(1,maxTrials);
LastBias = 1; %last trial were bias correction was used
PrevStimLoudness = S.StimLoudness; %variable to check if loudness has changed
singleSpoutBias = false; %flag to indicate if single spout was presented to counter bias

