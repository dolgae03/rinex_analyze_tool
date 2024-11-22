clear;
set(0, 'DefaultLineLineWidth', 1);
set(0, 'DefaultLineMarkerSize', 4);
set(0,'defaultAxesFontSize',9.9)

load('nyil_variation_mulmodel_1013.mat')

figure()
plot(mulmodel.xx,mulmodel.Orig_sig_sample+mulmodel.Orig_mean_sample,'-.ok')
hold on
plot(mulmodel.xx,mulmodel.Daily_sig_sample+mulmodel.Daily_mean_sample,'--ob')
plot(mulmodel.xx,mulmodel.DNN_sig_sample+mulmodel.DNN_mean_sample,'-or')
plot(mulmodel.xx,mulmodel.Orig_mean_sample,'-.k')
plot(mulmodel.xx,mulmodel.Daily_mean_sample,'--b')
plot(mulmodel.xx,mulmodel.DNN_mean_sample,'-r')
ylim([0 0.8])
xlim([10 90])
grid on
ylabel('Mean + Standard deviation (m)')
xlabel('Elevation angle (deg.)')

figure()
plot(mulmodel.xx,mulmodel.Orig_mean_dc+mulmodel.Orig_sig_dc,'-.ok')
hold on
plot(mulmodel.xx,mulmodel.Daily_mean_dc+mulmodel.Daily_sig_dc,'--ob')
plot(mulmodel.xx,mulmodel.DNN_mean_dc+mulmodel.DNN_sig_dc,'-or')
plot(mulmodel.xx,mulmodel.Orig_mean_sample,'-.k')
plot(mulmodel.xx,mulmodel.Daily_mean_sample,'--b')
plot(mulmodel.xx,mulmodel.DNN_mean_sample,'-r')
ylim([0 0.8])
xlim([10 90])
grid on
ylabel('Mean + Standard deviation (m)')
xlabel('Elevation angle (deg.)')

figure()
plot(mulmodel.xx,mulmodel.Orig_sig_dc_siginf,'-.ok')
hold on
plot(mulmodel.xx,mulmodel.Daily_sig_dc_siginf,'--ob')
plot(mulmodel.xx,mulmodel.DNN_sig_dc_siginf,'-or')
ylim([0 0.8])
xlim([10 90])
grid on
ylabel('Standard deviation (m)')
xlabel('Elevation angle (deg.)')