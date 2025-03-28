function plot_snr_elevation_constellation(dataset, start, duration, save_dir)
    %% Reference 위치 추정 
    xyz_const = wgslla2xyz(37.566535, 127.0277194, 38);

    %% 필요 변수 정의
    elevation_angles = [];
    snr_values = [];

    colors = lines(5);
    colors = colors([1, 2, 5, 3, 5], :);

    %% 모든 시간대에 대한 가시 위성수 생성
    target_val = dataset.snr1;
    plot_elevation = {};
    plot_snr = {};

    target_idx_list = find([1,0,1,0,1] == 1);
    sat_names = dataset.constellation_name(target_idx_list);

    for k=1:length(target_idx_list)
        elevation_angles = [];
        snr_values = [];

        for j=dataset.constellation_idx(target_idx_list(k)):dataset.constellation_idx(target_idx_list(k)+1)-1
            for i = start:start+duration
                sv_pos = squeeze(dataset.XS_tot1(i, j, :));
                if isnan(target_val(i, j)) || any(isnan(sv_pos))
                    continue
                end
               
                [azimuth, elevation] = calculateElevationAzimuth(xyz_const, sv_pos);
                
    
                % Store elevation and SNR values
                elevation_angles(end+1) = elevation;
                snr_values(end+1) = target_val(i, j);
            end
        end
        plot_elevation{k} = elevation_angles;
        plot_snr{k} = snr_values;
    end

    %% Plot 수행 (SNR vs. Elevation Histogram)
    for idx = 1:length(target_idx_list)
        fig = figure(573 + idx);
        clf;
        fig.Color = 'white';
        hold on;

        % 그래프 레이블 및 범례 설정
        xlabel('Elevation (degree)', 'FontSize', 14, 'FontWeight', 'bold');
        ylabel('C/N0 (dB-Hz)', 'FontSize', 14, 'FontWeight', 'bold');
        % title(['SNR vs. Elevation for ', sat_names{idx}]);
        ylim([0,60])
        xlim([0, 90]);
    
        % 축과 라벨의 글꼴 크기 및 두께 설정
        set(gca, 'FontSize', 14);  % 축 글꼴 크기 및 두께 설정

        grid on;

        scatter(plot_elevation{idx}, plot_snr{idx}, 4, colors(idx, :), 'filled');

                % Save figure if save directory is provided
        if nargin > 3 && ~isempty(save_dir)
            save_path = fullfile(save_dir, ['snr_elevation_dot_', sat_names{idx}, '.fig']);
            savefig(fig, save_path);

            save_path = fullfile(save_dir, ['snr_elevation_dot_', sat_names{idx}, '.png']);
            saveas(fig, save_path);
        end
    end



    %     %% Reference 위치 추정 
    % xyz_const = wgslla2xyz(37.566535, 127.0277194, 38);
    % 
    % %% 필요 변수 정의
    % elevation_angles = [];
    % snr_values = [];
    % 
    % colors = lines(5);
    % colors = colors([1, 2, 5, 3, 5], :);
    % 
    % %% 모든 시간대에 대한 가시 위성수 생성
    % target_val = dataset.snr3;
    % plot_elevation = {};
    % plot_snr = {};
    % 
    % target_idx_list = find([1,0,1,0,1] == 1);
    % sat_names = dataset.constellation_name(target_idx_list);
    % 
    % for k=1:length(target_idx_list)
    %     elevation_angles = [];
    %     snr_values = [];
    % 
    %     for j=dataset.constellation_idx(target_idx_list(k)):dataset.constellation_idx(target_idx_list(k)+1)-1
    %         for i = start:start+duration
    %             sv_pos = squeeze(dataset.XS_tot1(i, j, :));
    %             if isnan(target_val(i, j)) || any(isnan(sv_pos))
    %                 continue
    %             end
    % 
    %             [azimuth, elevation] = calculateElevationAzimuth(xyz_const, sv_pos);
    % 
    % 
    %             % Store elevation and SNR values
    %             elevation_angles(end+1) = elevation;
    %             snr_values(end+1) = target_val(i, j);
    %         end
    %     end
    %     plot_elevation{k} = elevation_angles;
    %     plot_snr{k} = snr_values;
    % end
    % 
    % %% Plot 수행 (SNR vs. Elevation Histogram)
    % for idx = 1:length(target_idx_list)
    %     fig = figure(573 + idx);
    %     clf;
    %     fig.Color = 'white';
    %     hold on;
    % 
    %     % 그래프 레이블 및 범례 설정
    %     xlabel('Elevation (degree)', 'FontSize', 14, 'FontWeight', 'bold');
    %     ylabel('C/N0 (dB-Hz)', 'FontSize', 14, 'FontWeight', 'bold');
    %     % title(['SNR vs. Elevation for ', sat_names{idx}]);
    %     ylim([0,60]);
    %     xlim([0,90]);
    % 
    %     % 축과 라벨의 글꼴 크기 및 두께 설정
    %     set(gca, 'FontSize', 14);  % 축 글꼴 크기 및 두께 설정
    % 
    %     grid on;
    % 
    %     scatter(plot_elevation{idx}, plot_snr{idx}, 4, colors(idx, :), 'filled');
    % 
    %             % Save figure if save directory is provided
    %     if nargin > 3 && ~isempty(save_dir)
    %         save_path = fullfile(save_dir, ['snr_elevation_dot_L5_', sat_names{idx}, '.fig']);
    %         savefig(fig, save_path);
    % 
    %         save_path = fullfile(save_dir, ['snr_elevation_dot_L5_', sat_names{idx}, '.png']);
    %         saveas(fig, save_path);
    %     end
    % end


end
