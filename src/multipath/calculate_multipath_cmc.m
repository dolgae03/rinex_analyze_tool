function dataset = calculate_multipath_cmc(dataset, use_local_detrend)

    addpath('./multipath');
    addpath('./multipath/sources');

    mp1_all = nan(size(dataset.pr1));
    mp5_all = nan(size(dataset.pr3));
    flag_all = nan(size(dataset.pr1));

    if nargin < 2, use_local_detrend = false; end  % 기본: detrend OFF

    %% ── 상수 ──────────────────────────────────────────────
    c   = 299792458;         fL1 = 1575.42e6;   fL5 = 1176.45e6;
    lam1 = c / fL1;          lam5 = c / fL5;    k = (fL5/fL1)^2;

    %% ── 측정값 ───────────────────────────────────────────
    target_idx_list = find([1,0,0,0,0] == 1);

    for i = 1:length(target_idx_list)
        sv_list = dataset.constellation_idx(target_idx_list(i)):dataset.constellation_idx(target_idx_list(i)+1)-1;  
%         sv_list = 6;
        for id_sv = sv_list
            C1 = dataset.pr1(:, id_sv);   C5 = dataset.pr3(:, id_sv);
            L1 = dataset.ph1(:, id_sv);   L5 = dataset.ph3(:, id_sv);          % cyclesI
            t = double(dataset.time_GPS);

            snr = dataset.snr1(:, id_sv);
    
            LTIAM_QC_option
            gamma = (fL1/fL5)^2;
            numData = size(L1,1);
        
            raw_iphi = (L1 * lam1 - L5 * lam5)/(gamma - 1);
            raw_irho = (C1-C5)/(gamma - 1);
            raw_lli = zeros(numData,1);
            
            out_iphi= preprocess_core_samsung(t, raw_iphi, raw_irho, raw_lli, ...
                con_arc,allow_arc_len,allow_arc_pnt,slip_para,...
                    eff_slip_para,out_para,out_para_rho);
            
            cycleslipFlag = out_iphi(:,3);
            iphi = out_iphi(:,1);
    
            mp1 = mpCalculator(t, cycleslipFlag, C1, L1, iphi, lam1);
            mp5 = mpCalculator(t, cycleslipFlag, C5, L5, iphi*gamma, lam5);
    
            mp1_all(:, id_sv) = mp1;
            mp5_all(:, id_sv) = mp5;    
            flag_all(:, id_sv) = cycleslipFlag;    
            
        end
    end

    dataset.mp1 = mp1_all;
    dataset.mp5 = mp5_all;
    dataset.cycleSlipFlag = flag_all;


%     fprintf('[MP] sigma(L1) = %.3f m  sigma(L5) = %.3f m\n', ...
%             mean(std(mp1), 'all', 'omitnan'), ...
%             mean(std(mp5), 'all', 'omitnan'));
end
