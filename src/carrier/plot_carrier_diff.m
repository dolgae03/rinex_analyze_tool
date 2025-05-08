function plot_carrier_diff(dataset, start, duration, save_dir, frequency)
% LOI == 0 (lock-OK) 구간만 골라 연속 구간별 carrier-phase 차분(Δφ) 시각화
%
% INPUTS
%   dataset   : 관측 데이터 구조체 (time, ph1/ph3, loi1/loi3, constellation 정보 포함)
%   start     : 시작 epoch 인덱스 (1-based)
%   duration  : 그릴 구간 길이 [샘플]
%   save_dir  : 그림 저장 폴더 ('' 이면 저장 안 함)
%   frequency : 1 → L1  /  5 → L5
%
% 2025-05-08  Minseong Kim 요청
% -------------------------------------------------------------

%% ── 1. 주파수별 데이터 선택 ───────────────────────────────
switch frequency
    case 1
        phase_all = dataset.ph1;     % carrier phase [cycle]
        loi_all   = dataset.loi1;    % LOI (0 = OK)
        f_label   = 'L1';
    case 5
        phase_all = dataset.ph3;
        loi_all   = dataset.loi3;
        f_label   = 'L5';
    otherwise
        error('frequency must be 1 (L1) or 5 (L5)');
end

if isempty(phase_all) || isempty(loi_all)
    error('phase or LOI array is empty - check dataset');
end

%% ── 2. 시간/인덱스 설정 ────────────────────────────────
idx_t = start : start + duration;              % 행 인덱스
time  = dataset.time(idx_t);                   % [s]

% 그릴 별자리(여기서는 예시로 GPS, GAL, BDS, ... 중 5개 선택)
target_idx_list = find([1 0 1 0 1] == 1);      % 필요 시 수정

% 색상 팔레트
clr = lines(5);
clr = clr([1 2 5 3 5], :);

%% ── 3. 별자리 루프 ──────────────────────────────────────
for idx = 1:numel(target_idx_list)
    idx_c = target_idx_list(idx);

    % 별자리별 열(col) 범위
    col_s = dataset.constellation_idx(idx_c);
    col_e = dataset.constellation_idx(idx_c + 1) - 1;
    sat_cols = col_s : col_e;
    if isempty(sat_cols),    continue;   end

    % 해당 구간 데이터 추출
    phi_seg = phase_all(idx_t, sat_cols);    % (T x Ns)
    loi_seg = loi_all  (idx_t, sat_cols);

    %% ── 4. 위성별 Δφ 계산 & 유효 LOI 블록 플롯 ───────────
    fig = figure(600 + idx_c);  clf;  hold on;  grid on;
    set(fig, 'Color', 'w');
    n_sat = numel(sat_cols);

    for s = 1:n_sat
        phi  = phi_seg(:, s);
        loi  = loi_seg(:, s);

        % LOI == 0 & NaN 아님인 지점만 유효
        is_ok = (loi == 0) & ~isnan(phi);

        % 연속 구간 분할
        d = diff([0; is_ok; 0]);
        seg_st = find(d == 1);
        seg_en = find(d == -1) - 1;

        for b = 1:numel(seg_st)
            st = seg_st(b);
            en = seg_en(b);
            if en - st < 1,   continue;  end   % diff 후 최소 1 포인트 필요

            % 1-차 차분 Δφ, 시간도 맞춰 한 칸 앞으로
            dphi = phi(st:en);
            t_hr = time(st:en) / 3600;        % [h], Δφ와 길이 맞춤

            plot(t_hr, dphi, '-', ...
                'Color', clr(idx, :), ...
                'LineWidth', 1.2);
        end
    end

    %% ── 5. 그래프 꾸미기 & 저장 ─────────────────────────
    xlabel('Time [hours]',   'FontSize', 13, 'FontWeight', 'bold');
    ylabel('Δ Carrier Phase [cycles]', 'FontSize', 13, 'FontWeight', 'bold');
    title(sprintf('Carrier-phase – %s (%s)', ...
          dataset.constellation_name{idx_c}, f_label), ...
          'FontSize', 14);

    set(gca, 'FontSize', 12);

    if ~isempty(save_dir)
        if ~exist(save_dir, 'dir');  mkdir(save_dir);  end
        fname = sprintf('carrier_phase_diff_%s_%s', f_label, ...
                        dataset.constellation_name{idx_c});
        savefig(fig, fullfile(save_dir, [fname, '.fig']));
        saveas(fig,  fullfile(save_dir, [fname, '.png']));
    end
end
end
