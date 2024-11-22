load('part1.mat')

yyyyvec = [];
doyvec = [];
for k = 1:size(doylist,1)
    doyvec = [doyvec doylist(k,1):doylist(k,2)];
    ntmp = doylist(k,2) - doylist(k,1) + 1;
    yyyyvec = [yyyyvec yyyylist(k)*ones(1, ntmp)];
end
doyvec = [yyyyvec; doyvec];
%% Normal Case
yyyy_normal = 2019;
doy_normal = 143;
doycol = find(doyvec(1,:) == yyyy_normal & doyvec(2,:) == doy_normal);

nstn = size(model_errDNN, 1);
mse_normal = nan(nstn, 2);
for k = 1:nstn
    mse_normal(k,1) = sqrt(mean(model_errDNN{k, doycol}.^2, 'omitnan'));
    mse_normal(k,2) = sqrt(mean(model_errYest{k, doycol}.^2, 'omitnan'));
end

%% Variation Case
yyyy_variate = 2019;
doy_variate = [130 130 129 131 129];
mse_variate = nan(nstn, 2);
for k = 1 : nstn
    doycol = find(doyvec(1,:) == yyyy_variate & doyvec(2, :) == doy_variate(k));
    mse_variate(k,1) = sqrt(mean(model_errDNN{k, doycol}.^2, 'omitnan'));
    mse_variate(k,2) = sqrt(mean(model_errYest{k, doycol}.^2, 'omitnan'));
end


% %% Normal Case
% yyyy_normal = 2019;
% doy_normal = 143;
% doycol = find(doyvec(1,:) == yyyy_normal & doyvec(2,:) == doy_normal);
% 
% nstn = size(model_errDNN, 1);
% msd_normal = nan(nstn, 2);
% for k = 1:nstn
%     msd_normal(k,1) = sqrt(mean(model_errDNN{k, doycol}.^2, 'omitnan'));
%     msd_normal(k,2) = sqrt(mean(model_errYest{k, doycol}.^2, 'omitnan'));
% end
% 
% %% Variation Case
% yyyy_variate = 2019;
% doy_variate = [130 130 129 131 129];
% msd_variate = nan(nstn, 2);
% for k = 1 : nstn
%     doycol = find(doyvec(1,:) == yyyy_variate & doyvec(2, :) == doy_variate(k));
%     msd_variate(k,1) = sqrt(mean(model_errDNN{k, doycol}.^2, 'omitnan'));
%     msd_variate(k,2) = sqrt(mean(model_errYest{k, doycol}.^2, 'omitnan'));
% end