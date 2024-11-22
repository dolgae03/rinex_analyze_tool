function generate_MP_new_dc_test(yyyy,mm,dd,rnxfile,ephfile,outname)
PROC_START_T = tic;

c = 299792458.0; % speed of light in m/s
f_1          = 1575.42e6;            % L1 frequency, Hz
f_2          = 1227.60e6;            % L2 frequency, Hz
lambda_1     = c/f_1;                % L1 wavelength, m
lambda_2     = c/f_2;                % L2 wavelength, m
gamma = (77/60)^2;
maskangle=0;
tintv=1;

% ant_lla = [36.36727716 127.3635 48.33325777]; %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
% sta_x = wgslla2xyz(ant_lla(1,1),ant_lla(1,2),ant_lla(1,3))';
sta_x = [-3119957.3055;  4086929.7250;  3761572.0368; ];  %<<<<<<< 1lsu station

t_start=[  2018    07    13    09    45   48.0000000]; %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
t_stop=[2018    07    15    12    03   26.0000000]; %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
%t_start=[yyyy mm dd 3 41 10.5];
%t_stop=[yyyy mm dd 3 47 56.5];

% get SV position
[t_gps prnlist x_sat ~] = ephget(ephfile,t_start,t_stop,tintv);

%RINEX read
[obsdate,epochs,types,~,~,~,rcvData,rcvSvid,rcvLLI,~,~,~,~]=readrinexobs_ltiam(rnxfile);
[~, ~, t_start] = cal2doysec(obsdate(1),obsdate(2),obsdate(3),...
    obsdate(4),obsdate(5),obsdate(6));


epochs = epochs + t_start;      % convert to second of day
% epochs = round(epochs);         % exact time
% epochs = epochs(rem(epochs,tintv)==0);  % sampling time

% Obs. types recorded RINEX
C1=0;   L1=0;   L2=0;   P1=0;   P2=0;  S1=0; S2=0;
for m=1:size(types,1)
    switch types{m}
        case 'C1'
            C1 = m;
        case 'P1'
            P1 = m;
        case 'L1'
            L1 = m;
        case 'P2'
            P2 = m;
        case 'L2'
            L2 = m;
        case 'S1'
            S1 = m;
        case 'S2'
            S2 = m;
        case 'D1'
            D1 = m;
        case 'D2'
            D2 = m;
    end
end

if P1 && sum(~isnan(rcvData(:,P1)))>10, C1=P1; end
% Elevation Angle
ellist = elget(t_gps,x_sat,prnlist,sta_x);
% Raw Iono. Delay
%         data = -1*ones(size(epochs,1),11);
data = -1*ones(size(epochs,1),11);
data_temp = -1*ones(size(epochs,1),6);
data_snr = -1*ones(size(epochs,1),9);
DSC = 0;
count=0;

% if ~exist('D1')
%     D1=1; D2=1; %%%%%%%%%%%%%%%%%%%%%%%% 지워야함
% end

for m=1:size(epochs,1)
    elrow = ellist(:,1)==epochs(m) & ellist(:,2)==rcvSvid(m);
    if ellist(elrow,3)>=maskangle
        count=count+1;
        irho = (rcvData(m,P2)-rcvData(m,C1))/(gamma-1);
        iphi = (rcvData(m,L1)*lambda_1-rcvData(m,L2)*lambda_2)/(gamma-1);
        icmc = (rcvData(m,C1)-rcvData(m,L1)*lambda_1)/2;
        multipath_f1 = rcvData(m,C1)-rcvData(m,L1)*lambda_1...
            -2*(f_2^2)/(f_1^2-f_2^2)*(rcvData(m,L1)*lambda_1-rcvData(m,L2)*lambda_2);
        multipath_f2 = rcvData(m,P2)-((2)/(gamma-1)+1)*rcvData(m,L1)*lambda_1+(2)/(gamma-1)*rcvData(m,L2)*lambda_2;
        if isnan(rcvLLI(m,L1)), rcvLLI(m,L1)=0; end
        if isnan(rcvLLI(m,L2)), rcvLLI(m,L2)=0; end
        data_snr(count,:)= [epochs(m) rcvSvid(m) rcvData(m,S1) rcvData(m,S2) rcvData(m,C1) rcvData(m,L1) rcvData(m,L2) rcvData(m,D1) rcvData(m,D2)];
        data(count,:)=[epochs(m) rcvSvid(m) irho iphi icmc ...
            ellist(elrow,3) ellist(elrow,4) ...
            rcvLLI(m,L1) rcvLLI(m,L2) multipath_f1 multipath_f2];
    end
end

data = data(1:count,:);
data_snr = data_snr(1:count,:);

% detect cycle slips
LTIAM_QC_option
outfile=sprintf('%s_qc_lvl.mat',outname);
data_tmp=data;
data=zeros(size(data_tmp,1),18);
prnlist = unique(data_tmp(:,2));
for prn=1:size(prnlist,1)
    prnrows = find(data_tmp(:,2)==prnlist(prn));
    lliphi=mod(data_tmp(prnrows,8),2)+mod(data_tmp(prnrows,9),2);
    %%%%%%%%%%%%%%%%%%%%%%%%% preprocess_core_qc_mp 를 바꿨음%%%%%%%%%%%%%%%
    [iphi irho_smooth short_acr_num]= preprocess_core_qc('aero_roof',data_tmp(prnrows,1),...
        data_tmp(prnrows,4), data_tmp(prnrows,3), data_tmp(prnrows,6),data_tmp(prnrows,10)...
        ,data_tmp(prnrows,11),lliphi,...
        con_arc,allow_arc_len,allow_arc_pnt,slip_para,...
        eff_slip_para,out_para,slip_mp_para, small_slip_para);
    data(prnrows,4:9)=iphi;
end

data(:,1:3) = data_tmp(:,1:3);
data(:,10:11)= data_tmp(:,6:7);
data(:,12:13)= data_snr(:,3:4);
data(:,14:16)= data_snr(:,5:7);
data(:,17:18)= data_snr(:,8:9);
save(outfile,'data');


% Smoothing code measerment for each arc
Smoothed_data = zeros(size(data,1),1);
Multipath_data = zeros(size(data,1),1);
for prn=1:size(prnlist,1)
    prnrows = find(data(:,2)==prnlist(prn));
    RANGEdata = data(prnrows,:);
    acrrow = find(RANGEdata(:,5)>=10);
    arc_num = size(acrrow,1);
    t = RANGEdata(:,1);
    Smoothd_Code =  zeros(size(prnrows,1),1);
    Multipath_Code =  zeros(size(prnrows,1),1);
    
    for arc=1:arc_num
        if arc_num==1 || arc==arc_num
            stop_t  = t(end);
        else
            stop_t  = t(acrrow(arc+1)-1);
        end
        if arc_num==1 || arc==1
            start_t = t(1);
        else
            start_t = t(acrrow(arc));
        end
        valrows = find(t>=start_t & t<=stop_t & ~isnan(RANGEdata(:,15)));
        rho = RANGEdata(valrows,14);
        phi = RANGEdata(valrows,15);
        adrLast = 0;
        Smoothed_psr = 0;
        SmoothCount = 0;
        psr_Smooth =  zeros(size(valrows,1),1);
        
       for j = 1:size(valrows,1)
        psr = rho(j,1);
        adr = phi(j,1);
        %%%%%%%%%%%%%%%% SmoothCode를 smoothing_dc로 바꿈
%         [Smoothed_psr,SmoothCount,adrLast] = SmoothCode(psr,adr,SmoothCount,adrLast,Smoothed_psr,200);
        [Smoothed_psr,SmoothCount,adrLast] = Smoothing_dc(psr,adr,SmoothCount,adrLast,Smoothed_psr,100);
        psr_Smooth(j,1) = Smoothed_psr;
       end
       Smoothd_Code(valrows,1) = psr_Smooth(:,1);
       
       Multipath_Code(valrows,1) = Smoothd_Code(valrows,1)-RANGEdata(valrows,15)*lambda_1...
            -2*(f_2^2)/(f_1^2-f_2^2)*(RANGEdata(valrows,15)*lambda_1-RANGEdata(valrows,16)*lambda_2); %MP1
       Multipath_Code(valrows,1) = Multipath_Code(valrows,1)-nanmean(Multipath_Code(valrows,1)); %MP1
    end
    Smoothed_data(prnrows,1)=Smoothd_Code;
    Multipath_data(prnrows,1)=Multipath_Code;
    
end

% data_model = [data(:,1:2) Multipath_data data(:,10:11)];
% outfile=sprintf('%s_mp.mat',outname);
% save(outfile,'data_model');

data_dc = [data(:,1:2) data(:,10:11) data(:,14) Smoothed_data data(:,15) data(:,6) Multipath_data data(:,12) data(:,17) data(:,5)];
outfile2=sprintf('%s_dc.mat',outname);
save(outfile2, 'data_dc');

toc(PROC_START_T)

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

