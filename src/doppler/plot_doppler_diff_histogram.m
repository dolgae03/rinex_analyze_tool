function plot_doppler_diff_histogram(rover, base, start, duration, save_dir)
    
global color_palette
colors = color_palette;
%%% Define frequencies for each constellation
%     target_idx_list = find([1,0,1,0,1] == 1);
    frequencies_base = [1575.42e6, 1575.42e6, 1561.098e6]; % Example for GPS L1, GLONASS L1, Galileo E1
    frequencies_rover = [1575.42e6, 1575.42e6, 1575.42e6]; % Example for GPS L1, GLONASS L1, Galileo E1
    target_idx_list = find([1,0,1,0,1] == 1);

    %% Doppler와 Pseudorange 데이터 추출
    time = rover.time(start:start + duration);

    rover_dop = [];
    target_pr = [];
    c = 299792458; % Speed of light (m/s)

        % Plot scatter
    fig = figure(900);
    clf;
    fig.Color = "white";
    sat_names = rover.constellation_name(target_idx_list);

    % REF sv 선정
   
    


    for idx = 1:length(target_idx_list)
        range = rover.constellation_idx(target_idx_list(idx)):rover.constellation_idx(target_idx_list(idx)+1)-1;


        rover_dop = rover.dop1(start:start+duration, range)/ frequencies_rover(idx) * c ;
        base_dop = -base.dop1(start:start+duration, range)/ frequencies_base(idx) * c ;
        
        is_valid_base = ~isnan(base_dop);
        is_valid_rover = ~isnan( rover_dop);
        common_sv_mask = any(is_valid_base & is_valid_rover, 1);
        common_sv_indices = find(common_sv_mask);
        ref_sv = common_sv_indices(1);  % 기준 위성은 자동 선택

        rover_dop_ref = rover_dop(:, ref_sv) ;
        base_dop_ref = base_dop(:, ref_sv);
        diff_dop_ref = rover_dop_ref - base_dop_ref;


        diff_dop = rover_dop - base_dop;

        %% DD
        clf;
        diff_dop_dd= diff_dop - diff_dop_ref;
        diff_dop_dd(:,ref_sv) = nan;


        bin_edges = -0.2:0.01:0.2;
        std_dop = std(diff_dop_dd, 0, "all", "omitnan");
        str_dop = sprintf("\\sigma: %.3f m/s", std_dop );
        histogram(diff_dop_dd, bin_edges,'Normalization','probability', ...
            'FaceColor', colors(idx,:),'DisplayName', str_dop);
         hold on;       
        
        xlabel('Double Differenced Doppler (m/s)', 'FontWeight', 'bold');
        ylabel('probability'); 
        legend;
        grid on;
        set(gca, 'FontSize', 15); % 축 글꼴 크기 및 두께 설정
% 
        save_path = fullfile(save_dir, ['DD_doppler_base_diff_hitogram', sat_names{idx}, '.fig']);
        savefig(fig, save_path);
        save_path = fullfile(save_dir, ['DD_doppler_base_diff_hitogram', sat_names{idx}, '.png']);
        saveas(fig, save_path);

    end
end
