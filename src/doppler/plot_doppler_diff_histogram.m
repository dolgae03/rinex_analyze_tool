function plot_doppler_diff_histogram(dataset, dataset_rcv, start, duration, save_dir)
    
global color_palette
colors = color_palette;
%%% Define frequencies for each constellation
%     target_idx_list = find([1,0,1,0,1] == 1);
    frequencies = [1575.42e6, 1575.42e6, 1561.098e6]; % Example for GPS L1, GLONASS L1, Galileo E1
    target_idx_list = find([1,0,0,0,0] == 1);

    %% Doppler와 Pseudorange 데이터 추출
    time = dataset.time(start:start + duration);

    target_dop = [];
    target_pr = [];
    c = 299792458; % Speed of light (m/s)

        % Plot scatter
    fig = figure(900);
    clf;
    fig.Color = "white";
    sat_names = dataset.constellation_name(target_idx_list);

    % REF sv 선정
    is_valid_base = ~isnan(dataset_rcv.ph1(start:start+duration,:));
    is_valid_rover = ~isnan(dataset.ph1(start:start+duration,:));
    common_sv_mask = any(is_valid_base & is_valid_rover, 1);
    sv_indices = find(common_sv_mask);
    ref_sv = sv_indices(1);  % 기준 위성은 자동 선택
    target_dop_ref = dataset.dop1(start:start+duration, ref_sv)/ frequencies(1) * c ;
    rcv_dop_ref = -dataset_rcv.dop1(start:start+duration, ref_sv)/ frequencies(1) * c ;
    diff_dop_ref = target_dop_ref - rcv_dop_ref;


    for idx = 1:length(target_idx_list)
        range = dataset.constellation_idx(target_idx_list(idx)):dataset.constellation_idx(target_idx_list(idx)+1)-1;

        
        target_dop = dataset.dop1(start:start+duration, range)/ frequencies(idx) * c ;
        rcv_dop = -dataset_rcv.dop1(start:start+duration, range)/ frequencies(idx) * c ;

%         target_dop = diff(dataset.pr1(start:start+duration, range));
%         rcv_dop = diff(dataset_rcv.pr1(start:start+duration, range)) ;
%         time = time(1: end-1);


        diff_dop = target_dop - rcv_dop;

        %% DD
        clf;
        diff_dop_dd= diff_dop - diff_dop_ref;
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

        save_path = fullfile(save_dir, ['DD_doppler_rcv_diff_hitogram', sat_names{idx}, '.fig']);
        savefig(fig, save_path);
        save_path = fullfile(save_dir, ['DD_doppler_rcv_diff_hitogram', sat_names{idx}, '.png']);
        saveas(fig, save_path);

    end
end
