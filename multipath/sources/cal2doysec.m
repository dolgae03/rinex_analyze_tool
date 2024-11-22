%
%   Objective : convert calendaric form into doy
%
%   Input
%       year    : year
%       mon     : month (= 1~12)
%       day     : day (= 1~31)
%       hr      : hour (= 0~23)
%       min     : minute (= 0~59)
%       sec     : second (= 0~59)
%
%   Output
%       yr      : year
%       doy     : day of year
%       sod     : second of day
%
%   Version 0.1
%
%   Programmed by Jung, 16 June 2010
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [yr, doy, sod] = cal2doysec(year,mon,day,hr,min,sec)

if nargin < 6, sec = 0; end
if nargin < 5, min = 0; end
if nargin < 4, hr = 0; end
yr = year;
doy = sum(eomday(yr,1:mon-1)) + day;
sod = hr*3600 + min*60 + sec;

if nargout < 1
    yr = [yr doy sod];
end