function plot_pr_carrier_diff(dataset, start, duration, save_dir)
    % Ensure the save directory exists
    if ~exist(save_dir, 'dir')
        mkdir(save_dir);
    end

    % Time vector
    time = dataset.time; % Assuming dataset.time exists
    indices = start:start+duration;

    pr1 = dataset.pr1(indices, 3:3);
    ph1 = dataset.ph1(indices, 3:3); % Carrier phase measurements for L1
    dop1 = dataset.dop1(indices, 3:3); % Carrier phase measurements for L1
    clock_drift = dataset.clock_drift(indices, 3:3);
    uncertainty = dataset.clock_drift_uncertainty(indices, 3:3);
    
    % Constants
    c = 299792458; % Speed of light in m/s
    f_L1 = 1575.42e6; % L1 frequency in Hz
    f_L5 = 1176.45e6; % L5 frequency in Hz
    
    % Calculate wavelengths
    lambda_L1 = c / f_L1;
    
    % Calculate differences
    pr1_diff = pr1 - ph1;
    
    fig = figure(12345);
    clf;
    
    time_range = start:start+duration-1;
    
    % 첫 번째 subplot: PR1 Diff Plot
    subplot(2,1,1);
    hold on;
    plot(time_range, diff(pr1), 'bo-', 'LineWidth', 1, 'MarkerSize', 5, 'DisplayName', 'PR Diff');
    xlabel('Time');
    ylabel('PR Diff');
    title('PR1 Differences');
    legend('show');
    grid on;
    
    % 두 번째 subplot: PH1 Diff & DOP1 Plot
    subplot(2,1,2);
    hold on;
    plot(time_range, diff(ph1), 'rs-', 'LineWidth', 1, 'MarkerSize', 5, 'DisplayName', 'Carrier Diff');
    plot(time_range, dop1(1:end-1), 'g', 'LineWidth', 1, 'MarkerSize', 5, 'DisplayName', 'DOP');
    xlabel('Time');
    ylabel('Carrier Diff & DOP Diff');
    title('PH1 Differences & DOP1');
    legend('show');
    grid on;
    
    % 그래프 저장
    save_path = fullfile(save_dir, 'plot_pr1_ph1_dop1.fig');
    savefig(fig, save_path);

    
    % Figure 3: Clock Drift & Uncertainty Plot
    fig3 = figure(31234234);
    clf;
    hold on;
    plot(time_range, clock_drift(1:end-1), 'm--', 'LineWidth', 1.5, 'DisplayName', 'Clock Drift');
    plot(time_range, clock_drift(1:end-1) + uncertainty(1:end-1), 'm:', 'LineWidth', 1, 'DisplayName', 'Clock Drift + Uncertainty');
    plot(time_range, clock_drift(1:end-1) - uncertainty(1:end-1), 'm:', 'LineWidth', 1, 'DisplayName', 'Clock Drift - Uncertainty');
    xlabel('Time');
    ylabel('Clock Drift');
    title('Clock Drift and Uncertainty');
    legend('show');
    grid on;
    save_path3 = fullfile(save_dir, 'plot_clock_drift.fig');
    savefig(fig3, save_path3);

    % Center the differences around zero
    pr1_diff_centered = pr1_diff - mean(pr1_diff, 'omitnan');

    % Plot settings
    figure_names = {'PR1 vs PH1 (L1)', 'PR3 vs PH5 (L5)'};
    pr_only = {pr1};
    carrier_only = {ph1};
    diffs = {pr1_diff_centered};

    for i = 1:1
        % Create figure with a unique number
        fig = figure(i + 15615);
        fig.Color = 'white';
        clf;

        % Plot the difference (centered)
        plot(time(indices), diffs{i}, 'r', 'LineWidth', 1.5); % Plot in red
        hold on;
        % plot(time(indices), pr_only{i}, 'b', 'LineWidth', 1.5); % Plot in blue
        % plot(time(indices), carrier_only{i}, 'g', 'LineWidth', 1.5); % Plot in green
        % hold off;

        % Add grid
        grid on;

        % Set labels, title, and limits
        xlabel('Time (s)');
        ylabel('Difference (m)');
        title([figure_names{i}, ' (Centered)']);
        xlim([time(indices(1)), time(indices(end))]);

        % Add legend to distinguish plots
        legend('Diff (Centered)', 'PR', 'Carrier', 'Location', 'best');

        save_path = fullfile(save_dir, ['plot_multipath' '.fig']);
        savefig(fig, save_path);
    end
end
