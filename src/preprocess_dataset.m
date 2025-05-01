function dataset = preprocess_dataset(dataset, prn_nan_ranges)
% 주어진 여러 PRN 범위에 해당하는 모든 컬럼을 NaN으로 설정합니다.
%
% INPUT:
%   dataset           : 관측 데이터 구조체
%   prn_nan_ranges    : Px2 행렬, 각 행은 [PRN_start, PRN_end] 범위를 의미
%
% 필드 대상:
%   pr1, pr3, ph1, ph3, dop1, dop3, snr1, snr3

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
