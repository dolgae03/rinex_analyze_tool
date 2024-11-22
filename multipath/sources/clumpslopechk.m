function [threat delay1 delay2 slope sig] = ...
    clumpslopechk(delay1,delay2,tslope,slope,sig,thslope,allow_arc_len,clumpbound,clumpratio)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   clumpslopechk.m
%
%   Objective : Check clump of iono. slope for large gradient
%
%   Input
%       delay1  : iono. delay and time of the 1st station (nx3). the 3rd
%                 column is a indicator for slip or outlier
%       delay2  : iono. delay and time of the 2nd station (nx3). the 3rd
%                 column is a indicator for slip or outlier
%       tslope  : time w.r.t slope in sec (nx1)
%       slope   : iono. slope in mm/km (nx1)
%       sig     : uncertainty of slope
%       thslope : threshold for ionospheric slope
%       allow_arc_len : miminum length of allowed arc in second
%       clumpbound  : boundary from mean value for iono. slope clump check
%                     in mm/km
%       clumpratio  : ratio within the given boundary of iono. slope in
%                     percentage
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
%   1. Leveling and slope uncertainty
%   2. include NaNs in delay (from v1.1 to v2.0)
%
%   Edited by Jung Sungwook, 20 Nov. 2010
%
%   Last Updated by Jung Sungwook, 2011-04-19
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


slipt1=delay1(logical(fix(delay1(:,4)/10)),1);
slipt2=delay2(logical(fix(delay2(:,4)/10)),1);
slipt = unique([slipt1; slipt2]);   % arc division time
arc_num = size(slipt,1);


%% Excessive-Biased Delay Check
for arc=1:arc_num
    start = slipt(arc);
    if arc~=arc_num
        stop = slipt(arc+1);
    else
        stop = tslope(end)+100;  % 100 (values to be added) is arbitrary
                                 % just for taking larger time value than t(end)
    end
    rows=find(tslope>=start & tslope<stop);
    if isempty(rows), continue, end
    slope_arc = slope(rows);
    if tslope(rows(end))-tslope(rows(1))>allow_arc_len  % enough length
        th_row = find(abs(slope_arc)>thslope, 1);
        slope_arc=slope_arc(~isnan(slope_arc));
        if ~isempty(th_row)
            avgslope=mean(slope_arc);
            boundrows=find(abs(slope_arc-avgslope)<=clumpbound);
            ratio = size(boundrows,1)/size(slope_arc,1)*100;
            if ratio >=clumpratio
                slope(rows)=NaN;        sig(rows)=NaN;
                row1= delay1(:,1)>=start & delay1(:,1)<stop;
                row2= delay2(:,1)>=start & delay2(:,1)<stop;
                delay1(row1,2)=NaN;     delay2(row2,2)=NaN;
                slope(rows)=NaN;        sig(rows)=NaN;
            end
        end
    end
end

%% Check for iono. threat
th_row = find(abs(slope)>thslope,1);
if isempty(th_row)
    threat=0;
else
    threat=1;
end