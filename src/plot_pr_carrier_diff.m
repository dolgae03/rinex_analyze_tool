function plot_pr_carrier_diff(dataset, start, duration, save_dir)
    % Ensure the save directory exists
    if ~exist(save_dir, 'dir')
        mkdir(save_dir);
    end

    % Time vector
    time = dataset.time; % Assuming dataset.time exists
    indices = start:start+duration;

    % Extract relevant data
    pr1 = dataset.pr1(indices, 4:4);
    pr3 = dataset.pr3(indices, 4:4);
    ph1 = dataset.ph1(indices, 4:4); % Carrier phase measurements for L1
    ph5 = dataset.ph3(indices, 4:4); % Carrier phase measurements for L5 (if available)

    % Constants
    c = 299792458; % Speed of light in m/s
    f_L1 = 1575.42e6; % L1 frequency in Hz
    f_L5 = 1176.45e6; % L5 frequency in Hz

    % Calculate wavelengths
    lambda_L1 = c / f_L1;
    lambda_L5 = c / f_L5;

    % Calculate differences
    pr1_diff = pr1 + ph1 * lambda_L1;
    pr3_diff = pr3 + ph5 * lambda_L5; % Assuming PR3 uses L5

    % Plot each case
    figure_names = {'PR1 vs PH1 (L1)' ,'PR3 vs PH5 (L5)'};
    pr_only = {pr1, pr3}
    carrier_only = {-ph1* lambda_L1, -ph5* lambda_L5};
    diffs = {pr1_diff, pr3_diff};
    
    for i = 1:2
        % Create figure with a unique number
        fig = figure(i + 15615);
        fig.Color = 'white';
    
        % Plot the difference (add unique data for clarity)
        plot(time(indices), diffs{i}, 'r', 'LineWidth', 1.5); % Plot in red
        hold on;
        plot(time(indices), pr_only{i}, 'b', 'LineWidth', 1.5); % Offset by +1 and plot in blue
        plot(time(indices), carrier_only{i}, 'g', 'LineWidth', 1.5); % Offset by -1 and plot in green
        hold off;
    
        % Add grid
        grid on;
    
        % Set labels, title, and limits
        xlabel('Time (s)');
        ylabel('Difference (m)');
        title([figure_names{i}, ' Difference']);
        xlim([start, start + duration]);
    
        % Add legend to distinguish plots
        legend('Diff', 'PR', 'Carrier', 'Location', 'best');
    end
end
