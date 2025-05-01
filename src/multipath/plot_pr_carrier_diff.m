function plot_pr_carrier_diff(dataset, start, duration, save_dir, frequency)
    % Ensure the save directory exists
    if ~exist(save_dir, 'dir')
        mkdir(save_dir);
    end

    % Time vector
    time = dataset.time; % Assuming dataset.time exists
    indices = start:start+duration;

    if frequency == 1
        target_val = dataset.mp1;
    elseif frequency == 5
        target_val = dataset.mp5;
    end

    sv_nan_counts = sum(isnan(target_val(indices, :)), 1);
    [~, target_sv] = min(sv_nan_counts);  % satellite with most valid data

    target_val = target_val(:, target_sv);

    % Create figure with a unique number
    fig = figure(15615);
    fig.Color = 'white';

    % Plot the difference (add unique data for clarity)
    plot(time(indices), target_val(indices), 'r', 'LineWidth', 1.5); % Plot in red
    hold on;
    % plot(time(indices), pr_only{i}, 'b', 'LineWidth', 1.5); % Offset by +1 and plot in blue
    % plot(time(indices), carrier_only{i}, 'g', 'LineWidth', 1.5); % Offset by -1 and plot in green
    hold off;

    % Add grid
    grid on;

    % Set labels, title, and limits
    xlabel('Time (s)');
    ylabel('Difference (m)');
    title('Code Carrier Difference');
    xlim([start, start + duration]);

    % Add legend to distinguish plots
    legend('Diff', 'Location', 'best');

    file_base = sprintf('multipath_sample_%d', frequency);
    
    savefig(fig, fullfile(save_dir, [file_base, '.fig']));
    saveas(fig, fullfile(save_dir, [file_base, '.png']));
end
