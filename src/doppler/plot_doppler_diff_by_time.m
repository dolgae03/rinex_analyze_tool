function plot_doppler_diff_by_time(dataset, dataset_rcv, start, duration, save_dir)
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
        colors = lines();
        range = dataset.constellation_idx(target_idx_list(idx)):dataset.constellation_idx(target_idx_list(idx)+1)-1;

        
        target_dop = dataset.dop1(start:start+duration, range)/ frequencies(idx) * c ;
        rcv_dop = -dataset_rcv.dop1(start:start+duration, range)/ frequencies(idx) * c ;

%         target_dop = diff(dataset.pr1(start:start+duration, range));
%         rcv_dop = diff(dataset_rcv.pr1(start:start+duration, range)) ;
%         time = time(1: end-1);


        diff_dop = target_dop - rcv_dop;

       
        
     %% SD
        % Flatten data for scatter plot
        fig1 = figure; clf; fig1.Color = "white";
        scatter(time ./3600, diff_dop, 10, 'filled');
        hold on;
        xlim([0, max(time./3600)]);
%         ylim([0, 100]);

        xlabel('Time (hours)', 'FontWeight', 'bold');
        ylabel('Single Differenced Doppler (m/s)', 'FontWeight', 'bold');
        grid on;
        set(gca, 'FontSize', 15); % 축 글꼴 크기 및 두께 설정

        save_path = fullfile(save_dir, ['SD_doppler_rcv_diff_time_', sat_names{idx}, '.fig']);
        savefig(fig1, save_path);
        save_path = fullfile(save_dir, ['SD_doppler_rcv_diff_time_', sat_names{idx}, '.png']);
        saveas(fig1, save_path);

        %% DD
         diff_dop_dd= diff_dop - diff_dop_ref;
        fig2 = figure; clf; fig2.Color = "white";
        scatter(time ./3600, diff_dop_dd, 10, 'filled');
        hold on;
        xlim([0, max(time./3600)]);
%         ylim([0, 100]);

        xlabel('Time (hours)', 'FontWeight', 'bold');
        ylabel('Double Differenced Doppler (m/s)', 'FontWeight', 'bold');
        grid on;
        set(gca, 'FontSize', 15); % 축 글꼴 크기 및 두께 설정

        save_path = fullfile(save_dir, ['DD_doppler_rcv_diff_time_', sat_names{idx}, '.fig']);
        savefig(fig2, save_path);
        save_path = fullfile(save_dir, ['DD_doppler_rcv_diff_time_', sat_names{idx}, '.png']);
        saveas(fig2, save_path);

    end
end
