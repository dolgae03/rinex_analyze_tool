% close all;
clear
[homedir, mfile, ext]=fileparts(mfilename('fullpath'));
addpath(homedir);
trainfncdir = sprintf('%s/sources_train', homedir);
addpath(trainfncdir);

load('nyil_prn19.mat')
% yestinput=[each_el(18,:)' each_az(18,:)' each_snr(18,:)'];
% yestoutput=[each_mul(18,:)'];  

load('DNN_case1.mat')
DNN=DNN_case1;
[mulDNN, errorDNN, sigDNN, sigOrig, rateDNN1,idx_DNN]=DNN_TestPlot(DNN, testinput, testoutput);
[errorYest, sigYest, rateYest1]=Yest_TestPlot(yestoutput, testoutput);

load('DNN_case2.mat')
DNN=DNN_case2;
[mulDNN, errorDNN, sigDNN, sigOrig, rateDNN2,idx_DNN]=DNN_TestPlot(DNN, testinput, testoutput);
[errorYest, sigYest, rateYest2]=Yest_TestPlot(yestoutput, testoutput);

load('DNN_case3.mat')
DNN=DNN_case3;
[mulDNN, errorDNN, sigDNN, sigOrig, rateDNN3,idx_DNN]=DNN_TestPlot(DNN, testinput, testoutput);
[errorYest, sigYest, rateYest3]=Yest_TestPlot(yestoutput, testoutput);

load('DNN_case4.mat')
DNN=DNN_case4;
[mulDNN, errorDNN, sigDNN, sigOrig, rateDNN4,idx_DNN]=DNN_TestPlot(DNN, testinput, testoutput);
[errorYest, sigYest, rateYest4]=Yest_TestPlot(yestoutput, testoutput);

load('DNN_case5.mat')
DNN=DNN_case5;
[mulDNN, errorDNN, sigDNN, sigOrig, rateDNN5,idx_DNN]=DNN_TestPlot(DNN, testinput, testoutput);
[errorYest, sigYest, rateYest5]=Yest_TestPlot(yestoutput, testoutput);

load('DNN_case6.mat')
DNN=DNN_case6;
[mulDNN, errorDNN, sigDNN, sigOrig, rateDNN6,idx_DNN]=DNN_TestPlot(DNN, testinput, testoutput);
[errorYest, sigYest, rateYest6]=Yest_TestPlot(yestoutput, testoutput);

load('DNN_case7.mat')
DNN=DNN_case7;
[mulDNN, errorDNN, sigDNN, sigOrig, rateDNN7,idx_DNN]=DNN_TestPlot(DNN, testinput, testoutput);
[errorYest, sigYest, rateYest7]=Yest_TestPlot(yestoutput, testoutput);
% plot(testoutput,'b')
% hold on
% plot(yestoutput,'r')
% plot(mulDNN,'k')