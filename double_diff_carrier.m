% run_double_difference_plot.m

% ─────────────────────────────────────────────
% 사용자 설정
base_file  = ".\data\obs\receiver_opensky.mat";   % ← 실제 base .mat 경로로 바꿔주세요
rover_file = ".\data\obs\smartphone_opensky.mat";  % ← 실제 rover .mat 경로로 바꿔주세요
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
% single_diff_doppler(base_dataset, rover_dataset, start_idx, duration, save_dir);

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
    title(sprintf('Doppler Single Difference – SV %d',  sv));
    saveas(fig, fullfile(save_dir, sprintf('sd_doppler_sv%d.fig', sv)));
end

function plot_double_difference(base_dataset, rover_dataset, start_idx, duration, save_dir)
    
%     sv_list = 9;
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

    ref_sv = sv_indices(1);  % 기준 위성은 자동 선택

    sv_exclude = [ref_sv, 9, 12, 13, 14,15,  28, 29];
%     sv_exclude = [];
    sv_list = [];

    for sv = 1:32
        is_skip = (any(sv == sv_exclude));
        if ~is_skip
            sv_list = [sv_list, sv];
        end

    end

    rover_dataset.ph1 = rover_dataset.ph1 ./ lam1;

    % 시간 벡터
    t = base_dataset.time_GPS(time_range) - base_dataset.time_GPS(time_range(1));

    dd_all = [];

    for target_sv_idx = sv_list
        sd_target = (rover_dataset.ph1(time_range, target_sv_idx) - base_dataset.ph1(time_range, target_sv_idx)) * lam1;
        sd_ref    = (rover_dataset.ph1(time_range, ref_sv)        - base_dataset.ph1(time_range, ref_sv))     * lam1;
        dd = sd_target - sd_ref;
    %     dd = dd - mean(dd, 'omitnan');
        valid_idx = ~isnan(dd);
        p = polyfit(t(valid_idx), dd(valid_idx), 2);
        trend = polyval(p, t);
        dd_detrended = dd - trend;
        dd_all = [dd_all dd_detrended];
    end

 
    

    % 시각화
    fig1 = figure(1800); clf; hold on; grid on;
    set(fig1, 'Color', 'w');
    set(gca, 'FontSize', 15);

    colors = lines(5);
    h_plot = plot(t, dd_all*1000, 'LineWidth', 1.2);
    mu = mean(dd_all*1000, 'all','omitnan');
    sigma = std(dd_all*1000, 0, 'all', 'omitnan');
    ylim([-60 60]);

    legend_str = sprintf('\\sigma = %.2f mm', sigma);
%     legend( legend_str, 'Location', 'best');
    xlabel('Time [s]');
    ylabel('Carrier Multipath [mm]');

    % ── 정규분포 히스토그램 + PDF ─────────────────
    fig2 = figure(1801); clf; hold on; grid on;
    set(fig2, 'Color', 'w');
    bin_edges = 1000*(-0.04:0.001:0.04);
%     disp(legend_str);
    
    histogram(dd_all*1000, bin_edges, 'Normalization', 'probability', 'FaceAlpha', 0.6, 'FaceColor', colors(4, :));
    legend( legend_str, 'Location', 'northeast');
    xlim([min(bin_edges) max(bin_edges)])
    xlabel('Carrier Multipath [mm]'); ylabel('Probability');
    set(gca, 'FontSize', 15);

    % ── 저장 ────────────────────────────────────────
    if ~exist(save_dir, 'dir'); mkdir(save_dir); end
    saveas(fig1, fullfile(save_dir, sprintf('dd_detrended_sv_all.png')));
    savefig(fig1, fullfile(save_dir, sprintf('dd_detrended_sv_all.fig')));  % MATLAB .fig
    saveas(fig2, fullfile(save_dir, sprintf('dd_pdf_sv_all.png')));
    savefig(fig2, fullfile(save_dir, sprintf('dd_pdf_sv_all.fig')));  % MATLAB .fig
end