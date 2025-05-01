function plot_visible_skyplot(dataset, start, duration, save_dir)
    %% 기준 수신기 위치 설정 (사용자의 실제 좌표 사용)
    xyz_const = wgslla2xyz(37.566535, 127.0277194, 38);  % 필요한 경우 실제 좌표로 변경

    %% 변수 초기화
    % 대상 별자리 인덱스 설정 (예: [1, 3, 5])
    target_idx_list = find([1, 0, 1, 0, 1] == 1);
    sat_names = dataset.constellation_name(target_idx_list);
    time = dataset.time(start:start + duration);

    % 방위각과 고도각 데이터를 저장할 배열 초기화
    all_azimuth = {};
    all_elevation = {};

    close_azimuth = {};
    close_elevation = {};

    %% 각 별자리의 위성에 대한 방위각과 고도각 계산
    for idx = 1:length(target_idx_list)
        k = target_idx_list(idx);
        elevation_angles = [];
        azimuth_angles = [];

        c_ele_angle = [];
        c_azi_angle = [];

        for j = dataset.constellation_idx(k):dataset.constellation_idx(k + 1) - 1
            is_close = false;
            is_first = true;

            for i = 1:length(time)
                sv_pos = squeeze(dataset.XS_tot1(start + i - 1, j, :));
                if any(isnan(sv_pos))
                    if ~isempty(elevation_angles) && ~is_first
                        c_ele_angle = [c_ele_angle; elevation_angles(end, :)];
                        c_azi_angle = [c_azi_angle; azimuth_angles(end, :)];
                        is_close = true;
                    end
                    continue;
                end
                [azimuth, elevation] = calculateElevationAzimuth(xyz_const, sv_pos);

                if elevation < 0
                    continue;
                end

                % 방위각과 고도각 저장
                elevation_angles = [elevation_angles; elevation];
                azimuth_angles = [azimuth_angles; azimuth];
                is_first = false;
                
                if is_close
                    c_ele_angle = [c_ele_angle; elevation_angles(end, :)];
                    c_azi_angle = [c_azi_angle; azimuth_angles(end, :)];
                    is_close = false;
                end
            end
        end

        % 모든 데이터 합치기
        all_elevation{idx} = elevation_angles;
        all_azimuth{idx} = azimuth_angles;

        close_elevation{idx} = c_ele_angle;
        close_azimuth{idx} = c_azi_angle;
    end

    % 색상 정의
    colors = lines(5);
    colors = colors([1, 2, 5, 3, 5], :);


    sat_names = dataset.constellation_name(target_idx_list);
    for idx = 1:length(target_idx_list)
        % Figure 생성
        fig = figure(1516+idx);
        fig.Color = 'white';
        clf;
    
        p = polarscatter(deg2rad(all_azimuth{idx}), ...
                         90 - all_elevation{idx}, ...
                         20, 'filled');
        
        % 마커 색상 설정
        p.MarkerFaceColor = colors(idx,:);
        p.MarkerEdgeColor = colors(idx,:);
        p.MarkerFaceAlpha = 0.7;
        p.MarkerEdgeAlpha = 0.8;
        
        % 반지름(고도) 설정
        rlim([0, 90]);
        rticks([0, 30, 60, 90]);
        rticklabels({'90', '60', '30', '0'});
        
        % 방위각(azimuth) 레이블
        thetaticks(0:30:330);
        thetaticklabels({'E', '30', '60', ...
                         'N', '120', '150', ...
                         'W', '210', '240', ...
                         'S', '300', '330'});
        
        % 재관측 지점 강조
        if ~isempty(close_azimuth{idx})
            hold on;
            polarscatter(deg2rad(close_azimuth{idx}), ...
                         90 - close_elevation{idx}, ...
                         40, 'x', 'LineWidth', 1.8, 'MarkerEdgeColor', 'k');
        end
        
        % title(['Skyplot - ', sat_names{idx}], 'Interpreter', 'none');
        set(gca, 'FontSize', 13);
    
    
        % 제목 설정
        % title(['Skyplot for Satellite ', sat_names{idx}], 'Interpreter', 'none');
    
        % 그림 저장
        save_path = fullfile(save_dir, ['Skyplot_Satellite_', sat_names{idx}, '.fig']);
        savefig(fig, save_path);
        save_path = fullfile(save_dir, ['Skyplot_Satellite_', sat_names{idx}, '.png']);
        saveas(fig, save_path);
    end
end
