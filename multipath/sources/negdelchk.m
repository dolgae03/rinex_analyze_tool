function [threat outdelay1 outdelay2 outslope outsig]...
    =negdelchk(delay1,delay2,t,slope,sig,thslope)  %#eml
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   negdelchk.m
%
%   Objective : Check negative iono. delay for large gradient
%
%   Input
%       delay1  : iono. delay and time of the 1st station (nx3). the 3rd
%                 column is a indicator for slip or outlier
%       delay2  : iono. delay and time of the 2nd station (nx3). the 3rd
%                 column is a indicator for slip or outlier
%       t       : time w.r.t slope in sec (nx1)
%       slope   : iono. slope in mm/km (nx1)
%       sig     : uncertainty of slope
%       thslope : threshold for ionospheric slope (mm/km)
%
%   Output
%       threat  : whether the threat of iono. slope exists or not.
%                       0 : non-threat
%                       1 : threat
%       delay1  : iono. delay and time of the 1st station (nx3). the 3rd
%                 column is a indicator for slip or outlier.
%                 after removal of the negative delay.
%       delay2  : iono. delay and time of the 2nd station (nx3). the 3rd
%                 column is a indicator for slip or outlier.
%                 after removal of the negative delay.
%       slope   : iono. slope after data removal (nx1)
%       sig     : uncertainty of slope
%
%   Version 2.0
%
%   History
%   1. Leveling uncerainty 
%   2. include NaNs in delay (from v1.1 to v2.0)
%
%   Last Updated by Jung Sungwook, 2011-04-19
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% dummy=-10000.1;
% kill_tmp = dummy*ones(100000,1);

eml.varsize('delay1','delay2',[8000 4],[1 1]);
eml.varsize('t','slope','sig',[8000 1],[1 0]); 
eml.varsize('outdelay1','outdelay2',[8000 4],[1 1]);
eml.varsize('outslope','outsig',[8000 1],[1 0]); 

outdelay1=zeros(size(delay1));
outdelay2=zeros(size(delay2));
outslope=zeros(size(slope));
outsig=zeros(size(sig));

rows=find(abs(slope)>thslope);
if isempty(rows)
    threat=0;
    return
end
threat_t=t(rows);

% Negative delay check
count=0;
for n=1:size(rows,1)
    row1=find(delay1(:,1)==threat_t(n));    row1=row1(1);
    row2=find(delay2(:,1)==threat_t(n));    row2=row2(1);
%     if delay1(row1,2)<0 || delay2(row2,2)<0
    if any([delay1(row1,2)<0, delay2(row2,2)<0])
        count=count+1;
        slope(rows(n))=NaN;     sig(rows(n))=NaN;
        delay1(row1,2)=NaN;     delay2(row2,2)=NaN;
    end
end

% Check for iono. threat
rows=find(abs(slope)>thslope, 1);
if isempty(rows)
    threat=0;
else
    threat=1;
end

outdelay1=delay1;       outdelay2=delay2;
outslope=slope;         outsig=sig;

% Return
%kill=kill1_tmp(kill_tmp~=dummy);
% delay1=delay1(~isnan(delay1(:,2)),:);
% delay2=delay2(~isnan(delay2(:,2)),:);
% slope=slope(~isnan(slope));
% sig=sig(~isnan(sig));