function plot_multipath(dataset, start, duration, save_dir)
    [homedir, mfile, ext]=fileparts(mfilename('fullpath'));
    addpath('./multipath/');
    addpath('./multipath/sources');
    addpath('./multipath/utility');

    for i=1:32
        t = find(~isnan(dataset.pr1(start: start+duration, i)) & ~isnan(dataset.pr3(start: start+duration, i)) ...
                & ~isnan(dataset.ph1(start: start+duration, i)) & ~isnan(dataset.ph3(start: start+duration, i)))';
        
        if length(t) == 0
            continue
        end

        time = dataset.time(t);
        C1 = dataset.pr1(t, i);
        L1 = dataset.ph1(t, i);
        C2 = dataset.pr3(t, i);
        L2 = dataset.ph3(t, i);

        mpCalculationConstant;

        [iphi, csFlag] = cycleslipDetector(time, C1, L1, C2, L2, LAMBDA_GPS_L1, LAMBDA_GPS_L5);
        mp1 = mpCalculator(time, csFlag, C1, L1, iphi, LAMBDA_GPS_L1);

        find(csFlag == 0)


        break
    end
  

    %% Plot 수행
    % Plotting mp1 over time
    fig = figure(165);
    plot(time, mp1, 'LineWidth', 1.5);
    xlabel('Time (s)');
    ylabel('Multipath Error (m)');
    title('Multipath Error (MP1) over Time');
    grid on;
end
