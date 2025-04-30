%PuffyPenguin_CloseSession
tic

% check if optoSeq is active and make sure optogenetics are disabled at session end
if S.optoSeqActive
    BpodSystem.ProtocolSettings.optoProb = 0;
end

% save settings
ProtocolSettings = BpodSystem.ProtocolSettings;
fname = BpodSystem.GUIData.SettingsFileName;
save(fname, 'ProtocolSettings');

% Move spouts to reset position.
teensyWrite([71 1 '0' 1 '0']); % Move spouts to zero position

% close visual stim server
if isfield(BpodSystem.PluginObjects, 'udpVisual') && ~isempty(BpodSystem.PluginObjects.udpVisual)
    fwrite(BpodSystem.PluginObjects.udpVisual, 'Close')
end
sca;

% stop video
try
    if exist('udplabcams','var')
        fwrite(udplabcams,sprintf('log=end'));fgetl(udplabcams);
%         fwrite(udplabcams,sprintf('softtrigger=0'));fgetl(udplabcams);
        fwrite(udplabcams,sprintf('manualsave=0'));fgetl(udplabcams);
%         fwrite(udplabcams,sprintf('quit=1'))
        fclose(udplabcams);
        clear udplabcams
        hasvideo = 1;
    end
    disp("Done stopping video.")

catch err
    disp("Error stopping video.")
    disp(err.message)
end

% save screenshot of current session
BpodSystem.GUIHandles.PuffyPenguin.TabGroup.SelectedTab = BpodSystem.GUIHandles.PuffyPenguin.TaskTab; %bring task tab to foreground
exportapp(BpodSystem.GUIHandles.PuffyPenguin.PuffyPenguinUIFigure, [BpodSystem.Path.CurrentDataFile '_GUIpic.jpg']);
  
% check for path to server and save behavior + graph
if exist(BpodSystem.ProtocolSettings.serverPath, 'dir') %if server responds
    try
        set(BpodSystem.GUIHandles.PuffyPenguin.StopButton,'Text','Copying data')
        set(BpodSystem.GUIHandles.PuffyPenguin.StopButton,'FontColor',[100,255,100])
        drawnow;
    end
    if ~(BpodSystem.ProtocolSettings.serverPath(end) == filesep)
        BpodSystem.ProtocolSettings.serverPath = [BpodSystem.ProtocolSettings.serverPath filesep];
    end
    serverPath = strrep(BpodSystem.Path.CurrentDataFile,...
        BpodSystem.Path.DataFolder,...
        BpodSystem.ProtocolSettings.serverPath);
    [serverdir,tmp] = fileparts(serverPath);
    try
        
        SessionData = BpodSystem.Data; %current session data
        if ~isempty(SessionData) && (iTrials > 10)
            if ~exist(serverdir,'dir')
                mkdir(serverdir)
            end
            disp(['Writing to: ',serverPath])
            [SUCCESS,MESSAGE,MESSAGEID] = copyfile([BpodSystem.Path.CurrentDataFile '.mat'],[serverPath '.mat']);
            [SUCCESS,MESSAGE,MESSAGEID] = copyfile([BpodSystem.Path.CurrentDataFile '_GUIpic.jpg'],[serverPath '_GUIpic.jpg']);
            try
                if exist('hasvideo','var')
                    if hasvideo
                        videoPaths = [dataPath filesep bhvFile];
                        disp('Copying video data')
                        filestocp = [dir([videoPaths,'*.avi']);dir([videoPaths,'*.camlog']); ...
                            dir([videoPaths,'*.csv'])];
                        if ~isempty(filestocp)
                            for f = 1:length(filestocp)
                                [SUCCESS,MESSAGE,MESSAGEID] = copyfile([filestocp(f).folder,...
                                    filesep,filestocp(f).name],serverdir);
                                if ~SUCCESS
                                    disp(['ERRROR - Copy ',videoPaths,filesep,filestocp(f).name,' failed'])
                                else
                                    disp(['Copied ',videoPaths,filesep,filestocp(f).name])
                                end
                            end
                        end
                    end
                end
            end
        end
        disp('Done.')
    catch ER
        warning('!!! Error while writing to server. Make sure local data got copied correctly. !!!');
        disp(ER.message);
    end
end
try
    set(BpodSystem.GUIHandles.PuffyPenguin.StopButton,'Text','Start')
    set(BpodSystem.GUIHandles.PuffyPenguin.StopButton,'FontColor',[0,0,0])
    drawnow;
end

% close GUI
close(BpodSystem.GUIHandles.PuffyPenguin.PuffyPenguinUIFigure);
RunProtocol('Stop');
toc