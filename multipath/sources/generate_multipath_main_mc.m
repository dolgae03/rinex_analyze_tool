function generate_multipath_main_mc(yyyy,doy,staid,homedir,tintv,smoothingTime)
%% data information

wkdir = sprintf('%s/iacs/%4d/%3.3d',homedir,yyyy,doy);
if ~exist(wkdir,'dir'), mkdir(wkdir); end
cd(wkdir);

yy = rem(yyyy,100);

outname = sprintf('%s%3.3d%2.2d',staid,doy,yy);
rnxhome = [homedir '\rinex'];
brdchome = [homedir '\brdc'];
rnxdir = sprintf('%s/%4d/%3.3d',rnxhome,yyyy,doy);
if ~exist(rnxdir,'dir'), mkdir(rnxdir); end
brdcdir = sprintf('%s/%4d',brdchome,yyyy);
if ~exist(brdcdir,'dir'), mkdir(brdcdir); end

    

rnxfile = sprintf('%s/%s%3.3d0.%2.2do',rnxdir,staid,doy,yy);
ephfile = sprintf('%s/brdc%3.3d0.%2.2d%s',brdcdir,doy,yy,'n');


% sta_x = [1249891.1850  -4440006.9000  4391037.3870];  % 1*3 structure
[~, mm, dd] = doy2cal(yyyy,doy);
t_start=[yyyy mm dd 0 0 0];
t_stop=[yyyy mm dd 23 59 59];


%% 파일 있으면 그냥 빠져나오기

outfile=sprintf('%s.mat',outname);
if exist(outfile, 'file')
    return
end

%% start
PROC_START_T = tic;

c = 299792458.0; % speed of light in m/s
f_1          = 1575.42e6;            % L1 frequency, Hz
f_2          = 1227.60e6;            % L2 frequency, Hz
lambda_1     = c/f_1;                % L1 wavelength, m
lambda_2     = c/f_2;                % L2 wavelength, m
gamma = (77/60)^2;
maskangle=10;


% get SV position
[t_gps prnlist x_sat ~] = ephget(ephfile,t_start,t_stop,tintv);

%RINEX read
[obsdate,epochs,types,~,~,~,rcvData,rcvSvid,rcvLLI,sta_x,~,~,~,~]=readrinexobs_ltiam(rnxfile);
[~, ~, t_start] = cal2doysec(obsdate(1),obsdate(2),obsdate(3),...
    obsdate(4),obsdate(5),obsdate(6));


epochs = epochs + t_start;      % convert to second of day

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

% Elevation Angle
ellist = elget(t_gps,x_sat,prnlist,sta_x);
% Raw Iono. Delay
data = [];

for m=1:size(epochs,1)
    elrow = ellist(:,1)==epochs(m) & ellist(:,2)==rcvSvid(m);
    if ellist(elrow,3)>=maskangle
        irho = (rcvData(m,P2)-rcvData(m,C1))/(gamma-1);
        iphi = (rcvData(m,L1)*lambda_1-rcvData(m,L2)*lambda_2)/(gamma-1);
        icmc = (rcvData(m,C1)-rcvData(m,L1)*lambda_1)/2;
        if isnan(rcvLLI(m,L1)), rcvLLI(m,L1)=0; end
        if isnan(rcvLLI(m,L2)), rcvLLI(m,L2)=0; end
        data=[data; epochs(m) rcvSvid(m) irho iphi icmc ...
            ellist(elrow,3) ellist(elrow,4) ...
            rcvLLI(m,L1) rcvLLI(m,L2) rcvData(m,S1) rcvData(m,S2) rcvData(m,C1) rcvData(m,L1) rcvData(m,L2)];
    end
end


% detect cycle slips
LTIAM_QC_option
prnlist = unique(data(:,2));
for prn=1:size(prnlist,1)
    prnrows = find(data(:,2)==prnlist(prn));
    lliphi=mod(data(prnrows,8),2)+mod(data(prnrows,9),2);
    out_iphi= preprocess_core(staid,data(prnrows,1),...
        data(prnrows,4), data(prnrows,3), data(prnrows,6),lliphi,...
        con_arc,allow_arc_len,allow_arc_pnt,slip_para,...
        eff_slip_para,out_para,out_para_rho, smoothwin);
    
    data(prnrows,8)=out_iphi(:,3);
end



% Smoothing code measerment for each arc
Smoothed_data = zeros(size(data,1),1);
Multipath_data = zeros(size(data,1),1);
for prn=1:size(prnlist,1)
    prnrows = find(data(:,2)==prnlist(prn));
    RANGEdata = data(prnrows,:);
    acrrow = find(RANGEdata(:,8)>=10);
    if isempty(acrrow);
        arc_num=1;
    else
        arc_num = size(acrrow,1);
    end
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
        valrows = find(t>=start_t & t<=stop_t & ~isnan(RANGEdata(:,13)));
        rho = RANGEdata(valrows,12);
        phi = RANGEdata(valrows,13);
        adrLast = 0;
        Smoothed_psr = 0;
        SmoothCount = 0;
        psr_Smooth =  zeros(size(valrows,1),1);
        
       for j = 1:size(valrows,1)
        psr = rho(j,1);
        adr = phi(j,1);
        %%%%%%%%%%%%%%%% SmoothCode를 smoothing_dc로 바꿈
        [Smoothed_psr,SmoothCount,adrLast] = Smoothing_dc(psr,adr,SmoothCount,adrLast,Smoothed_psr,round(smoothingTime/tintv));
        psr_Smooth(j,1) = Smoothed_psr;
       end
       Smoothd_Code(valrows,1) = psr_Smooth(:,1);
       
       Multipath_Code(valrows,1) = Smoothd_Code(valrows,1)-RANGEdata(valrows,13)*lambda_1...
            -2*(f_2^2)/(f_1^2-f_2^2)*(RANGEdata(valrows,13)*lambda_1-RANGEdata(valrows,14)*lambda_2); %MP1
       Multipath_Code(valrows,1) = Multipath_Code(valrows,1)-nanmean(Multipath_Code(valrows,1)); %MP1
    end
    Smoothed_data(prnrows,1)=Smoothd_Code;
    Multipath_data(prnrows,1)=Multipath_Code;
    
end

% data_model = [data(:,1:2) Multipath_data data(:,10:11)];
% outfile=sprintf('%s_mp.mat',outname);
% save(outfile,'data_model');
data_dc = [data(:,[1 2 6 7 10]) Multipath_data Smoothed_data data(:,12)];
outfile=sprintf('%s/%s.mat',wkdir,outname);
save(outfile, 'data_dc');

toc(PROC_START_T)
