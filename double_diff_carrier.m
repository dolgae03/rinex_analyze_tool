% run_double_difference_plot.m

% ─────────────────────────────────────────────
% 사용자 설정
base_file  = "C:\Users\mskim\Desktop\workspace\samsung_analyze_tool\data\obs_real - 복사본\BMHR21030714D_2025-05-07_17-21-04_processed_aligned.mat";   % ← 실제 base .mat 경로로 바꿔주세요
rover_file = "C:\Users\mskim\Desktop\workspace\samsung_analyze_tool\data\obs_real - 복사본\29742_gnss_log_2025_05_07_17_22_10_aligned.mat";  % ← 실제 rover .mat 경로로 바꿔주세요
save_dir   = './data/result';             % 결과 저장 디렉토리
start_idx  = 200;                   % 시작 인덱스 (예: 1000)
duration   = 1000;                    % 분석할 epoch 수 (예: 500)
% ─────────────────────────────────────────────

% 데이터 로드
base_dataset  = load(base_file);
rover_dataset = load(rover_file);

c = 299792458;  % 빛의 속도 [m/s]
fL1 = 1575.42e6; % L1 주파수 [Hz]
fL5 = 1176.45e6; % L5 주파수 [Hz]
lam1 = c / fL1;  % L1 파장 [m]
lam5 = c / fL5;  % L5 파장 [m]

% 함수 호출
plot_double_difference(base_dataset, rover_dataset, start_idx, duration, save_dir);
single_diff_doppler(base_dataset, rover_dataset, start_idx, duration, save_dir);

disp('Double difference plot complete.');

function single_diff_doppler(base_dataset, rover_dataset, start_idx, duration, save_dir)
    % ── 상수 ────────────────────────────────────────────
    c = 299792458;          % 빛의 속도 [m/s]
    fL1 = 1575.42e6;        % L1 주파수 [Hz]
    fL5 = 1176.45e6;        % L5 주파수 [Hz]
    lam1 = c / fL1;         % L1 파장 [m]
    lam5 = c / fL5;         % L5 파장 [m]

    % ── 사용자 설정 ─────────────────────────────────────
    target_sv_idx = 11;     % 분석할 대상 위성 번호
    time_range = start_idx : (start_idx + duration - 1);

    % ── 유효성 확인 ─────────────────────────────────────
    is_valid_base = ~isnan(base_dataset.dop1(time_range,:));
    is_valid_rover = ~isnan(rover_dataset.dop1(time_range,:));
    common_sv_mask = any(is_valid_base & is_valid_rover, 1);
    sv_indices = find(common_sv_mask);

    if numel(sv_indices) < 2
        warning('공통 위성이 2개 이상 필요합니다.');
        return;
    end

    if ~ismember(target_sv_idx, sv_indices)
        warning('지정한 target_sv_idx는 공통 위성이 아닙니다.');
        return;
    end

    sv = sv_indices(1);  % 기준 위성은 자동 선택

    % ── Doppler 단일 차분 계산 ─────────────────────────
    rover_dataset.dop1 = rover_dataset.dop1 ./ lam1;
    rover_dataset.dop3 = rover_dataset.dop3 ./ lam5;

    % 시간 벡터
    t = 1:duration;
    sd = rover_dataset.dop1(time_range,sv) + base_dataset.dop1(time_range,sv);   % [m/s] 환산
    fig = figure('Name',['SD-Doppler'] , 'NumberTitle','off'); clf; hold on; grid on;
    plot(t, sd, 'LineWidth',1.2);
    xlabel('Time [s]'); ylabel('Single Difference [m/s]');
    title(sprintf('Doppler Single Difference (%s) – SV %d', tag, sv));
    save_all(fig, fullfile(save_dir, sprintf('sd_doppler_%s_sv%d.png', lower(tag), sv)));
end

function plot_double_difference(base_dataset, rover_dataset, start_idx, duration, save_dir)
    target_sv_idx = 11;
    lam1 = 299792458 / 1575.42e6;  % L1 파장 [m]
    time_range = start_idx : (start_idx + duration - 1);

    % 유효성 확인
    is_valid_base = ~isnan(base_dataset.ph1(time_range,:));
    is_valid_rover = ~isnan(rover_dataset.ph1(time_range,:));
    common_sv_mask = any(is_valid_base & is_valid_rover, 1);
    sv_indices = find(common_sv_mask);

    if numel(sv_indices) < 2
        warning('공통 위성이 2개 이상 필요합니다.');
        return;
    end

    if ~ismember(target_sv_idx, sv_indices)
        warning('지정한 target_sv_idx는 공통 위성이 아닙니다.');
        return;
    end

    ref_sv = sv_indices(1);  % 기준 위성은 자동 선택

    rover_dataset.ph1 = rover_dataset.ph1 ./ lam1;

    % 시간 벡터
    t = base_dataset.time_GPS(time_range) - base_dataset.time_GPS(time_range(1));

    % 이중차분 계산
    sd_target = (rover_dataset.ph1(time_range, target_sv_idx) - base_dataset.ph1(time_range, target_sv_idx)) * lam1;
    sd_ref    = (rover_dataset.ph1(time_range, ref_sv)        - base_dataset.ph1(time_range, ref_sv))     * lam1;

    dd = sd_target - sd_ref;
    dd = dd - mean(dd, 'omitnan');

    valid_idx = ~isnan(dd);
    p = polyfit(t(valid_idx), dd(valid_idx), 2);
    trend = polyval(p, t);
    dd_detrended = dd - trend;

    % 시각화
    fig1 = figure(1800); clf; hold on; grid on;
    set(fig1, 'Color', 'w');

    mu = mean(abs(dd_detrended), 'omitnan');  % 평균 계산
    h_plot = plot(t, dd_detrended, 'LineWidth', 1.2);

    legend_str = sprintf('|\\mu| = %.4f m', abs(mu));
    legend(h_plot, legend_str, 'Location', 'best');

    title(sprintf('Detrended DD: SV %d - SV %d', target_sv_idx, ref_sv));
    xlabel('Time [s]');
    ylabel('Double Difference [m]');

    % ── 정규분포 히스토그램 + PDF ─────────────────
    fig2 = figure(1801); clf; hold on; grid on;
    set(fig2, 'Color', 'w');
    histogram(dd_detrended, 'Normalization', 'pdf', 'FaceAlpha', 0.6);

    mu = mean(dd_detrended, 'omitnan');
    sigma = std(dd_detrended, 'omitnan');

    x_vals = linspace(min(dd_detrended), max(dd_detrended), 200);
    y_vals = normpdf(x_vals, mu, sigma);
    plot(x_vals, y_vals, 'r-', 'LineWidth', 1.5);

    legend_str = sprintf('\\sigma = %.4f m', sigma);
    legend('Histogram', legend_str, 'Location', 'best');

    title('Double Difference Histogram with Normal PDF');
    xlabel('DD Value [m]'); ylabel('PDF');

    % ── 저장 ────────────────────────────────────────
    if ~exist(save_dir, 'dir'); mkdir(save_dir); end
    saveas(fig1, fullfile(save_dir, sprintf('dd_detrended_sv%d.png', target_sv_idx)));
    savefig(fig1, fullfile(save_dir, sprintf('dd_detrended_sv%d.fig', target_sv_idx)));  % MATLAB .fig
    saveas(fig2, fullfile(save_dir, sprintf('dd_pdf_sv%d.png', target_sv_idx)));
    savefig(fig2, fullfile(save_dir, sprintf('dd_pdf_sv%d.fig', target_sv_idx)));  % MATLAB .fig
end