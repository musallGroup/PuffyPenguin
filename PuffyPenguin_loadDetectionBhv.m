function bhv = PuffyPenguin_loadDetectionBhv(Animals, cPath, newRun)

if ~exist('cPath', 'var') || isempty(cPath)
    cPath = '\\grid-hs\churchland_nlsas_data\\data\Behavior_Simon\';
% cPath = '\\CHURCHLANDNAS\homes\DOMAIN=CSHL\smusall\Behavior_Simon\';
end

if strcmpi(Animals, 'EMX')
    Animals = {'2471' '2472'};
elseif strcmpi(Animals, 'CStr')
    Animals = {'2480' '2481'};
elseif strcmpi(Animals, 'Plexin')
%     Animals = {'Plex05' 'Plex06' 'Plex07' 'Plex08' 'Plex68' 'Plex69' 'Plex72' 'Plex73'};
    Animals = {'Plex05' 'Plex06' 'Plex07' 'Plex08' 'Plex68' 'Plex72' 'Plex73'};
elseif strcmpi(Animals, 'CSP')
%     Animals = {'CSP8' 'CSP20' 'CSP24' 'CSP25'};
%     Animals = {'CSP7' 'CSP8' 'CSP20' 'CSP24' 'CSP25'};
    Animals = {'CSP7' 'CSP8' 'CSP20' 'CSP24'};
elseif strcmpi(Animals, 'Control')
    Animals = {'CTP3' 'CTP7'};
end
    
if ~exist('newRun', 'var')
    newRun = false;
end
if ~newRun
    try
        load([cPath 'PuffyPenguin' filesep 'optoDetect_' Animals{:}], 'bhv')
    catch ME
        disp(ME.message);
        newRun = true;
        fprintf('Couldnt load processed bhv data. Loading raw files instead.\n')
    end
end
        
if newRun
    bhv = [];
    for iAnimals = 1:length(Animals)
        [~, cBhv] = PuffyPenguin_optoStim(Animals{iAnimals},cPath);
        
        if ~isempty(cBhv)
            cBhv.AnimalID = ones(1, length(cBhv.Rewarded)) * iAnimals;
            if ~isempty(bhv)
                cBhv.SessionNr = cBhv.SessionNr + max(bhv.SessionNr);
            end
            bhv = appendBehavior(bhv,cBhv); %append into larger array
        end
    end
    bhv = selectBehaviorTrials(bhv,~ismember(bhv.SessionNr, unique(bhv.SessionNr(bhv.distFrac > 0)))); %only use sessions that don't include discrmination trials
    if ~exist([cPath 'PuffyPenguin' filesep 'MergedData' filesep], 'dir')
        mkdir([cPath 'PuffyPenguin' filesep 'MergedData' filesep]);
    end
    
    %remove very large fields and save to file
    bhv = rmfield(bhv,'stimEvents');
    bhv = rmfield(bhv,'TrialSettings');
    save([cPath 'PuffyPenguin' filesep 'MergedData' filesep 'optoDetect_' Animals{:}], 'bhv', '-v7.3')
end

%add animal names as output
bhv.Animals = Animals;
