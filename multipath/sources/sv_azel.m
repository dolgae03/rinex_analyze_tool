% Name : sv_azel.m
%
% Purpose : This funciton returns satellite elevation angle and azimuth
% 
% Date : 2/2/00
% Modified :11/29/02 : PDM application
% Author : Jiyun, Lee
% Modified by Jung Sungwook, 08/31/10 : Add Azimuth Angle

function [el az] = sv_azel(GPS_pos, x0)
% Input parameters :  GPS_pos -- SV position in ECEF frame
%                     x0 -- initial user position
% Output parameters : az -- SV azimuth angle
%                     el -- SV elevation angle

r2d = 180/pi;

[reflat, reflon, refalt] = wgsxyz2lla(x0);
enu = wgsxyz2enu(GPS_pos, reflat, reflon, refalt);

% azimuth is defined from north, therefore atan2(E/N)
az = atan2(enu(1),enu(2)) * r2d;

% elevation is defined from the local level (N-E) plane positive 
%in the up direction
north_east_mag = sqrt(enu(1)^2 + enu(2)^2);   % magnitude in the N-E plane
el = atan2(enu(3), north_east_mag) * r2d;     % elevation 

if az < 0 
	az = az + 360;
end
