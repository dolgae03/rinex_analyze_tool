function [out_iphi out_mp_irho_smooth short_acr_num]= preprocess_core_qc...
    (staid,in_t,in_iphi,in_irho,in_el,in_mp1,in_mp2,in_lli,con_arc,allow_arc_len,...
    allow_arc_pnt,slip_para,eff_slip_para,out_para,slip_mp_para,small_slip_para)

ws = warning('off','all');
warning(ws);

if size(in_t)~=size(in_iphi)
    error('Size of t and iphi must be equal !!!');
end

%% Output
out_iphi = zeros(size(in_iphi,1),6);
out_mp_irho_smooth = zeros(size(in_iphi,1),2);

%% Pre-detect Cycle-Slip with Data-Gaps
% doubtrows=(isnan(in_iphi) & isnan(in_irho));
invalidrows=(isnan(in_iphi));
doubt_t=in_t(invalidrows);
out_iphi(invalidrows,2) = 1;   % new flag


%% Valid Data Check (Non-Nan)
validrows = ~isnan(in_iphi);


validrows_smooth= ~isnan(in_iphi) & ~isnan(in_irho);
t_smooth = in_t(validrows_smooth);
iphi_smooth(:,1)=in_iphi(validrows_smooth);
irho_smooth(:,1)=in_irho(validrows_smooth);
zero_matric = zeros(size(validrows_smooth,1),1);
mp_irho_smooth_150(:,1)=zero_matric(validrows_smooth);
mp_irho_smooth_300(:,1)=zero_matric(validrows_smooth);

t = in_t(validrows);
if isempty(t)
    %     out_iphi = zeros(size(in_iphi,1),3);
    short_acr_num = 0;
    out_iphi(:,1) = in_iphi;
    out_iphi(:,3) = in_mp1;
    out_iphi(:,4) = in_mp2;
    out_iphi(:,5) = nan;
    out_iphi(:,6) = nan;
    return
end

%% Detect Effective Arc from Time Tags
iphi=zeros(size(in_iphi(validrows),1),6);
iphi(:,1)=in_iphi(validrows);
mp1(:,1)=in_mp1(validrows);
mp2(:,1)=in_mp2(validrows);

% irho=in_irho(validrows);
el=in_el(validrows);
lli=in_lli(validrows);
arc_bound = effective_arc(staid,t,con_arc);
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
            iphi(telirow,2)=2;
        end
        short_num(:,arc) = 1;
        continue
    end
    
    % arc division with cycle slip detection
    valrows=find(t>=start_t & t<=stop_t & ~isnan(iphi(:,1)));
    preslip_t=doubt_t(doubt_t>=start_t & doubt_t<=stop_t); % No measurement : Doubt cycle slip
    test_t=t(valrows);       test_iphi=iphi(valrows,:);
    test_lli=lli(valrows);
    % cycle slip detection & preliminary outlier elimination
    [arc2 test_iphi(:,2) short_num2] =cycleslip_qc(test_t,test_iphi(:,1),test_lli,...
        preslip_t,slip_para,eff_slip_para,allow_arc_len,small_slip_para);
    % kill arc (short arcs or preliminary outliers)
    
    test_iphi(logical(rem(test_iphi(:,2),10)),1)=NaN;
    
    iphi(valrows,:)=test_iphi;
    
    short_num(:,arc) = short_num2;
    
    %remove outlier processe
    % outlier removal for each arc
    % for I_phi
    for n=1:size(arc2,1)
        valrows=find(t>=arc2(n,1) & t<=arc2(n,2));
        killrows=outlier(t(valrows),iphi(valrows,1),out_para);
        if ~isempty(killrows)
            iphi(valrows(killrows),1)=NaN;
            iphi(valrows(killrows),2)=iphi(valrows(killrows),2)+4;
        end
    end
    arc_mp_1 = []; arc_mp_2 = [];
    valrows=find(t>=start_t & t<=stop_t & ~isnan(mp1));
    if ~isempty(valrows)
        test_t=t(valrows);      test_mp1=mp1(valrows);
        flag_1 = zeros(size(test_t,1),1);
        dx_1 = abs(diff(test_mp1));
        dmp1 = [nan; dx_1];
        jump_row_1 = find(dx_1>slip_mp_para);
        if ~isempty(jump_row_1)
            flag_1(jump_row_1+1) = 1000*1;
        end
        arc_mp_1 = test_t(jump_row_1+1);
        
        iphi(valrows,3)=test_mp1;
        iphi(valrows,2) = iphi(valrows,2)+flag_1;
        iphi(valrows,5) = dmp1;
    end
    
    
    
    valrows=find(t>=start_t & t<=stop_t & ~isnan(mp2));
    if ~isempty(valrows)
        test_t=t(valrows);      test_mp2=mp2(valrows);
        flag_2 = zeros(size(test_t,1),1);
        
        dx_2 = abs(diff(test_mp2));
        dmp2 = [nan; dx_2];
        jump_row_2 = find(dx_2>slip_mp_para);
        if ~isempty(jump_row_2)
            flag_2(jump_row_2+1) = 1000*2;
        end
        arc_mp_2 = test_t(jump_row_2+1);
        
        
        iphi(valrows,4) = test_mp2;
        iphi(valrows,2) = iphi(valrows,2)+flag_2;
        iphi(valrows,6) = dmp2;
    end
    
    arc_1 = unique([arc2(:,1); arc_mp_1]);
    for n = 1:size(arc_1,1)
        if n<size(arc_1,1)
            stop_row=find(t<arc_1(n+1,1),1,'last');
        else
            stop_row=find(stop_t==t);
        end
        arc_1(n,2)=t(stop_row);
    end
    
    
    arc_2 = unique([arc2(:,1); arc_mp_2]);
    for n = 1:size(arc_2,1)
        if n<size(arc_2,1)
            stop_row=find(t<arc_2(n+1,1),1,'last');
        else
            stop_row=find(stop_t==t);
        end
        arc_2(n,2)=t(stop_row);
    end
    %     % for I_rho
    %     valrows=find(t>=start_t & t<=stop_t & ~isnan(irho));
    %     find(t>=start_t & t<=stop_t);
    %     if ~isempty(valrows)
    %     test_t=t(valrows);      test_irho=irho(valrows);
    %     killrows=outlier_rho(test_t,test_irho,out_para_rho);
    %     if ~isempty(killrows)
    %         irho(valrows(killrows))=NaN;
    %     end
    %     end
    for n=1:size(arc_1,1)
        valrows = find(t>=arc_1(n,1) & t<=arc_1(n,2) & ~isnan(mp1));
        if ~isempty(valrows)
            Bias_mp1 = mean(iphi(valrows,3));
            iphi(valrows,3) = iphi(valrows,3)-Bias_mp1;
        end
    end
    for n=1:size(arc_2,1)
        valrows = find(t>=arc_2(n,1) & t<=arc_2(n,2) & ~isnan(mp2));
        if ~isempty(valrows)
            Bias_mp2 = mean(iphi(valrows,4));
            iphi(valrows,4) = iphi(valrows,4)-Bias_mp2;
        end
    end
    
    % smoothing of irho
    for n=1:size(arc2,1)
        valrows=find(t_smooth>=arc2(n,1) & t_smooth<=arc2(n,2));
        %         iphi(valrows(1),3)=1;
        input_iphi = iphi_smooth(valrows,1);
        input_irho = irho_smooth(valrows);
%         rows_smooth=find(~isnan(input_iphi) & ~isnan(input_irho));
%         iphi_in=in_iphi(rows_smooth);
%         irho_in=in_irho(rows_smooth);
        irho_150 = smooth_rho(input_irho,input_iphi,5);
        irho_300 = smooth_rho(input_irho,input_iphi,10);
        mp_irho_150 = irho_150 - input_iphi;
        mp_irho_300 = irho_300 - input_iphi;
        mp_irho_smooth_150(valrows,1) = mp_irho_150 - nanmean(mp_irho_150);
        mp_irho_smooth_300(valrows,1) = mp_irho_300 - nanmean(mp_irho_300);
  
    end
    
end

%% Return
short_acr_num = sum(short_num);
out_iphi(:,1) = in_iphi;
out_iphi(:,3) = in_mp1;
out_iphi(:,4) = in_mp2;
out_iphi(:,5) = nan;
out_iphi(:,6) = nan;
rmrows = find(rem(iphi(:,2),10)==2 | rem(iphi(:,2),10)==4);
iphi(rmrows,3:4)=nan;
out_iphi(validrows,:)=iphi;

out_mp_irho_smooth(validrows_smooth,:)=[mp_irho_smooth_150 mp_irho_smooth_300];




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