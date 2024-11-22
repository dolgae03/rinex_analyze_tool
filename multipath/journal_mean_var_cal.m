clear
stalist=cell({ 'nyil' 'nylp' 'txau' 'rod1' 'txan'});

[homedir, mfile, ext]=fileparts(mfilename('fullpath'));
addpath(homedir);
resultdir=sprintf('%s/result matfile',homedir);
resultfile=sprintf('%s/threshold_1.mat',resultdir);
load(resultfile)

idx_var=logical(idx_var);

rateDNN_var=mean(rateDNN_day(idx_var));
rateDNN_var_std=std(rateDNN_day(idx_var));
rateYest_var=mean(rateYest_day(idx_var));
rateYest_var_std=std(rateYest_day(idx_var));

rateDNN_normal=mean(rateDNN_day(~idx_var));
rateDNN_normal_std=std(rateDNN_day(~idx_var));
rateYest_normal=mean(rateYest_day(~idx_var));
rateYest_normal_std=std(rateYest_day(~idx_var));


rateDNN_allmean=mean2(rateDNN_all);
rateDNN_allmean_std=std2(rateDNN_all);
rateYest_allmean=mean2(rateYest_all);
rateYest_allmean_std=std2(rateYest_all);
