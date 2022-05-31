function [res] = teensyWrite(bytes)
% function to check the handshake with a teensy module. Module should run
% the TouchShaker code and sent byte 14 or 15 in response to receiving a command
% through bpod. Other bytes should be ignored.
% If 'stopParadigm' is true, the code will stop the current paradigm if
% handshake is not successful.


global BpodSystem
if ~BpodSystem.Status.InStateMatrix
    BpodSystem.StopModuleRelay('TouchShaker1');
    BpodSystem.StartModuleRelay('TouchShaker1');
    ModuleWrite('TouchShaker1',bytes);
    res = 0;
    for i=1:4
        try
            Byte = ModuleRead('TouchShaker1', 1);
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
    BpodSystem.StopModuleRelay('TouchShaker1');
else
   disp('This only works when the state machine is not running.') 
end

try
    if int8(bytes(1)) == 71
       
        idx1 = 2 + (1:int8(bytes(2)));
        val1 = str2num(bytes(idx1));
        
        idx2 = idx1(end)+1 + (1:int8(bytes(idx1(end)+1)));
        val2 = str2num(bytes(idx2));
        
        BpodSystem.GUIHandles.PuffyPenguin.LeftSpoutEdit.Value = val1;
        BpodSystem.GUIHandles.PuffyPenguin.RightSpoutEdit.Value = val2;
        BpodSystem.GUIHandles.PuffyPenguin.SpoutLeftKnob.Value = val1;
        BpodSystem.GUIHandles.PuffyPenguin.SpoutRightKnob.Value = val2;

    end
end
%     
% %check 2nd input
% if ~exist('stopParadigm','var') || isempty(stopParadigm)
%     stopParadigm = false;
% end
% 
% %send bytes to teensy, wait a moment then check for response
% ModuleWrite('TouchShaker1',bytes); tic;
% 
% % wait for handshake for a max of 1s
% good = false; %flag that positive handshake was received
% bad = false; %flag that negative handshake was received
% 
% if BpodSystem.Modules.RelayActive(strcmpi(BpodSystem.Modules.Name, 'TouchShaker1')) %only check for handshale if relay is active
%     while ~(good || bad)
%         try
%             Byte = ModuleRead('TouchShaker1', 1);
%             good = Byte == 14; %positve handshake received
%             bad = Byte == 15; %negative handshake received
%         end
%         if toc > 1
%             break
%         end
%     end
% else
%     error('!!! Teensy relay is inactive, so handshake can not be received. !!!');
%     
% end
% 
% % if no handshake was received in time
% if ~(good || bad)
%     if stopParadigm % stop paradigm if no handshake was received
%         disp('!!! Teensy module did not send any response. Session aborted. !!!');
%         BpodSystem.Status.BeingUsed = 0;
%     else %try again
%         disp('!!! Teensy module did not send any response. Sending command again. !!!');
%         BpodSystem.Data.byteLoss = BpodSystem.Data.byteLoss + 1;
%         teensyWrite(bytes, true);
%     end
% end