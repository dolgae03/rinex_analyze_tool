%
%   Objective : computing of elevation and azimuth angles of satellites
%
%   Input
%       t_gps   : time (in GPS time), nx1
%       x_sat   : satellite position, nx3
%       prnlist : list of PRN, nx1
%       sta_x   : station position, 1x3
%
%   Output
%       ellist : elevation and azimuth of satellits (nx4)
%           1) time (second of day)
%           2) prn
%           3) elevation
%           4) azimuth
%
%   Version 1.0
%       
%   Programmed by Jung Sungwook, 8 May 2011
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ellist = elget(t_gps,x_sat,prnlist,sta_x)

%% Read the Ephemeris File
% [t_gps prnlist x_sat ~]=ephget(ephfile,t_start,t_stop,dt);
t_cal = gps2utc(t_gps,0);
t_sod = zeros(size(t_cal,1),3);
ellist = zeros(size(t_cal,1),4);
for n=1:size(t_cal,1)
    if (rem(n/size(t_cal,1)*100,10)==0)
         fprintf('elaz process %d pct. \n',n/size(t_cal,1)*100);
    end

    [t_sod(n,1) t_sod(n,2) t_sod(n,3)] = ...
        cal2doysec(t_cal(n,1),t_cal(n,2),t_cal(n,3),...
        t_cal(n,4),t_cal(n,5),t_cal(n,6));
    [el az]=sv_azel(x_sat(n,:)',sta_x');
    ellist(n,:)=[t_sod(n,3) prnlist(n) el az];
end
