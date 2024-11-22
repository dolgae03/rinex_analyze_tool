function out_iphi = preprocess_core_samsung...
    (in_t,in_iphi,in_irho,in_lli,con_arc,allow_arc_len,...
    allow_arc_pnt,slip_para,eff_slip_para,out_para,out_para_rho)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   preprocess_core.m
%
%   Objective : core function for pre-processing of LT_iono.
%
%   Input
%       staid       : station ID
%       in_t        : time tags for ionospheric delay
%       in_iphi     : input of ionospheric delay to be processed
%       in_irho     : code derived ionospheric measurement
%       in_el       : elevation angle
%       in_lli      : Loss of Lock Indicator
%       con_arc     : parameter for continuous arc in second
%       all_arc     : parameter for allowed short arc in second
%       slip_para   : parameter for cycle slip detection
%       out_para    : parameter for outlier detection
%
%   Output
%       out_iphi    : pre_processed ionospheric delay
%             1      |           2          |      3
%     ---------------|----------------------|------------------------------
%       iono. delay  | leveling uncetrainty | pre-process indicator
%
%   ** Pre-process indicator
%       format : %1d%1d%1d,con_flag,slip_flag,outlier_flag
%       1) con_flag : start point of continuous arc w.r.t time
%           1 : start point
%           0 : normal point
%       2) slip_flag : flags for cycle slip detection
%           bit0 : data jump
%           bit1 : LLI
%           bit2 : data gap
%       3) out_flag : for NaN valued points
%           bit0 : originally NaN. able to be realted with bit2 of slip_flag
%           bit1 : short arc removal
%           bit2 : interpreted as outliers
%       
%   Version 2.0
%
%   History
%   1. Leveling uncertainty was added in the output. (v 1.1)
%   Edited by Jung Sungwook, 20 Nov. 2010
%
%   2. Modification for change of flags to be related with pre_process
%   
%   Written by Jung Sungwook, 29 Mar. 2011
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ws = warning('off','all'); 
warning(ws);

if size(in_t)~=size(in_iphi)
    error('Size of t and iphi must be equal !!!');
end

%% Output
out_iphi = zeros(size(in_iphi,1),3);

%% Pre-detect Cycle-Slip with Data-Gaps
% doubtrows=(isnan(in_iphi) & isnan(in_irho));
invalidrows=(isnan(in_iphi));
doubt_t=in_t(invalidrows);
out_iphi(invalidrows,3) = 1;   % new flag


%% Valid Data Check (Non-Nan)
validrows = ~isnan(in_iphi);
t = in_t(validrows);
if isempty(t)
%     out_iphi = zeros(size(in_iphi,1),3);
    out_iphi(:,1) = in_iphi;
    return
end

%% Detect Effective Arc from Time Tags
iphi=zeros(size(in_iphi(validrows),1),3);
iphi(:,1)=in_iphi(validrows);
irho=in_irho(validrows);
lli=in_lli(validrows);
arc_bound = effective_arc('aaaa',t,con_arc);
arc_num = size(arc_bound,1)+1;

%% Outlier & Cycle Slip Detection
for arc=1:arc_num
    if arc_num==1 || arc==arc_num
        stop_t  = t(end);
    else
        stop_t  = arc_bound(arc);
    end
    if arc_num==1 || arc==1
        start_t = t(1);
    else
        start_t = t(find(t==arc_bound(arc-1))+1);
    end
    % Elimination of Short Arcs
    if stop_t-start_t<=allow_arc_len || size(find(t>=start_t & t<=stop_t & ~isnan(iphi(:,1))),1)<=allow_arc_pnt
        for telirow=find(t==start_t):find(t==stop_t)
            iphi(telirow,1)=NaN;
            iphi(telirow,3)=2;
        end
        continue
    end
    
    % arc division with cycle slip detection
    valrows=find(t>=start_t & t<=stop_t & ~isnan(iphi(:,1)));
    preslip_t=doubt_t(doubt_t>=start_t & doubt_t<=stop_t); % No measurement : Doubt cycle slip
    test_t=t(valrows);       test_iphi=iphi(valrows,:);
    test_lli=lli(valrows);
    % cycle slip detection & preliminary outlier elimination
    [arc2 test_iphi(:,3)] =cycleslip(test_t,test_iphi(:,1),test_lli,...
        preslip_t,slip_para,eff_slip_para,allow_arc_len);
    % kill arc (short arcs or preliminary outliers)
    test_iphi(logical(rem(test_iphi(:,3),10)),1)=NaN;
    iphi(valrows,:)=test_iphi;
    
    % outlier removal for each arc
    % for I_phi
    for n=1:size(arc2,1)
        valrows=find(t>=arc2(n,1) & t<=arc2(n,2));
        killrows=outlier(t(valrows),iphi(valrows,1),out_para);
        if ~isempty(killrows)
            iphi(valrows(killrows),1)=NaN;
            iphi(valrows(killrows),3)=iphi(valrows(killrows),3)+4;
        end
    end
    
    % for I_rho
    valrows=find(t>=start_t & t<=stop_t & ~isnan(irho));
    find(t>=start_t & t<=stop_t);
    if ~isempty(valrows)
    test_t=t(valrows);      test_irho=irho(valrows);
    killrows=outlier_rho(test_t,test_irho,out_para_rho);
    if ~isempty(killrows)
        irho(valrows(killrows))=NaN;
    end        
    end
    

end

%% Return
out_iphi(:,1) = in_iphi;
out_iphi(validrows,:)=iphi;

function [arc_bound effectiveness] = effective_arc(staid,t,eff_tintv)
allowed_arc_num = 1000;
effectiveness  = 1;

dt = diff(t);   % time difference between each iphiervation
boundary=find(dt>eff_tintv);
arc_bound_tmp=zeros(allowed_arc_num,1);
if ~isempty(boundary)   % if there exit some boundaries for arcs
    for n=1:size(boundary,1)
        arc_bound_tmp(n)=t(boundary(n));
    end
    if n>allowed_arc_num
        fprintf('\n There exist so many break points in %s data\n',staid);
        effectiveness = 0;
    end
else
    arc_bound_tmp=[];
end

if effectiveness
    arc_bound=nonzeros(arc_bound_tmp);
else
    arc_bound=1;
end