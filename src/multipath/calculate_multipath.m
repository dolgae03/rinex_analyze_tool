function dataset = calculate_multipath(dataset)
    % Extract relevant data
    pr1 = dataset.pr1;
    pr3 = dataset.pr3;
    ph1 = dataset.ph1; % Carrier phase measurements for L1
    ph5 = dataset.ph3; % Carrier phase measurements for L5 (if available)

    % Constants
    c = 299792458; % Speed of light in m/s
    f_L1 = 1575.42e6; % L1 frequency in Hz
    f_L5 = 1176.45e6; % L5 frequency in Hz

    % Calculate wavelengths
    lambda_L1 = c / f_L1;
    lambda_L5 = c / f_L5;

    % Calculate differences
    pr1_diff = pr1 - ph1 * lambda_L1;
    pr5_diff = pr3 - ph5 * lambda_L5; % Assuming PR3 uses L5

    % Parameters for detrending
    window_time = 180; % seconds
    sample_interval = 1; % seconds between samples (adjust if needed)

    window_size = round(window_time / sample_interval); % samples per window

    % Detrend per column
    pr1_diff = window_detrend_poly3(pr1_diff, window_size);
    pr5_diff = window_detrend_poly3(pr5_diff, window_size);

    % Final mean removal along time axis (axis=1)
    pr1_diff = pr1_diff - mean(pr1_diff, 1, 'omitnan');
    pr5_diff = pr5_diff - mean(pr5_diff, 1, 'omitnan');

    % Save results
    dataset.mp1 = pr1_diff;
    dataset.mp5 = pr5_diff;
end

function detrended = window_detrend(data, window_size)
    [N, M] = size(data);
    detrended = NaN(size(data));
    for col = 1:M
        for i = 1:window_size:N
            idx_end = min(i + window_size - 1, N);
            segment = data(i:idx_end, col);
            mean_val = mean(segment, 'omitnan');
            detrended(i:idx_end, col) = segment - mean_val;
        end
    end
end

function detrended = window_detrend_poly2(data, window_size)
    [N, M] = size(data);
    detrended = NaN(size(data));
    for col = 1:M
        for i = 1:window_size:N
            idx_end = min(i + window_size - 1, N);
            segment = data(i:idx_end, col);
            t = (i:idx_end)'; % Time index for polyfit
            
            % Remove NaN before fitting
            valid_idx = ~isnan(segment);
            if sum(valid_idx) >= 3 % At least enough points for 2nd-order fit
                p = polyfit(t(valid_idx), segment(valid_idx), 2);
                trend = polyval(p, t);
                detrended(i:idx_end, col) = segment - trend;
            else
                detrended(i:idx_end, col) = NaN; % not enough data to fit
            end
        end
    end
end

function detrended = window_detrend_poly3(data, window_size)
    [N, M] = size(data);
    detrended = NaN(size(data));
    min_points = 4;  % 3차 다항식에 필요한 최소 유효 점 개수

    for col = 1:M
        i = 1;
        while i <= N
            % 기본 윈도우 구간
            idx_end = min(i + window_size - 1, N);
            segment = data(i:idx_end, col);
            t = (i:idx_end)';  % 시간 인덱스

            valid_idx = ~isnan(segment);

            % 유효한 점이 부족한 경우 → 확장 시도
            if sum(valid_idx) < min_points
                idx_end_ext = min(i + 2 * window_size - 1, N);
                segment_ext = data(i:idx_end_ext, col);
                t_ext = (i:idx_end_ext)';

                valid_idx_ext = ~isnan(segment_ext);
                if sum(valid_idx_ext) >= min_points
                    % 확장 구간으로 fit
                    p = polyfit(t_ext(valid_idx_ext), segment_ext(valid_idx_ext), 3);
                    trend = polyval(p, t_ext);
                    detrended(i:idx_end_ext, col) = segment_ext - trend;
                    i = idx_end_ext + 1;  % 확장 구간만큼 이동
                    continue;
                else
                    % 확장해도 부족하면 그냥 NaN
                    detrended(i:idx_end_ext, col) = NaN;
                    i = idx_end_ext + 1;
                    continue;
                end
            else
                % 정상적으로 fit 수행

                p = polyfit(t(valid_idx), segment(valid_idx), 3);
                trend = polyval(p, t);
                detrended(i:idx_end, col) = segment - trend;
                i = idx_end + 1;  % 기본 윈도우만큼 이동
            end
        end
    end
end
