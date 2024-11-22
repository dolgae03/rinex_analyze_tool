
[homedir, mfile, ext]=fileparts(mfilename('fullpath'));
addpath(homedir);
sourcedir=sprintf('%s/sources',homedir);
addpath(sourcedir);

load('tempdata2.mat')

mpCalculationConstant

csFlag = cycleslipDetector(t, C1, L1, C2, L2, LAMBDA_GPS_L1, LAMBDA_GPS_L2);

mp1 = mpCalculator(t, csFlag, C1, L1, L2, LAMBDA_GPS_L1, LAMBDA_GPS_L2);

