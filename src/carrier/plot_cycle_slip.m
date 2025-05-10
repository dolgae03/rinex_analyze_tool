function plot_cycle_slip(dataset, start, duration, save_dir, frequency)
% 별자리 단위로 Cycle-Slip 발생 구간 시각화
%
% detect_cycle_slip.m 이 같은 폴더에 있어야 합니다.
%% 0) 공통 설정



c = 299792458;                 % [m/s]
switch frequency
    case 1              % L1
        phase_all = dataset.ph1;
        code_all = dataset.pr1;
        lambda     = c / 1575.42e6;
        f_label    = 'L1';
    case 5              % L5
        phase_all = dataset.ph3;
        code_all = dataset.pr3;
        lambda     = c / 1176.45e6;
        f_label    = 'L5';
    otherwise
        error('frequency must be 1 or 5');
end

time  = dataset.time(start : start+duration);         % Nx1
idx_t = start : start+duration;                       % 행 인덱스                                 % 최대 6개 별자리 색

target_idx_list = find([1, 0, 1, 0, 1] == 1);

% 색상 정의
colors = lines(5);
colors = colors([1, 2, 5, 3, 5], :);

for idx = 1:length(target_idx_list)
    idx_c = target_idx_list(idx);
    % 별자리에 해당하는 위성 컬럼 인덱스
    col_s = dataset.constellation_idx(idx_c);
    col_e = dataset.constellation_idx(idx_c+1)-1;
    sat_cols = col_s:col_e;                % 1×Nsat
    if isempty(sat_cols),  continue, end

    % (duration+1)×Nsat 부분행렬
    phase_seg = phase_all(idx_t, sat_cols);

    %---------- ① Cycle-Slip 논리행렬 계산 (N-1 × Nsat)
    slip_mat = detect_cycle_slip(phase_seg, lambda, 30);   % (N-2) x Nsat
    slip_mat = [false(2, size(slip_mat,2)); slip_mat];     % 위에 2줄 false로 패딩하여 (N x Nsat)로 맞춤

    %---------- ② 플롯
    fig = figure(500 + idx_c); clf(fig); set(fig, 'Color', 'w'); hold on;
    n_sat = numel(sat_cols);
    
    x_all = [];  % 전체 X (시간)
    y_all = [];  % 전체 Y (PRN)
    c_all = [];  % 색상 인덱싱용 (PRN별 색)
    
    x_slip = [];
    y_slip = [];
    
    for s = 1:n_sat
        phase_s  = phase_seg(:,s);           % N×1
        is_valid = ~isnan(phase_s);
        slip_s   = slip_mat(:,s);
    
        t_all = time / 3600;
    
        % === 정상 구간 ===
        is_normal = is_valid & ~slip_s;
        changes = diff([0; is_normal; 0]);
        i_on  = find(changes == 1);
        i_off = find(changes == -1) - 1;
    
        for k = 1:length(i_on)
            a = i_on(k); b = i_off(k);
            if b - a < 1, continue; end
            x_all = [x_all, NaN, t_all(a:b)'];
            y_all = [y_all, NaN, s * ones(1, b - a + 1)];
            c_all = [c_all; colors(idx,:)];  % 색상은 post-processing
        end
    
        % === 슬립 구간 ===
        slip_idx = find(slip_s);
        slip_idx = slip_idx(slip_idx > 1 & slip_idx < length(t_all));
        for j = slip_idx'
            x_slip = [x_slip, NaN, t_all(j - 1), t_all(j)];
            y_slip = [y_slip, NaN, s, s];
        end
    end

    % === 전체 정상구간 한번에 그림 ===
    plot(x_all, y_all, '-', 'Color', colors(idx,:), 'LineWidth', 1.8);  % 중간색
    
    % === 슬립 구간 한번에 그림 ===
    plot(x_slip, y_slip, 'x', 'Color', 'r', 'LineWidth', 2);
        
    % ----- 축·제목 등 나머지 부분은 그대로 유지 -----
    xlabel('Time (hours)','FontSize',13,'FontWeight','bold');
    ylabel('PRN index (within constellation)','FontSize',13,'FontWeight','bold');
    title(sprintf('Cycle-Slip events – %s (%s)', ...
          dataset.constellation_name{idx_c}, f_label), ...
          'FontSize',14);
    xlim([0 max(time)/3600]);
    ylim([0.5 n_sat+0.5]);
    grid on; set(gca,'FontSize',12);

    if ~isempty(save_dir)
        if ~exist(save_dir,'dir'), mkdir(save_dir); end
        fname = sprintf('slip_interval_%s_%s', f_label, dataset.constellation_name{idx_c});
%         savefig(fig, fullfile(save_dir, [fname '.fig']));
%         saveas(fig,  fullfile(save_dir, [fname '.png']));
    end
end
end


function cycle_slip_flags = detect_cycle_slip(phase_data, lambda, threshold)
    % phase_data: NxM matrix (N epochs, M satellites)
    % lambda: wavelength in meters
    % threshold: e.g., 1 * lambda
    % Returns logical matrix of same size as phase_data (except first row)

    % 1차 차분 계산
    d2_phase = diff(phase_data, 2, 1);  % (N-2)xM

    % meter로 변환
    d_range = d2_phase * lambda;

    % Cycle slip 여부 (임계값 초과 여부)
    cycle_slip_flags = abs(d_range) > threshold;
end
