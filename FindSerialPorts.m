function Ports = FindSerialPorts
% Stolen brazenly from psychtoolbox
% Search for connected serial devices and return as cell array
if isunix
    Ports = {'/dev/ttyACM1','/dev/ttyACM2','/dev/ttyACM0'};
else
    [~, RawString] = system('wmic path Win32_SerialPort Get DeviceID');
    PortLocations = strfind(RawString, 'COM');
    Ports = cell(1,100);
    nPorts = length(PortLocations);
    for x = 1:nPorts
        Clip = RawString(PortLocations(x):PortLocations(x)+6);
        Ports{x} = Clip(1:find(Clip == 32,1, 'first')-1);
    end
    Ports = Ports(1:nPorts);
end
end