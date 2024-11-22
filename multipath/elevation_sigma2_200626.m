[homedir, mfile, ext]=fileparts(mfilename('fullpath'));
addpath(homedir);
overdir=sprintf('%s/two_step_gaussian_bounding',homedir);
addpath(overdir);
%%
clear
load('elmul_nyil143.mat')
bins=15:5:90;
binmulYest={};
binmulDNN={};
binmulOrig={};
for k=1:length(bins)
    rows=find(elmulYest(:,1)<bins(k));
    binmulYest{k}=elmulYest(rows,2)-mean(elmulYest(rows,2));

    elmulYest(rows,:)=[];
    binmulDNN{k}=elmulDNN(rows,2)-mean(elmulDNN(rows,2));
    elmulDNN(rows,:)=[];

    binmulOrig{k}=elmulOrig(rows,2)-mean(elmulOrig(rows,2));
    elmulOrig(rows,:)=[];
end

% save('elmul3.mat', 'binmulDNN', 'binmulYest', 'binmulOrig')

%%
% Nsamples = length(sample_data);
Nbins = 100;
NstepsCdf = 1000;
epsilon = 0.0025;

elmulsigDNN=zeros(1,16);
elmulsigYest=zeros(1,16);
elmulsigOrig=zeros(1,16);
elmulsigDNN_bound=zeros(1,16);
elmulsigYest_bound=zeros(1,16);
elmulsigOrig_bound=zeros(1,16);

for k=1:16
    elmulsigDNN(k)=std(binmulDNN{1,k});
    elmulsigYest(k)=std(binmulYest{1,k});
    elmulsigOrig(k)=std(binmulOrig{1,k});
    
    [mean_overbound, sigma_overbound, epsilon_achieved, intervals]=gaussian_overbound(binmulDNN{1,k}, epsilon, Nbins, NstepsCdf);
    elmulsigDNN_bound(k)=sigma_overbound;
    
    [mean_overbound, sigma_overbound, epsilon_achieved, intervals]=gaussian_overbound(binmulYest{1,k}, epsilon, Nbins, NstepsCdf);
    elmulsigYest_bound(k)=sigma_overbound;
    
    [mean_overbound, sigma_overbound, epsilon_achieved, intervals]=gaussian_overbound(binmulOrig{1,k}, epsilon, Nbins, NstepsCdf);
    elmulsigOrig_bound(k)=sigma_overbound;

end

%%
figure()

xx=[12.5:5:87.5];
plot(xx,elmulsigDNN,'r')
hold on
plot(xx,elmulsigYest,'b')
plot(xx,elmulsigOrig,'k')

plot(xx,elmulsigDNN_bound,'ro-')
hold on
plot(xx,elmulsigYest_bound,'bo-')
plot(xx,elmulsigOrig_bound,'ko-')
type=2;
LAD_multipathmodel

xlim([10 90]);
ylim([0 0.8]);
xlabel('Elevation angle (deg.)');
ylabel('Standard deviation (m)');

% save('elmulmodel_txan143.mat', 'elmulsigDNN', 'elmulsigYest','elmulsigOrig','elmulsigDNN_bound', 'elmulsigYest_bound','elmulsigOrig_bound');