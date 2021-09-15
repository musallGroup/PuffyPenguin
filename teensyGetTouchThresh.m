function res = teensyGetTouchThresh()
global BpodSystem
res = [];
if ~BpodSystem.Status.InStateMatrix
    BpodSystem.StartModuleRelay('TouchShaker1');
    ModuleWrite('TouchShaker1',95);
    byte = ModuleRead('TouchShaker1', 1);
    i = 0;
    while ~(byte==14)
        i = i + 1;
        res = [res,byte];
        byte = ModuleRead('TouchShaker1', 1);
        if i == 100
            break
        end
    end
    if i > 100
        disp('Teensy module did not get a reply.')
        res = [];
    else
        res = str2num(strrep(char(res),'_',' '));
    end
    BpodSystem.StopModuleRelay('TouchShaker1');
else
    disp('This only works when the state machine is not running.')
end