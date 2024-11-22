clear
clc

[homedir, mfile, ext]=fileparts(mfilename('fullpath'));
addpath(homedir);

matname=sprintf('%s/result matfile/all_rate.mat',homedir);
load(matname);

% stalist=cell({ 'nyil' 'nylp' 'txau' 'rod1' 'txan'});
stalist=['nyil'; 'nylp'; 'txau'; 'rod1'; 'txan'];
rateDNN=nan(17,31,5);
rateYest=nan(17,31,5);
for i=1:5
    rateDNN(:,:,i)=rateDNN_all2(17*(i-1)+1:17*i,:);
    rateYest(:,:,i)=rateYest_all2(17*(i-1)+1:17*i,:);
end

rateDNN_day=nan(5,17);
rateYest_day=nan(5,17);
idx_var=nan(5,17);
for i=1:5
    rateDNN_day(i,:)=mean(rateDNN(:,:,i),2)';
    rateYest_day(i,:)=mean(rateYest(:,:,i),2)';
    tmp_medi=mean(rateYest_day(i,:));
    
    tmp_idx=isoutlier(rateYest_day(i,:),'median','ThresholdFactor',1);
    tmp_idx2=rateYest_day(i,:)<tmp_medi;
    idx_var(i,:)=tmp_idx&tmp_idx2;
    
    mean_var_yest(i)=mean(rateYest_day(i,logical(idx_var(i,:))));
    mean_nom_yest(i)=mean(rateYest_day(i,~logical(idx_var(i,:))));
    mean_var_DNN(i)=mean(rateDNN_day(i,logical(idx_var(i,:))));
    mean_nom_DNN(i)=mean(rateDNN_day(i,~logical(idx_var(i,:))));
    
    std_var_yest(i)=std(rateYest_day(i,logical(idx_var(i,:))));
    std_nom_yest(i)=std(rateYest_day(i,~logical(idx_var(i,:))));
    std_var_DNN(i)=std(rateDNN_day(i,logical(idx_var(i,:))));
    std_nom_DNN(i)=std(rateDNN_day(i,~logical(idx_var(i,:))));
    
end
stat_norm(3)=mean(rateYest_day(logical(~idx_var)));
stat_norm(1)=mean(rateDNN_day(logical(~idx_var)));
stat_norm(4)=std(rateYest_day(logical(~idx_var)));
stat_norm(2)=std(rateDNN_day(logical(~idx_var)));

stat_var(3)=mean(rateYest_day(logical(idx_var)));
stat_var(1)=mean(rateDNN_day(logical(idx_var)));
stat_var(4)=std(rateYest_day(logical(idx_var)));
stat_var(2)=std(rateDNN_day(logical(idx_var)));
    
idx_var=logical(idx_var);
xx=1:17;
for i=1:5
    figure()
    plot(xx,rateDNN_day(i,:),'r');
    hold on
    plot(xx,rateYest_day(i,:),'b');
    plot(xx(idx_var(i,:)),rateYest_day(i,idx_var(i,:)),'o');
    titlee=stalist(i,:);
    title(titlee);
    figname=sprintf('%s/figure/%s.fig',homedir,titlee);
%     saveas(gcf,figname)
end
