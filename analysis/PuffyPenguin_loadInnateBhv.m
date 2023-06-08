function [bhv, Performance] = PuffyPenguin_loadInnateBhv(Animals, cPath, newRun)

if strcmpi(Animals, 'CStr')
    Animals = {'2480', '2481', '2482', '2484', '2485'};
elseif strcmpi(Animals, 'EMX')
    Animals =  {'2523' '2524' '2525' '2526'};
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
        [Performance{iAnimals}, cBhv] = PuffyPenguin_optoStim(Animals{iAnimals},cPath);
        
        if ~isempty(cBhv)
            cBhv.AnimalID = ones(1, length(cBhv.Rewarded)) * iAnimals;
            if ~isempty(bhv)
                cBhv.SessionNr = cBhv.SessionNr + max(bhv.SessionNr);
            end
            bhv = appendBehavior(bhv,cBhv); %append into larger array
        end
    end
    if ~exist([cPath 'PuffyPenguin' filesep 'MergedInnateData' filesep], 'dir')
        mkdir([cPath 'PuffyPenguin' filesep 'MergedInnateData' filesep]);
    end
    
    %remove very large fields and save to file
    bhv = rmfield(bhv,'stimEvents');
    bhv = rmfield(bhv,'TrialSettings');
    save([cPath 'PuffyPenguin' filesep 'MergedData' filesep 'optoDetect_' Animals{:}], 'bhv', '-v7.3')
end

%add animal names as output
bhv.Animals = Animals;
