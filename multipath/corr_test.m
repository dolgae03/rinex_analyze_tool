clear all;
% close all;
% clc

%%
stalist=cell({ 'nyil'});
% stalist=cell({ 'nyil' 'nylp' 'txau' 'rod1' 'txan'});
prnlist=19;
% prnlist=7;

doy_start = 121;
doy_end = 143;
interval=5;
%%
hiddenlay = [20 20];
yyyy = 2019;
yy=rem(yyyy,100);

%%
[homedir, mfile, ext]=fileparts(mfilename('fullpath'));
addpath(homedir);
trainfncdir = sprintf('%s/sources_train', homedir);
addpath(trainfncdir);
sourcedir=sprintf('%s/sources',homedir);
addpath(sourcedir);
count=0;
full_time=[];
full_mul=[];
full_el=[];
full_az=[];
full_snr=[];
doylist=[];
for staid=stalist
    for doy_test=doy_start:doy_end
        staid=char(staid);
        for prn=prnlist
            matfile=sprintf('%s/mat file/2019/%s/PRN%2.2d/%sPRN%2.2dDOY%3.3d.mat',homedir,staid,prn,staid,prn,doy_test);
            if ~exist(matfile, 'file')
                continue;
            end
            load(matfile);            
            testtime=prndata(:,1);
            testinput=prndata(:,2:4);
            testoutput=prndata(:,5);
            full_time=[full_time; testtime+(doy_test-1)*86400];
            full_mul=[full_mul; testoutput];
            full_el=[full_el; testinput(:,1)];
            full_az=[full_az; testinput(:,2)];
            full_snr=[full_snr; testinput(:,3)];
            doylist=[doylist;doy_test];
         


        end
    end
end
idx=full_el>10;
full_el=full_el(idx);
full_az=full_az(idx);
full_snr=full_snr(idx);
full_mul=full_mul(idx);
full_time=full_time(idx);
flag=diff(full_time);
idx=find(flag>50000)+1;

each_time=zeros(22,5000);
each_mul=zeros(22,5000);
each_el=zeros(22,5000);
each_az=zeros(22,5000);
each_snr=zeros(22,5000);
for k=1:22
    tmp=idx(k+1)-idx(k);
    each_time(k,1:tmp)=full_time(idx(k):idx(k+1)-1);
    each_mul(k,1:tmp)=full_mul(idx(k):idx(k+1)-1);
    each_el(k,1:tmp)=full_el(idx(k):idx(k+1)-1);
    each_az(k,1:tmp)=full_az(idx(k):idx(k+1)-1);
    each_snr(k,1:tmp)=full_snr(idx(k):idx(k+1)-1);
end

each_time=each_time(:,1:4637);
each_mul=each_mul(:,1:4637);
each_el=each_el(:,1:4637);
each_az=each_az(:,1:4637);
each_snr=each_snr(:,1:4637);

col1=1:3023;
col2=3024:3920;
time_tmp=(each_time(12,col1(end))+5):5:(each_time(12,col2(1))-5);
time_tmp=time_tmp(1:end-3);
each_time(12,:)=[each_time(12,col1) time_tmp each_time(12,col2)];
each_mul(12,:)=[each_mul(12,col1) nan(1, length(time_tmp)+4) each_mul(12,col2(1:end-4))];
each_el(12,:)=[each_el(12,col1) nan(1, length(time_tmp)+4) each_el(12,col2(1:end-4))];
each_az(12,:)=[each_az(12,col1) nan(1, length(time_tmp)+4) each_az(12,col2(1:end-4))];
each_snr(12,:)=[each_snr(12,col1) nan(1, length(time_tmp)+4) each_snr(12,col2(1:end-4))];


corr_mul2=zeros(1,22);
for k=1:22
    corr_mul2(k)=max(xcorr(each_mul(22,:),each_mul(k,:),'coeff'));
end
    
numdoy=22;
for i=1:numdoy
    corr_mul=zeros(1,numdoy);
    for k=1:numdoy
        %     [tmp, tmplag]=xcorr(each_mul(numdoy,:),each_mul(k,:),'coeff');
        %     plot(tmplag,tmp)
        [crossval crosslag]=xcorr(each_mul(i,:),each_mul(k,:),'coeff');
        idx=find(crosslag==0);
        corr_mul(k)=crossval(idx);
        %     corr_mul(k)=max(xcorr(each_mul(numdoy-3,:),each_mul(k,:),'coeff'));
    end
    figure()
    plot(doylist(1:numdoy),corr_mul)
    grid on
    ylim([0 1]);
    titles=sprintf('DOY %d',doylist(i));
    title(titles)
end
col_doy=[doylist(1:end-1) [1:size(each_mul,1)]'];
% save 'nyil_prn19.mat' each_mul each_el each_az each_snr col_doy
