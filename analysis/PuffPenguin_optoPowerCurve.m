function allData = PuffPenguin_optoPowerCurve(bhv, oInd)
% function to compute performance curve for different optogenetic power
% levels. bhv is a struct with trials from the PuffyPengiun paradigm, oInd
% is an index with trials in which optogenetic trials were presented.

perfInd = ~bhv.DidNotChoose & logical(bhv.Assisted); %performed trials
oInd = oInd & perfInd; %only use performed optogenetics trials
optoPowers = unique([bhv.optoAmp1(oInd), bhv.optoAmp2(oInd)]); %get used power levels in optogenetic trials
allData.optoPowers = [0, optoPowers]; 

%% compute performane in non-optogenetic control trials
ctrlInd = ismember(bhv.SessionNr, unique(bhv.SessionNr(oInd))) & ~oInd & perfInd;
rInd = bhv.Rewarded & ctrlInd; %correct trials
allData.Detect = sum(rInd)/sum(ctrlInd); %percent correct choices
[allData.detectUp, allData.detectLow] = Behavior_wilsonError(sum(rInd), sum(ctrlInd)); %error
allData.trialCnt = sum(ctrlInd);
        
%% compute performance in optogenetic trials with different powers
for iPower = 1 : length(optoPowers)
        
    powerInd = oInd & (bhv.optoAmp1 == optoPowers(iPower) | bhv.optoAmp2 == optoPowers(iPower)); %select trials with correct power
    rInd = bhv.Rewarded & powerInd; %correct trials
    allData.optoDetect(iPower) = sum(rInd)/sum(powerInd); %percent correct choices
    [allData.optoDetectUp(iPower), allData.optoDetectLow(iPower)] = Behavior_wilsonError(sum(rInd), sum(powerInd)); %error
    allData.optoTrialCnt(iPower) = sum(powerInd);
        
end