function sma = smaPassiveHabituation(sma, S, TrialTypes, currentTrial, ...
    ValveTime, ResetBNC, OpenReward, RewardState, RandomValues, RewardProbability)

% TrialTypes:
% 1 = left
% 2 = right

% Reward always automatic
RewardType = {'Reward','Reward'};

%% =========================================================
% WAIT FOR TRIAL START (VR handshake)
%% =========================================================

sma = AddState(sma, 'Name', 'WaitForTrialStart', ...
    'Timer', S.GUI.ResponseTime, ...
    'StateChangeConditions', {'SoftCode1', 'TrialStart'}, ...
    'OutputActions', {ResetBNC{:}, ...
                      'SoftCode', TrialTypes(currentTrial) + 11});  
% encodes stimulus side to VR


%% =========================================================
% TRIAL START (stimulus onset)
%% =========================================================

sma = AddState(sma, 'Name', 'TrialStart', ...
    'Timer', 0, ...
    'StateChangeConditions', {'Tup', 'AutoReward'}, ...
    'OutputActions', {'SoftCode', 9});  
% show stimulus (unilateral)


%% =========================================================
% AUTOMATIC REWARD (no lick required)
%% =========================================================

sma = AddState(sma, 'Name', 'AutoReward', ...
    'Timer', ValveTime, ...
    'StateChangeConditions', {'Tup', 'CloseValves'}, ...
    'OutputActions', {'ValveState', OpenReward, ...
                      'BNC1', 1});  


%% =========================================================
% CLOSE VALVES
%% =========================================================

sma = AddState(sma, 'Name', 'CloseValves', ...
    'Timer', 0, ...
    'StateChangeConditions', {'Tup', 'WaitForVREnd'}, ...
    'OutputActions', {'ValveState', 0, ResetBNC{:}});


%% =========================================================
% WAIT FOR VR END
%% =========================================================

sma = AddState(sma, 'Name', 'WaitForVREnd', ...
    'Timer', Inf, ...
    'StateChangeConditions', {'SoftCode4', 'VREnd'}, ...
    'OutputActions', {});


%% =========================================================
% VR END
%% =========================================================

sma = AddState(sma, 'Name', 'VREnd', ...
    'Timer', 0, ...
    'StateChangeConditions', {'Tup', '>exit'}, ...
    'OutputActions', {'SoftCode', 7});

end
