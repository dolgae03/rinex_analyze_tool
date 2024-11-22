function [Brs Brsig] = level_phi2rho(in_iphi,in_irho,in_el,smoothwin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   level_phi2rho.m
%
%   Objective : Leveling of Iphi to Irho
%
%   Input
%       in_iphi     : input Iphi
%       in_irho     : input Irho
%       In_el       : input elevation
%       smoothwin   : the length of smoothind window
%
%   Output
%       Brs         : leveling
%       Brsig       : leveling uncertainty
%
%   Version 1.1
%
%   Edited by Jung Sungwook, 20 Nov. 2010
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% in_irho=smooth_rho(in_irho,in_iphi);
rows=find(~isnan(in_iphi) & ~isnan(in_irho));% & in_el>=10);
if size(rows,1)<=10
%     rows=find(~isnan(in_iphi) & ~isnan(in_irho));
    Brs = NaN; Brsig = NaN;
    return
end
iphi=in_iphi(rows);
irho=in_irho(rows);
el=in_el(rows)*pi/180;
Brs=0; Brsig=0; sina=0; invsina=0;

%% Code Smoothing
% irho = smooth_rho(irho,iphi,smoothwin);
irho = smooth_rho(irho,iphi,200);

%% Leveling
for n=1:size(rows,1)
    Brs = Brs + (irho(n)-iphi(n))*(sin(el(n)))^2;
    sina = sina + (sin(el(n)))^2;
    invsina = invsina + 1/(sin(el(n)))^2;
end
Brs = Brs/sina;

%% Leveling Uncertainty
for n=1:size(rows,1)
    Brsig = Brsig + (irho(n)-iphi(n)-Brs)^2;
end
Brsig = 1/sqrt(sina)*sqrt(1/(n-1)*Brsig)/sqrt(invsina/n);