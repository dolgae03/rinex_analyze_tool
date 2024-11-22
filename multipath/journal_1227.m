clear all;
% close all;
% clc

%%
stalist=cell({'nyil' 'nylp' 'txau' 'rod1' 'txan'});
prnlist=1:32;

doy_start = 127;
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
truemul = [];
dnnmul = [];
dailymul = [];
els = [];


% for staid=stalist
%     count=count+1;
%     for doy_test=doy_start:doy_end
%        
%         staid=char(staid);
%         for prn=prnlist
%             modeldir = sprintf('%s/model file/%4d/%s/PRN%2.2d',homedir,yyyy,staid,prn);
%             laystr = num2str(hiddenlay,'%2.2d');
%             modelname = sprintf('%s/DNN%sprn%2.2d_layer%s_testDOY%3.3d.mat',modeldir,staid,prn,laystr,doy_test);
%             if ~exist(modelname, 'file')
%                 continue;
%             end
%             load(modelname);
%             yest=[yesttime yestinput yestoutput];
%             tod=[testtime testinput testoutput];
%             
%             [mulOrig testinput mulYest yestinput timee]=findidx2(yest, tod, interval);
%             [mulDNN, errorDNN, sigDNN, sigOrig, rateDNN,idx_DNN]=DNN_TestPlot(DNN, testinput, mulOrig);
%             mulYest=mulYest(idx_DNN);
%             mulOrig=mulOrig(idx_DNN);
%             [errorYest, sigYest, rateYest]=Yest_TestPlot(mulYest, mulOrig);
%             
%             testinput=testinput(idx_DNN,:);
%             
%             truemul = [truemul; mulOrig];
%             dnnmul = [dnnmul; errorDNN];
%             dailymul = [dailymul; errorYest];
%             els = [els; testinput(:,1)];
% 
%         end
%     end
% end

filename=sprintf('%s/journal_1227/multipath_error_1227.mat',homedir);
load(filename);

[els_sort, idx] = sort(els);
truemul_sort=truemul(idx);
dnnmul_sort=dnnmul(idx);
dailymul_sort=dailymul(idx);

el_step = 10;
el_lb = 10:el_step:80;
el_ub = 20:el_step:90;
els_cell = cell(length(el_lb),1);
truemul_cell = cell(length(el_lb),1);
dnnmul_cell = cell(length(el_lb),1);
dailymul_cell = cell(length(el_lb),1);
truemul_std = nan(length(el_lb),1);
dnnmul_std = nan(length(el_lb),1);
dailymul_std = nan(length(el_lb),1);
for k = 1:length(el_lb)
    idx = find((els_sort>=el_lb(k)) & (els_sort<el_ub(k)));
    truemul_cell{k} = truemul_sort(idx);
    dnnmul_cell{k} = dnnmul_sort(idx);
    dailymul_cell{k} = dailymul_sort(idx);
    els_cell{k} = els_sort(idx);
    
    truemul_std(k) = std(truemul_sort(idx));
    dnnmul_std(k) = std(dnnmul_sort(idx));
    dailymul_std(k) = std(dailymul_sort(idx)); 
end







