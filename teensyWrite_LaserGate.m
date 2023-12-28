function [res] = teensyWrite_LaserGate(bytes)
% function to check the handshake with a teensy-based laser gate module. Module should run
% the LaserGate code and sent byte 14 or 15 in response to receiving a command
% through bpod. Other bytes should be ignored.
% If 'stopParadigm' is true, the code will stop the current paradigm if
% handshake is not successful.


global BpodSystem
if ~BpodSystem.Status.InStateMatrix
    BpodSystem.StopModuleRelay('LaserGate1');
    BpodSystem.StartModuleRelay('LaserGate1');
    ModuleWrite('LaserGate1', bytes);
    res = 0;
    for i=1:4
        try
            Byte = ModuleRead('LaserGate1', 1);
        catch
            disp(['Did not return from: ', num2str(bytes)])
            Byte = 0;
        end
        if Byte
            res = Byte == 14; %positve handshake received
            break
        end
    end
    if i > 5
        disp('Teensy module did not get a reply.')
    end
    BpodSystem.StopModuleRelay('LaserGate1');
else
   disp('This only works when the state machine is not running.') 
end