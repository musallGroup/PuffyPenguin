% PuffyPenguin_checkMouseWarnings_test
%
% Test script for PuffyPenguin_checkMouseWarnings.
% Mocks the BpodSystem fields that update_performance_plots would populate.
% All data is deterministic.
%
% Scenarios:
%   1) No alarm         - healthy performance, balanced sides, good response rate
%   2) Performance drop - rolling perf drops >20pp below grand average
%   3) Side asymmetry   - left and right rolling perf differ by >20pp
%   4) Low response rate - fewer than 30% of last 20 trials responded
%   5) Cooldown         - alarm should NOT re-fire within 5 trials
%   6) Too few trials   - minimum trial counts not met, no alarm
%   7) One sound only   - perf drop + low response both ready; only perf fires
%   8) Pending alarm    - resp alarm fires on next trial once perf still in cooldown

global BpodSystem
pass = true;

% =========================================================================
fprintf('\n--- Test 1: No alarm (healthy performance) ---\n');
% =========================================================================
buildBase(40, 0.75, 0.75, 0.75);
alarmState = [];
alarmState = PuffyPenguin_checkMouseWarnings(alarmState);

if alarmState.lastPerfAlarm==-Inf && alarmState.lastSideAlarm==-Inf && alarmState.lastRespAlarm==-Inf
    fprintf('  PASS: no alarm fired\n');
else
    fprintf('  FAIL: alarm fired unexpectedly\n'); pass = false;
end
pause(0.5);

% =========================================================================
fprintf('\n--- Test 2: Performance drop alarm ---\n');
% =========================================================================
% Grand avg = 75%, rolling drops to 50% -> delta = 25pp > 20pp
buildBase(40, 0.75, 0.75, 0.75);
BpodSystem.Data.Performance(end) = 0.50;  % simulate recent drop
alarmState = [];
alarmState = PuffyPenguin_checkMouseWarnings(alarmState);

if alarmState.lastPerfAlarm == 40
    fprintf('  PASS: performance drop alarm fired\n');
else
    fprintf('  FAIL: performance drop alarm did not fire\n'); pass = false;
end
pause(1.5);

% =========================================================================
fprintf('\n--- Test 3: Side asymmetry alarm ---\n');
% =========================================================================
% Left = 30%, right = 70% -> diff = 40pp > 20pp; overall perf = 50% (no drop)
buildBase(40, 0.50, 0.30, 0.70);
alarmState = [];
alarmState = PuffyPenguin_checkMouseWarnings(alarmState);

if alarmState.lastSideAlarm == 40
    fprintf('  PASS: side asymmetry alarm fired\n');
else
    fprintf('  FAIL: side asymmetry alarm did not fire\n'); pass = false;
end
pause(1.5);

% =========================================================================
fprintf('\n--- Test 4: Low response rate alarm ---\n');
% =========================================================================
% Stable 75% performance, but last 20 trials only 20% responded
buildBase(40, 0.75, 0.75, 0.75);
BpodSystem.Data.DidNotChoose(21:40) = repmat([0 1 1 1 1], 1, 4);  % 20% respond
alarmState = [];
alarmState = PuffyPenguin_checkMouseWarnings(alarmState);

if alarmState.lastRespAlarm == 40
    fprintf('  PASS: low response rate alarm fired\n');
else
    fprintf('  FAIL: low response rate alarm did not fire\n'); pass = false;
end
pause(1.5);

% =========================================================================
fprintf('\n--- Test 5: Cooldown (alarm should NOT re-fire within 5 trials) ---\n');
% =========================================================================
buildBase(40, 0.75, 0.75, 0.75);
BpodSystem.Data.Performance(end) = 0.50;
alarmState = [];
alarmState = PuffyPenguin_checkMouseWarnings(alarmState);
firedAt = alarmState.lastPerfAlarm;

% advance by 1 trial - still within cooldown
BpodSystem.Data.cTrial = 41;
BpodSystem.Data.Performance(end+1)   = 0.50;
BpodSystem.Data.lPerformance(end+1)  = 0.75;
BpodSystem.Data.rPerformance(end+1)  = 0.75;
BpodSystem.Data.Rewarded(end+1)      = 1;
BpodSystem.Data.Assisted(end+1)      = true;
BpodSystem.Data.DidNotChoose(end+1)  = false;
BpodSystem.Data.CorrectSide(end+1)   = 1;
alarmState = PuffyPenguin_checkMouseWarnings(alarmState);

if alarmState.lastPerfAlarm == firedAt
    fprintf('  PASS: cooldown suppressed re-alarm (still at trial %d)\n', firedAt);
else
    fprintf('  FAIL: alarm fired again during cooldown\n'); pass = false;
end
pause(0.5);

% =========================================================================
fprintf('\n--- Test 6: Too few trials (minimum counts not met) ---\n');
% =========================================================================
% Only 15 total trials -> sum(iAll)=15 <= minTrialsOverall=20; only 7 per side <= 10
buildBase(15, 0.40, 0.20, 0.80);  % would trigger alarms if counts were sufficient (cTrial=14)
alarmState = [];
alarmState = PuffyPenguin_checkMouseWarnings(alarmState);

if alarmState.lastPerfAlarm==-Inf && alarmState.lastSideAlarm==-Inf
    fprintf('  PASS: no alarm with insufficient trial counts\n');
else
    fprintf('  FAIL: alarm fired with insufficient trial counts\n'); pass = false;
end

% =========================================================================
fprintf('\n--- Test 7: Only one sound per trial when multiple alarms ready ---\n');
% =========================================================================
% Perf drop AND low response both ready; only perf (higher priority) fires
buildBase(40, 0.75, 0.75, 0.75);
BpodSystem.Data.Performance(end)     = 0.50;                        % perf drop ready
BpodSystem.Data.DidNotChoose(21:40)  = repmat([0 1 1 1 1], 1, 4);  % resp alarm ready

alarmState = [];
alarmState = PuffyPenguin_checkMouseWarnings(alarmState);

if alarmState.lastPerfAlarm == 40 && alarmState.lastRespAlarm == -Inf
    fprintf('  PASS: only performance drop fired; resp alarm is pending\n');
else
    fprintf('  FAIL: expected only perf alarm (perfAlarm=%g, respAlarm=%g)\n', ...
        alarmState.lastPerfAlarm, alarmState.lastRespAlarm); pass = false;
end
pause(1.5);

% =========================================================================
fprintf('\n--- Test 8: Pending resp alarm fires while perf is in cooldown ---\n');
% =========================================================================
% Advance 1 trial from test 7 state: perf still in cooldown, resp fires
BpodSystem.Data.cTrial = 41;
BpodSystem.Data.Performance(end+1)   = 0.50;
BpodSystem.Data.lPerformance(end+1)  = 0.75;
BpodSystem.Data.rPerformance(end+1)  = 0.75;
BpodSystem.Data.Rewarded(end+1)      = 0;
BpodSystem.Data.Assisted(end+1)      = true;
BpodSystem.Data.DidNotChoose(end+1)  = true;   % keep resp rate low
BpodSystem.Data.CorrectSide(end+1)   = 1;

alarmState2 = alarmState;  % copy state from test 7 (perf in cooldown)
alarmState2 = PuffyPenguin_checkMouseWarnings(alarmState2);

if alarmState2.lastRespAlarm == 41
    fprintf('  PASS: pending resp alarm fired on next trial\n');
else
    fprintf('  FAIL: pending resp alarm did not fire (lastRespAlarm = %g)\n', ...
        alarmState2.lastRespAlarm); pass = false;
end
pause(1.5);

% =========================================================================
fprintf('\n=========================================\n');
if pass
    fprintf('All tests PASSED\n');
else
    fprintf('Some tests FAILED - see output above\n');
end
fprintf('=========================================\n\n');

% Helper: build a base BpodSystem.Data struct with N assisted, responded,
% balanced trials at the given overall performance level.
function buildBase(nTrials, perfLevel, lPerfLevel, rPerfLevel)
    global BpodSystem
    half = floor(nTrials / 2);
    BpodSystem.Data.cTrial      = half * 2;  % actual array length (even)
    n = half * 2;  % actual array length (always even)
    BpodSystem.Data.Assisted     = true(1, n);
    BpodSystem.Data.DidNotChoose = false(1, n);
    BpodSystem.Data.CorrectSide  = [ones(1, half) ones(1, half)*2];  % 1=left, 2=right

    % build Rewarded to match requested per-side performance
    lRew = [ones(1, round(half*lPerfLevel)) zeros(1, half - round(half*lPerfLevel))];
    rRew = [ones(1, round(half*rPerfLevel)) zeros(1, half - round(half*rPerfLevel))];
    BpodSystem.Data.Rewarded = [lRew, rRew];

    % pre-computed performance fields (as update_performance_plots would set)
    BpodSystem.Data.Performance  = repmat(perfLevel,  1, n);
    BpodSystem.Data.lPerformance = repmat(lPerfLevel, 1, n);
    BpodSystem.Data.rPerformance = repmat(rPerfLevel, 1, n);
end
