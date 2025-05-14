function plot_multipath_histogram(dataset, start, duration, save_dir, frequency, rcv_type )
    
 global color_palette
    colors = color_palette;
RCV_TYPE_SMARTPHONE = 0;
    RCV_TYPE_RECEIVER = 1;

    %% 모든 시간대에 대한 가시 위성수 생성
    time = dataset.time(start:start+duration); % 시간 데이터

    xyz_const = wgslla2xyz(37.566535, 127.0277194, 38);

    if rcv_type  == RCV_TYPE_SMARTPHONE
%         bin_edges = -60:2:60; y_max = 0.2; 
         bin_edges = -60:2:60; y_max = 0.08; 
    elseif rcv_type == RCV_TYPE_RECEIVER
        bin_edges = -3:0.1:3; y_max = 0.2;
    end

    if frequency == 1
        target_val = dataset.mp1;

    elseif frequency == 5
        target_val = dataset.mp5;
%         bin_edges = -20:1:20; y_max = 0.4; 
        bin_edges = -60:2:60; y_max = 0.08;
   
    end
    

    %% Constellation 별 가시 위성수 생성
    target_idx_list = find([1,0,1,0,1] == 1);
%     target_idx_list = find([1,0,0,0,0] == 1);
    sat_names = dataset.constellation_name(target_idx_list); % 위성 이름

    target_multipath = {[], [], []};
    snr_per_each_sat = {[], [], []};

    for k=1:length(target_idx_list)
        for j=dataset.constellation_idx(target_idx_list(k)):dataset.constellation_idx(target_idx_list(k)+1)-1
            for i = start:start+duration
                sv_pos = squeeze(dataset.XS_tot1(i, j, :));
                if isnan(target_val(i, j)) || any(isnan(sv_pos))
                    continue
                end

                [azimuth, elevation] = calculateElevationAzimuth(xyz_const, sv_pos);

                target_multipath{k}(end+1) = target_val(i, j);
                snr_per_each_sat{k}(end+1) = elevation;
            end
        end
    end

    %% Reference 위치 추정
    xyz_const = wgslla2xyz(37.566535, 127.0277194, 38);




    %% Plot 수행
    for i = 1:length(target_idx_list)
        % Create a new figure for each satellite
        fig = figure(i + 3500467);
        clf;
        fig.Color = 'white';
    
        % Flatten and remove NaN values
        snr_flattened = snr_per_each_sat{i}(:); % SNR 데이터 플래튼
        
        multipath_flattened = target_multipath{i}(:); % Multipath 데이터 플래튼

%         multipath_flattened(abs(multipath_flattened ) > 50) = nan;
        
        valid_idx = ~isnan(snr_flattened) & ~isnan(multipath_flattened); % 유효 데이터 필터링
        snr_clean = snr_flattened(valid_idx); % 유효 SNR 데이터
        multipath_clean = multipath_flattened(valid_idx); % 유효 Multipath 데이터

        std_mp = std(multipath_clean);
        std_str = sprintf("STD: %.2f m", std_mp);
        histogram(multipath_clean, bin_edges, 'Normalization','probability',...
            'FaceColor', colors(i, :), 'DisplayName', std_str);
        
        legend;

        % 그래프 설정
        xlabel('Multipath Noise (m)', 'FontSize', 14, 'FontWeight', 'bold');
        ylabel('Probability', 'FontSize', 14, 'FontWeight', 'bold');
        set(gca, 'FontSize', 14); % 축 글꼴 크기 및 두께 설정
        
        % title(['Multipath over Elevation : ', sat_names{i}]);
        xlim([min(bin_edges) max(bin_edges)]); 
        ylim([0 y_max]);
        grid on;

        % Save the figure
        file_base = sprintf('plot_multipath_histogram_%s_%d', sat_names{i}, frequency);
        
        savefig(fig, fullfile(save_dir, [file_base, '.fig']));
        saveas(fig, fullfile(save_dir, [file_base, '.png']));
    end
end
