function SpatialSparrow
global BpodSystem

SpatialSparrow_Settings; %script to define default settings if they are not defined by settings file
SpatialSparrow_Init; %initialize hardware and establish labcams communication

%% wait for start signal from GUI
BpodSystem.Status.SpatialSparrowPause = true;
while BpodSystem.Status.SpatialSparrowPause
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
BpodSystem.Status.SpatialSparrowExit = false;
for iTrials = 1 : maxTrials
    
    % check the pause button
    if BpodSystem.Status.SpatialSparrowPause
        disp('Spatial Sparrow paused')
        while BpodSystem.Status.SpatialSparrowPause 
            drawnow; pause(0.03); 
            if ~BpodSystem.Status.BeingUsed || BpodSystem.Status.SpatialSparrowExit
                break
            end
        end
    end
    
    % only run this code if protocol is still active
    if BpodSystem.Status.BeingUsed && ~BpodSystem.Status.SpatialSparrowExit
        
        tic % single trial timer
        
        SpatialSparrow_TrialInit %check basic variables (timing etc for current stimulus)
        SpatialSparrow_StimulusInit %set up simuli for different modalities/sides etc and generate analog waveforms - CHANGE THIS
        SpatialSparrow_OptoInit %set up optogenetic stimuli for left/right and at what point in the trial - CHANGE THIS
        SpatialSparrow_AutoReward %check if single spouts should be given, based on trainingsstatus
        
        Signal = Signal([1:2,7:8],:);
        SpatialSparrow_BpodTrialInit %prepare variables for state machine - CHANGE THIS
        SpatialSparrow_DisplayTrialData %show current trial stuff on GUI
        
        
        %% create ITI jitter
        trialPrep = toc; %check how much time was used to prepare trial and subtract from ITI
        if (ITIjitter - trialPrep - 0.1)*1000  > 0 % removing the 0.1 because there is a delay in sending the state machine
            %disp(['ITI ' , num2str(ITIjitter), 's'])
            java.lang.Thread.sleep((ITIjitter - trialPrep - 0.1)*1000); %wait a moment to get to determined ITI
        end
        
        BpodSystem.SerialPort.read(BpodSystem.SerialPort.bytesAvailable, 'uint8'); %remove all bytes from serial port
        setMotorPositions;
        
        BpodSystem.Data.weirdBytes = false;
        while BpodSystem.SerialPort.bytesAvailable > 0 %clear excess bytes from bpod that aquired from ITI
            disp('!!! Something really weird is going on with the serial communication to Bpod !!!');
            disp(BpodSystem.SerialPort.bytesAvailable);
            BpodSystem.SerialPort.read(BpodSystem.SerialPort.bytesAvailable, 'uint8'); %remove all bytes from serial port
            pause(0.01);
            BpodSystem.Data.weirdBytes = true;
        end

        %% run bpod and save data after trial is finished
        SpatialSparrow_StateMachine; %produce state machine and upload to bpod - Change THIS
        
        % set the frame number just before starting
        if exist('udplabcams','var')
            fwrite(udplabcams,sprintf('log=trial_start:%d',iTrials));
        end
        
        RawEvents = RunStateMachine; % run state matrix
        
        % upate labcams counter
        if exist('udplabcams','var')
            fwrite(udplabcams,sprintf('log=trial_end:%d',iTrials));
        end

        SpatialSparrow_SaveTrial
        
        try
            BpodSystem.GUIHandles.spatialSparrow.update_performance_plots();
        catch
            disp('Could not update performance plots.')
        end
        toc;disp('==============================================')
        % send the motors to zero before starting another trial
        
        teensyWrite([71 1 '0' 1 '0']); % move spouts to zero;
        HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
        if BpodSystem.Status.SpatialSparrowExit
            RunProtocol('Stop')
        end
    else  %stop code if stop button is pressed and close figures
        SpatialSparrow_CloseSession
        break;
    end
end
