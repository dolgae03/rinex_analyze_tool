clear
stalist=cell({ 'nyil' 'nylp' 'txau' 'rod1' 'txan'});

[homedir, mfile, ext]=fileparts(mfilename('fullpath'));
addpath(homedir);
resultdir=sprintf('%s/result matfile',homedir);
resultfile=sprintf('%s/threshold_1.mat',resultdir);
load(resultfile)
resultfile=sprintf('%s/all_rate.mat',resultdir);
load(resultfile)

meanNor=nan(5,2);
meanVar=nan(5,2);
stdNor=nan(5,2);
stdVar=nan(5,2);
for i=1:5
    idx=idx_var(i,:)';
    rateDNN_all=rateDNN_all2(17*(i-1)+1:17*i,:);
    rateYest_all=rateYest_all2(17*(i-1)+1:17*i,:);
    
    meanNor(i,1)=mean2(rateDNN_all(~idx,:));
    meanNor(i,2)=mean2(rateYest_all(~idx,:));
    meanVar(i,1)=mean2(rateDNN_all(idx,:));
    meanVar(i,2)=mean2(rateYest_all(idx,:));
    
   stdNor(i,1)=std2(rateDNN_all(~idx,:));
   stdNor(i,2)=std2(rateYest_all(~idx,:));
   stdVar(i,1)=std2(rateDNN_all(idx,:));
   stdVar(i,2)=std2(rateYest_all(idx,:));
end

meanNor_stn=nan(2,2);
meanVar_stn=nan(2,2);
meanNor_stn(1,1)=mean(rateDNN_day(~idx_var));
meanNor_stn(1,2)=mean(rateYest_day(~idx_var));
meanNor_stn(2,1)=std(rateDNN_day(~idx_var));
meanNor_stn(2,2)=std(rateYest_day(~idx_var));

meanVar_stn(1,1)=mean(rateDNN_day(idx_var));
meanVar_stn(1,2)=mean(rateYest_day(idx_var));
meanVar_stn(2,1)=std(rateDNN_day(idx_var));
meanVar_stn(2,2)=std(rateYest_day(idx_var));
   