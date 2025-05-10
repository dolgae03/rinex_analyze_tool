function plot_multipath_elevation(dataset, start, duration, save_dir, frequency)
 global color_palette
    colors = color_palette;    
%% 모든 시간대에 대한 가시 위성수 생성
    xyz_const = wgslla2xyz(37.566535, 127.0277194, 38);

    %% Constellation 별 가시 위성수 생성
%     target_idx_list = find([1,0,1,0,1] == 1);
    target_idx_list = find([1,0,0,0,0] == 1);
    
    if frequency == 1
        target_val = dataset.mp1;
    elseif frequency == 5
        target_val = dataset.mp5;
    end
   
    sat_names = dataset.constellation_name(target_idx_list);

    plot_snr = cell(length(target_idx_list), 200);         % 3 elevation bins
    plot_elevation = cell(length(target_idx_list), 200);

    for k=1:length(target_idx_list)
        for j=dataset.constellation_idx(target_idx_list(k)):dataset.constellation_idx(target_idx_list(k)+1)-1
            for i = start:start+duration
                sv_pos = squeeze(dataset.XS_tot1(i, j, :));
                if isnan(target_val(i, j)) || any(isnan(sv_pos))
                    continue
                end

                [azimuth, elevation] = calculateElevationAzimuth(xyz_const, sv_pos);

                plot_snr{k,j}(end+1) = target_val(i, j);
                plot_elevation{k,j}(end+1) = elevation;
            end
        end
    end
   
    %% Plot 수행
    for i=1:length(target_idx_list)
        % Create a new figure for each satellite
        fig = figure(i+350044);
        clf;
        fig.Color = 'white';
        
        y_lim = 0;
        new_colors = lines();
        % Plot SNR over time for the current satellite
        for j=1:200
            scatter(plot_elevation{i, j}, abs(plot_snr{i, j}), 3, 'filled', 'MarkerFaceColor',new_colors(j, :)); % Size=15, color=blue
            hold on;
            if ~isempty(plot_snr{i, j})
                y_lim = max([abs(plot_snr{i, j}), y_lim]);
            end
        end
        xlabel('Elevation (degree)', 'FontSize', 14, 'FontWeight', 'bold');
        ylabel('Multipath Noise (m)', 'FontSize', 14, 'FontWeight', 'bold');
        set(gca, 'FontSize', 14); % 축 글꼴 크기 및 두께 설정
        xlim([0, 90]);
        ylim([0, y_lim + 1]);
        % title(['Multipath over Elevation : ', sat_names{i}]);
        grid on;
       
        file_base = sprintf('plot_multipath_elevation_%s_%d', sat_names{i}, frequency);
        
        savefig(fig, fullfile(save_dir, [file_base, '.fig']));
        saveas(fig, fullfile(save_dir, [file_base, '.png']));
    end
end
