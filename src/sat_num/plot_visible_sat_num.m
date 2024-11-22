function plot_visable_sat_num(dataset, start, duration, save_dir)
    %% Constellation 별 가시 위성수 생성
    target_idx_list = find([1, 0, 1, 0, 1] == 1);
    visable_sat_mat = {};

    for i = 1:length(target_idx_list)
        range = dataset.constellation_idx(target_idx_list(i)):dataset.constellation_idx(target_idx_list(i)+1) - 1;
        visable_sat_mat{i} = sum(~isnan(dataset.pr1(start:start + duration, range)), 2)';
    end

    time = dataset.time(start:start + duration);

    %% 그림 그리기 
    fig = figure(6); 
    clf;
    fig.Color = "white";

    fig.Name = save_dir;  % Set the figure window title to save_dir
    fig.NumberTitle = 'off';  % Turn off the default figure numbering
    hold on;

    colors = lines(5);
    colors = colors([1, 2, 5, 3, 5], :);

    % Stairs plot
    p_stairs = gobjects(1, length(visable_sat_mat)); % 핸들 배열 초기화
    for i = 1:length(visable_sat_mat)
        p_stairs(i) = stairs(time ./ 3600, visable_sat_mat{i}, ...
                             'Color', colors(i, :), ...
                             'LineWidth', 1); % 기본 선 굵기
        hold on;
    end

    % 범례를 위한 Plot 핸들 생성
    p_cov_sat = gobjects(1, length(target_idx_list)); % 핸들 배열 초기화
    for i = 1:length(target_idx_list)
        p_cov_sat(i) = plot(nan, nan, ...
                            'Color', colors(i, :), ...
                            'LineWidth', 2); % 굵은 선을 범례에 사용
        hold on;
    end

    % 동적으로 생성된 legend 적용 및 위치 설정, LaTeX 해석을 사용
    lgd = legend(p_cov_sat, dataset.constellation_name(target_idx_list), ...
                 'Location', 'northwest', 'Interpreter', 'latex'); % 범례에 LaTeX 적용
    set(lgd, 'FontSize', 14, 'FontWeight', 'bold'); % 범례 글꼴 크기와 두께 설정

    % 축과 라벨의 글꼴 크기 및 두께 설정
    set(gca, 'FontSize', 14); % 축 글꼴 크기 및 두께 설정
    xlabel('Time (hours)', 'FontSize', 14, 'FontWeight', 'bold'); % X축 라벨 글꼴 크기 및 두께 설정
    ylabel('# of Satellite', 'FontSize', 14, 'FontWeight', 'bold'); % Y축 라벨 글꼴 크기 및 두께 설정

    xlim([0, 21]);
    ylim([0, 24]);
    grid on;

    ax = gca; % Get current axes
    ax.YTick = 0:2:24; % Set y-axis ticks with interval 1

    % Save figure
    fig_file_pos_path = fullfile(save_dir, sprintf('result_sat_num.fig'));
    savefig(fig, fig_file_pos_path);

    fig_file_pos_path = fullfile(save_dir, sprintf('result_sat_num.png'));
    saveas(fig, fig_file_pos_path);
end
