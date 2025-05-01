function plot_carrier_diff(dataset, start, duration, save_dir, frequency)
% 각 별자리의 carrier phase 차분 값 시각화 (연속된 구간만 연결)
%
% INPUTS:
% - dataset     : 측정 데이터 구조체
% - start       : 시작 인덱스
% - duration    : 몇 초간 그릴지
% - save_dir    : 그림 저장 경로
% - frequency   : 1 (L1), 5 (L5)

% --- 기본 설정
c = 299792458; % [m/s]
switch frequency
    case 1
        phase_all = dataset.ph1;
        f_label = 'L1';
    case 5
        phase_all = dataset.ph3;
        f_label = 'L5';
    otherwise
        error('Invalid frequency. Use 1 or 5.');
end

% 시간 및 인덱스
idx_t = start : start + duration;
time = dataset.time(idx_t);   % 시간 (초)

target_idx_list = find([1, 0, 1, 0, 1] == 1);

% 색상 정의
colors = lines(5);
colors = colors([1, 2, 5, 3, 5], :);

for idx = 1:length(target_idx_list)
    idx_c = target_idx_list(idx);

    col_s = dataset.constellation_idx(idx_c);
    col_e = dataset.constellation_idx(idx_c+1) - 1;
    sat_cols = col_s:col_e;
    if isempty(sat_cols), continue; end

    % 추출된 carrier data
    phase_seg = phase_all(idx_t, sat_cols);  % (duration+1) x Nsat

    % 플롯
    fig = figure(600 + idx_c); clf;
    set(fig, 'Color', 'w'); hold on;
    n_sat = numel(sat_cols);

    for s = 1:n_sat
        phi = phase_seg(:, s);         % 1개 위성

        % 유효한 인덱스 블록 단위로 나누기
        is_valid = ~isnan(phi);
        d = diff([0; is_valid; 0]);
        start_idx = find(d == 1);
        end_idx = find(d == -1) - 1;

        for b = 1:length(start_idx)
            st = start_idx(b);
            en = end_idx(b);
            if en - st < 2, continue; end  % 최소 3개 포인트 필요 (diff 후 2개 이상)

            t_block = time(st:en)/3600;
            phi_block = phi(st:en);
            phi_diff = diff(phi_block);
            t_plot = t_block(2:end);

            plot(t_plot, phi_diff, '-', ...
                'Color', colors(idx, :), ...
                'LineWidth', 1.2);
        end
    end

    % 축 및 제목
    xlabel('Time (hours)', 'FontSize', 13, 'FontWeight', 'bold');
    ylabel('Δ Carrier Phase (cycles)', 'FontSize', 13, 'FontWeight', 'bold');
    title(sprintf('Carrier Phase Difference – %s (%s)', ...
        dataset.constellation_name{idx_c}, f_label), ...
        'FontSize', 14);
    grid on;
    set(gca, 'FontSize', 12);

    % 저장
    if ~isempty(save_dir)
        if ~exist(save_dir, 'dir'), mkdir(save_dir); end
        fname = sprintf('carrier_phase_diff_%s_%s', f_label, dataset.constellation_name{idx_c});
        savefig(fig, fullfile(save_dir, [fname '.fig']));
        saveas(fig,  fullfile(save_dir, [fname '.png']));
    end
end
end
