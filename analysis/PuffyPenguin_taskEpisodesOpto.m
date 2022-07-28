function allData = PuffyPenguin_taskEpisodesOpto(bhv,cInd,dateRange)
%short function to compute detection performance with optogenetic
%inactivation during different trial episodes

typeOrder = [1 4 2 3]; %order different task episodes chronologically. This assumes Early Stimulus(1), LateStimulus(4), Delay(2), Response(3)
stimLocs = unique(bhv.optoLocation);

if ~exist('cInd','var') || isempty(cInd)
    cInd = true(1,length(bhv.Rewarded));
end
if ~exist('dateRange','var') || isempty(dateRange)
    dateRange = [1 inf];
end


cInd = cInd & bhv.date >= dateRange(1) & bhv.date <= dateRange(2);
oInd = cInd & bhv.optoDur == 0.5 & bhv.optoType > 0 & bhv.optoSide == 3 & bhv.distFrac == 0; %bilateral stimulation, different episodes
allData.dates = unique(bhv.date(oInd)); %keep dates with optogenetic trials

for iSide = 1:2
    % non-opto performance
    pInd = cInd & ~bhv.DidNotChoose & logical(bhv.Assisted) & bhv.distFrac == 0 & bhv.CorrectSide == iSide; %only use active detection trials on current side
    dInd = pInd & bhv.optoDur == 0 & ismember(bhv.SessionNr, unique(bhv.SessionNr(oInd))); %non-optogenetic trials from same sessions
%     dInd = rateDisc_equalizeTrialsPerMouse(bhv, dInd); %equalize trial counts for animals in current selection
    rInd = dInd & ((bhv.CorrectSide == 1 & bhv.Punished) | (bhv.CorrectSide == 2 & bhv.Rewarded)); %right-choice trials
    
    allData.detect(iSide) = sum(rInd)/sum(dInd); %percent right choices
    [allData.detectUp(iSide), allData.detectLow(iSide)] = Behavior_wilsonError(sum(rInd)*2, sum(dInd)*2); %error
    allData.stimCnt(iSide) = sum(dInd);
    
    for iTime = 1 : length(typeOrder) %different task episodes.
        for stimLoc = 1 : length(stimLocs) % opto performance - frontal (1) / parietal (2) / S1 (3)
            
            dInd = pInd & oInd & strcmp(bhv.optoLocation, stimLocs{stimLoc}) & bhv.optoType == typeOrder(iTime); %optogenetic trials
%             dInd = rateDisc_equalizeTrialsPerMouse(bhv, dInd); %equalize trial counts for animals in current selection
            rInd = dInd & ((bhv.CorrectSide == 1 & bhv.Punished) | (bhv.CorrectSide == 2 & bhv.Rewarded)); %right-choice trials
            allData.optoDetect(iSide,iTime,stimLoc) = sum(rInd)/sum(dInd); %percent right choices
            [allData.optoDetectUp(iSide,iTime,stimLoc), allData.optoDetectLow(iSide,iTime,stimLoc)] = Behavior_wilsonError(sum(rInd), sum(dInd)); %error
            
        end
    end
end

% same thing for all trials non-opto performance
pInd = ~bhv.DidNotChoose & logical(bhv.Assisted) & bhv.distFrac == 0; %use active detection trials on both sides
dInd = pInd & bhv.optoDur == 0 & ismember(bhv.SessionNr, unique(bhv.SessionNr(oInd))); %non-optogenetic trials from same sessions
% dInd = rateDisc_equalizeTrialsPerMouse(bhv, dInd); %equalize trial counts for animals in current selection
rInd = dInd & bhv.Rewarded; %correct trials

allData.detect(iSide+1) = sum(rInd)/sum(dInd); %percent correct choices
[allData.detectUp(iSide+1), allData.detectLow(3)] = Behavior_wilsonError(sum(rInd), sum(dInd)); %error
allData.stimCnt(iSide+1) = sum(dInd);
allData.controlCnt = sum(dInd); 

for iTime = 1 : length(typeOrder) %different task episodes.
    for stimLoc = 1 : length(stimLocs) % opto performance - frontal / parietal / S1
        
        dInd = pInd & oInd & strcmp(bhv.optoLocation, stimLocs{stimLoc}) & bhv.optoType == typeOrder(iTime); %optogenetic trials
%         dInd = [false dInd(1:end-1)] & ~oInd; %subsequent non-opto trials
%         dInd = rateDisc_equalizeTrialsPerMouse(bhv, dInd); %equalize trial counts for animals in current selection
        rInd = dInd & bhv.Rewarded; %correct trials
        allData.optoDetect(iSide+1,iTime,stimLoc) = sum(rInd)/sum(dInd); %percent right choices
        [allData.optoDetectUp(iSide+1,iTime,stimLoc), allData.optoDetectLow(iSide+1,iTime,stimLoc)] = Behavior_wilsonError(sum(rInd)*1.4, sum(dInd)*1.4); %error
        allData.optoCnt(iTime,stimLoc) = sum(dInd);
        allData.indCnt(iTime,stimLoc) = sum(dInd) / length(unique(bhv.AnimalID(dInd)));
        
    end
end