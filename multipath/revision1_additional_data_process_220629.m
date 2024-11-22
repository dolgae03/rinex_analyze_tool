clear all;

% stalist = cell({'nyil' 'nylp' 'txau' 'rod1' 'txan'});
stalist = cell({'txau'});
nstn = length(stalist);
prnlist=1:32;
nprn = prnlist;
% doylist = [127 143; 75 81];
doylist = [140 140];

ndoy = 0;
for k = 1:size(doylist, 1)
    ndoy = ndoy + doylist(k,2) - doylist(k,1) + 1;
end

interval=5;

%%
hiddenlay = [20 20];
% yyyylist = [2019 2020];
yyyylist = 2019;

%% Part1 - 각 DOY, 각 기준국마다 reduction rate 계산
[homedir, mfile, ext]=fileparts(mfilename('fullpath'));
addpath(homedir);
trainfncdir = sprintf('%s/sources_train', homedir);
addpath(trainfncdir);
sourcedir=sprintf('%s/sources',homedir);
addpath(sourcedir);
count_stn=0;
rateDNN_all = [];
rateYest_all = [];
rateDNN_all2=[];
rateYest_all2=[];
mse= [];
model_errDNN = cell(nstn, ndoy);
model_errYest = cell(nstn, ndoy);
model_mulOrig = cell(nstn, ndoy);
model_input = cell(nstn, ndoy)
for staid = stalist
    count_doy = 0;
    count_stn = count_stn + 1;
    rateDNN_stn = [];
    rateYest_stn = [];
    
    for k = 1 : length(yyyylist)
        yyyy = yyyylist(k)
        doy_start = doylist(k, 1);
        doy_end = doylist(k,2);
        
        for doy_test = doy_start : doy_end
            count_doy = count_doy + 1;
            staid = char(staid);
            rateDNN_prn = [];
            rateYest_prn = [];
            ednn = [];
            edail = [];
            morig = [];
            ell = [];
            
            for prn = prnlist
                modeldir = sprintf('%s/학습 모델 취합_220629_2030/model file/%4d/%s/PRN%2.2d',homedir,yyyy,staid,prn);
                laystr = num2str(hiddenlay,'%2.2d');
                modelname = sprintf('%s/DNN%sprn%2.2d_layer%s_testDOY%3.3d.mat',modeldir,staid,prn,laystr,doy_test);
                if ~exist(modelname, 'file')
                    rateDNN_prn = [rateDNN_prn; nan];
                    rateYest_prn=[rateYest_prn; nan];
                    
                    continue;
                end
                load(modelname);
                yest = [yesttime yestinput yestoutput];
                tod = [testtime testinput testoutput];
                
                [mulOrig testinput mulYest yestinput timee]=findidx2(yest, tod, interval);
                [mulDNN, errorDNN, sigDNN, sigOrig, rateDNN,idx_DNN]=DNN_TestPlot(DNN, testinput, mulOrig);
                ednn = [ednn; errorDNN];
                
                mulYest=mulYest(idx_DNN);
                mulOrig=mulOrig(idx_DNN);
                morig = [morig; mulOrig];
                timee=timee(idx_DNN);
                yestinput=yestinput(idx_DNN,:);
                testinput=testinput(idx_DNN,:);
                rateDNN_prn=[rateDNN_prn; rateDNN];
                
                [errorYest, sigYest, rateYest]=Yest_TestPlot(mulYest, mulOrig);
                edail = [edail; errorYest];
                rateYest_prn=[rateYest_prn; rateYest];
                
                ell = [ell; testinput];
            end
            model_errDNN{count_stn, count_doy}  = ednn;
            model_errYest{count_stn, count_doy}  = edail;
            model_mulOrig{count_stn, count_doy}  = morig;
            model_input{count_stn, count_doy}  = ell;
            
            rateDNN_all2=[rateDNN_all2; rateDNN_prn'];
            rateYest_all2=[rateYest_all2; rateYest_prn'];
            
            rateDNN_stn=[rateDNN_stn; median(rateDNN_prn)];
            rateYest_stn=[rateYest_stn; median(rateYest_prn)];
        end
    end
    rateDNN_all = [rateDNN_all; rateDNN_stn'];
    rateYest_all = [rateYest_all; rateYest_stn'];
end
% clear rateDNN rateYest
% save('part1.mat')
%% Part 2 - Normal과 Variation Day 검출하고, 각 Station 별로 Reduction Rate의 Mean과 Standard deviation 계산
% load('part1.mat')
% 
% for i=1:nstn
%     rateDNN(:,:,i) = rateDNN_all2(ndoy*(i-1)+1:ndoy*i,:);
%     rateYest(:,:,i) = rateYest_all2(ndoy*(i-1)+1:ndoy*i,:);
% end
% 
% rateDNN_day=nan(nstn, ndoy);
% rateYest_day=nan(nstn, ndoy);
% idx_var=nan(nstn, ndoy);
% 
% for i=1:nstn
%     rateDNN_day(i,:)=mean(rateDNN(:,:,i),2, 'omitnan')';
%     rateYest_day(i,:)=mean(rateYest(:,:,i),2, 'omitnan')';
%     tmp_medi=mean(rateYest_day(i,:), 'omitnan');
%     
%     tmp_idx=isoutlier(rateYest_day(i,:),'median','ThresholdFactor',1);
%     tmp_idx2=rateYest_day(i,:)<tmp_medi;
%     idx_var(i,:)=logical(tmp_idx&tmp_idx2);
% end
% 
% 
% meanNor=nan(nstn,2);
% meanVar=nan(nstn,2);
% stdNor=nan(nstn,2);
% stdVar=nan(nstn,2);
% for i=1:nstn
%     idx=logical(idx_var(i,:)');
%     rateDNN_all=rateDNN_all2(ndoy*(i-1)+1:ndoy*i,:);
%     rateYest_all=rateYest_all2(ndoy*(i-1)+1:ndoy*i,:);
%     
%     meanNor(i,1)=mean(mean(rateDNN_all(~idx,:), 'omitnan'), 'omitnan');
%     meanNor(i,2)=mean(mean(rateYest_all(~idx,:), 'omitnan'), 'omitnan');
%     meanVar(i,1)=mean(mean(rateDNN_all(idx,:), 'omitnan'), 'omitnan');
%     meanVar(i,2)=mean(mean(rateYest_all(idx,:), 'omitnan'), 'omitnan');
%     
%     stdNor(i,1)=stdnan(rateDNN_all(~idx,:));
%     stdNor(i,2)=stdnan(rateYest_all(~idx,:));
%     stdVar(i,1)=stdnan(rateDNN_all(idx,:));
%     stdVar(i,2)=stdnan(rateYest_all(idx,:));
% end
% 
% meanNor_stn=nan(2,2);
% meanVar_stn=nan(2,2);
% meanNor_stn(1,1)=mean(rateDNN_day(~logical(idx_var)));
% meanNor_stn(1,2)=mean(rateYest_day(~logical(idx_var)));
% meanNor_stn(2,1)=std(rateDNN_day(~logical(idx_var)));
% meanNor_stn(2,2)=std(rateYest_day(~logical(idx_var)));
% 
% meanVar_stn(1,1)=mean(rateDNN_day(logical(idx_var)));
% meanVar_stn(1,2)=mean(rateYest_day(logical(idx_var)));
% meanVar_stn(2,1)=std(rateDNN_day(logical(idx_var)));
% meanVar_stn(2,2)=std(rateYest_day(logical(idx_var)));
% 
% save('part2.mat')
%% Part 3 - Elevation 별로 Mean 및 Standard deviation 계산
load('part2.mat')
normal_DNN = [];
normal_Yest = [];
normal_Orig = [];

variate_DNN = [];
variate_Yest = [];
variate_Orig = [];

normal_ell = [];
variate_ell = [];

for k = 1:numel(idx_var)
    if ~logical(idx_var(k))
        normal_DNN = [normal_DNN; model_errDNN{k}];
        normal_Yest = [normal_Yest; model_errYest{k}];
        normal_Orig = [normal_Orig; model_mulOrig{k}];
        normal_ell = [normal_ell; model_input{k}];
    else 
        variate_DNN = [variate_DNN; model_errDNN{k}];
        variate_Yest = [variate_Yest; model_errYest{k}];
        variate_Orig = [variate_Orig; model_mulOrig{k}];
        variate_ell = [variate_ell; model_input{k}];    
    end
end
    

% Normal case
bins=[10:10:90];
numbins=length(bins)-1;

mulOrig_bins_normal=cell(1,numbins);
mulDNN_bins_normal=cell(1,numbins);
mulDaily_bins_normal=cell(1,numbins);

idx_el=elevationIdx(bins,normal_ell);
for k=1:numbins
    mulOrig_bins_normal{k}=[mulOrig_bins_normal{k}; normal_Orig(idx_el{k})];
    mulDNN_bins_normal{k}=[mulDNN_bins_normal{k}; normal_DNN(idx_el{k})];
    mulDaily_bins_normal{k}=[mulDaily_bins_normal{k}; normal_Yest(idx_el{k})];
end
    
numsample=length(mulOrig_bins_normal{numbins});
for k=1:numbins
    ds=length(mulOrig_bins_normal{k});
    tmp=[1:1:ds];
    tmp2=randsample(tmp,numsample);
    mulOrig_bins_normal{k}=mulOrig_bins_normal{k}(tmp2);
    mulDaily_bins_normal{k}=mulDaily_bins_normal{k}(tmp2);;
    mulDNN_bins_normal{k}=mulDNN_bins_normal{k}(tmp2);;
end

% Variation case
bins=[10:10:90];
numbins=length(bins)-1;

mulOrig_bins_variate=cell(1,numbins);
mulDNN_bins_variate=cell(1,numbins);
mulDaily_bins_variate=cell(1,numbins);

idx_el=elevationIdx(bins,variate_ell);
for k=1:numbins
    mulOrig_bins_variate{k}=[mulOrig_bins_variate{k}; variate_Orig(idx_el{k})];
    mulDNN_bins_variate{k}=[mulDNN_bins_variate{k}; variate_DNN(idx_el{k})];
    mulDaily_bins_variate{k}=[mulDaily_bins_variate{k}; variate_Yest(idx_el{k})];
end
    
numsample=length(mulOrig_bins_variate{numbins});
for k=1:numbins
    ds=length(mulOrig_bins_variate{k});
    tmp=[1:1:ds];
    tmp2=randsample(tmp,numsample);
    mulOrig_bins_variate{k}=mulOrig_bins_variate{k}(tmp2);
    mulDaily_bins_variate{k}=mulDaily_bins_variate{k}(tmp2);;
    mulDNN_bins_variate{k}=mulDNN_bins_variate{k}(tmp2);;
end


%% Part 4 - 그래프 그리기
for k=1:numbins
    
    mulmodel.Orig_sig_normal(k)=std(mulOrig_bins_normal{1,k});
    mulmodel.DNN_sig_normal(k)=std(mulDNN_bins_normal{1,k});
    mulmodel.Daily_sig_normal(k)=std(mulDaily_bins_normal{1,k});
    mulmodel.Orig_mean_normal(k)=mean(mulOrig_bins_normal{1,k});
    mulmodel.DNN_mean_normal(k)=mean(mulDNN_bins_normal{1,k});
    mulmodel.Daily_mean_normal(k)=mean(mulDaily_bins_normal{1,k});
    
    mulmodel.Orig_sig_variate(k)=std(mulOrig_bins_variate{1,k});
    mulmodel.DNN_sig_variate(k)=std(mulDNN_bins_variate{1,k});
    mulmodel.Daily_sig_variate(k)=std(mulDaily_bins_variate{1,k});
    mulmodel.Orig_mean_variate(k)=mean(mulOrig_bins_variate{1,k});
    mulmodel.DNN_mean_variate(k)=mean(mulDNN_bins_variate{1,k});
    mulmodel.Daily_mean_variate(k)=mean(mulDaily_bins_variate{1,k});
end


itv=diff(bins);
itv=itv(1)/2;
xx=bins+itv;
mulmodel.xx=xx(1:end-1);

xx_gad = 0:0.01:90;
sig_gad = 0.16 + 1.07 * exp(-xx_gad/15.5);

set(0, 'DefaultLineLineWidth', 1.5);
set(0, 'DefaultLineMarkerSize', 5);
set(0,'defaultAxesFontSize',10)
figure()
hold on
plot(xx_gad, sig_gad, '-m', 'Displayname', 'GAD-B')
plot(mulmodel.xx, mulmodel.Orig_sig_normal + abs(mulmodel.Orig_mean_normal),':ok', 'Displayname', 'True')
plot(mulmodel.xx, mulmodel.Daily_sig_normal + abs(mulmodel.Daily_mean_normal),'--db', 'Displayname', 'Daily filter')
plot(mulmodel.xx, mulmodel.DNN_sig_normal + abs(mulmodel.DNN_mean_normal),'-sr', 'Displayname', 'DNN')
grid on
xlabel(['Elevation angle (' char(176) ')']);
ylabel('Standard deviation (m)');
xlim([10 90])
ylim([0.05 0.45])
xticks([10 30 50 70 90])
yticks([0 0.15 0.25 0.35 0.45])
legend('show')

figure()
hold on
plot(xx_gad, sig_gad, '-m', 'Displayname', 'GAD-B')
plot(mulmodel.xx, mulmodel.Orig_sig_variate + abs(mulmodel.Orig_mean_variate),':ok', 'Displayname', 'True')
plot(mulmodel.xx, mulmodel.Daily_sig_variate + abs(mulmodel.Daily_mean_variate),'--db', 'Displayname', 'Daily filter')
plot(mulmodel.xx, mulmodel.DNN_sig_variate + abs(mulmodel.DNN_mean_variate),'-sr', 'Displayname', 'DNN')
grid on
xlabel(['Elevation angle (' char(176) ')']);
ylabel('Standard deviation (m)');
xlim([10 90])
ylim([0.05 0.45])
xticks([10 30 50 70 90])
yticks([0 0.15 0.25 0.35 0.45])
legend('show')
























    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    