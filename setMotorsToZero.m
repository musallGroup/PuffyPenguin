teensyWrite([71 1 '0' 1 '0']); % Move spouts to zero position
teensyWrite([72 1 '0']); % Move motors to zero position

% this needs to wait for everything to move before releasing the function.
% wait for movement to finish
done = false;
while ~teensyWrite(88)
end

