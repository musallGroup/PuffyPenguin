function i=Randi(n,dims)
% Stolen brazenly from psychtoolbox
    if nargin<1 || nargin>2 || numel(n) ~= 1
        error('Usage: i=Randi(n,[dims])')
    end
    if nargin ==1
        dims=[1 1];
    end
    i = ceil(n*rand(dims));
end