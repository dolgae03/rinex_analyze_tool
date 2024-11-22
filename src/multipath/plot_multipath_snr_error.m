function plot_multipath_snr_error(dataset, start, duration, save_dir)
    %% 모든 시간대에 대한 가시 위성수 생성
    target_val = dataset.snr1; % SNR 데이터
    time = dataset.time(start:start+duration); % 시간 데이터

    %% Constellation 별 가시 위성수 생성
    target_idx_list = find([1, 0, 0, 0, 0] == 1); % 활성화된 별자리 인덱스
    sat_names = dataset.constellation_name(target_idx_list); % 위성 이름

    target_multipath = {};
    snr_per_each_sat = {};
    
    for i = 1:length(target_idx_list)
        range = dataset.constellation_idx(target_idx_list(i)):dataset.constellation_idx(target_idx_list(i)+1)-1;
        snr_per_each_sat{i} = target_val(start:start+duration, range)'; % SNR 데이터
        target_multipath{i} = dataset.mp(start:start+duration, range)'; % Multipath 데이터
    end

    %% Reference 위치 추정
    xyz_const = wgslla2xyz(37.566535, 127.0277194, 38);
    colors = lines(5); % 색상 정의
    colors = colors([1, 2, 5, 3, 5], :);

    %% Plot 수행
    for i = 1:length(target_idx_list)
        % Create a new figure for each satellite
        fig = figure(i + 35084);
        clf;
        fig.Color = 'white';
    
        % Flatten and remove NaN values
        snr_flattened = snr_per_each_sat{i}(:); % SNR 데이터 플래튼
        multipath_flattened = target_multipath{i}(:); % Multipath 데이터 플래튼
        
        valid_idx = ~isnan(snr_flattened) & ~isnan(multipath_flattened); % 유효 데이터 필터링
        snr_clean = snr_flattened(valid_idx); % 유효 SNR 데이터
        multipath_clean = multipath_flattened(valid_idx); % 유효 Multipath 데이터
        multipath_clean = abs(multipath_clean);
        
        % SNR 구간별 평균 및 표준 편차 계산
        snr_bins = 25:0.5:60; % SNR 구간 정의
        bin_means = zeros(1, length(snr_bins)-1);
        bin_std = zeros(1, length(snr_bins)-1);
        bin_centers = zeros(1, length(snr_bins)-1);
        
        for j = 1:length(snr_bins)-1
            bin_idx = snr_clean >= snr_bins(j) & snr_clean < snr_bins(j+1); % 현재 구간에 해당하는 데이터 필터링
            if any(bin_idx)
                bin_means(j) = mean(multipath_clean(bin_idx)); % 평균
                bin_std(j) = std(multipath_clean(bin_idx)); % 표준 편차
                bin_centers(j) = mean([snr_bins(j), snr_bins(j+1)]); % 구간 중심
            else
                bin_means(j) = NaN;
                bin_std(j) = NaN;
                bin_centers(j) = mean([snr_bins(j), snr_bins(j+1)]);
            end
        end

        % Plot 평균 및 표준 편차 (Error bar)
        errorbar(bin_centers, bin_means, bin_std, 'o', ...
            'Color', colors(i, :), ...  % 마커 및 에러바 색상
            'LineWidth', 1.5, ...      % 에러바 굵기
            'MarkerSize', 6, ...       % 마커 크기
            'MarkerFaceColor', colors(i, :), ... % 마커 내부 색상
            'CapSize', 0, ...          % 캡 크기를 0으로 설정 (캡 제거)
            'LineStyle', 'none');      % 선 스타일 제거 (Error bar만 표시)
        
        % 그래프 설정
        xlabel('C/N0 (dB-Hz)', 'FontSize', 14, 'FontWeight', 'bold');
        ylabel('Multipath Noise (m)', 'FontSize', 14, 'FontWeight', 'bold');
        set(gca, 'FontSize', 14); % 축 글꼴 크기 및 두께 설정
        xlim([25, 60]);
        ylim([0, max(bin_means + bin_std, [], 'omitnan') + 0.5]);
        % title(['Multipath over SNR : ', sat_names{i}]);
        grid on;

        % Save the figure
        save_path = fullfile(save_dir, ['plot_multipath_snr_error_', sat_names{i}, '.fig']);
        savefig(fig, save_path);
    
        save_path = fullfile(save_dir, ['plot_multipath_snr_error_', sat_names{i}, '.png']);
        saveas(fig, save_path);
    end
end
