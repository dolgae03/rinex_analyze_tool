% overbounding 위한 파라미터
Nbins = 200;
NstepsCdf = 500;
epsilon = 0.0025;

% 변수 초기화
global mulmodel
for k=1:numbins
    
    % 일반 mean, sigma 계산
    mulmodel.Orig_sig_sample(k)=std(mulOrig_bins{1,k});
    mulmodel.DNN_sig_sample(k)=std(mulDNN_bins{1,k});
    mulmodel.Daily_sig_sample(k)=std(mulDaily_bins{1,k});
    mulmodel.Orig_mean_sample(k)=mean(mulOrig_bins{1,k});
    mulmodel.DNN_mean_sample(k)=mean(mulDNN_bins{1,k});
    mulmodel.Daily_mean_sample(k)=mean(mulDaily_bins{1,k});
    
    
    % Juan 박사님 코드 기반 bounding 계산
    [mean_overbound, sigma_overbound, epsilon_achieved, intervals]=gaussian_overbound(mulOrig_bins{1,k}, epsilon, Nbins, NstepsCdf);
    mulmodel.Orig_sig_juan(k)=sigma_overbound;
    mulmodel.Orig_mean_juan(k)=mean_overbound;
    [mean_overbound, sigma_overbound, epsilon_achieved, intervals]=gaussian_overbound(mulDNN_bins{1,k}, epsilon, Nbins, NstepsCdf);
    mulmodel.DNN_sig_juan(k)=sigma_overbound;
    mulmodel.DNN_mean_juan(k)=mean_overbound;
    [mean_overbound, sigma_overbound, epsilon_achieved, intervals]=gaussian_overbound(mulDaily_bins{1,k}, epsilon, Nbins, NstepsCdf);
    mulmodel.Daily_sig_juan(k)=sigma_overbound;    
    mulmodel.Daily_mean_juan(k)=mean_overbound;
    
    % 혜연누나 코드 기반 bounding 계산
    [sample_mean, sig_bound, sample_sig, flag]= gaussian_overbound_dc(mulOrig_bins{1,k}, epsilon,Nbins);
    if flag
        fprintf('Orig not bound bin: %d \n',k)
    end
    mulmodel.Orig_sig_dc(k)=sig_bound;
    mulmodel.Orig_mean_dc(k)=sample_mean;
    [sample_mean, sig_bound, sample_sig, flag]= gaussian_overbound_dc(mulDNN_bins{1,k}, epsilon,Nbins);
    if flag
        fprintf('DNN not bound bin: %d \n',k)
    end
    mulmodel.DNN_sig_dc(k)=sig_bound;
    mulmodel.DNN_mean_dc(k)=sample_mean;
    [sample_mean, sig_bound, sample_sig, flag]= gaussian_overbound_dc(mulDaily_bins{1,k}, epsilon,Nbins);
    if flag
        fprintf('Daily not bound bin: %d \n',k)
    end
    mulmodel.Daily_sig_dc(k)=sig_bound;
    mulmodel.Daily_mean_dc(k)=sample_mean;
    
    % 0평균에서 Sigma만 팽창 시키기
    [sig_bound, sample_sig, flag]= gaussian_overbound_dc_siginf(mulOrig_bins{1,k}, epsilon,Nbins);
    if flag
        fprintf('Orig not bound bin: %d \n',k)
    end
    mulmodel.Orig_sig_dc_siginf(k)=sig_bound;
    [sig_bound, sample_sig, flag]= gaussian_overbound_dc_siginf(mulDNN_bins{1,k}, epsilon,Nbins);
    if flag
        fprintf('DNN not bound bin: %d \n',k)
    end
    mulmodel.DNN_sig_dc_siginf(k)=sig_bound;
    [sig_bound, sample_sig, flag]= gaussian_overbound_dc_siginf(mulDaily_bins{1,k}, epsilon,Nbins);
    if flag
        fprintf('Daily not bound bin: %d \n',k)
    end
    mulmodel.Daily_sig_dc_siginf(k)=sig_bound;
   
    
end

% 그림 그리기
set(0, 'DefaultLineLineWidth', 1);
set(0, 'DefaultLineMarkerSize', 4);
set(0,'defaultAxesFontSize',9.9)
itv=diff(bins);
itv=itv(1)/2;
xx=bins+itv;
mulmodel.xx=xx(1:end-1);

figure()
hold on
plot(mulmodel.xx,mulmodel.Orig_mean_sample+mulmodel.Orig_sig_sample,'-.ok');
plot(mulmodel.xx,mulmodel.Orig_mean_sample,'-.k');
plot(mulmodel.xx,mulmodel.DNN_mean_sample+mulmodel.DNN_sig_sample,'-or');
plot(mulmodel.xx,mulmodel.DNN_mean_sample,'-r');
plot(mulmodel.xx,mulmodel.Daily_mean_sample+mulmodel.Daily_sig_sample,'--ob');
plot(mulmodel.xx,mulmodel.Daily_mean_sample,'--b');
grid on
title('Sample Mean + Sample Sigma')
xlabel('Elevation angle (deg.)');
ylabel('Standard deviation (m)');
xlim([10 90]);
ylim([0 0.8]);

figure()
hold on
plot(mulmodel.xx,mulmodel.Orig_mean_juan+mulmodel.Orig_sig_juan,'-.dk');
plot(mulmodel.xx,mulmodel.Orig_mean_juan,'-.k');
plot(mulmodel.xx,mulmodel.DNN_mean_juan+mulmodel.DNN_sig_juan,'-dr');
plot(mulmodel.xx,mulmodel.DNN_mean_juan,'-r');
plot(mulmodel.xx,mulmodel.Daily_mean_juan+mulmodel.Daily_sig_juan,'--db');
plot(mulmodel.xx,mulmodel.Daily_mean_juan,'--b');
grid on
title('Bounded Mean + Bounded Sigma by Juan')
xlabel('Elevation angle (deg.)');
ylabel('Standard deviation (m)');
xlim([10 90]);
ylim([0 0.8]);

figure()
hold on
plot(mulmodel.xx,mulmodel.Orig_mean_dc+mulmodel.Orig_sig_dc,'-.ok');
plot(mulmodel.xx,mulmodel.Orig_mean_dc,'-.k');
plot(mulmodel.xx,mulmodel.DNN_mean_dc+mulmodel.DNN_sig_dc,'-or');
plot(mulmodel.xx,mulmodel.DNN_mean_dc,'-r');
plot(mulmodel.xx,mulmodel.Daily_mean_dc+mulmodel.Daily_sig_dc,'--ob');
plot(mulmodel.xx,mulmodel.Daily_mean_dc,'--b');
grid on
title('Sample Mean + Bounded Sigma by Dongchan')
xlabel('Elevation angle (deg.)');
ylabel('Standard deviation (m)');
xlim([10 90]);
ylim([0 0.8]);

figure()
hold on
plot(mulmodel.xx,mulmodel.Orig_sig_dc_siginf,'-.ok');
plot(mulmodel.xx,mulmodel.DNN_sig_dc_siginf,'-or');
plot(mulmodel.xx,mulmodel.Daily_sig_dc_siginf,'--ob');
grid on
title('Only Bounded Sigma by Dongchan')
xlabel('Elevation angle (deg.)');
ylabel('Standard deviation (m)');
xlim([10 90]);
ylim([0 0.8]);