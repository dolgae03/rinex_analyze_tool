clear all;
% close all;
clc

%% 메인 인풋 파라미터 설정
staid=['nyil'];

prn=26;
doy_start = 91;
doy_end = 131;


%% 서브 인풋 파라미터 설정
hiddenlay = [20 20];
dataratio = [0.8 0.1 0.1];
yyyy = 2019;
yy=rem(yyyy,100);

%% 실행
[homedir, mfile, ext]=fileparts(mfilename('fullpath'));
addpath(homedir);
trainfncdir = sprintf('%s/sources_train', homedir);
addpath(trainfncdir);

fulltime=[];
fullmul=[];
fullel=[];
fullaz=[];
fullsnr=[];
doylist=[];
count=0;
for doy=doy_start:doy_end
    matfilename = sprintf('%s/mat file/%4d/%s/PRN%2.2d/%sPRN%2.2dDOY%3.3d.mat', homedir,yyyy,staid,prn,staid,prn,doy);
    count=count+1;
    if ~exist(matfilename, 'file')
    continue;
    end
    doylist=[doylist; doy];
    load(matfilename);
    testtime=prndata(:,1);
    testinput=prndata(:,2:4);
    testoutput=prndata(:,5);
    fulltime=[fulltime; testtime+(count-1)*86400];
%     fulltime=[fulltime; testtime];
    fullmul=[fullmul; testoutput];
    fullel=[fullel; testinput(:,1)];
    fullaz=[fullaz; testinput(:,2)];
    fullsnr=[fullsnr; testinput(:,3)];
end
idx=fullel>10;
fullel=fullel(idx);
fullaz=fullaz(idx);
fullsnr=fullsnr(idx);
fullmul=fullmul(idx);
fulltime=fulltime(idx);

flag=diff(fulltime);
idx=find(flag>5)+1;
idx=[1; idx; length(fulltime)];
numdoy=length(doylist);
each_time=zeros(numdoy,5000);
each_mul=zeros(numdoy,5000);
each_el=zeros(numdoy,5000);
each_az=zeros(numdoy,5000);
each_snr=zeros(numdoy,5000);
for k=1:numdoy
    tmp=idx(k+1)-idx(k);
    each_time(k,1:tmp)=fulltime(idx(k):idx(k+1)-1);
    each_mul(k,1:tmp)=fullmul(idx(k):idx(k+1)-1);
    each_el(k,1:tmp)=fullel(idx(k):idx(k+1)-1);
    each_az(k,1:tmp)=fullaz(idx(k):idx(k+1)-1);
    each_snr(k,1:tmp)=fullsnr(idx(k):idx(k+1)-1);
end

each_time=each_time(:,1:4235);
each_mul=each_mul(:,1:4235);
each_el=each_el(:,1:4235);
each_az=each_az(:,1:4235);
each_snr=each_snr(:,1:4235);

tmp=[each_time(25,1:2715); each_mul(25,1:2715); each_el(25,1:2715); each_az(25,1:2715);each_snr(25,1:2715)];
each_time(25,:)=nan(1,4235);
each_mul(25,:)=nan(1,4235);
each_el(25,:)=nan(1,4235);
each_az(25,:)=nan(1,4235);
each_snr(25,:)=nan(1,4235);
each_time(25,1525:end)=tmp(1,1:end-4);
each_mul(25,1525:end)=tmp(2,1:end-4);
each_el(25,1525:end)=tmp(3,1:end-4);
each_az(25,1525:end)=tmp(4,1:end-4);
each_snr(25,1525:end)=tmp(5,1:end-4);

corr_mul=zeros(1,numdoy);
for k=1:numdoy
    %     [tmp, tmplag]=xcorr(each_mul(numdoy,:),each_mul(k,:),'coeff');
    %     plot(tmplag,tmp)
    [crossval crosslag]=xcorr(each_mul(17,:),each_mul(k,:),'coeff');
    idx=find(crosslag==0);
    corr_mul(k)=crossval(idx);
    
    %     corr_mul(k)=max(xcorr(each_mul(numdoy-3,:),each_mul(k,:),'coeff'));
end
figure()
plot(doylist,corr_mul)
grid on
% save nyil_prn26.mat each_time each_mul each_el each_az each_snr
%% variation 찾기
figure()
cc=mean(abs(diff(each_mul)),2);
xx=doylist(2:end);
idxx=isoutlier(cc,'median','thresholdfactor',1);
plot(xx,cc)
grid on
hold on
plot(xx(idxx),cc(idxx),'o')

tmp=1:numdoy;
col_doy=[doylist tmp'];
% %% mul
% for k=1:numdoy
%     xx=1:length(each_mul(k,:));
%     plot(xx,each_mul(k,:));
%     hold on
%     grid on
% end

%% 

% for i=1:numdoy
%     corr_mul=zeros(1,numdoy);
%     for k=1:numdoy
%         %     [tmp, tmplag]=xcorr(each_mul(numdoy,:),each_mul(k,:),'coeff');
%         %     plot(tmplag,tmp)
%         [crossval crosslag]=xcorr(each_mul(i,:),each_mul(k,:),'coeff');
%         idx=find(crosslag==0);
%         corr_mul(k)=crossval(idx);
%         %     corr_mul(k)=max(xcorr(each_mul(numdoy-3,:),each_mul(k,:),'coeff'));
%     end
%     figure()
%     plot(doylist,corr_mul)
%     grid on
%     ylim([0 1]);
%     titles=sprintf('DOY %d',doylist(i));
%     title(titles)
% end

%%
figure()
% for i=[37 36 29 28 27 26 25 24 23 22 21 20];
for i=[29:37];
    plot(each_mul(i,:))
    hold on
    grid on
end



