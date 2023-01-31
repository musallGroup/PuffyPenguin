function PuffyPenguin
global BpodSystem

BpodSystem.Status.PuffyPenguinExit = false;
PuffyPenguin_Settings; %script to define default settings if they are not defined by settings file
PuffyPenguin_Init; %initialize hardware and establish labcams communication

%% wait for start signal from GUI
BpodSystem.GUIHandles.PuffyPenguin.PauseSwitch.Value = 'pause'; drawnow;
BpodSystem.Status.PuffyPenguinPause = true;
figure(BpodSystem.GUIHandles.PuffyPenguin.PuffyPenguinUIFigure); %bring to foreground
while BpodSystem.Status.PuffyPenguinPause && ~BpodSystem.Status.PuffyPenguinExit 
    drawnow; pause(0.03);
end

%% Start saving labcams if connected
if exist('udplabcams','var')
    fwrite(udplabcams,'softtrigger=0')
    fgetl(udplabcams);
    fwrite(udplabcams,'manualsave=1')
    fgetl(udplabcams);
    fwrite(udplabcams,'softtrigger=1')
    fgetl(udplabcams);
    BpodSystem.Status.labcamsRuns = true; %flag that video is being recorded
end

%% Main loop for single trials
optoSeqStartTime = now; %start point for sequential optogenetics mode
optoSeqTrialCnt = inf; %trialcounter for sequential optogenetics mode
for iTrials = 1 : maxTrials
    
    % check the pause button
    if BpodSystem.Status.PuffyPenguinPause
        disp('Spatial Sparrow paused')
        while BpodSystem.Status.PuffyPenguinPause 
            drawnow; pause(0.03); 
            if ~BpodSystem.Status.BeingUsed || BpodSystem.Status.PuffyPenguinExit
                break
            end
        end
    end
    
    %check bpod pause button
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
        
    % only run this code if protocol is still active
    if BpodSystem.Status.BeingUsed && ~BpodSystem.Status.PuffyPenguinExit
        
        tic % single trial timer

        %update trial counter
        BpodSystem.Data.cTrial = iTrials;
    
        %% run main scripts to prepare current trial
        PuffyPenguin_TrialInit %check basic variables (timing etc for current stimulus)
        PuffyPenguin_StimulusInit %set up simuli for different modalities/sides etc and generate analog waveforms
        PuffyPenguin_AutoReward %check if single spouts should be given, based on trainingsstatus
        PuffyPenguin_OptoInit %set up optogenetic stimuli for left/right and at what point in the trial
        PuffyPenguin_BpodTrialInit %prepare variables for state machine
        PuffyPenguin_DisplayTrialData %show current trial stuff on GUI
        
        %% create ITI jitter
        trialPrep = toc; %check how much time was used to prepare trial and subtract from ITI
        if (ITIjitter - trialPrep - 0.1)*1000  > 0 % removing the 0.1 because there is a delay in sending the state machine
            %disp(['ITI ' , num2str(ITIjitter), 's'])
            java.lang.Thread.sleep((ITIjitter - trialPrep - 0.1)*1000); %wait a moment to get to determined ITI
        end
        
        BpodSystem.SerialPort.read(BpodSystem.SerialPort.bytesAvailable, 'uint8'); %remove all bytes from serial port        
        setMotorPositions;
        
        %% check for weird bytes. This maybe happens if the touchshaker sends a lot of false lick bytes? Broken cable?
        BpodSystem.Data.weirdBytes = false;
        while BpodSystem.SerialPort.bytesAvailable > 0 %clear excess bytes from bpod that aquired from ITI
            disp('!!! Something really weird is going on with the serial communication to Bpod !!!');
            disp(BpodSystem.SerialPort.bytesAvailable);
            BpodSystem.SerialPort.read(BpodSystem.SerialPort.bytesAvailable, 'uint8'); %remove all bytes from serial port
            pause(0.01);
            BpodSystem.Data.weirdBytes = true;
        end
        
        %% run bpod and save data after trial is finished
        PuffyPenguin_StateMachine; %produce state machine and upload to bpod

        % set the frame number just before starting
        if exist('udplabcams','var')
            fwrite(udplabcams,sprintf('log=trial_start:%d',iTrials));
        end
        
        % run state matrix
        RawEvents = RunStateMachine; 
        
        % update labcams counter
        if exist('udplabcams','var')
            fwrite(udplabcams,sprintf('log=trial_end:%d',iTrials));
        end

        PuffyPenguin_SaveTrial; %save data from current trial and settings if requested
        
        try
            BpodSystem.GUIHandles.PuffyPenguin.update_performance_plots;
        catch
            disp('Could not update performance plots.')
        end
        toc;disp('==============================================')
        
        % move spouts to zero;
        teensyWrite([71 1 '0' 1 '0']); 

    else  %stop code if stop button is pressed and close figures
        PuffyPenguin_CloseSession
        PuffyPenguin_checkPerformance
        break;
    end
end
