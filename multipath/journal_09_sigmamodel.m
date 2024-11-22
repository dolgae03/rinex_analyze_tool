%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Input : 기준국, DOY list
% Output : 다중경로 오차 sigma 모델, VPL 시뮬레이션 결과

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc;
%% Input
staid = 'nyil';
doylist = [130 131 134 135 140];  % NYIL variation case
% doylist = [127 128 129 132 133 136 137 138 139 141 142 143];  % NYIL normal case

%% directory 설정
[homedir, mfile, ext]=fileparts(mfilename('fullpath'));
addpath(homedir);
trainfncdir = sprintf('%s/sources_train', homedir);
addpath(trainfncdir);
sourcedir=sprintf('%s/sources',homedir);
addpath(sourcedir);
overdir=sprintf('%s/two_step_gaussian_bounding',homedir);
addpath(overdir);
araimdir=sprintf('%s/MAAST for ARAIM v0.4_modification_200708',homedir);
addpath(araimdir);

%% Output
% true 다중경로 오차, residual 다중경로 오차, elevation angle 불러오고 elvation 별로 나누기
journal_multipath_bin_make
% save('nyil_variation_multipath_1013_2.mat','mulOrig_bins','mulDaily_bins','mulDNN_bins', 'numbins', 'bins')

% 나눠진 multipath들 std랑 overbounded std 계산하기
% load('nyil_normal_multipath_0925.mat')
% load('nyil_variation_multipath_0925.mat')
journal_multipath_model_make
% save('nyil_variation_mulmodel_1013_2.mat','mulmodel','numbins', 'bins')


% VPL 시뮬레이션
% load('nyil_normal_mulmodel.mat')
% load('nyil_variation_mulmodel.mat')


global xx Orig_model DNN_model Daily_model
% xx=mulmodel.xx;
% xx=[10 xx 90]*pi/180';

% Sample Mean + Sample Std
% Orig_model=mulmodel.Orig_mean_sample+mulmodel.Orig_sig_sample;
% DNN_model=mulmodel.DNN_mean_sample+mulmodel.DNN_sig_sample;
% Daily_model=mulmodel.Daily_mean_sample+mulmodel.Daily_sig_sample;

% Bounded Mean + Bounded Std by Juan
% Orig_model=mulmodel.Orig_mean_juan+mulmodel.Orig_sig_juan;
% DNN_model=mulmodel.DNN_mean_juan+mulmodel.DNN_sig_juan;
% Daily_model=mulmodel.Daily_mean_juan+mulmodel.Daily_sig_juan;

% Sample Mean + Bounded Std by Dongchan
% Orig_model=mulmodel.Orig_mean_dc+mulmodel.Orig_sig_dc;
% DNN_model=mulmodel.DNN_mean_dc+mulmodel.DNN_sig_dc;
% Daily_model=mulmodel.Daily_mean_dc+mulmodel.Daily_sig_dc;

% Only Bounded Std (0 mean) by Dongchan
% Orig_model=mulmodel.Orig_sig_dc_siginf;
% DNN_model=mulmodel.DNN_sig_dc_siginf;
% Daily_model=mulmodel.Daily_sig_dc_siginf;

% Curve 사용한 VPL 시뮬레이션
% Variation case
% load('curve_model_201013.mat')
% xx=xx2;
% Orig_model=cv_Orig;
% Daily_model=cv_Daily;
% DNN_model=cv_DNN;
% journal_VPL_simulation