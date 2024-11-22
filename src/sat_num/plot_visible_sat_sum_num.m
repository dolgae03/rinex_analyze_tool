function plot_visable_sat_sum_num(dataset, start, duration, save_dir)
    %% Constellation별 가시 위성수 생성
    % 대상 별자리 인덱스 설정
    target_idx_list = find([1, 0, 1, 0, 1] == 1);
    num_targets = length(target_idx_list);
    visable_sat_mat = cell(1, num_targets);

    % 시간 벡터 생성
    time = dataset.time(start:start + duration);

    % 각 별자리의 가시 위성수 계산
    for idx = 1:num_targets
        i = target_idx_list(idx);

        if idx == 3
        end
        range = dataset.constellation_idx(i):dataset.constellation_idx(i + 1) - 1;
        visable_sat_mat{idx} = sum(~isnan(dataset.pr1(start:start + duration, range)), 2);
    end

    % 누적 합 계산
    cumulative_sat_mat = visable_sat_mat;
    for idx = 2:num_targets
        cumulative_sat_mat{idx} = cumulative_sat_mat{idx - 1} + visable_sat_mat{idx};
    end

    %% 그림 그리기
    fig = figure(324);
    clf;
    fig.Color = 'white'
    hold on;

    % 색상 정의
    colors = lines(5);
    colors = colors([1, 2, 5, 3, 5], :);

    % 범례를 위한 핸들 초기화
    p_stairs = gobjects(num_targets, 1);

    % 영역 채우기 및 선 그리기
    for idx = num_targets:-1:1  % 아래부터 채우기 위해 역순으로 반복
        x = [time./3600; flipud(time./3600)];  % x 좌표 생성
        y = [cumulative_sat_mat{idx}; zeros(size(cumulative_sat_mat{idx}))];  % y 좌표 생성

        % 영역 채우기
        fill(x, y, colors(idx, :), 'FaceAlpha', 0.3, 'EdgeColor', 'none');

        % 계단형 선 그리기
        p_stairs(idx) = stairs(time./3600, cumulative_sat_mat{idx}, ...
                               'Color', colors(idx, :), ...
                               'LineWidth', 1.5);
    end

    % 범례 설정
    lgd = legend(p_stairs, {'GPS', 'GAL+GPS', 'BDS+GPS+GAL'}, ...
                 'Location', 'northwest', 'Interpreter', 'latex');
    set(lgd, 'FontSize', 14, 'FontWeight', 'bold');

    % 축 레이블 및 제목 설정
    xlabel('Time (hours)', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('Cumulative # of Satellites', 'FontSize', 14, 'FontWeight', 'bold');

    % 축 한계 및 눈금 설정
    xlim([0, 21]);
    ylim([0, 42]);
    yticks(0:3:42);
    set(gca, 'FontSize', 14);

    grid on;

    % 그림 저장
    fig_file_pos_path = fullfile(save_dir, 'result_sat_sum_num.fig');
    savefig(fig, fig_file_pos_path);

    fig_file_pos_path = fullfile(save_dir, 'result_sat_sum_num.png');
    saveas(fig, fig_file_pos_path);
end
