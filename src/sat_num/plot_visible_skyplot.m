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

    %% 각 별자리의 위성에 대한 방위각과 고도각 계산
    for idx = 1:length(target_idx_list)
        k = target_idx_list(idx);
        elevation_angles = [];
        azimuth_angles = [];

        for j = dataset.constellation_idx(k):dataset.constellation_idx(k + 1) - 1
            for i = 1:length(time)
                sv_pos = squeeze(dataset.XS_tot1(start + i - 1, j, :));
                if any(isnan(sv_pos))
                    continue;
                end

                [azimuth, elevation] = calculateElevationAzimuth(xyz_const, sv_pos);

                if elevation < 0
                    continue;
                end

                % 방위각과 고도각 저장
                elevation_angles = [elevation_angles; elevation];
                azimuth_angles = [azimuth_angles; azimuth];
            end
        end

        % 모든 데이터 합치기
        all_elevation{idx} = elevation_angles;
        all_azimuth{idx} = azimuth_angles;
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
    
        % Skyplot 생성
        sph = skyplot(all_azimuth{idx}, all_elevation{idx});
        
        % 마커 속성 설정
        sph.MarkerSizeData = 30;  % 마커 크기 설정 (기본값: 100)
        sph.MarkerFaceColor = 'k';
        sph.MarkerEdgeColor = colors(idx,:);  % 마커 테두리 색상 (검정색)
        sph.MarkerEdgeAlpha = 0.8;  % 마커 테두리 투명도
        sph.MarkerFaceAlpha = 0.6;  % 마커 면 투명도
    
        % 글꼴 크기 설정
        sph.LabelFontSize = 14;
    
        % 제목 설정
        % title(['Skyplot for Satellite ', sat_names{idx}], 'Interpreter', 'none');
    
        % 그림 저장
        save_path = fullfile(save_dir, ['Skyplot_Satellite_', sat_names{idx}, '.fig']);
        savefig(fig, save_path);
        save_path = fullfile(save_dir, ['Skyplot_Satellite_', sat_names{idx}, '.png']);
        saveas(fig, save_path);
    end
end
