clear;
clc;
load('nyil_prn19.mat')

hiddenlay = [20 20];
dataratio = [0.8 0.1 0.1];

[homedir, mfile, ext]=fileparts(mfilename('fullpath'));
addpath(homedir);
trainfncdir = sprintf('%s/sources_train', homedir);
addpath(trainfncdir);

mse_dailyfilter=[col_doy(2:end,:) mean(abs(diff(each_mul)),2)]
%% Case1
% training:125-138, test:139
traininput=[];
trainoutput=[];
for k=5:18
    traininput=[traininput; each_el(k,:)' each_az(k,:)' each_snr(k,:)'];
    trainoutput=[trainoutput; each_mul(k,:)'];    
end
testinput=[each_el(19,:)' each_az(19,:)' each_snr(19,:)'];
testoutput=[each_mul(19,:)'];    
yestinput=[each_el(18,:)' each_az(18,:)' each_snr(18,:)'];
yestoutput=[each_mul(18,:)'];   
DNN_case1 = dnnModelBuild(traininput, trainoutput, hiddenlay, dataratio);
save('DNN_case1.mat', 'DNN_case1','traininput','trainoutput','testinput','testoutput','yestinput','yestoutput')

%% Case2
% training:125-138 중 127, 130, 133 제외
% test:139
traininput=[];
trainoutput=[];
for k=5:18
    if k==7 | k==10 | k==13
        continue
    end
    traininput=[traininput; each_el(k,:)' each_az(k,:)' each_snr(k,:)'];
    trainoutput=[trainoutput; each_mul(k,:)'];    
end
testinput=[each_el(19,:)' each_az(19,:)' each_snr(19,:)'];
testoutput=[each_mul(19,:)'];    
DNN_case2 = dnnModelBuild(traininput, trainoutput, hiddenlay, dataratio);
save('DNN_case2.mat', 'DNN_case2','traininput','trainoutput','testinput','testoutput','yestinput','yestoutput')

%% Case3
% training:125-138 중 127, 130, 132, 133, 134 제외
% test:139
traininput=[];
trainoutput=[];
for k=5:18
    if k==7 | k==10 | k==12 | k==13 | k==14 
        continue
    end
    traininput=[traininput; each_el(k,:)' each_az(k,:)' each_snr(k,:)'];
    trainoutput=[trainoutput; each_mul(k,:)'];    
end
testinput=[each_el(19,:)' each_az(19,:)' each_snr(19,:)'];
testoutput=[each_mul(19,:)'];    
DNN_case3 = dnnModelBuild(traininput, trainoutput, hiddenlay, dataratio);
save('DNN_case3.mat', 'DNN_case3','traininput','trainoutput','testinput','testoutput','yestinput','yestoutput')

%% Case4
% training:121-138 중 127, 130, 132, 133, 134 제외
% test:139
traininput=[];
trainoutput=[];
for k=1:18
    if k==7 | k==10 | k==12 | k==13 | k==14 
        continue
    end
    traininput=[traininput; each_el(k,:)' each_az(k,:)' each_snr(k,:)'];
    trainoutput=[trainoutput; each_mul(k,:)'];    
end
testinput=[each_el(19,:)' each_az(19,:)' each_snr(19,:)'];
testoutput=[each_mul(19,:)'];    
DNN_case4 = dnnModelBuild(traininput, trainoutput, hiddenlay, dataratio);
save('DNN_case4.mat', 'DNN_case4','traininput','trainoutput','testinput','testoutput','yestinput','yestoutput')

%% Case5
% training:122-138 중 127, 130, 132, 133, 134 제외
% test:139
traininput=[];
trainoutput=[];
for k=2:18
    if k==7 | k==10 | k==12 | k==13 | k==14 
        continue
    end
    traininput=[traininput; each_el(k,:)' each_az(k,:)' each_snr(k,:)'];
    trainoutput=[trainoutput; each_mul(k,:)'];    
end
testinput=[each_el(19,:)' each_az(19,:)' each_snr(19,:)'];
testoutput=[each_mul(19,:)'];    
DNN_case5 = dnnModelBuild(traininput, trainoutput, hiddenlay, dataratio);
save('DNN_case5.mat', 'DNN_case5','traininput','trainoutput','testinput','testoutput','yestinput','yestoutput')

%% Case6
% training:123-138 중 127, 130, 132, 133, 134 제외
% test:139
traininput=[];
trainoutput=[];
for k=3:18
    if k==7 | k==10 | k==12 | k==13 | k==14 
        continue
    end
    traininput=[traininput; each_el(k,:)' each_az(k,:)' each_snr(k,:)'];
    trainoutput=[trainoutput; each_mul(k,:)'];    
end
testinput=[each_el(19,:)' each_az(19,:)' each_snr(19,:)'];
testoutput=[each_mul(19,:)'];    
DNN_case6 = dnnModelBuild(traininput, trainoutput, hiddenlay, dataratio);
save('DNN_case6.mat', 'DNN_case6','traininput','trainoutput','testinput','testoutput','yestinput','yestoutput')

%% Case7
% training:124-138 중 127, 130, 132, 133, 134 제외
% test:139
traininput=[];
trainoutput=[];
for k=4:18
    if k==7 | k==10 | k==12 | k==13 | k==14 
        continue
    end
    traininput=[traininput; each_el(k,:)' each_az(k,:)' each_snr(k,:)'];
    trainoutput=[trainoutput; each_mul(k,:)'];    
end
testinput=[each_el(19,:)' each_az(19,:)' each_snr(19,:)'];
testoutput=[each_mul(19,:)'];    
DNN_case7 = dnnModelBuild(traininput, trainoutput, hiddenlay, dataratio);
save('DNN_case7.mat', 'DNN_case7','traininput','trainoutput','testinput','testoutput','yestinput','yestoutput')