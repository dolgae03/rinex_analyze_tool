function plot_cycle_slip_skyplot(dataset, start, duration, save_dir, frequency)
    global color_palette
    %% 기준 수신기 위치 설정 (사용자의 실제 좌표 사용)
    xyz_const = wgslla2xyz(37.566535, 127.0277194, 38);  % 필요한 경우 실제 좌표로 변경

    %% 변수 초기화
    % 대상 별자리 인덱스 설정 (예: [1, 3, 5])
    target_idx_list = find([1, 0, 0, 0, 0] == 1);
    sat_names = dataset.constellation_name(target_idx_list);
    time = dataset.time(start:start + duration);
    phase = dataset.ph1(start:start + duration,:);
    flag = dataset.cycleSlipFlag(start:start + duration,:);

    % 방위각과 고도각 데이터를 저장할 배열 초기화
    all_azimuth = {};
    all_elevation = {};

    cs_azimuth = {};
    cs_elevation = {};

    %% 각 별자리의 위성에 대한 방위각과 고도각 계산
    for idx = 1:length(target_idx_list)
        k = target_idx_list(idx);
        elevation_angles = [];
        azimuth_angles = [];


        c_ele_angle = [];
        c_azi_angle = [];


        sv_list = dataset.constellation_idx(k):dataset.constellation_idx(k + 1) - 1;
        

        for j = sv_list           

            for i = 1:length(time)
                is_valid = ~isnan(phase(i,j));
                is_slip = flag(i,j)>1;
                is_normal = is_valid & ~is_slip;
                
                sv_pos = squeeze(dataset.XS_tot1(start + i - 1, j, :));
%                 if any(isnan(sv_pos))
%                     continue;
%                 end
                [azimuth, elevation] = calculateElevationAzimuth(xyz_const, sv_pos);

                if elevation < 0
                    continue;
                end

                % 방위각과 고도각 저장
                if is_normal
                    elevation_angles = [elevation_angles; elevation];
                    azimuth_angles = [azimuth_angles; azimuth];
                end
                                
                if is_slip
                    c_ele_angle = [c_ele_angle; elevation];
                    c_azi_angle = [c_azi_angle; azimuth];
                end
            end

        end

        % 모든 데이터 합치기
        all_elevation{idx} = elevation_angles;
        all_azimuth{idx} = azimuth_angles;

        cs_elevation{idx} = c_ele_angle;
        cs_azimuth{idx} = c_azi_angle;
    end
    
    total_cs = numel(cs_elevation{1});
    high_cs = sum(cs_elevation{1}>30);
    fprintf("probability of high cs: %2.2fp\n", 100*high_cs/total_cs);

    % 색상 정의
    colors = color_palette ;


    sat_names = dataset.constellation_name(target_idx_list);
    for idx = 1:length(target_idx_list)
        % Figure 생성
        fig = figure(1516+idx);
        fig.Color = 'white';
        clf;
    
        p = polarscatter(deg2rad(all_azimuth{idx}), 90-all_elevation{idx}, 30, 'filled');
        set(gca, 'ThetaZeroLocation', 'top', 'ThetaDir', 'clockwise', 'RTick', [0 20 40 60 80]);

        theta_ticks = 0:30:330;
        theta_labels = string(theta_ticks)+char(176);
        theta_labels(theta_ticks == 0)   = "N";
        theta_labels(theta_ticks == 90)  = "E";
        theta_labels(theta_ticks == 180) = "S";
        theta_labels(theta_ticks == 270) = "W";
        radius_ticks = 0:20:80;
        radius_labels = string(flip(radius_ticks))+char(176);
   
        set(gca, 'ThetaTick', theta_ticks, 'ThetaTickLabel', theta_labels, ...
            'RTick', radius_ticks, 'RTickLabel', radius_labels);
        
        % 마커 색상 설정
        p.MarkerFaceColor = colors(idx,:);
        p.MarkerEdgeColor = colors(idx,:);
        p.MarkerFaceAlpha = 0.7;
        p.MarkerEdgeAlpha = 0.8;

        
        % Cycleslip
        if ~isempty(cs_azimuth{idx})
            hold on;
            p2 =polarscatter(deg2rad(cs_azimuth{idx}), 90-cs_elevation{idx},...
                30, 'rx', 'LineWidth', 2.0);
            
        end
        
        % title(['Skyplot - ', sat_names{idx}], 'Interpreter', 'none');
        set(gca, 'FontSize', 15);
    
    
        % 제목 설정
        % title(['Skyplot for Satellite ', sat_names{idx}], 'Interpreter', 'none');
    
        % 그림 저장
        save_path = fullfile(save_dir, ['Skyplot_cycleslip_', sat_names{idx}, '.fig']);
        savefig(fig, save_path);
        save_path = fullfile(save_dir, ['Skyplot_cycleslip_', sat_names{idx}, '.png']);
        saveas(fig, save_path);


        fig = figure();
        bin_edges = 0:2:90;
        histogram(cs_elevation{1}, bin_edges, 'Normalization','probability', 'FaceColor', colors(idx,:)); hold on; grid on;
        xlabel("Elevation (deg)");
        ylabel("P(Cycle Slips)");
        xlim([0, 90]); ylim([0, 0.25])
        set(gca, 'fontsize', 15);
        save_path = fullfile(save_dir, ['histogram_cycleslip_', sat_names{idx}, '.fig']);
        savefig(fig, save_path);
        save_path = fullfile(save_dir, ['histogram_', sat_names{idx}, '.png']);
        saveas(fig, save_path);



        %%

    end
end