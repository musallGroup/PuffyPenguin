function [Y,index] = Sample(X)
% Stolen brazenly from psychtoolbox

    [n,m] = size(X);
    if n == 1 || m == 1
        index = Randi(length(X));
        Y = X(index);
    else
        index = Randi(n*ones(1,m));
        Y = X(index+(0:m-1)*n);
    end
end