# SpatialSparrow

Multimodal rate discriminaton behavioral task for mice.

## Description of the setup

This should show a labeled picture of the setup. 

## Data saving and automatic copy

This should say what gets saved where and what is automatically copied and when. 

The TouchShaker teensy module reports lick and handle touch times, these get communicated and logged by Bpod.

### SessionData.RawEvents

Event list correspondence :

| TouchShaker byte | Event |
|------------------|-------|
| TouchShaker1_1 | left_spout_touch |
| TouchShaker1_2 | right_spout_touch |
| TouchShaker1_3 | left_spout_release |
| TouchShaker1_4 | right_spout_release |
| TouchShaker1_5 | left_handle_touch |
| TouchShaker1_6 | right_handle_touch |
| TouchShaker1_7 | both_handle_touch |
| TouchShaker1_8 | left_handle_release |
| TouchShaker1_9 | right_handle_release |
| TouchShaker1_14 | acknowledge |
| TouchShaker1_15 | error |

State list correspondence:



## Settings and description

Settings can be set from Bpod (mat files in Bpod Local/Settings).
Default settings are in SpatialSparrow.m

Settings for `training control`:

| Setting | Default | Description |
|---------|---------|-------------|
| SubjectName | | Name of the mouse |
| RewardedModality | AudioVisual |'Vision', 'Audio', Somatossensory, 'AudioVisual', 'Mixed' |
| leftRewardVolume | 2 ul | Amount of water per left reward |
| rightRewardVolume | 2 ul | Amount of water per right reward |
| AutoReward | OFF | Pre-load rewarded spout |
| TrainingMode | OFF | Move spouts to the correct side |
| autoRewardVision | 1 | Fraction of self-performed trials (Vision) |
| autoRewardAudio | 1 | Fraction of self-performed trials (Auditory) |
| autoRewardPiezo | 1 | Fraction of self-performed trials (Somatossensory) |
| autoRewardMixed | 1 | Fraction of self-performed trials (Mixed) |
| LeverSound | true | Play a sound when the mouse touches the handles |
| RegularStim | false | Produce regular stimuli sequences |
| biasSeqLength | 3 | nr of trials on one side after which the oposite side is switched with 50% probability |

Settings for `trial timing` :

| Setting | Default | Description |
|---------|---------|-------------|
| preStimDelay | 1 (s) | time on handle before stimuli presentation |
| StimDuration | 1 (s) | duration of the stimulus |
| happyTime | 0.5 (s) | duration of the last state (gives time to collect reward) |
| varStimDur | 0 (s) | variable stim duration (StimDuration + varStimDur) is the actual stim duration |
| optoDur | 0.5 (s) | duration of the optogenetics stimuli |
| optoRmp | 0.2 (s) | duration of the optogenetics ramp down (optoDur = 0.5 and optoRamp = 0.2 makes a 500ms stimulus that ramps down after 300ms) ??????? |
| minITI | 1 (s) | min inter trial interval (additional) |
| maxITI | 2 (s) | max inter trial interval (additional) |
| ITIlambda | 10 (AU) | bariability between minITI and maxITI. High lambda -> closer to minITI |
| WaitingTime | 1 (s) | minimum waiting time before a response can be made, early licks are ignored |
| TimeToChoose | 3 (s) | how long to wait for choice report |
| TimeToConfirm | 0.5 (s) | how long to wait for a 2nd (confirmation) lick |
| Timeout | 3 (s) | timeout to punish wrong responses |
| LeverWait | 10 (s) | time to wait for handle grasp |
| MoveLever | TRUE | move levers or not (set to FALSE during habituation)|
| UseBothLevers | FALSE | Whether both handles need to be touched to initiate trials |
| WaitBeforeLever | 1 (s) | Wait time before handles are moved in after trial onset|

Settings for `stimuli parameters` :

| Setting | Default | Description |
|---------|---------|-------------|
| TargRate  | 10 (Hz) | Rate of the target sequence |
| ProbRight  | 0.5 | Fraction of targets on the right |
| DistFractions  | 0  | Distractor pulses (fraction of the target sequence). Can be a scalar [0-1] or a vector |
| DistProb  | 0  | Probability of presenting a distractor |
| TestModality  | 0  | Modality to be used with discrimination (1=vis, 2=aud, 4=ss). Zero is inactive. Other values are detection only |
| BinSize  | 50 (ms) | Stimuli refractory period (min interval between pulses) |
| StimCoherence  | TRUE | Determines whether multisensory stimuli are correlated | 
| UseNoise  | FALSE | Use noise burst (TRUE) of clicks (FALSE) as auditory stimuli |
| varStimOn  | [0 0.125 0.25] (s) | Variable onset time for stimulus after lever grab in s. This can be a vector of values. Have to be 0 and higher. |
| StimGap  | 0 (s) | Duration of the gap in the middle of stimulus presentation in s; if >0 the stim duration is of stimDuration*2 + stimGap long |
| DecisionGap  | [0.3 1.5] (s) | Range of the interval between the stimulus and the decision period |
| BeepDuration  | 20 (ms) | Beep (auditory) duration |
| StimLoudness  | 0.5 | Strength of auditory stimuli |
| FlashDuration  | 20 (ms) | Flash (visual) duration |
| StimBrightness  | 20  | Brightness of flashes. Multiplier of the base frequency, default is 100Hz (????) |
| BuzzDuration  | 20 (ms) | Buzz (somatossensory) duration |
| BuzzStrength  | 1  | Strength of buzzes |
| ProbAudio  | 0  | Probability of presenting an auditory-only trial (for multimodal) |
| ProbVisual  | 0  | Probability of presenting a visual-only trial (for multimodal) |
| ProbPiezo  | 0  | Probability of presenting a somatossensory-only trial (for multimodal) |
| sRate  | 20000  | Sampling rate of the AnalogOutput module |
| PunishSoundDur  | 0 (s)  | Duration of the white noise punishment sound |
| optoProb  | 0  | Fraction of optogenetics trials |
| optoTimes  | Stimulus/Delay | Part of the trial where optogenetic stimulus should be presented |
| optoRight  | 0.5  | Probability for occurence of an optogenetic stimulus on the right |
| optoBoth  | 1  | Probability for occurence of an optogenetic stimulus on both sides. This comes after determining a single HS target ??? |
| optoPower  | 5  | Fraction of optogenetics stimuli |

Settings for `hardware control and sync` :

| Setting | Default | Description |
|---------|---------|-------------|
| SpoutSpeed | 25 (ms) | Duration of spout movement |
| rMaxSpoutIn | 30 | Right spout inner position (value between 0 and 100) |
| lMaxSpoutIn | 30 | Left spout outer position (value between 0 and 100) |
| spoutOffset | 10 | Distance from inner spout position |
| lOuterLim | 3.5 | Left spout outer position (value between 0 and 100) |
| LeverSpeed | 150 (ms) | Duration of handle movement (ms) |
| LeverIn | 20 | Inner position of the handles |
| LeverOut | 0 | Position of handle out of reach |
| TouchThresh| 5 (SDUs) | Threshold for capacitive touch lines |
| WaitForCam  | false  | Trials wait for a camera trigger to start. |

To check: rInnerLim, lInnerLim, rOuterLim, lOuterLim

Settings for `paths and data copy` :
| Setting | Default | Description |
|---------|---------|-------------|
| widefieldPath | ... | path to widefield data on server |
| serverPath |  ... | path to behavioral data on server |
| videoDrive | C: | path to behavioral data on server |
| bonsaiEXE | ... | path to bonsai.exe  |
| bonsaiParadim | ... | path to the bonsai workflow ('' to skip bonsai)  |
| labcamsAddress | localhost:9999 | address to connect to labcams for video acquisition (leave empty to skip) |
| wavePort | COM18 | COM port of the AnalogOutput Module |


`Plot` settings:
| Variable | Default | Description |
|----------|---------|-------------|
| PerformanceSwitch| Performed | Show performance over all trials or only self-performed trials |
| DoFit| false | Show curve fitting in the performance plot |
| modSelector| Combined | Which data to show in the performance plot |

Operational variables:
| Variable | Default | Description |
|----------|---------|-------------|
| SaveSettings | false | Saves the current settings |
| AdjustSpouts | 0 | Pause for spout adjustment |
| StartTime | ? | Start time of the current session |
| cTrial |  | Number of the current trial |
| runTime |  | Duration of the current session |
| servoPos | [0 0] | position of left and right spout, relative to their inner limit. these values will be changed by anti-bias correction to correct spout position |


## Instalation and build instructions

Clone the repository to Bpod Local/Protocols. If you make changes; create a branch and remember to commit changes regularly.

Build instructions coming here soon.

### Video

There are 2 options for recording video with SpatialSparrow: using [Bonsai](https://bonsai-rx.org/introduction) or using [labcams](https://bitbucket.org/jpcouto/labcams). This readme should show you how to sync the cameras to the BPod (work in progress). 
