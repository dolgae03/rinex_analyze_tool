function plot_doppler_by_time(dataset, start, duration, save_dir)
    %%% Define frequencies for each constellation
    target_idx_list = find([1,0,0,0,0] == 1);
    frequencies = [1575.42e6, 1575.42e6, 1561.098e6]; % Example for GPS L1, GLONASS L1, Galileo E1

    %% Doppler와 Pseudorange 데이터 추출
    time = dataset.time(start:start + duration);

    target_dop = [];
    target_pr = [];
    c = 299792458; % Speed of light (m/s)

        % Plot scatter
    fig = figure(9);
    clf;
    fig.Color = "white";
    for k = 1:length(target_idx_list)
        range = dataset.constellation_idx(target_idx_list(k)):dataset.constellation_idx(target_idx_list(k)+1)-1;

        
        target_dop = dataset.dop1(start:start+duration, range) / frequencies(k) * c;
        target_pr = dataset.pr1(start:start+duration, range);

        target_pr_change = -diff(target_pr, 1, 1); % Pseudorange 변화율
        target_dop = target_dop(1:end-1, :); % Doppler 데이터 크기 맞춤

        diff_velocity_pseudorange = target_dop - target_pr_change; % 각 데이터 포인트별 차이 계산
    
        % Flatten data for scatter plot
        time_scatter = time(1:end-1)';

        scatter(time_scatter ./3600, abs(diff_velocity_pseudorange), 10, 'filled');
        hold on;
    end

    xlim([0,21]);

    if any(any(abs(diff_velocity_pseudorange) > 5000))
        ylim([0,2000])
    end
    xlabel('Time (hours)', 'FontSize', 14, 'FontWeight', 'bold');
    % ylabel('$|\rho_o - \dot{\rho}_o \cdot \Delta t|$ (m)', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');

    % title('Scatter: Velocity - Pseudorange Change Differences Over Time', 'FontSize', 16, 'FontWeight', 'bold');
    grid on;
    set(gca, 'FontSize', 14); % 축 글꼴 크기 및 두께 설정

    % Save scatter plot
    scatter_file_path = fullfile(save_dir, sprintf('scatter_velocity_vs_pseudorange_diff.fig'));
    savefig(fig, scatter_file_path);

    scatter_file_path = fullfile(save_dir, sprintf('scatter_velocity_vs_pseudorange_diff.png'));
    saveas(fig, scatter_file_path);
end
