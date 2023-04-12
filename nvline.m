function nvline(x,varargin)

a = gca;
if ishold(a)
    checker = false;
else
    hold(a,'on'); checker = true;
end

for xx = 1 : length(x)
    plot([x(xx),x(xx)],a.YLim,varargin{:});
end

if checker
    hold(a,'off');
end