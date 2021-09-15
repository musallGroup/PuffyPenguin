function  teensySetTouchThresh(thresh)

aa = num2str(thresh(1));
bb = num2str(thresh(2));
cc = num2str(thresh(3));
dd = num2str(thresh(4));
a = length(aa);
b = length(bb);
c = length(cc);
d = length(dd);
msg = [89 a b c d aa bb cc dd];
teensyWrite(msg);
