startVisServer = ~BpodSystem.ProtocolSettings.blackScreen;

if BpodSystem.ProtocolSettings.blackScreen
    % cant use blackScreen if visual stimulation is requested
    if ismember(StimType, [1 3 5 7])
        sca;
        BpodSystem.ProtocolSettings.blackScreen = false;
        startVisServer = true;
    
    else
        % make sure visual stim server is closed
        if isfield(BpodSystem.PluginObjects, 'udpVisual') && ~isempty(BpodSystem.PluginObjects.udpVisual)
            fwrite(BpodSystem.PluginObjects.udpVisual, 'Close')
        end
        startVisServer = false;
        
        %black screen
        screenNumber = Screen('Screens'); % Draw to the external screen if avaliable
        screenNumber(screenNumber == 0) = [];
        useScreens = BpodSystem.ProtocolSettings.stimScreens;
        
        if sum(ismember(useScreens, screenNumber)) < length(useScreens)
            disp(['Could not use screens ' num2str(useScreens) ' for visual stimulus.'])
            disp(['Only screens ' num2str(screenNumber) ' are available.'])
            useScreens = [];
        end
        
        if ~isempty(BpodSystem.ProtocolSettings.stimScreens)
            Screen('Preference', 'Verbosity', 0);
            Screen('Preference', 'SkipSyncTests',1);
            Screen('Preference', 'VisualDebugLevel',0);
            
            % check open PTB windows
            windowPtrs = Screen('Windows');
            foundScreens = NaN(1, length(windowPtrs));
            for x = 1 : length(windowPtrs)
                foundScreens(x) = Screen('WindowScreenNumber', windowPtrs(x));
            end
            
            % remove screens with open PTB windows
            useScreens(ismember(useScreens, foundScreens)) = [];
            for x = useScreens
                window = Screen('OpenWindow', x, 128); %open ptb window and save handle in pSettings
            end
        end
    end
else
    sca;
end

% check visual stim server status
PuffyPenguin_VisualStimServer;