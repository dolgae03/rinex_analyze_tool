clc
clear
close all

load('rate.mat')
DNN=cell2mat(statisticPCT(:,2))*(-1);

load('yestrate.mat')
yest=cell2mat(statisticPCT(:,2))*(-1);

plot(DNN, '-ob','linewidth', 4,'markersize',15)
hold on
plot(yest, '-^r','linewidth', 4,'markersize',15)
xlim([0 8]);
ylim([-20 70])
grid on
