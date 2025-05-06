function dataset = calculate_multipath_other(dataset, use_local_detrend)
% Multipath (CMC) + dual-freq iono 보정 + 슬립 분할 평균 0 보정
%
% IN : dataset.pr1, pr3, ph1, ph3  (size = [epoch × SV])
% OUT: dataset.mp1, dataset.mp5
%
% 2025-05-05   Minseong Kim 요청 확장판

    if nargin < 2,  use_local_detrend = false;  end   % 기본: detrend OFF

    %% ── 상수 ──────────────────────────────────────────────
    c   = 299792458;         fL1 = 1575.42e6;   fL5 = 1176.45e6;
    lam1 = c / fL1;          lam5 = c / fL5;    k = (fL5/fL1)^2;

    %% ── 측정값 ───────────────────────────────────────────
    P1 = dataset.pr1;   P5 = dataset.pr3;
    L1 = dataset.ph1;   L5 = dataset.ph3;          % cycles

    %% ── 1. 슬립 감지 & 마스킹 ───────────────────────────
    slipThr_L1 = 0.5;   slipThr_L5 = 0.5;          % [cycle]
    [P1, P5, L1, L5, slipFlag] = mask_cycle_slip(P1, P5, L1, L5, ...
                                                 slipThr_L1, slipThr_L5);

    %% ── 2. Carrier → m 변환 ────────────────────────────
    phi1 = L1 * lam1;    phi5 = L5 * lam5;

    %% ── 3. CMC (Tropo 제거) ───────────────────────────
    CMC1 = P1 - phi1;
    CMC5 = P5 - phi5;

    %% ── 4. Carrier 두 주파수로 Iono 추정 ────────────
    I1 = (phi1 - phi5) ./ (1 - k);   I5 = I1 .* k;

    %% ── 5. Iono 제거 → 원시 Multipath ────────────────
    mp1 = CMC1 - 2 .* I1;
    mp5 = CMC5 - 2 .* I5;

    %% ── 6. 슬립-경계별 평균 0 보정 ───────────────────
    [N, M] = size(mp1);
    for sv = 1:M
        % 슬립 경계행 인덱스 (true→슬립 발생 지점)
        slipRows = find(slipFlag(:,sv));
        segStarts = [1; slipRows+1];
        segEnds   = [slipRows; N];

        for s = 1:numel(segStarts)
            idx = segStarts(s):segEnds(s);
            % NaN 만인 세그먼트 건너뛰기
            if all(isnan(mp1(idx,sv))),  continue;  end
            mu1 = mean(mp1(idx,sv), 'omitnan');
            mu5 = mean(mp5(idx,sv), 'omitnan');
            mp1(idx,sv) = mp1(idx,sv) - mu1;
            mp5(idx,sv) = mp5(idx,sv) - mu5;
        end
    end

    %% ── 7. (선택) 로컬 detrend ────────────────────────
    if use_local_detrend
        win_sec = 180;   samp_dt = 1;   win_sz = round(win_sec/samp_dt);
        mp1 = window_detrend_poly3(mp1, win_sz);
        mp5 = window_detrend_poly3(mp5, win_sz);
    end

    %% ── 8. 결과 저장 ───────────────────────────────────
    dataset.mp1 = mp1;
    dataset.mp5 = mp5;

    fprintf('[MP] mean|L1| = %.3f m  mean|L5| = %.3f m\n', ...
            mean(abs(mp1), 'all', 'omitnan'), ...
            mean(abs(mp5), 'all', 'omitnan'));
end

function [P1,P5,L1,L5,slipFlag] = mask_cycle_slip(P1,P5,L1,L5,thr1,thr5)
% |Δφ| > threshold 인 epoch을 슬립으로 간주 → 해당 행 NaN 처리
    slipFlag = false(size(L1));              % same size
    dL1 = [NaN(1,size(L1,2)); diff(L1)];     % 1-epoch diff
    dL5 = [NaN(1,size(L5,2)); diff(L5)];

    slipFlag = abs(dL1) > thr1 | abs(dL5) > thr5;

    % 슬립 epoch 자체를 포함한 항목 NaN
    P1(slipFlag) = NaN;  P5(slipFlag) = NaN;
    L1(slipFlag) = NaN;  L5(slipFlag) = NaN;
end
