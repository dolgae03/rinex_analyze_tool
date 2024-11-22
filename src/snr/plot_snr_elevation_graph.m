function plot_snr_elevation_graph(dataset, start, duration, save_dir)
    %% Reference 위치 추정 
    xyz_const = wgslla2xyz(37.566535, 127.0277194, 38);

    colors = lines(5);
    colors = colors([1, 2, 5, 3, 5], :);

    %% 모든 시간대에 대한 가시 위성수 생성
    target_val = dataset.snr1;
   
    target_idx_list = find([1,0,1,0,1] == 1);
    sat_names = dataset.constellation_name(target_idx_list);

    plot_snr = cell(length(target_idx_list), 3);         % 3 elevation bins
    plot_elevation = cell(length(target_idx_list), 3);


    for k=1:length(target_idx_list)
        for j=dataset.constellation_idx(target_idx_list(k)):dataset.constellation_idx(target_idx_list(k)+1)-1
            for i = start:start+duration
                sv_pos = squeeze(dataset.XS_tot1(i, j, :));
                if isnan(target_val(i, j)) || any(isnan(sv_pos))
                    continue
                end

                [azimuth, elevation] = calculateElevationAzimuth(xyz_const, sv_pos);

                if elevation < 30
                    check_idx = 1;
                elseif elevation < 60
                    check_idx = 2;
                else
                    check_idx = 3;
                end

                plot_snr{k, check_idx}(end+1) = target_val(i, j);
                plot_elevation{k, check_idx}(end+1) = elevation;
            end
        end
    end

    %% Histogram Plotting (SNR vs. Number of Datapoint)
    bin_edges = 32:1:56; % Bins from 32 to 56 with intervals of 4

    for idx = 1:length(target_idx_list)
        for check_idx = 1:3
            fig = figure(583 + idx*10 + check_idx);
            clf;
            fig.Color = 'white';
            hold on;

            % Get SNR data
            snr_data = plot_snr{idx, check_idx};
            if isempty(snr_data)
                continue;
            end

            % Plot histogram
            histogram(snr_data, bin_edges, 'Normalization','probability', 'FaceColor', colors(idx, :));

            % Labels and title
            xlabel('C/N0 (dB-Hz)', 'FontSize', 14, 'FontWeight', 'bold');
            ylabel('Probability', 'FontSize', 14, 'FontWeight', 'bold');
            % title(['Histogram of SNR for ', sat_names{idx}, ' (Elevation bin ', num2str(check_idx), ')']);
            xlim([32, 56]);
            ylim([0, 0.3])

            % Set font size
            set(gca, 'FontSize', 14);

            grid on;

            % Save figure if save directory is provided
            if nargin > 3 && ~isempty(save_dir)
                save_path = fullfile(save_dir, ['Histogram_Satellite_', sat_names{idx}, '_ElevationBin_', num2str(check_idx), '.fig']);
                savefig(fig, save_path);

                save_path = fullfile(save_dir, ['Histogram_Satellite_', sat_names{idx}, '_ElevationBin_', num2str(check_idx), '.png']);
                saveas(fig, save_path);
            end
        end
    end




        %% Reference 위치 추정 
    xyz_const = wgslla2xyz(37.566535, 127.0277194, 38);

    colors = lines(5);
    colors = colors([1, 2, 5, 3, 5], :);

    %% 모든 시간대에 대한 가시 위성수 생성
    target_val = dataset.snr3;
   
    target_idx_list = find([1,0,1,0,1] == 1);
    sat_names = dataset.constellation_name(target_idx_list);

    plot_snr = cell(length(target_idx_list), 3);         % 3 elevation bins
    plot_elevation = cell(length(target_idx_list), 3);


    for k=1:length(target_idx_list)
        for j=dataset.constellation_idx(target_idx_list(k)):dataset.constellation_idx(target_idx_list(k)+1)-1
            for i = start:start+duration
                sv_pos = squeeze(dataset.XS_tot1(i, j, :));
                if isnan(target_val(i, j)) || any(isnan(sv_pos))
                    continue
                end

                [azimuth, elevation] = calculateElevationAzimuth(xyz_const, sv_pos);

                if elevation < 30
                    check_idx = 1;
                elseif elevation < 60
                    check_idx = 2;
                else
                    check_idx = 3;
                end

                plot_snr{k, check_idx}(end+1) = target_val(i, j);
                plot_elevation{k, check_idx}(end+1) = elevation;
            end
        end
    end

    %% Histogram Plotting (SNR vs. Number of Datapoint)
    bin_edges = 32:1:56; % Bins from 32 to 56 with intervals of 4

    for idx = 1:length(target_idx_list)
        for check_idx = 1:3
            fig = figure(583 + idx*10 + check_idx);
            clf;
            fig.Color = 'white';
            hold on;

            % Get SNR data
            snr_data = plot_snr{idx, check_idx};
            if isempty(snr_data)
                continue;
            end

            % Plot histogram
            histogram(snr_data, bin_edges, 'Normalization','probability', 'FaceColor', colors(idx, :));

            % Labels and title
            xlabel('C/N0 (dB-Hz)', 'FontSize', 14, 'FontWeight', 'bold');
            ylabel('Probability', 'FontSize', 14, 'FontWeight', 'bold');
            % title(['Histogram of SNR for ', sat_names{idx}, ' (Elevation bin ', num2str(check_idx), ')']);
            xlim([32, 56]);
            ylim([0, 0.3])

            % Set font size
            set(gca, 'FontSize', 14);

            grid on;

            % Save figure if save directory is provided
            if nargin > 3 && ~isempty(save_dir)
                save_path = fullfile(save_dir, ['Histogram_Satellite_L5_', sat_names{idx}, '_ElevationBin_', num2str(check_idx), '.fig']);
                savefig(fig, save_path);

                save_path = fullfile(save_dir, ['Histogram_Satellite_L5_', sat_names{idx}, '_ElevationBin_', num2str(check_idx), '.png']);
                saveas(fig, save_path);
            end
        end
    end
end
