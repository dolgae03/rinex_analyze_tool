clear all;
% close all;
% clc

%%
% stalist=cell({ 'nyil'});
stalist=cell({'nyil' 'nylp' 'txau' 'rod1' 'txan'});
% prnlist=19;
prnlist=1:32;

doy_start = 75;
doy_end = 81;
interval=5;
%%
hiddenlay = [20 20];
yyyy = 2020;
yy=rem(yyyy,100);

%%
[homedir, mfile, ext]=fileparts(mfilename('fullpath'));
addpath(homedir);
trainfncdir = sprintf('%s/sources_train', homedir);
addpath(trainfncdir);
sourcedir=sprintf('%s/sources',homedir);
addpath(sourcedir);
count=0;
rateDNN_all=nan(length(stalist),doy_end-doy_start+1);
rateYest_all=nan(length(stalist),doy_end-doy_start+1);
idx_all=nan(length(stalist),doy_end-doy_start+1);

rateDNN_all2=[];
rateYest_all2=[];
mse= [];
ednn = [];
edail = [];
for staid=stalist
    count=count+1;
    rateDNN_stn=[];
    rateYest_stn=[];
    for doy_test=doy_start:doy_end
        %             for doy_test=134;
        
        staid=char(staid);
        rateDNN_prn=[];
        rateYest_prn=[];
        for prn=prnlist
            modeldir = sprintf('%s/학습 모델 취합_220629_2030/model file/%4d/%s/PRN%2.2d',homedir,yyyy,staid,prn);
            laystr = num2str(hiddenlay,'%2.2d');
            modelname = sprintf('%s/DNN%sprn%2.2d_layer%s_testDOY%3.3d.mat',modeldir,staid,prn,laystr,doy_test);
            if ~exist(modelname, 'file')
                continue;
            end
            load(modelname);
            yest=[yesttime yestinput yestoutput];
            tod=[testtime testinput testoutput];
            
            [mulOrig testinput mulYest yestinput timee]=findidx2(yest, tod, interval);
            [mulDNN, errorDNN, sigDNN, sigOrig, rateDNN,idx_DNN]=DNN_TestPlot(DNN, testinput, mulOrig);
            ednn = [ednn; errorDNN];
            mulYest=mulYest(idx_DNN);
            mulOrig=mulOrig(idx_DNN);
            timee=timee(idx_DNN);
            yestinput=yestinput(idx_DNN,:);
            testinput=testinput(idx_DNN,:);
            rateDNN_prn=[rateDNN_prn; rateDNN];
            
            [errorYest, sigYest, rateYest]=Yest_TestPlot(mulYest, mulOrig);
            edail = [edail; errorYest];
            rateYest_prn=[rateYest_prn; rateYest];
            
        end
        rateDNN_all2=[rateDNN_all2; rateDNN_prn'];
        rateYest_all2=[rateYest_all2; rateYest_prn'];
        
        rateDNN_stn=[rateDNN_stn; median(rateDNN_prn)];
        rateYest_stn=[rateYest_stn; median(rateYest_prn)];
    end
    figure()
    titlee=sprintf('%s',staid);
    xx=1:length(rateDNN_stn);
    idx=isoutlier(rateYest_stn,'median','ThresholdFactor',2);
    plot(xx,rateDNN_stn,'r')
    hold on
    plot(xx,rateYest_stn,'b')
    plot(xx(idx),rateYest_stn(idx),'ko')
    title(titlee)
    
    idx_all(count,:)=idx';
    rateDNN_all(count,:)=rateDNN_stn';
    rateYest_all(count,:)=rateYest_stn';
    figurename=sprintf('%s/figure/%s.fig',homedir, titlee);
    %     saveas(gcf,figurename);
    tmp = [nanmean(edail.^2); nanmean(ednn.^2)];
    mse = [mse tmp]
end



