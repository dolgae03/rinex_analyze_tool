clear;
load('nyil_variation_mulmodel_1013.mat')

xx=mulmodel.xx;
ovbsig_Orig=mulmodel.Orig_sig_dc_siginf;
ovbsig_Daily=mulmodel.Daily_sig_dc_siginf;
ovbsig_DNN=mulmodel.DNN_sig_dc_siginf;

a=0.35;
b=0.6;
c=20;
xx2=[0:0.1:90];
cv=a+b*exp(-xx2/c);

plot(xx,ovbsig_Orig,'-.ok');
hold on
plot(xx,ovbsig_Daily,'--ob');
plot(xx,ovbsig_DNN,'-or');

cv_Orig=0.36+0.6*exp(-xx2/20);
plot(xx2,cv_Orig,'-.k');
cv_Daily=0.42*ones(length(xx2),1);
cv_Daily=0.13+0.6*exp(-xx2/60);
plot(xx2,cv_Daily,'--b');
cv_DNN=0.25+0.2*exp(-xx2/20);
plot(xx2,cv_DNN,'-r');
cv=0.16+1.07*exp(-xx2/15.5);
plot(xx2,cv,':k');

ylim([0 0.8]);
xlim([10 90]);
grid on
xlabel('Elevation')
ylabel('standrd')

save curve_model_201013.mat xx2 cv_Orig cv_Daily cv_DNN

