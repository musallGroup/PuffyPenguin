function PuffyPenguin_softCodeHandler(byte)

global BpodSystem

if byte == 1
    fwrite(BpodSystem.PluginObjects.udpVisual, BpodSystem.Data.visualString{BpodSystem.Data.cTrial})
    disp(BpodSystem.Data.visualString{BpodSystem.Data.cTrial});
elseif byte == 255
    fwrite(BpodSystem.PluginObjects.udpVisual, 'Close')
end