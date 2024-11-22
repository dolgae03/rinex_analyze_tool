load('nyil_variation_multipath_1013.mat')
load('nyil_variation_mulmodel_1013.mat')

bin=1
xx=[-1.5:0.1:1.5];

figure()
histogram(mulOrig_bins{bin},200,'normalization','pdf')
hold on
yy=normpdf(xx,mulmodel.Orig_mean_sample(bin),mulmodel.Orig_sig_sample(bin));
plot(xx,yy)
yy2=normpdf(xx,mulmodel.Orig_mean_sample(bin),mulmodel.Orig_sig_dc(bin));
plot(xx,yy2)
xlim([-2 2]);
ylim([10^-10 2]);
set(gca,'YScale','log')

figure()
histogram(mulDNN_bins{bin},200,'normalization','pdf')
hold on
yy=normpdf(xx,mulmodel.DNN_mean_sample(bin),mulmodel.DNN_sig_sample(bin));
yy2=normpdf(xx,mulmodel.DNN_mean_sample(bin),mulmodel.DNN_sig_dc(bin));
plot(xx,yy)
plot(xx,yy2)
xlim([-2 2]);
ylim([10^-10 2]);
set(gca,'YScale','log')

figure()
histogram(mulDaily_bins{bin},200,'normalization','pdf')
hold on
yy=normpdf(xx,mulmodel.Daily_mean_sample(bin),mulmodel.Daily_sig_sample(bin));
yy2=normpdf(xx,mulmodel.Daily_mean_sample(bin),mulmodel.Daily_sig_dc(bin));
plot(xx,yy)
plot(xx,yy2)
xlim([-2 2]);
ylim([10^-10 2]);
set(gca,'YScale','log')
