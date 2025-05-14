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



function plot_double_difference(base_dataset, rover_dataset, start_idx, duration, save_dir)
    target_idx_list = find([0 0 0 0 1]==1);
    freq_rover = {1575.42e6 nan 1575.42e6 nan 1176.45};
    freq_base = {1575.42e6 nan 1575.42e6 nan 1176.45};
    time_range = start_idx : (start_idx + duration - 1);
    
    
    sat_names = base_dataset.constellation_name(target_idx_list);
    

    for i = 1:length(target_idx_list)
        
        dd_all = [];
        c=  299792458;
        
        lam_rover = c/freq_rover{target_idx_list(i)};
        lam_base = c/freq_base{target_idx_list(i)};

            
        sv_list_all = base_dataset.constellation_idx(target_idx_list(i)): base_dataset.constellation_idx(target_idx_list(i)+1)-1;
    
        % 유효성 확인
        base_ph = base_dataset.ph3(time_range, sv_list_all);
        rover_ph = rover_dataset.ph3(time_range, sv_list_all) ./lam_rover;
        


        is_valid_base = ~isnan(base_ph);
        is_valid_rover = ~isnan(rover_ph);
        
        common_sv_mask = any(is_valid_base & is_valid_rover, 1);
        common_sv_indices = find(common_sv_mask);
                    
    
        if numel(common_sv_indices) < 2
            warning('공통 위성이 2개 이상 필요합니다.');
            return;
        end
    
        ref_sv = common_sv_indices(1);  % 기준 위성은 자동 선택
        % 시간 벡터
        t = base_dataset.time_GPS(time_range) - base_dataset.time_GPS(time_range(1));
    
        figure(1000); clf; hold on;
    
        for target_sv_idx = 1: numel(sv_list_all)
            if (target_sv_idx == ref_sv)
                continue;
            end
            sd_target = rover_ph(:, target_sv_idx)*lam_rover -base_ph(:, target_sv_idx) * lam_base;
            sd_ref    = rover_ph(:, ref_sv)*lam_rover        - base_ph(:, ref_sv)* lam_base;
            dd = sd_target - sd_ref;
        %     dd = dd - mean(dd, 'omitnan');
            valid_idx = ~isnan(dd);
            p = polyfit(t(valid_idx), dd(valid_idx), 2);
            trend = polyval(p, t);
            dd_detrended = dd - trend;
            dd_all = [dd_all dd_detrended];
            
            figure(1000);
            plot(dd_detrended);
            
        end


        i_out = abs(dd_all)> 0.1;
        dd_all(i_out) = nan;
    
     
        % 시각화
        fig1 = figure(1800 + i); clf; hold on; grid on;
        set(fig1, 'Color', 'w');
        set(gca, 'FontSize', 15);
    
        colors = lines(5);
        colors = colors([1 2 5 3 5],:);
        h_plot = plot(t, dd_all*1000, 'LineWidth', 1.2);
        mu = mean(dd_all*1000, 'all','omitnan');
        sigma = std(dd_all*1000, 0, 'all', 'omitnan');
        ylim([-60 60]);
    
        legend_str = sprintf('\\sigma = %.2f mm', sigma);
    %     legend( legend_str, 'Location', 'best');
        xlabel('Time [s]');
        ylabel('Carrier Multipath [mm]');
    
        % ── 정규분포 히스토그램 + PDF ─────────────────
        fig2 = figure(1900+i); clf; hold on; grid on;
        set(fig2, 'Color', 'w');
        bin_edges = 1000*(-0.04:0.001:0.04);
    %     disp(legend_str);
        
        histogram(dd_all*1000, bin_edges, 'Normalization', 'probability', 'FaceAlpha', 0.6, 'FaceColor', colors(i, :));
        legend( legend_str, 'Location', 'northeast');
        xlim([min(bin_edges) max(bin_edges)])
        xlabel('Carrier Multipath [mm]'); ylabel('Probability');
        set(gca, 'FontSize', 15);
    
        % ── 저장 ────────────────────────────────────────
        if ~exist(save_dir, 'dir'); mkdir(save_dir); end
        saveas(fig1, fullfile(save_dir, sprintf('dd_detrended_sv_all_%s.png', sat_names{i})));
        savefig(fig1, fullfile(save_dir, sprintf('dd_detrended_sv_all_%s.fig',sat_names{i})));  % MATLAB .fig
        saveas(fig2, fullfile(save_dir, sprintf('dd_pdf_sv_all_%s.png',sat_names{i})));
        savefig(fig2, fullfile(save_dir, sprintf('dd_pdf_sv_all_%s.fig',sat_names{i})));  % MATLAB .fig

    end
end