% Define or load default settings for protocol
% General settings.
DefaultSettings.paradigmName = 'PuffyPenguin';
DefaultSettings.SubjectName = 'Dummy';
DefaultSettings.RewardedModality = 'AudioVisual'; % modality that is rewarded - 'Vision' for flashes, 'Audio' for beeps, 'AudioVisual' for multisensory
DefaultSettings.leftRewardVolume = 2;  % ul
DefaultSettings.rightRewardVolume = 2; % ul
DefaultSettings.UseAntiBias = true; % Spout correction
DefaultSettings.AutoReward = 0; % automatic or self-performed trials with audio stimulation. Default is 1 (fully self-performed).
DefaultSettings.fractionTrainingVision = 1; % Amount of self-performed trials with visual stimulation. Default is 1 (fully self-performed).
DefaultSettings.fractionTrainingTactile = 1; % Amount of self-performed trials with somatosensory stimulation. Default is 1 (fully self-performed).
DefaultSettings.fractionTrainingAudio = 1; % Amount of self-performed trials with auditory stimulation. Default is 1 (fully self-performed).
DefaultSettings.fractionTrainingMixed = 1; % Amount of self-performed trials with mixed stimulation. Default is 1 (fully self-performed).
DefaultSettings.SaveSettings = true; % Allows to save current settings to file
DefaultSettings.PerformanceSwitch = 'Performed'; % Switch to show performance over all trials (including trials that were not self-performed)
DefaultSettings.modSelect = 'Combined'; % selector which part of the data show in the performance curve window
DefaultSettings.StartTime = '1'; %start time of current session.
DefaultSettings.cTrial = 1; %Nr of current trial.
DefaultSettings.biasSeqLength = 3; %nr of trials on one side after which the other side is switched with 50% probability

DefaultSettings.widefieldPath = '\\naskampa\LTS2\BpodWidefield\'; %path to widefield data on server
DefaultSettings.serverPath = '\\naskampa\DATA\BpodBehavior\'; %path to behavioral data on server
DefaultSettings.labcamsAddress = '127.0.0.1:9998';
DefaultSettings.visualAddress = '127.0.0.1:5005';
DefaultSettings.wavePort = 'COM18'; %com port for analog output module
DefaultSettings.analogInPort = 'COM4'; %com port for analog input module
DefaultSettings.rotaryEncoderPort = 'COM10'; %com port for rotary encoder module
DefaultSettings.ambientPort = 'COM11'; %com port for ambient module

DefaultSettings.TrainingMode = false; %flag if training is being used
DefaultSettings.labcamsWidefield = '';%'peanutbread.cshl.edu:9998'
DefaultSettings.triggerWidefield = 0; 

% Spout settings
DefaultSettings.SpoutSpeed = 25; % Duration of spout movement from start to endpoint when moving in or out (value in ms)
DefaultSettings.rInnerLim = 90; % Servo position to move right spoute close the animal (value between 0 and 100)
DefaultSettings.lInnerLim = 90; % Servo position to move left spoute close the animal (value between 0 and 100)
DefaultSettings.rOuterLim = 80; % Servo position to move right spoute more distant from the animal (value between 0 and 100)
DefaultSettings.lOuterLim = 80; % Servo position to move left spoute more distant from the animal (value between 0 and 100)
DefaultSettings.TouchThresh = 5; % Threshold for touch lines (SDUs)
DefaultSettings.lMaxSpoutIn = 150; % maximal inner position for left spout
DefaultSettings.rMaxSpoutIn = 150; % maximal inner position for right spout
DefaultSettings.spoutOffset = 10; %distance from inner spout position when moved out

% Trial timing
DefaultSettings.preStimDelay = 1; % (s) animal should sit still before a new stimulus is presented
DefaultSettings.ITI_scale = 1.1; % (s) scale of the gamma distribution of inter trial intervals
DefaultSettings.ITI_shape = 2; % (s) shape of the gamma distribution

DefaultSettings.WaitingTime = 1; % (s) minimum waiting time before a response can be made. Earlier licks are being ignored.
DefaultSettings.TimeToChoose = 3; % (s) wait for a decision
DefaultSettings.TimeToConfirm = 0.5; % (s) wait for a decision
DefaultSettings.TimeOut = 3; % (s) timeout punish for false response
DefaultSettings.StimDuration = 3; % (s) Duration of a stimulus sequence
DefaultSettings.runTime = 0; % (h) Duration of the current session
DefaultSettings.varStimDur = 0; % (s) Variable duration of the stimulus sequence. Stim will be StimDuration + (0 to varStimDur)
DefaultSettings.optoDur = 0.5; % (s) Duration of the optogenetic stimulus.
DefaultSettings.optoRamp = 0.2; % (s) Time where optogenetic stimulus is ramping down. Example: optoDur = 0.5 and optoRamp = 0.2 makes a 500ms stimulus that ramps down after 300ms.
DefaultSettings.happyTime = 0.5; % (s) Time of the last bpod state. This is to give the animal some time to collect the water.
DefaultSettings.TrialStartCue = 1;
DefaultSettings.UseStimStartCue = 1;

DefaultSettings.optoSeqActive = false; %activate optogenetic sequence mode: run a certain number of optogenetic trials after a specific duration in minutes
DefaultSettings.optoSeqUnilateral = false; %perform unilateral optogenetic stimulation sequence
DefaultSettings.optoSeqTrials = 0; %number of optogenetic trials that will be activated each cycle
DefaultSettings.optoSeqInterval = 0; % (min) duration of interval until next set of optogenetic trials is activated.
DefaultSettings.optoSeqStartTime = 0; % (min) time of the first optogenetic sequence after beginning of the first trial.

%Stimulus settings
DefaultSettings.BeepDuration = 3; % Beep duration in ms.
DefaultSettings.FlashDuration = 20; % Flash duration in ms.
DefaultSettings.BuzzDuration = 50; % Buzz duration in ms.
DefaultSettings.varStimOn = [0 0.125 0.25]; % Variable onset time for stimulus after lever grab in s. This can be a vector of values. Have to be 0 and higher.
DefaultSettings.StimBrightness = 20; %Brightness of flashes. Multiplier of base frequency (default is 100Hz).
DefaultSettings.StimLoudness = 0.5; %Loudness of tones
DefaultSettings.BuzzStrength = 1; %Strength of buzzes
DefaultSettings.WaitForCam = false; % Any positive value will make each trial wait for a trigger signal from the camera. After CamWait seconds without trigger, protocol will continue.
DefaultSettings.StimRate = 2; % Rate of target sequence. Can be either a single scalar or a vector.
DefaultSettings.TargFractions = 1; % Probability of showing a stimulus in a given bin of the target sequence. Should be a single number between 0-1
DefaultSettings.DistFractions = 0.3; % Probability of showing a stimulus in a given bin of a distractor sequence. Should be a single number between 0-1
DefaultSettings.DistProb = 0; % Probability of a presenting a distractor trial. Only has an effect if DistFractions > 0.
DefaultSettings.useDistAudio = true;
DefaultSettings.useDistVisual = true;
DefaultSettings.useDistTactile = true;
DefaultSettings.BinPos = 0; % Start of auditory/tactile stimuli within a given bin (in seconds).
DefaultSettings.StimCoherence = 1; % Flag to determine if multisensory stimuli on the same side should be correlated (1) or not (0). Only used for non-regular stim sequences.
DefaultSettings.UseNoise = 0; % Amplitude (V) of auditory white-noise that is played in addition to other stimuli. Can be used to change auditory SNR.
DefaultSettings.ProbAudio = 0; % Probability of presenting an audio only trial when modality setting allows it. Has no function otherwise.
DefaultSettings.ProbVision = 0; % Probability of presenting an vision only trial when modality setting allows it. Has no function otherwise.
DefaultSettings.ProbTactile = 0; % Probability of presenting a somatosensory only trial when modality setting allows it. Has no function otherwise.
DefaultSettings.DecisionGap = [1]; % Range of a gap between stimulus and decision period in s.
DefaultSettings.TestModality = 0; % Define a modality to be used with discrimination (1=vis,2=aud,4=ss), inactive if set to 0. All others will be detection only.
DefaultSettings.optoProb = 0; % Probability to present an optogenetic stimulus. Ranges from 0 (no optogenetics) to 1 (all trials).
DefaultSettings.optoAmp1 = 2; % Magnitude of optogenetic stimulus on line 3 (mW).
DefaultSettings.optoAmp2 = 2; % Magnitude of optogenetic stimulus on line 4 (mW).
DefaultSettings.optoLocation = 'A1'; % Location of optogenetic stimulation/inactivation.
DefaultSettings.optoPeriod = 'Stimulus/Delay'; % Part of the trial where optogenetic stimulus should be presented.
DefaultSettings.optoRight = 0.5; %Probability for occurence of an optogenetic stimulus on the right.
DefaultSettings.optoBoth = 1; %Probability for occurence of an optogenetic stimulus on both sides. This comes after determining a single HS target.
DefaultSettings.optoPower = 5; %Power of optogenetic light on the brain surface. This is just an indicator.
DefaultSettings.sRate = 20000; % This is the sampling rate of the analog output module. Max rates: 2ch = 100kHz, 4ch = 50kHz, 8ch = 20kHz
DefaultSettings.PunishSoundDur = 0; % (s) Duration of white noise punish sound when the animal makes a mistake.
DefaultSettings.blackScreen = false; %flag to set screens to black when no visual stimulation is used. This stops the visual stim server.
DefaultSettings.stimScreens = [3 4]; %ID number of screens that should be used for visual stimulation.
DefaultSettings.showWater = false; %flag to present a water drop during the pre-stimulus period.
DefaultSettings.maxDetectionSequence = true; % rather to always present the maximum number of target cues in detection trials or not?
DefaultSettings.distDifficulties = 1:5; % Difficuilties to uniformly present in discrim. trials

% Stimulus presentation settings
DefaultSettings.ProbRight = 0.5; %Probability for occurence of a target presentation on the right.
DefaultSettings.contingencyReversal = false; %if true, this will invert the stimulus - response relation. so stimulus on the left should be response on the right.
DefaultSettings.ServoPos = zeros(1,2); % position of left and right spout, relative to their inner limit. these values will be changed by anti-bias correction to correct spout position.
DefaultSettings.maxServoPos = zeros(1,2)+3;