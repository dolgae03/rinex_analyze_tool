clear all;
% close all;
% clc

%%
stalist=cell({ 'nyil'});
% stalist=cell({ 'nyil' 'nylp' 'txau' 'rod1' 'txan'});
prnlist=1:32;
% prnlist=7;

doy_start = 143;
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

elmulDNN=[];
elmulYest=[];
elmulOrig=[];
for staid=stalist
    for doy_test=doy_start:doy_end
        
        staid=char(staid);
        for prn=prnlist
            modeldir = sprintf('%s/model file/%4d/%s/PRN%2.2d',homedir,yyyy,staid,prn);
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
            mulYest=mulYest(idx_DNN);
            mulOrig=mulOrig(idx_DNN);
            timee=timee(idx_DNN);
            yestinput=yestinput(idx_DNN,:);
            testinput=testinput(idx_DNN,:);
            
            errorYest=mulOrig-mulYest;
            errorDNN;
            elmulYest=[elmulYest; testinput(:,1) errorYest];
            elmulDNN=[elmulDNN; testinput(:,1) errorDNN];
            elmulOrig=[elmulOrig; testinput(:,1) mulOrig];

        end
    end
end



