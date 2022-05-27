%% check if stim server is already up
if startVisServer
    if isfield(BpodSystem.PluginObjects, 'udpVisual') && isobject(BpodSystem.PluginObjects.udpVisual)
        while BpodSystem.PluginObjects.udpVisual.BytesAvailable > 0
            fread(BpodSystem.PluginObjects.udpVisual);
        end

        tic
        fwrite(BpodSystem.PluginObjects.udpVisual,'Ping');
        while toc <0.1
            if BpodSystem.PluginObjects.udpVisual.BytesAvailable > 0
                fgetl(BpodSystem.PluginObjects.udpVisual);
                startVisServer = false;
%                 disp(' -> Stim server is running.');
                break
            end
        end
    end
end
        
%% initialize communication with visual stimulation server
if startVisServer
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
    fwrite(BpodSystem.PluginObjects.udpVisual,'Ping'); tic
    while BpodSystem.PluginObjects.udpVisual.BytesAvailable == 0 && toc < 1; end
    
    if BpodSystem.PluginObjects.udpVisual.BytesAvailable > 0
        fgetl(BpodSystem.PluginObjects.udpVisual);
        startVisServer = false;
        disp(' -> Stim server connected.');
    else
        warning('Could not establish connection to visual stimulation server. Visual stimuli wont be available.');
    end
end