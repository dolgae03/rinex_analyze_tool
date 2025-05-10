function plot_doppler_diff_by_el(dataset, dataset_rcv, start, duration, save_dir)
    %%% Define frequencies for each constellation
    xyz_const = wgslla2xyz(37.566535, 127.0277194, 38);
    target_idx_list = find([1,0,0,0,0] == 1);
    frequencies = [1575.42e6, 1575.42e6, 1561.098e6]; % Example for GPS L1, GLONASS L1, Galileo E1

    %% Doppler와 Pseudorange 데이터 추출

    c = 299792458; % Speed of light (m/s)
    target_val = dataset.dop1;

        % Plot scatter
    fig1 = figure(900);
    clf;
    fig1.Color = "white";
    sat_names = dataset.constellation_name(target_idx_list);
    plot_elevation = cell(length(target_idx_list), 200);
    plot_dop_diff = cell(length(target_idx_list), 200);
    plot_dop_diff_dd = cell(length(target_idx_list), 200);

    

    for k = 1:length(target_idx_list)
        % REF sv 선정
        sv_list = dataset.constellation_idx(target_idx_list(k)):dataset.constellation_idx(target_idx_list(k)+1)-1;
        is_valid_base = ~isnan(dataset_rcv.ph1(start:start+duration, sv_list));
        is_valid_rover = ~isnan(dataset.ph1(start:start+duration, sv_list));
        common_sv_mask = any(is_valid_base & is_valid_rover, 1);
        sv_indices = find(common_sv_mask);
        ref_sv = sv_indices(1);  % 기준 위성은 자동 선택

        target_dop_ref = dataset.dop1(:, ref_sv)/ frequencies(1) * c ;
        rcv_dop_ref = -dataset_rcv.dop1(:, ref_sv)/ frequencies(1) * c ;
        diff_dop_ref = target_dop_ref - rcv_dop_ref;

        
        for j = sv_list
            for i = start:start+duration
                sv_pos = squeeze(dataset.XS_tot1(i, j, :));
                if isnan(target_val(i, j)) || any(isnan(sv_pos))
                    continue
                end

                [azimuth, elevation] = calculateElevationAzimuth(xyz_const, sv_pos);
                plot_elevation{k,j}(end+1) = elevation;
                dop = dataset.dop1(i,j)/frequencies(k) * c;
                dop_rcv = -dataset_rcv.dop1(i,j)/frequencies(k) * c;
                diff_dop = dop - dop_rcv;
                plot_dop_diff{k,j}(end+1) = diff_dop;
                plot_dop_diff_dd{k,j}(end+1) = diff_dop - diff_dop_ref(i);
                
                
            end
            

        end
    end
   
    %% Plot 수행
    for i=1:length(target_idx_list)
        %% SD
        % Create a new figure for each satellite
        fig1 = figure(i+350044);
        clf;
        fig1.Color = 'white';
        
        new_colors = lines();
        % Plot SNR over time for the current satellite
        for j=1:200
            scatter(plot_elevation{i, j}, abs(plot_dop_diff{i, j}), 3, 'filled', 'MarkerFaceColor',new_colors(j, :)); % Size=15, color=blue
            hold on;
        end
        xlabel('Elevation (degree)', 'FontSize', 14, 'FontWeight', 'bold');
        ylabel('Single Differenced Doppler (m/s)', 'FontSize', 14, 'FontWeight', 'bold');
        set(gca, 'FontSize', 14); % 축 글꼴 크기 및 두께 설정
        xlim([0, 90]);
%         ylim([0, 100]);
        grid on;
       
        % Save scatter plot
        save_path = fullfile(save_dir, ['SD_doppler_rcv_diff_el_', sat_names{i}, '.fig']);
        savefig(fig1, save_path);
        save_path = fullfile(save_dir, ['SD_doppler_rcv_diff_el_', sat_names{i}, '.png']);
        saveas(fig1, save_path);
        %% DD

        fig2 = figure(i+350055);
        clf;
        fig2.Color = 'white';
        
        new_colors = lines();
        % Plot SNR over time for the current satellite
        for j=1:200
            scatter(plot_elevation{i, j}, abs(plot_dop_diff_dd{i, j}), 3, 'filled', 'MarkerFaceColor',new_colors(j, :)); % Size=15, color=blue
            hold on;
        end
        xlabel('Elevation (degree)', 'FontSize', 14, 'FontWeight', 'bold');
        ylabel('Double Differenced Doppler (m/s)', 'FontSize', 14, 'FontWeight', 'bold');
        set(gca, 'FontSize', 14); % 축 글꼴 크기 및 두께 설정
        xlim([0, 90]);
%         ylim([0, 100]);
        grid on;
       
        % Save scatter plot
        save_path = fullfile(save_dir, ['DD_doppler_rcv_diff_el_', sat_names{i}, '.fig']);
        savefig(fig2, save_path);
        save_path = fullfile(save_dir, ['DD_doppler_rcv_diff_el_', sat_names{i}, '.png']);
        saveas(fig2, save_path);
    end

end
