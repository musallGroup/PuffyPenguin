for iTrials = 1 : length(BpodSystem.Data.Rewarded)
    
    iAll = BpodSystem.Data.Assisted(1:iTrials) & (~BpodSystem.Data.DidNotChoose(1:iTrials));
    PerformanceVec = cumsum(BpodSystem.Data.Assisted(1:iTrials) & BpodSystem.Data.Rewarded(1:iTrials)) ./cumsum(iAll);
    if sum(iAll)<=ntrials_avg*2
        sPerformanceVec = PerformanceVec;
    else %get performance for the last ntrials_avg trials
        sPerformanceVec = BpodSystem.Data.Performance;
        temp = find(iAll); iAll = false(1,length(iAll)); iAll(temp(end-(ntrials_avg*2)+1:end)) = true; clear temp %only use the last ntrials_avg trials
        a = BpodSystem.Data.Rewarded(1:iTrials);
        sPerformanceVec(end+1) = sum(a(iAll))/(ntrials_avg*2); % add performance in current trial
    end
    BpodSystem.Data.Performance = sPerformanceVec; %update Bpod data with overall performance
    
end