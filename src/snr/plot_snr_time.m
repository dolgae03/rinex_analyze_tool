function plot_snr_time(dataset, start, duration, save_dir)
    %% 모든 시간대에 대한 가시 위성수 생성

    target_val = dataset.snr1;

    time = dataset.time(start: start+duration);

    %% Constellation 별 가시 위성수 생성
    target_idx_list = find([1,0,1,0,1] == 1);
    sat_names = dataset.constellation_name(target_idx_list);

    snr_per_each_sat = {};
    
    for i=1:length(target_idx_list)
        range = dataset.constellation_idx(target_idx_list(i)):dataset.constellation_idx(target_idx_list(i)+1)-1;
        snr_per_each_sat{i} = target_val(start: start+duration, range)';
    end
    %% Reference 위치 추정 
    
    xyz_const = wgslla2xyz(37.566535, 127.0277194, 38);

   
    %% Plot 수행
    for i=1:length(target_idx_list)
        % Create a new figure for each satellite
        fig = figure(i+35);
        clf;
        fig.Color = 'white';
    
        % Plot SNR over time for the current satellite
        plot(time./3600, snr_per_each_sat{i}, ...
             'LineWidth', 1);
        
        xlabel('Time (hours)', 'FontSize', 14, 'FontWeight', 'bold');
        ylabel('C/N0 (dB-Hz)', 'FontSize', 14, 'FontWeight', 'bold');
        set(gca, 'FontSize', 14); % 축 글꼴 크기 및 두께 설정
        xlim([0, 21]);
        ylim([10, 60]);
        % title(['SNR over Time for Satellite ', sat_names{i}]);
        grid on;

        save_path = fullfile(save_dir, ['plot_snr_time_', sat_names{i}, '.fig']);
        savefig(fig, save_path);

        save_path = fullfile(save_dir, ['plot_snr_time_', sat_names{i}, '.png']);
        saveas(fig, save_path);
        % Add legend with LaTeX interpreter
        % legend(dataset.constellation_name{i}, 'Location', 'northwest', 'Interpreter', 'latex');
    end




    % %% 모든 시간대에 대한 가시 위성수 생성
    % 
    % target_val = dataset.snr3;
    % 
    % time = dataset.time(start: start+duration);
    % 
    % %% Constellation 별 가시 위성수 생성
    % target_idx_list = find([1,0,1,0,1] == 1);
    % sat_names = dataset.constellation_name(target_idx_list);
    % 
    % snr_per_each_sat = {};
    % 
    % for i=1:length(target_idx_list)
    %     range = dataset.constellation_idx(target_idx_list(i)):dataset.constellation_idx(target_idx_list(i)+1)-1;
    %     snr_per_each_sat{i} = target_val(start: start+duration, range)';
    % end
    % %% Reference 위치 추정 
    % 
    % xyz_const = wgslla2xyz(37.566535, 127.0277194, 38);
    % 
    % 
    % %% Plot 수행
    % for i=1:length(target_idx_list)
    %     % Create a new figure for each satellite
    %     fig = figure(i+35);
    %     clf;
    %     fig.Color = 'white';
    % 
    %     % Plot SNR over time for the current satellite
    %     plot(time./3600, snr_per_each_sat{i}, ...
    %          'LineWidth', 1);
    % 
    %     xlabel('Time (hours)', 'FontSize', 14, 'FontWeight', 'bold');
    %     ylabel('C/N0 (dB-Hz)', 'FontSize', 14, 'FontWeight', 'bold');
    %     set(gca, 'FontSize', 14); % 축 글꼴 크기 및 두께 설정
    %     xlim([0, 21]);
    %     ylim([10, 60]);
    %     % title(['SNR over Time for Satellite ', sat_names{i}]);
    %     grid on;
    % 
    %     save_path = fullfile(save_dir, ['plot_snr3_time_L5_', sat_names{i}, '.fig']);
    %     savefig(fig, save_path);
    % 
    %     save_path = fullfile(save_dir, ['plot_snr3_time_L5_', sat_names{i}, '.png']);
    %     saveas(fig, save_path);
    %     % Add legend with LaTeX interpreter
    %     % legend(dataset.constellation_name{i}, 'Location', 'northwest', 'Interpreter', 'latex');
    % end
end
