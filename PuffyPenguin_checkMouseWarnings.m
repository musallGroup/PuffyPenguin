function alarmState = PuffyPenguin_checkMouseWarnings(alarmState)
% PuffyPenguin_checkMouseWarnings
%
% Reads performance metrics pre-computed by update_performance_plots from
% the global BpodSystem object (always called before this function):
%   BpodSystem.Data.Performance  - rolling overall perf (last 20 assisted trials)
%   BpodSystem.Data.lPerformance - rolling left perf    (last 10 assisted left trials)
%   BpodSystem.Data.rPerformance - rolling right perf   (last 10 assisted right trials)
%
% The auditory warnings are aligned with the visual indicators in the GUI.
%
% Rules:
% 1) Overall performance alarm:
%    Descending two-tone if rolling overall performance drops more than 20pp
%    below the session grand average (assisted, responded trials only).
%    Requires at least 20 assisted+responded trials.
%
% 2) Left/right asymmetry alarm:
%    Alternating two-tone if the difference between rolling left and right
%    performance exceeds 20pp. Requires at least 10 trials per side.
%
% 3) No-response alarm:
%    Low double-pulse if fewer than 30% of the last 20 trials were responded
%    to (all trials, not filtered by Assisted).
%
% Each alarm type has its own independent cooldown. At most one sound plays
% per trial (highest-priority alarm wins); lower-priority alarms remain
% pending and fire on the next eligible trial.
% Priority: performance drop > side asymmetry > low response rate.

    global BpodSystem

    % -----------------------------
    % Parameters (window sizes match GUI: ntrials_avg = 10)
    % -----------------------------
    perfDropThresh   = 0.20;  % 20pp below grand average -> alarm
    sideDiffThresh   = 0.20;  % 20pp between left and right -> alarm
    respThresh       = 0.30;  % below 30% response rate -> alarm
    minTrialsOverall = 20;    % min assisted+responded trials for perf alarm
    minTrialsPerSide = 10;    % min assisted+responded trials per side for side alarm
    respWindow       = 20;    % window size for response rate check
    cooldownTrials   = 5;     % trials of silence after each alarm type

    % initialise alarmState fields if missing
    if nargin < 1 || isempty(alarmState)
        alarmState = struct();
    end
    if ~isfield(alarmState, 'lastPerfAlarm'), alarmState.lastPerfAlarm = -Inf; end
    if ~isfield(alarmState, 'lastSideAlarm'), alarmState.lastSideAlarm = -Inf; end
    if ~isfield(alarmState, 'lastRespAlarm'), alarmState.lastRespAlarm = -Inf; end

    t      = BpodSystem.Data.cTrial;
    iAll   = BpodSystem.Data.Assisted & ~BpodSystem.Data.DidNotChoose;
    iLeft  = BpodSystem.Data.CorrectSide == 1 & iAll;
    iRight = BpodSystem.Data.CorrectSide == 2 & iAll;

    % =========================================================
    % Phase 1: evaluate all conditions
    % =========================================================

    % 1) Overall performance: rolling (from GUI) vs session grand average
    perfReady = false;
    if sum(iAll) > minTrialsOverall && ~isempty(BpodSystem.Data.Performance)
        pRolling = BpodSystem.Data.Performance(end);
        pGrand   = mean(BpodSystem.Data.Rewarded(iAll), 'omitnan');
        perfReady = pRolling < (pGrand - perfDropThresh) && ...
                    (t - alarmState.lastPerfAlarm > cooldownTrials);
    end

    % 2) Left/right asymmetry: compare rolling left vs right (from GUI)
    sideReady = false;
    if sum(iLeft) >= minTrialsPerSide && sum(iRight) >= minTrialsPerSide && ...
       ~isempty(BpodSystem.Data.lPerformance) && ~isempty(BpodSystem.Data.rPerformance)
        lPerf     = BpodSystem.Data.lPerformance(end);
        rPerf     = BpodSystem.Data.rPerformance(end);
        sideReady = abs(lPerf - rPerf) > sideDiffThresh && ...
                    (t - alarmState.lastSideAlarm > cooldownTrials);
    end

    % 3) Low response rate over last respWindow trials (all trials, not filtered)
    respReady = false;
    if t >= respWindow
        resp20    = mean(~BpodSystem.Data.DidNotChoose(t-respWindow+1:t), 'omitnan');
        respReady = resp20 < respThresh && (t - alarmState.lastRespAlarm > cooldownTrials);
    end

    % =========================================================
    % Phase 2: fire at most one alarm (highest priority first)
    % =========================================================
    if perfReady
        % descending two-tone: 880 Hz -> 440 Hz
        sound([makeTone(880, 0.25), makeTone(440, 0.30)], 22050);
        fprintf('\n=== WARNING at trial %d: Performance drop ===\n', t);
        fprintf('  rolling = %.1f%%,  grand avg = %.1f%%\n', 100*pRolling, 100*pGrand);
        alarmState.lastPerfAlarm = t;

    elseif sideReady
        % alternating two-tone: 660 -> 880 -> 660 Hz
        sound([makeTone(660, 0.18), makeTone(880, 0.18), makeTone(660, 0.18)], 22050);
        fprintf('\n=== WARNING at trial %d: Side asymmetry ===\n', t);
        fprintf('  left = %.1f%%,  right = %.1f%%\n', 100*lPerf, 100*rPerf);
        alarmState.lastSideAlarm = t;

    elseif respReady
        % slow low double-pulse: 300 Hz
        gap = zeros(1, round(22050 * 0.15));
        sound([makeTone(300, 0.35), gap, makeTone(300, 0.35)], 22050);
        fprintf('\n=== WARNING at trial %d: Low response rate ===\n', t);
        fprintf('  last %d trials responded = %.1f%%\n', respWindow, 100*resp20);
        alarmState.lastRespAlarm = t;
    end
end

% -------------------------------------------------------------------------
function y = makeTone(freq, dur)
% Synthesise a soft sine tone at the given frequency (Hz) and duration (s).
% Uses a raised cosine envelope to avoid clicks. Sample rate is 22050 Hz.
    fs  = 22050;
    amp = 0.35;
    t   = (0 : round(fs*dur)-1) / fs;
    env = 0.5 * (1 - cos(2*pi*t/dur)); % raised cosine: smooth fade in/out
    y   = amp * env .* sin(2*pi*freq*t);
end
