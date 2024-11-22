%
%   Objective : convert doy into calendric form
%
%   Input
%       yr  : year
%       doy : day of year
%
%   Output
%       year : year
%       mon  : month
%       day  : day
%
%   Version 0.1
%
%   Programmed by Jung Sungwook, 3 Aug. 2010
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [year, mon, day]=doy2cal(yr,doy)

if nargin < 2
    tmp=clock;
    doy=yr;
    yr=tmp(1);
end

year = yr;
for n=1:12
    if sum(eomday(yr,1:n))>=doy        
        mon=n;
        break
    end
end

day = doy-sum(eomday(yr,1:mon-1));

if nargout < 1
    year = [year mon day];
end
