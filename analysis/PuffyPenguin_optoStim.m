function [Performance,bhv] = PuffyPenguin_optoStim(Animal,cPath)
% Analyze behavioral data from rate discrimination task to test for the
% impact of optogenetic manipulation.

%% check optional input
if ~strcmpi(cPath(end),filesep)
    cPath = [cPath filesep];
end
minTrials = 10;

%% get files and date for each recording
paradigm = 'PuffyPenguin';
cPath = [cPath Animal '\' paradigm '\Session Data\']; %folder with behavioral data

for iChecks = 1:10 %check for files repeatedly. Sometimes the server needs a moment to be indexed correctly
    Files = dir([cPath '*\' Animal '_PuffyPenguin*.mat']); %behavioral files in correct cPath
    if ~isempty(Files)
        break;
    end
    pause(0.1);
end

%% load data
bhv = []; Cnt = 0;
Performance = NaN(size(Files,1),2);
for iFiles = 1:size(Files,1)
    clear SessionData
    load(fullfile(Files(iFiles).folder, Files(iFiles).name)); %load current bhv file
    
    %this determines if a session is used or not
    useData = sum(SessionData.optoDur > 0 & ~SessionData.DidNotChoose) > minTrials && isfield(SessionData.TrialSettings(1), 'optoLocation'); %if file contains some optogenetic trials
    
    normIdx = SessionData.optoDur == 0 & ~SessionData.SingleSpout & ~SessionData.DidNotChoose;
    Performance(iFiles, 1) = sum(SessionData.Rewarded(normIdx)) / sum(normIdx);

    optoIdx = SessionData.optoDur > 0 & ~SessionData.SingleSpout & ~SessionData.DidNotChoose;
    Performance(iFiles, 2) = sum(SessionData.Rewarded(optoIdx)) / sum(optoIdx);

    if useData
        Cnt = Cnt + 1;
        
        %% combine into one larger array
        SessionData.optoLocation = {SessionData.TrialSettings.optoLocation};
        SessionData.SessionNr = repmat(Cnt,1,SessionData.nTrials); %tag all trials in current dataset with session nr
        bhv = appendBehavior(bhv,SessionData); %append into larger array
    end
end
disp(['Current subject: ' Animal '; Using ' num2str(Cnt) '/' num2str(size(Files,1)) ' files']);