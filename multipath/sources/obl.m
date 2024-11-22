% Function obliquity = obl(el) returns the obliquity factor in the range
% of [1,5] to the caller.  Assumes thin shell height of ionosphere is 350
% km.  Input argument el should be in radians.
% 
% Seebany Datta-Barua
% 12 Nov 2003

function obliquity = obl(el)

obliquity = 1 ./ cos(asin(0.94797966*cos(el)));
% obliquity = 1 ./ cos(asin(0.9409876*cos(el)));

return
