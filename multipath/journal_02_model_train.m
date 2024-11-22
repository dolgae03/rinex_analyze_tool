clear all;
close all;
clc

%% 메인 인풋 파라미터 설정
stalist=cell({ 'nyil' 'nylp' 'txau' 'rod1' 'txan'});

% stalist=cell({'nyil'});

prnlist=1:32;
doy_start = 75;
doy_end = 91;

%% 서브 인풋 파라미터 설정
hiddenlay = [20 20];
dataratio = [0.8 0.1 0.1];
yyyy = 2020;
yy=rem(yyyy,100);

%% 실행
[homedir, mfile, ext]=fileparts(mfilename('fullpath'));
addpath(homedir);
trainfncdir = sprintf('%s/sources_train', homedir);
addpath(trainfncdir);
datadir = sprintf('%s/2020', homedir);
addpath(datadir);

for doy_test=doy_start:doy_end
% for doy_test=171
    doy_first=doy_test-14;
    for staid=stalist
        staid=char(staid);
        for prn=prnlist
            doy_test
            model_train(homedir, yyyy, yy, staid, prn, doy_first, doy_test, hiddenlay, dataratio)
        end
    end
end


        