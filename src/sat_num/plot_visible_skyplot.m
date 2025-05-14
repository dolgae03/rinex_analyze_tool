function plot_visible_skyplot(dataset, start, duration, save_dir)
    global color_palette
    colors = color_palette;    

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
        
          % constellation 내 위성 인덱스 범위
        start_idx = dataset.constellation_idx(k);
        end_idx = dataset.constellation_idx(k+1) - 1;

        for j = start_idx:end_idx
            % 위성 j에 대한 가시성 여부
            pr1 = dataset.pr1(start:start+duration, j);
            visibility = ~isnan(pr1);

            % 전체 가시 구간 데이터 수집
            for i = 1:length(time)
                if visibility(i)
                    sv_pos = squeeze(dataset.XS_tot1(start + i - 1, j, :));
                    [az, el] = calculateElevationAzimuth(xyz_const, sv_pos);
                    if el >= 0
                        azimuth_angles = [azimuth_angles; az];
                        elevation_angles = [elevation_angles; el];
                    end
                end
            end

            % 트래킹 단절 구간 탐지
            changes = diff([0; visibility; 0]);
            start_vis = find(changes == 1);
            end_vis = find(changes == -1) - 1;

            for v = 2:length(start_vis)
                % 끊기기 직전
                t1 = end_vis(v - 1);
                sv1 = squeeze(dataset.XS_tot1(start + t1 - 1, j, :));
                [az1, el1] = calculateElevationAzimuth(xyz_const, sv1);
                if el1 >= 0
                    c_azi_angle = [c_azi_angle; az1];
                    c_ele_angle = [c_ele_angle; el1];
                end

                % 재관측 시작
                t2 = start_vis(v);
                sv2 = squeeze(dataset.XS_tot1(start + t2 - 1, j, :));
                [az2, el2] = calculateElevationAzimuth(xyz_const, sv2);
                if el2 >= 0
                    c_azi_angle = [c_azi_angle; az2];
                    c_ele_angle = [c_ele_angle; el2];
                end
            end
        end

        % 모든 데이터 합치기
        all_elevation{idx} = elevation_angles;
        all_azimuth{idx} = azimuth_angles;

        close_elevation{idx} = c_ele_angle;
        close_azimuth{idx} = c_azi_angle;
    end



    sat_names = dataset.constellation_name(target_idx_list);
    for idx = 1:length(target_idx_list)
        % Figure 생성
        fig = figure(1516+idx);
        fig.Color = 'white';
        clf;
    
        p = polarscatter(deg2rad(all_azimuth{idx}), 90-all_elevation{idx}, 15, 'filled');
        set(gca, 'ThetaZeroLocation', 'top', 'ThetaDir', 'counterclockwise', 'RTick', [0 30 60 90]);

        theta_ticks = 0:30:330;
        theta_labels = string(theta_ticks)+char(176);
        theta_labels(theta_ticks == 0)   = "N";
        theta_labels(theta_ticks == 90)  = "E";
        theta_labels(theta_ticks == 180) = "S";
        theta_labels(theta_ticks == 270) = "W";
        radius_ticks = 0:30:90;
        radius_labels = string(flip(radius_ticks))+char(176);
   
        set(gca, 'ThetaTick', theta_ticks, 'ThetaTickLabel', theta_labels, ...
            'RTick', radius_ticks, 'RTickLabel', radius_labels);
        
        % 마커 색상 설정
        p.MarkerFaceColor = colors(idx,:);
        p.MarkerEdgeColor = colors(idx,:);
        p.MarkerFaceAlpha = 0.7;
        p.MarkerEdgeAlpha = 0.8;

        
        % 재관측 지점 강조
        if ~isempty(close_azimuth{idx})
            hold on;
            p2 =polarscatter(deg2rad(close_azimuth{idx}), 90-close_elevation{idx},...
                40, 'x', 'LineWidth', 1.8, 'MarkerEdgeColor', 'k');
            
        end
        
        % title(['Skyplot - ', sat_names{idx}], 'Interpreter', 'none');
        set(gca, 'FontSize', 18);
    
    
        % 제목 설정
        % title(['Skyplot for Satellite ', sat_names{idx}], 'Interpreter', 'none');
    
        % 그림 저장
        save_path = fullfile(save_dir, ['Skyplot_Satellite_', sat_names{idx}, '.fig']);
        savefig(fig, save_path);
        save_path = fullfile(save_dir, ['Skyplot_Satellite_', sat_names{idx}, '.png']);
        saveas(fig, save_path);
    end
end
