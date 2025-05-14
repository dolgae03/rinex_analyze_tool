function plot_multipath_time(dataset, start, duration, save_dir, frequency)
    %% 모든 시간대에 대한 가시 위성수 생성
    time = dataset.time(start:start+duration); % 시간 데이터
    
    %% Constellation 별 가시 위성수 생성
    target_idx_list = find([1,0,1,0,1] == 1);
%     target_idx_list = find([1,0,0,0,0] == 1);
    sat_names = dataset.constellation_name(target_idx_list);

    target_multipath = cell(length(target_idx_list), 200);
    snr_per_each_sat = cell(length(target_idx_list), 200);

    if frequency == 1
        target_val = dataset.mp1;
    elseif frequency == 5
        target_val = dataset.mp5;
    end
    
    for i = 1:length(target_idx_list)
        range = dataset.constellation_idx(target_idx_list(i)):dataset.constellation_idx(target_idx_list(i)+1)-1;  

        for j = range
            snr_per_each_sat{i,j} = [snr_per_each_sat{i, j}; time(:)];
            target_multipath{i,j} = [target_multipath{i, j}; target_val(start: start+duration, j)];
        end
    end

    %% Reference 위치 추정
    xyz_const = wgslla2xyz(37.566535, 127.0277194, 38);
    colors = lines(5);
    colors = colors([1, 2, 5, 3, 5], :);

    y_lim = 0;

    %% Plot 수행
    for i = 1:length(target_idx_list)
        % Create a new figure for each satellite
        
        fig = figure(i + 150042);
        clf;
        fig.Color = 'white';
        new_colors = lines();
        for j=1:200
            snr_flattened = snr_per_each_sat{i, j}(:);
            multipath_flattened = target_multipath{i, j}(:);
            
            valid_idx = ~isnan(snr_flattened) & ~isnan(multipath_flattened);
            snr_clean = snr_flattened(valid_idx);
            multipath_clean = multipath_flattened(valid_idx);

            scatter(snr_clean ./ 3600, multipath_clean, 3, 'filled', 'MarkerFaceColor',new_colors(j, :)); % Size=15, color=blue
            hold on;
            
            if ~isempty(multipath_clean)
                y_lim = max([multipath_clean; y_lim]);
            end
        end
        
        xlabel('Time (hours)', 'FontSize', 14, 'FontWeight', 'bold'); % x축 레이블
        ylabel('Multipath Noise (m)', 'FontSize', 14, 'FontWeight', 'bold'); % y축 레이블
        set(gca, 'FontSize', 14); % 축 글꼴 크기 및 두께 설정
        xlim([0, max(time./3600)]);
        ylim([-(y_lim + 1), y_lim + 1]);
        % title(['Multipath over Time : ', sat_names{i}]); % 제목
        grid on;
    
        file_base = sprintf('plot_multipath_time_%s_%d', sat_names{i}, frequency);
        
        savefig(fig, fullfile(save_dir, [file_base, '.fig']));
        saveas(fig, fullfile(save_dir, [file_base, '.png']));
    end
end
