function dataset = preprocess_dataset(dataset, prn_nan_ranges)
% 주어진 여러 PRN 범위에 해당하는 모든 컬럼을 NaN으로 설정합니다.
%
% INPUT:
%   dataset           : 관측 데이터 구조체
%   prn_nan_ranges    : Px2 행렬, 각 행은 [PRN_start, PRN_end] 범위를 의미
%
% 필드 대상:
%   pr1, pr3, ph1, ph3, dop1, dop3, snr1, snr3

    c = 299792458;  % 빛의 속도 [m/s]
    fL1 = 1575.42e6; % L1 주파수 [Hz]
    fL5 = 1176.45e6; % L5 주파수 [Hz]
    lam1 = c / fL1;  % L1 파장 [m]
    lam5 = c / fL5;  % L5 파장 [m]

    [N,M] = size(dataset.pr1);

    if ~isfield(dataset, 'loi1')
        dataset.loi1 = zeros(N, M);
    end
    if ~isfield(dataset, 'loi3')
        dataset.loi3 = zeros(N, M);
    end

    % Carrier Phase (cycle) 변환
    if isfield(dataset, 'ph1')
        dataset.ph1 = dataset.ph1 / lam1;          % L1 → cycle
        zero_mask = (dataset.ph1 == 0);            % 0 값 위치
        dataset.ph1(zero_mask) = NaN;              % 0 → NaN

        % loi1 없으면 생성 (전부 0으로 초기화)
        if ~isfield(dataset, 'loi1')
            dataset.loi1 = zeros(size(dataset.ph1));
        end
        dataset.loi1(zero_mask) = 4;               % LOI = 4 (invalid)
    end

    if isfield(dataset, 'ph3')
        dataset.ph3 = dataset.ph3 / lam5;          % L5 → cycle
        zero_mask = (dataset.ph3 == 0);
        dataset.ph3(zero_mask) = NaN;

        if ~isfield(dataset, 'loi3')
            dataset.loi3 = zeros(size(dataset.ph3));
        end
        dataset.loi3(zero_mask) = 4;
    end

    % Doppler Shift (Hz) 변환
    if isfield(dataset, 'dop1')
        dataset.dop1 = dataset.dop1 / lam1;  % L1 Doppler (Hz)
    end
    if isfield(dataset, 'dop3')
        dataset.dop3 = dataset.dop3 / lam5;  % L5 Doppler (Hz)
    end

    pr_fields = {'pr1', 'pr3'};
    related_fields = {'pr1', 'pr3', 'ph1', 'ph3', 'dop1', 'dop3', 'snr1', 'snr3', 'loi1', 'loi3'};
    pr_threshold = [2.0e+07, 2.803246884597588e+07];

    for k = 1:numel(pr_fields)
        if isfield(dataset, pr_fields{k})
            pr_data = dataset.(pr_fields{k});
            % 너무 큰 값 또는 작은 값 마스킹
            invalid_mask = (pr_data < pr_threshold(1)) | (pr_data > pr_threshold(2));

            % NaN으로 설정 (관련 필드 포함)
            for j = 1:numel(related_fields)
                if isfield(dataset, related_fields{j})
                    data = dataset.(related_fields{j});
                    data(invalid_mask) = NaN;
                    dataset.(related_fields{j}) = data;
                end
            end
        end
    end

    % 위성 개수
    n_cols = size(dataset.pr1, 2);
    col_mask = false(1, n_cols);

    % constellation 기준 정보
    col_ranges = dataset.constellation_idx;

    % === 모든 PRN 범위에 대해 마스킹 ===
    for r = 1:size(prn_nan_ranges, 1)
        prn_start = prn_nan_ranges(r, 1);
        prn_end   = prn_nan_ranges(r, 2);

        for i = 1:length(col_ranges)-1
            col_start = col_ranges(i);
            col_end   = col_ranges(i+1) - 1;
            prn_base  = col_ranges(i);  % PRN 시작 값

            % 현재 별자리의 PRN 값들
            prns = prn_base : prn_base + (col_end - col_start);
            mask_local = prns >= prn_start & prns <= prn_end;

            % 컬럼 마스크 업데이트
            col_mask(col_start:col_end) = col_mask(col_start:col_end) | mask_local;
        end
    end

    % === 대상 필드 ===
    fields = {'pr1', 'pr3', 'ph1', 'ph3', 'dop1', 'dop3', 'snr1', 'snr3'};

    for i = 1:numel(fields)
        field = fields{i};
        if isfield(dataset, field)
            data = dataset.(field);
            data(:, col_mask) = NaN;
            dataset.(field) = data;
        end
    end
end
