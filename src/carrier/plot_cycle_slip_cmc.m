function plot_cycle_slip_cmc(dataset, start, duration, save_dir, frequency)
% 별자리 단위로 Cycle-Slip 발생 구간 시각화
%
% detect_cycle_slip.m 이 같은 폴더에 있어야 합니다.
%% 0) 공통 설정
global color_palette


c = 299792458;                 % [m/s]
switch frequency
    case 1              % L1
        phase_all = dataset.ph1;      
        lambda     = c / 1575.42e6;
        f_label    = 'L1';
    case 5              % L5
        phase_all = dataset.ph3;
        lambda     = c / 1176.45e6;
        f_label    = 'L5';
    otherwise
        error('frequency must be 1 or 5');
end

time  = dataset.time(start : start+duration);         % Nx1
idx_t = start : start+duration;                       % 행 인덱스                                 % 최대 6개 별자리 색

% target_idx_list = find([1, 0, 1, 0, 1] == 1);
target_idx_list = find([1, 0, 0, 0, 0] == 1);

% 색상 정의
colors = color_palette;

for k = 1:length(target_idx_list)
    idx_c = target_idx_list(k);
    % 별자리에 해당하는 위성 컬럼 인덱스
    col_s = dataset.constellation_idx(idx_c);
    col_e = dataset.constellation_idx(idx_c+1)-1;
    sat_cols = col_s:col_e;                % 1×Nsat
    if isempty(sat_cols),  continue, end

    % (duration+1)×Nsat 부분행렬
    phase = dataset.ph1(start:start + duration,:);
    flag = dataset.cycleSlipFlag(start:start + duration,:);

    %---------- ② 플롯
    fig = figure(5000 + idx_c); clf(fig); set(fig, 'Color', 'w'); hold on;
    n_sat = numel(sat_cols);
    
    x_all = [];  % 전체 X (시간)
    y_all = [];  % 전체 Y (PRN)    
    x_slip = [];
    y_slip = [];

    sv_list = dataset.constellation_idx(k):dataset.constellation_idx(k + 1) - 1;
    for sv = sv_list 
        t_all = time / 3600;
        for i = 1: length(t_all)
            is_slip = flag(i,sv)>1;
            is_valid = ~isnan(phase(i,sv));
            is_normal = is_valid & ~is_slip;

            if is_normal
                sv_pos = squeeze(dataset.XS_tot1(start + i - 1, sv, :));
                if any(isnan(sv_pos))
                    continue;
                end
                 x_all = [x_all; t_all(i)];
                 y_all = [y_all;  sv];
            end
            if is_slip
                 x_slip = [x_slip;  t_all(i)];
                 y_slip = [y_slip; sv];
            end
        end
        x_all = [x_all; nan];
        y_all = [y_all; nan];
        x_slip = [x_slip; nan];
        y_slip = [y_slip; nan];
    
        % === 정상 구간 ===
        
%         x_all = [x_all; nan; t_all(is_valid)];
%         y_all = [y_all; nan; s*ones(sum(is_valid),1)];
%         c_all = [c_all; nan(1,3); colors(idx,:)];  % 색상은 post-processing
    
        % === 슬립 구간 ===
%         slip_idx = find(slip_s);
%         slip_idx = slip_idx(slip_idx > 1);
%         for j = slip_idx'
% %             x_slip = [x_slip, NaN, t_all(j - 1), t_all(j)];
% %             y_slip = [y_slip, NaN, s, s];
%             x_slip = [x_slip, t_all(j)];
%             y_slip = [y_slip, s];
% 
%         end
    end

    % === 전체 정상구간 한번에 그림 ===
    plot(x_all, y_all, 'o',  'MarkerSize', 2, 'MarkerFaceColor', colors(k,:), 'MarkerEdgeColor', colors(k,:));  % 중간색
    
    % === 슬립 구간 한번에 그림 ===
    plot(x_slip, y_slip, 'x', 'Color', 'r', 'LineWidth', 2);
        
    % ----- 축·제목 등 나머지 부분은 그대로 유지 -----
    xlabel('Time (hours)','FontSize',13,'FontWeight','bold');
    ylabel('PRN','FontSize',13,'FontWeight','bold');

    xlim([0 max(time)/3600]);
    ylim([0.5 n_sat+0.5]);
    grid on; set(gca,'FontSize',15);

    if ~isempty(save_dir)
        if ~exist(save_dir,'dir'), mkdir(save_dir); end
        fname = sprintf('slip_interval_%s_%s', f_label, dataset.constellation_name{idx_c});
        savefig(fig, fullfile(save_dir, [fname '.fig']));
        saveas(fig,  fullfile(save_dir, [fname '.png']));
    end
end
end

