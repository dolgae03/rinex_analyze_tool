function plot_snr_elevation_skyplot(dataset, start, duration, save_dir)
    %% Reference 위치 추정 
    % calculation_idx = find(~isnan(dataset.pr3(start, :)));
    % l5_signal = dataset.pr3(start, calculation_idx)';
    % result = squeeze(dataset.XS_tot1(start, calculation_idx, :));
    % 
    % meas = [l5_signal, result];
    % [xyz, b] = GNSS_LS(meas, length(result), [0, 0, 0]);
    
    xyz_const = wgslla2xyz(37.566535, 127.0277194, 38);

    %% 모든 시간대에 대한 가시 위성수 생성

    target_val = dataset.snr1;

    target_idx_list = find([1,0,1,0,1] == 1);
    sat_names = dataset.constellation_name(target_idx_list);
    
    for k = 1:length(target_idx_list)
        angles = []; % 각도를 라디안으로 변환
        radii = [];  % 반전된 거리 값
        values = [];  % 0에서 50까지의 C/N0 값 (색상으로 표현)
        
        for i = start:start+duration
            for j = dataset.constellation_idx(target_idx_list(k)):dataset.constellation_idx(target_idx_list(k)+1)-1
                
                sv_pos = squeeze(dataset.XS_tot1(i, j, :));
    
                if isnan(target_val(i, j)) || any(isnan(sv_pos))
                    continue
                end
               
                [azimuth, elevation] = calculateElevationAzimuth(xyz_const, sv_pos);
                
                if elevation < 0
                    continue;
                end
    
                angles(end+1) = deg2rad(azimuth + 90);  % 라디안으로 변환
                radii(end+1) = 90 - elevation;  % 반전된 거리 값
                values(end+1) = target_val(i, j);
            end
        end

        %% Plot 수행
        fig = figure(555+k);
        clf;
        fig.Color = 'white';
        polarplot(angles, radii, 'o');
        hold on;
        
        % 컬러맵 및 색상 설정
        colormap(jet);
        caxis([30, 56]);  % C/N0 값의 범위 설정
        scatter_colors = values;  
        polarscatter(angles, radii, 100, scatter_colors, 'filled');
        
        % 색상 바 추가
        colorbar;
        ylabel(colorbar, 'C/N0 (dB-Hz)');  % 색상 바 라벨 설정
        
        % 반경 레이블 반전 설정
        rlim([0, 90]);  % 거리(r)의 범위 설정
        rticks([0, 30, 60, 90]);  % 원하는 위치에 레이블 추가
        rticklabels({'90', '60', '30', '0'});  % 반전된 레이블 설정
    
        % 각도 범위 설정 및 타이틀 추가
        thetalim([0, 360]);  % 각도(θ)의 범위 설정
    
        % 각도 설정
        thetalim([0, 360]);  % 각도(θ)의 범위 설정
        thetaticklabels({'E', '300', '330', ...
                         'N','30', '60', ...
                         'W', '120', '150', ...
                         'S', '210', '240'});  % 각도를 N, E, S, W로 표시

        set(gca, 'FontSize', 14);
    
        % title([sat_names{k}, ' SNR Polar Plot']);
    
        save_path = fullfile(save_dir, ['plot_skyplot_snr_', sat_names{k}, '.fig']);
        savefig(fig, save_path);

        save_path = fullfile(save_dir, ['plot_skyplot_snr_', sat_names{k}, '.png']);
        saveas(fig, save_path);
    end




        %% Reference 위치 추정 
    % calculation_idx = find(~isnan(dataset.pr3(start, :)));
    % l5_signal = dataset.pr3(start, calculation_idx)';
    % result = squeeze(dataset.XS_tot1(start, calculation_idx, :));
    % 
    % meas = [l5_signal, result];
    % [xyz, b] = GNSS_LS(meas, length(result), [0, 0, 0]);
    
    xyz_const = wgslla2xyz(37.566535, 127.0277194, 38);

    %% 모든 시간대에 대한 가시 위성수 생성

    target_val = dataset.snr3;

    target_idx_list = find([1,0,1,0,1] == 1);
    sat_names = dataset.constellation_name(target_idx_list);
    
    for k = 1:length(target_idx_list)
        angles = []; % 각도를 라디안으로 변환
        radii = [];  % 반전된 거리 값
        values = [];  % 0에서 50까지의 C/N0 값 (색상으로 표현)
        
        for i = start:start+duration
            for j = dataset.constellation_idx(target_idx_list(k)):dataset.constellation_idx(target_idx_list(k)+1)-1
                
                sv_pos = squeeze(dataset.XS_tot1(i, j, :));
    
                if isnan(target_val(i, j)) || any(isnan(sv_pos))
                    continue
                end
               
                [azimuth, elevation] = calculateElevationAzimuth(xyz_const, sv_pos);
                
                if elevation < 0
                    continue;
                end
    
                angles(end+1) = deg2rad(azimuth + 90);  % 라디안으로 변환
                radii(end+1) = 90 - elevation;  % 반전된 거리 값
                values(end+1) = target_val(i, j);
            end
        end

        %% Plot 수행
        fig = figure(555+k);
        clf;
        fig.Color = 'white';
        polarplot(angles, radii, 'o');
        hold on;
        
        % 컬러맵 및 색상 설정
        colormap(jet);
        caxis([30, 56]);  % C/N0 값의 범위 설정
        scatter_colors = values;  
        polarscatter(angles, radii, 100, scatter_colors, 'filled');
        
        % 색상 바 추가
        colorbar;
        ylabel(colorbar, 'C/N0 (dB-Hz)');  % 색상 바 라벨 설정
        
        % 반경 레이블 반전 설정
        rlim([0, 90]);  % 거리(r)의 범위 설정
        rticks([0, 30, 60, 90]);  % 원하는 위치에 레이블 추가
        rticklabels({'90', '60', '30', '0'});  % 반전된 레이블 설정
    
        % 각도 범위 설정 및 타이틀 추가
        thetalim([0, 360]);  % 각도(θ)의 범위 설정
    
        % 각도 설정
        thetalim([0, 360]);  % 각도(θ)의 범위 설정
        thetaticklabels({'E', '300', '330', ...
                         'N','30', '60', ...
                         'W', '120', '150', ...
                         'S', '210', '240'});  % 각도를 N, E, S, W로 표시

        set(gca, 'FontSize', 14);
    
        % title([sat_names{k}, ' SNR Polar Plot']);
    
        save_path = fullfile(save_dir, ['plot_skyplot_snr3_L5_', sat_names{k}, '.fig']);
        savefig(fig, save_path);

        save_path = fullfile(save_dir, ['plot_skyplot_snr3_L5_', sat_names{k}, '.png']);
        saveas(fig, save_path);
    end
end