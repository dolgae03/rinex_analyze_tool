function plot_visible_prn(dataset, start, duration, save_dir)
    %% 기준 수신기 위치 설정 (사용자의 실제 좌표 사용)
    xyz_const = wgslla2xyz(37.566535, 127.0277194, 38);  % 필요한 경우 실제 좌표로 변경

    %% 변수 초기화
    % 대상 별자리 인덱스 설정 (예: [1, 3, 5])
    target_idx_list = find([1, 0, 1, 0, 1] == 1);
    max_prn_num = [36,40,64];
    sat_names = dataset.constellation_name(target_idx_list);
    time = dataset.time(start:start + duration);
    target_val = dataset.pr1;

    % 색상 정의
    colors = lines(5);
    colors = colors([1, 2, 5, 3, 5], :);

    %% 각 별자리의 위성에 대한 가시성 계산 및 플롯
    for idx = 1:length(target_idx_list)
        constellation = target_idx_list(idx);
        fig = figure(1520 + idx);
        fig.Color = 'white';
        clf;
        hold on;

        % 현재 별자리의 위성 인덱스 가져오기
        start_idx = dataset.constellation_idx(constellation);
        end_idx = dataset.constellation_idx(constellation + 1) - 1;
        sat_indices = start_idx:end_idx;
        num_sats = length(sat_indices);

        % 가시성 매트릭스 초기화
        visibility = ~isnan(target_val(start:start + duration, sat_indices));

        % 각 위성의 가시성 기간 플롯
        for s = 1:num_sats
            sat_vis = visibility(:, s);
            changes = diff([0; sat_vis; 0]);
            start_vis = find(changes == 1);
            end_vis = find(changes == -1) - 1;

            for v = 1:length(start_vis)
                vis_start = start_vis(v);
                vis_end = end_vis(v);
                % 가시성 구간 플롯
                plot(time(vis_start:vis_end)./3600, repmat(s, vis_end - vis_start + 1, 1), ...
                     'LineWidth', 1.5, 'Color', colors(idx, :));
                % 가시성 시작/끝에 마커 추가
                if v > 1 && v < length(start_vis)
                    plot(time(vis_start)./3600, s, 'o', 'Color', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', 4);
                    plot(time(vis_end)./3600, s, 'o', 'Color', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', 4);
                end
            end
        end

        % 축 레이블 및 제목 설정
        xlabel('Time (hours)', 'FontSize', 14, 'FontWeight', 'bold');
        ylabel('PRN', 'FontSize', 14, 'FontWeight', 'bold');

        % 축 한계 및 눈금 설정
        xlim([0,21]);
        ylim([0, max_prn_num(idx)]);
        yticks(0:4:max_prn_num(idx));
        set(gca, 'FontSize', 14);

        hold off;

        % 그림 저장 (필요한 경우)
        if nargin == 4 && ~isempty(save_dir)
            savefig(fig, fullfile(save_dir, ['prn_visible_' sat_names{idx} '.fig']));
            saveas(fig, fullfile(save_dir, ['prn_visible_' sat_names{idx} '.png']));
        end
    end
end
