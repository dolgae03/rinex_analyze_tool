function dataset = calculate_multipath_other(dataset, use_local_detrend)
% Multipath (CMC) + dual-freq iono 보정 + 슬립 분할 평균 0 보정 (LOI 포함)
%
% IN : dataset.pr1, pr3, ph1, ph3, loi1, loi3  (size = [epoch × SV])
% OUT: dataset.mp1, dataset.mp5
%
% 2025-05-07   Minseong Kim 요청 확장판

    if nargin < 2, use_local_detrend = false; end  % 기본: detrend OFF

    %% ── 상수 ──────────────────────────────────────────────
    c   = 299792458;         fL1 = 1575.42e6;   fL5 = 1176.45e6;
    lam1 = c / fL1;          lam5 = c / fL5;    k = (fL5/fL1)^2;

    %% ── 측정값 ───────────────────────────────────────────
    P1 = dataset.pr1;   P5 = dataset.pr3;
    L1 = dataset.ph1;   L5 = dataset.ph3;          % cycles
    loi1 = dataset.loi1;  % L1의 LOI (0: 정상, NaN: 데이터 끊김, 4: Cycle Slip)
    loi3 = dataset.loi3;  % L5의 LOI

    addpath('./multipath');
    addpath('./multipath/sources');

    %% ── 2. Carrier → m 변환 ────────────────────────────
    phi1 = L1 * lam1;    phi5 = L5 * lam5;

    %% ── 3. CMC (Tropo 제거) ───────────────────────────
    CMC1 = P1 - phi1;
    CMC5 = P5 - phi5;

    %% ── 5. Iono 제거 → 원시 Multipath ────────────────
    mp1 = CMC1;
    mp5 = CMC5;

    %% ── ph-only cycle-slip Fallback ─────────────────────
    % Check if loi1 and loi3 exist, if not, initialize with zeros
    if ~isfield(dataset, 'loi1')
        dataset.loi1 = zeros(N, M);
    end
    if ~isfield(dataset, 'loi3')
        dataset.loi3 = zeros(N, M);
    end

    [N,M] = size(L1);

    % ― 1·2차 시간 차분(행 방향) ----------
    dL1  = diff(L1 ,1,1);     dL5  = diff(L5 ,1,1);
    ddL1 = diff(dL1,1,1);     ddL5 = diff(dL5,1,1);

    metric = abs(ddL1 - ddL5);        % [cycle]
    slip_thr = 30;                   % 임계값(½ cycle)

    [row,sv_idx] = find(metric > slip_thr);
    for k = 1:numel(row)
        t  = row(k)+1;                % ddL → 원본 index 보정
        sv = sv_idx(k);

        win = max(1,t-1):min(N,t+1);  % ±1 epoch(총 3)
        loi1(win,sv) = 4;
        loi3(win,sv) = 4;
    end

    %% ── 6. LOI 기반 슬립 감지 및 NaN 처리 ──────────────
    [N, M] = size(mp1);
    for sv = 1:M
        % NaN 또는 Cycle Slip (4)인 부분을 NaN으로 처리 (L1)
        invalid_idx1 = isnan(loi1(:,sv)) | (loi1(:,sv) == 4);
        mp1(invalid_idx1, sv) = NaN;

        % NaN 또는 Cycle Slip (4)인 부분을 NaN으로 처리 (L5)
        invalid_idx5 = isnan(loi3(:,sv)) | (loi3(:,sv) == 4);
        mp5(invalid_idx5, sv) = NaN;
    end

    %% ── 7. 슬립-경계별 평균 0 보정 ───────────────────
    for sv = 1:M
        if sv == 142
            3;
        end

        % 슬립 경계행 인덱스 (loi1 == 4 또는 loi3 == 4인 위치)
        slipRows1 = find(loi1(:, sv) == 4);
        slipRows5 = find(loi3(:, sv) == 4);
    
        % 시작점과 종료점 설정
        segStarts1 = [1; slipRows1 + 1];
        segEnds1   = [slipRows1 - 1; N];
    
        segStarts5 = [1; slipRows5 + 1];
        segEnds5   = [slipRows5 - 1; N];
    
        % L1 평균 0 보정
        for s = 1:numel(segStarts1)
            idx = segStarts1(s):segEnds1(s);
    
            % 유효 구간 찾기 (loi1 == 0인 경우만 유효)
            valid_idx1 = (loi1(idx, sv) == 0);
    
            % 유효 데이터가 적거나 모두 NaN일 경우 전체를 NaN으로 처리
            if sum(valid_idx1) <= 10 || all(isnan(mp1(idx, sv)))
                mp1(idx, sv) = NaN;
                continue;
            end
            
            % 평균 0 보정 (L1)
            mu1 = mean(mp1(idx(valid_idx1), sv), 'omitnan');
            mp1(idx(valid_idx1), sv) = mp1(idx(valid_idx1), sv) - mu1;

            if max(abs(mp1(idx(valid_idx1), sv))) > 300
                mp1(idx(valid_idx1), sv) = NaN;
            end
        end
    
        % L5 평균 0 보정
        for s = 1:numel(segStarts5)
            idx = segStarts5(s):segEnds5(s);
    
            % 유효 구간 찾기 (loi3 == 0인 경우만 유효)
            valid_idx5 = (loi3(idx, sv) == 0);
    
            % 유효 데이터가 적거나 모두 NaN일 경우 전체를 NaN으로 처리
            if sum(valid_idx5) <= 10 || all(isnan(mp5(idx, sv)))
                mp5(idx, sv) = NaN;
                continue;
            end
            
            % 평균 0 보정 (L5)
            mu5 = mean(mp5(idx(valid_idx5), sv), 'omitnan');
            mp5(idx(valid_idx5), sv) = mp5(idx(valid_idx5), sv) - mu5;

            if max(abs(mp5(idx(valid_idx5), sv))) > 300
                mp5(idx(valid_idx5), sv) = NaN;
            end
        end
    end

    %% ── 8. (선택) 로컬 detrend ────────────────────────
    if use_local_detrend
        win_sec = 180;   samp_dt = 1;   win_sz = round(win_sec / samp_dt);
        mp1 = window_detrend_poly3(mp1, win_sz);
        mp5 = window_detrend_poly3(mp5, win_sz);
    end

    %% ── 9. 결과 저장 ───────────────────────────────────
    dataset.mp1 = mp1;
    dataset.mp5 = mp5;

    fprintf('[MP] mean|L1| = %.3f m  mean|L5| = %.3f m\n', ...
            mean(abs(mp1), 'all', 'omitnan'), ...
            mean(abs(mp5), 'all', 'omitnan'));
end
