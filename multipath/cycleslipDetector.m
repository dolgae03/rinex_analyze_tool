function [iphi, cycleslipFlag] = cycleslipDetector(t, C1, L1, C2, L2, lambda1, lambda2)


%% Input data check
arguments
    t (:,1) double {mustBeNonNan}
    C1 (:,1) double 
    L1 (:,1) double 
    C2 (:,1) double 
    L2 (:,1) double 
    lambda1 (1,1) double {mustBePositive}
    lambda2 (1,1) double {mustBePositive}
end

if size(t,1) ~= size(L1,1)
    error('t와 L1 사이즈 통일 필요')
end

if size(t,1) ~= size(L2,1)
    error('t와 L2 사이즈 통일 필요')
end

%% Initialization
LTIAM_QC_option

gamma = (lambda2/lambda1)^2;

numData = size(t, 1);

%% Preprocessing
raw_iphi = (L1*lambda1 - L2*lambda2)/(gamma - 1);
raw_irho = (C1-C2)/(gamma - 1);
raw_mp1 = C1 - L1*lambda1 - 2*raw_iphi;
raw_mp2 = C2 - L1*lambda2 - 2*raw_iphi;
raw_lli = zeros(numData,1);

out_iphi= preprocess_core_samsung(t, raw_iphi, raw_irho, raw_lli, ...
    con_arc,allow_arc_len,allow_arc_pnt,slip_para,...
        eff_slip_para,out_para,out_para_rho);

cycleslipFlag = out_iphi(:,3);
iphi = out_iphi(:,1);

end



