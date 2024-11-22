function [t_out prn x v] = ephget(ephfile,t_start,t_stop,dt)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   ephget.m
%
%   Objective
%   Obtain ephemeris of satellites from a navigation file
%
%   Input
%   ephfile     : navigation file (with a full path)
%   t_start     : start time in calendric format [yyyy mm dd hh mm ss]
%   t_stop      : stop time in calendric format [yyyy mm dd hh mm ss]
%   dt          : output interval in seconds, default = 60 sec
%
%   Output
%   t_out       : GPS time vector (mx2)
%   prn         : S/C (PRN) number (mx1)
%   x           : S/C position in ECEF meters (nx(3xm))
%   v           : S/C velocity in EFEF m/s (nx(3xm))
%
%   Written by Jung Sungwook
%   June.15.2010
%
%   History
%   1. The routine for the Reference Epoch was chaned on Jul.1.2010
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<4, dt=60; end

%% Conversion of time system (calendric -> GPS time)
t_cal = [t_start; t_stop];
t_gps = zeros(2,3);
[t_gps(1,1) t_gps(1,2) t_gps(1,3)]=utc2gps(t_cal(1,:),0);
[t_gps(2,1) t_gps(2,2) t_gps(2,3)]=utc2gps(t_cal(2,:),0);

%% Read a navigatoin file
eph=readeph(ephfile);
    % This is now deemed a valid ephemeris, save in the nx24 GPS ephemeris
    % format...
    %   1   2    3    4    5                   6
    % [prn,M0,delta_n,e,sqrt_a,long. of asc_node at GPS week epoch,
    %  7    8       9      10    11  12  13  14  15  16  17  18
    %  i,perigee,ra_rate,i_rate,Cuc,Cus,Crc,Crs,Cic,Cis,Toe,IODE,
    %     19     20  21  22  23      24
    %  GPS_week,Toc,Af0,Af1,Af2,perigee_rate]

%% Satellite Position
% list-up of PRN list
prn = unique(eph(:,1));

%for t=t_gps(1,2):dt:t_gps(2,2)
% reference eph of each PRN
eph_ref = zeros(size(prn,1),24);
for prn_i=1:size(prn,1)
    prnrow=find(eph(:,1)==prn(prn_i),6);
%    t_diff=t-eph(prnrow,20);
    eph_ref(prn_i,:)=eph(prnrow(end),:);
end

% Propagation of Orbits
[t_out prn x v]=propgeph(eph_ref,[t_gps(1,1) t_gps(1,2)],...
    [t_gps(2,1) t_gps(2,2)],dt);
% Note: Output are in time order with all of the satellites at time #1
%       first, followed by the satellites at time #2, etc.  The position and
%       velocity correspond to the times and satellite numbers in the 
%       corresponding columns. The t_out and prn matrices have the following form
%                           wk  s  prn   X    Y    Z    Vx    Vy    Vz
%        [t_out prn x v] = [933 1   1   x11  y11  z11  vx11  vy11  vz11
%                           933 1   2   x12  y12  z12  vx12  vy12  vz12
%                            .      .    .    .    .     .     .     .
%                            .      .    .    .    .     .     .     .
%                           933 1   24  x124 y124 z124 vx124 vy124 vz124
%                           933 2   1   x21  y21  z21  vx21  vy21  vz21
%                           933 2   2   x22  y22  z22  vx22  vy22  vz22
%                            .      .    .    .    .     .     .     .
%                           933 600 24   .    .    .     .     .     .  ]

