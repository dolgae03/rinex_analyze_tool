function [modified_base_dataset, modified_rover_dataset] = preprocess_multipath(base_dataset, rover_dataset,start_idx, duration, save_dir)
% 상용 수신기와 스마트폰 수신기 비교
% 목적 : 스마트폰 수신기에 발생하는 바이어스 특성 파악
fig_constant = 1374;

%% Data Load
convenRx = base_dataset;
chipsetRx = rover_dataset;

%% 공통 변수 정의

% Constant

run('./multipath/mpCalculationConstant.m')

% 시간
t = convenRx.time_GPS;

% 공통 PRN
convenRxPrn = find(any(~isnan(convenRx.pr1),1));
chipsetRxPrn = find(any(~isnan(chipsetRx.pr1),1));
commonPrn = intersect(convenRxPrn, chipsetRxPrn);
numPrn = numel(commonPrn);

commonPrnGPS = commonPrn(commonPrn<33);

% 그래프 색깔
colors = lines(numPrn);

% Single Difference
singleDiff.pr1 = chipsetRx.pr1 - convenRx.pr1;
idxOut = isoutlier(singleDiff.pr1);
singleDiff.pr1(idxOut) = nan;

% Double Difference
[~, idx] = max(sum(~isnan(singleDiff.pr1(:,commonPrnGPS)),1));
refPrn = commonPrnGPS(idx);
doubleDiff.pr1 = singleDiff.pr1 - singleDiff.pr1(:,refPrn);

%% Pseudorange 분석
kk = 1;
fig = figure(fig_constant + 2);
clf;
set(gcf, 'Color', 'white'); % 배경을 white로 설정
for i = commonPrn
    % Pseudorange Difference Plot

    errors = chipsetRx.pr1(:, i) - convenRx.pr1(:, i);

    % 그래프 제목 및 데이터 플롯
    plot(t/3600, errors,'Color',colors(kk, :), 'LineWidth', 1);
    hold on;
    

    % p_cov_sat = gobjects(1, 1); % 핸들 배열 초기화
    % for i = 1:1
    %     p_cov_sat(i) = plot(nan, ...
    %                         'LineWidth', 2); % 굵은 선을 범례에 사용
    %     hold on;
    % end
    
    %    % 동적으로 생성된 legend 적용 및 위치 설정, LaTeX 해석을 사용
    % lgd = legend(p_cov_sat, {'PR differenced'}, ...
    %              'Location', 'northwest', 'Interpreter', 'latex'); % 범례에 LaTeX 적용
    
    % 제목 및 축 설정
    % title('Pseudorange Difference', 'FontSize', 14, 'FontWeight', 'bold'); % 제목 설정

    kk = kk + 1;
end
xlabel('Time (hours)', 'FontSize', 14, 'FontWeight', 'bold'); % x축 설정
ylabel('Pesudorange Difference (m)', 'FontSize', 14, 'FontWeight', 'bold'); % y축 설정
set(gca, 'FontSize', 14'); % 축 글씨 설정
grid on;
ylim([-400,500])
xlim([0,21])
save_file = fullfile([save_dir, 'pr_diff_multipath_l1.fig']);
savefig(fig, save_file);

save_file = fullfile([save_dir, 'pr_diff_multipath_l1.png']);
saveas(fig, save_file);



%% ConvenRx Carrier vs. ChipsetRx Carrier 비교
 kk = 1;
fig = figure(fig_constant + 4);
    fig.Color = 'white';
    clf;
for i = commonPrn

    % figure(fig_constant + 3)
    % clf;
    % title('Absolute Carrier')
    % plot(t, convenRx.ph1(:,i)-mean(convenRx.ph1(:,i), 'omitnan'), 'o', 'Color', colors(kk, :));
    % hold on
    % plot(t, -chipsetRx.ph1(:,i)+mean(chipsetRx.ph1(:,i), 'omitnan'), '-', 'Color', colors(kk, :));
    % xlabel('Time (sec)')
    % ylabel('Pseudorange (m)')
    new_chipset = chipsetRx.ph1(:, i);

    % 조건을 만족하는 인덱스에 NaN 할당
    new_chipset(abs(new_chipset) < 10) = NaN;


    % title('Carrier Difference')
    errors = (-new_chipset+mean(chipsetRx.ph1(:,i), 'omitnan')) - (convenRx.ph1(:,i)-mean(convenRx.ph1(:,i), 'omitnan'));
    plot(t/3600, errors, 'Color', colors(kk, :), 'LineWidth', 1);
    
    hold on;

    kk = kk + 1;
end

xlim([0, 21]);
% title('Carrier Difference', 'FontSize', 14, 'FontWeight', 'bold'); % 제목 설정
xlabel('Time (hours)', 'FontSize', 14, 'FontWeight', 'bold'); % x축 설정
ylabel('Carrier Difference (cycle)', 'FontSize', 14, 'FontWeight', 'bold'); % y축 설정
set(gca, 'FontSize', 14'); % 축 글씨 설정
ylim([-1.5e11,1.5e11])
grid on;
save_file = fullfile([save_dir, 'multipath_carrier_diff_l1.fig']);
savefig(fig, save_file);

save_file = fullfile([save_dir, 'multipath_carrier_diff_l1.png']);
saveas(fig, save_file);


% mpCalculationConstant;
convmp = fullfile(save_dir, 'results_241120.mat');
load(convmp);

chipsetRxClkBias = chipsetRxClkBias.f1;

%% 그림 그리는 용도

%% Pseudorange 분석
kk = 1;
for i = commonPrn
    % Pseudorange Difference Plot
    fig = figure(fig_constant + 87);
    clf;
    set(gcf, 'Color', 'white'); % 배경을 white로 설정
    errors = chipsetRx.pr1(:, i) - convenRx.pr1(:, i);

    % 그래프 제목 및 데이터 플롯
    plot(t/3600, errors, 'Color', colors(3, :), 'LineWidth', 1);
    hold on;
    save_file = fullfile([save_dir, 'multipath_pr_diff_error_by_step_l1.fig']);
    savefig(fig, save_file);

    save_file = fullfile([save_dir, 'multipath_pr_diff_error_by_step_l1.png']);
    saveas(fig, save_file);
    
    kk = kk + 1;
    break; % 첫 번째 PRN만 그리도록 유지
end

for i = commonPrnGPS
    % Clock Bias 제거 후 Multipath Noise 계산
    diffChipCon = chipsetRx.pr1(:, i) - convenRx.pr1(:, i) - chipsetRxClkBias;
    mp_with_clock_bias_removed = diffChipCon; % Clock bias 제거된 결과
    
    % Clock Bias를 제거한 결과 플롯
    plot(t/3600, mp_with_clock_bias_removed, 'LineWidth', 1, 'Color', colors(4, :));
    hold on;
    grid on;

    % Multipath Noise 제거
    chipsetRx.mp1SD(:, i) = diffChipCon + convenRx.mp1(:, i);

    % 이상치 제거
    i_out = isoutlier(chipsetRx.mp1SD(:, i));
    chipsetRx.mp1SD(i_out, i) = nan;

    % Multipath Noise 제거 후 결과 플롯
    plot(t/3600, chipsetRx.mp1SD(:, i), 'LineWidth', 1, 'Color', colors(1, :));
    hold on;
    % title('Multipath after Noise Removal', 'FontSize', 14, 'FontWeight', 'bold');
    xlabel('Time (hours)', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('Error (m)', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14);
    xlim([6, 9]);

    target_color = [colors(3, :); colors(4, :); colors(1, :)];
    ylim([-150,150])

    p_cov_sat = gobjects(1, 3); % 핸들 배열 초기화
    for i = 1:3
        p_cov_sat(i) = plot(nan, nan, ...
                            'LineWidth', 2, ...
                            'Color', target_color(i, :)); % 굵은 선을 범례에 사용
        hold on;
    end
    
       % 동적으로 생성된 legend 적용 및 위치 설정, LaTeX 해석을 사용
    lgd = legend(p_cov_sat, {'PR differenced','Clock Bias removed', 'Multipath removed'}, ...
                 'Location', 'northwest', 'Interpreter', 'latex'); % 범례에 LaTeX 적용
    lgd.FontSize = 14;   % 글꼴 크기 설정
    lgd.FontWeight = 'bold';  % 글꼴 굵기 설정
    grid on;
    save_file = fullfile([save_dir, 'multipath_noise_error_l1.fig']);
    
    savefig(fig, save_file);


    save_file = fullfile([save_dir, 'multipath_noise_error_l1.png']);
    
    saveas(fig, save_file);
    % Display both results for the current PRN
    % legend({'Original','Clock Bias Removed', 'Noise Removed'}, 'FontSize', 12, 'Location', 'best');

    % Break for single PRN analysis (remove this if all PRNs need to be plotted)
    break;
end

for i = commonPrnGPS
    diffChipCon = chipsetRx.pr1(:,i) - convenRx.pr1(:,i);
    
    chipsetRx.mp1SD(:,i) = diffChipCon + convenRx.mp1(:,i) - chipsetRxClkBias;
    i_out = isoutlier(chipsetRx.mp1SD(:,i));
    chipsetRx.mp1SD(i_out,i) = nan;
end


%% Double Difference로 Multipath Std 계산
i_out = isoutlier(doubleDiff.pr1);
doubleDiff.pr1(i_out) = nan;
doubleDiff.pr1(:,refPrn) = nan;

chipsetRx.mp1DD = nan(size(chipsetRx.pr1));
for i = commonPrnGPS
    chipsetRx.mp1DD(:,i) = doubleDiff.pr1(:,i) + convenRx.mp1(:,i) - convenRx.mp1(:,refPrn);

    i_out = isoutlier(chipsetRx.mp1DD(:,i));
    chipsetRx.mp1DD(i_out,i) = nan;
end

fig = figure(fig_constant + 97);
clf;
color = lines(2);
fig.Color = 'white';
plot(t / 3600, chipsetRx.mp1DD(:,commonPrnGPS(1)), 'Color',color(2, :));
hold on;

plot(t / 3600, chipsetRx.mp1SD(:,commonPrnGPS(1)), 'Color',color(1, :));
hold on;
xlim([6, 9]);

% title('Multipath after Noise Removal', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Time (hours)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Multipath Noise (m)', 'FontSize', 14, 'FontWeight', 'bold');
set(gca, 'FontSize', 14);
grid on;

p_cov_sat = gobjects(1, 2); % 핸들 배열 초기화
for i = 1:2
    p_cov_sat(i) = plot(nan, nan, ...
                        'Color', colors(i, :), ...
                        'LineWidth', 2); % 굵은 선을 범례에 사용
    hold on;
end

   % 동적으로 생성된 legend 적용 및 위치 설정, LaTeX 해석을 사용
lgd = legend(p_cov_sat, {'Single Difference','Double Difference'}, ...
             'Location', 'northwest', 'Interpreter', 'latex'); % 범례에 LaTeX 적용
lgd.FontSize = 14;   % 글꼴 크기 설정
lgd.FontWeight = 'bold';  % 글꼴 굵기 설정
ylim([-40, 40])

% title('Single Difference and Double Difference Multipath')
save_file = fullfile([save_dir, 'multipath_sd_dd_l1.fig']);
savefig(fig, save_file);

save_file = fullfile([save_dir, 'multipath_sd_dd_l1.png']);
saveas(fig, save_file);


%% Double Difference로 Multipath Std 계산
i_out = isoutlier(doubleDiff.pr1);
doubleDiff.pr1(i_out) = nan;
doubleDiff.pr1(:,refPrn) = nan;

chipsetRx.mp1DD = nan(size(chipsetRx.pr1));
for i = commonPrnGPS
    chipsetRx.mp1DD(:,i) = doubleDiff.pr1(:,i) + convenRx.mp1(:,i) - convenRx.mp1(:,refPrn);

    i_out = isoutlier(chipsetRx.mp1DD(:,i));
    chipsetRx.mp1DD(i_out,i) = nan;
end

fig = figure(fig_constant + 9715616);
clf;
color = lines(2);
fig.Color = 'white';
plot(t / 3600, chipsetRx.mp1DD(:,commonPrnGPS(1)), 'Color',color(2, :));
hold on;
plot(t / 3600, convenRx.mp1(:,commonPrnGPS(1)) - convenRx.mp1(:,30), 'Color','k');
hold on;
xlim([6, 9]);
ylim([-40, 40]);



% title('Multipath after Noise Removal', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Time (hours)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Multipath Noise (m)', 'FontSize', 14, 'FontWeight', 'bold');
set(gca, 'FontSize', 14);
grid on;

p_cov_sat = gobjects(1, 2); % 핸들 배열 초기화

p_cov_sat(1) = plot(nan, nan, ...
                    'Color', colors(2, :), ...
                    'LineWidth', 2); % 굵은 선을 범례에 사용
hold on;
p_cov_sat(2) = plot(nan, nan, ...
                    'Color', 'k', ...
                    'LineWidth', 2); % 굵은 선을 범례에 사용
hold on;
grid on;

   % 동적으로 생성된 legend 적용 및 위치 설정, LaTeX 해석을 사용
lgd = legend(p_cov_sat, {'Chipset DD', 'Conv DD'}, ...
             'Location', 'northwest', 'Interpreter', 'latex'); % 범례에 LaTeX 적용
lgd.FontSize = 14;   % 글꼴 크기 설정
lgd.FontWeight = 'bold';  % 글꼴 굵기 설정
ylim([-40, 40])


% title('Single Difference and Double Difference Multipath')
save_file = fullfile([save_dir, 'multipath_dd_only_l1.fig']);
savefig(fig, save_file);

save_file = fullfile([save_dir, 'multipath_dd_only_l1.png']);
saveas(fig, save_file);

%% Standard Deviation 비교
sig_singleDiff = std(chipsetRx.mp1SD(:), 'omitnan');
sig_doubleDiff = std(chipsetRx.mp1DD(:), 'omitnan');

sdtemp = chipsetRx.mp1SD(:);
sdtemp(isnan(sdtemp)) = [];
ddtemp = chipsetRx.mp1DD(:);
ddtemp(isnan(ddtemp)) = [];



fig = figure(fig_constant + 9);
clf;
fig.Color = 'white';
histogram(ddtemp, 'Normalization', 'pdf', 'FaceColor',color(2, :),'BinWidth', 2);
hold on;
histogram(sdtemp, 'Normalization', 'pdf', 'FaceColor',color(1, :), 'BinWidth', 2);

p_cov_sat = gobjects(1, 2); % 핸들 배열 초기화
for i = 1:2
    p_cov_sat(i) = histogram(nan, ...
                        'FaceColor', colors(i, :)); % 굵은 선을 범례에 사용
    hold on;
end

   % 동적으로 생성된 legend 적용 및 위치 설정, LaTeX 해석을 사용
lgd = legend(p_cov_sat, {['Single Diff MP Error STD = ' num2str(sig_singleDiff) 'm'], ['Double Diff MP Error STD = ' num2str(sig_doubleDiff) 'm'] }, ...
             'Location', 'northwest', 'Interpreter', 'latex'); % 범례에 LaTeX 적용
lgd.FontSize = 14;   % 글꼴 크기 설정
lgd.FontWeight = 'bold';  % 글꼴 굵기 설정

% legend(['Double Diff. MP. STD = ' num2str(sig_doubleDiff)], ['Single Diff. MP. STD = ' num2str(sig_singleDiff)])
grid on
xlabel('Multipath Error (m)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('PDF', 'FontSize', 14, 'FontWeight', 'bold');
set(gca, 'FontSize', 14);

xlim([-60,60])
    ylim([0, 0.1])


save_file = fullfile([save_dir, 'multipath_histo_l1.fig']);
savefig(fig, save_file);

save_file = fullfile([save_dir, 'multipath_histo_l1.png']);
saveas(fig, save_file);



%% Standard Deviation 비교
sig_singleDiff = std(chipsetRx.mp1SD(:), 'omitnan');
sig_doubleDiff = std(chipsetRx.mp1DD(:), 'omitnan');

sdtemp = chipsetRx.mp1SD(:);
sdtemp(isnan(sdtemp)) = [];
ddtemp = chipsetRx.mp1DD(:);
ddtemp(isnan(ddtemp)) = [];

fig = figure(fig_constant + 93154);
clf;
fig.Color = 'white';
histogram(sdtemp, 'Normalization', 'pdf', 'FaceColor',color(1, :),'BinWidth',2);
hold on;

p_cov_sat = gobjects(1, 2); % 핸들 배열 초기화
for i = 1:2
    p_cov_sat(i) = histogram(nan, ...
                        'FaceColor', colors(1, :)); % 굵은 선을 범례에 사용
    hold on;
end

   % 동적으로 생성된 legend 적용 및 위치 설정, LaTeX 해석을 사용
lgd = legend(p_cov_sat, {['Single Diff MP Error STD = ' num2str(sig_singleDiff) 'm']}, ...
             'Location', 'northwest', 'Interpreter', 'latex'); % 범례에 LaTeX 적용
lgd.FontSize = 14;   % 글꼴 크기 설정
lgd.FontWeight = 'bold';  % 글꼴 굵기 설정

% legend(['Double Diff. MP. STD = ' num2str(sig_doubleDiff)], ['Single Diff. MP. STD = ' num2str(sig_singleDiff)])
grid on
xlabel('Multipath Error (m)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('PDF', 'FontSize', 14, 'FontWeight', 'bold');
set(gca, 'FontSize', 14);

xlim([-60,60])
    ylim([0, 0.1])

save_file = fullfile([save_dir, 'multipath_histo_l1_only.fig']);
savefig(fig, save_file);

save_file = fullfile([save_dir, 'multipath_histo_l1_only.png']);
saveas(fig, save_file);



%% Standard Deviation 비교 L5
sig_singleDiff = std(chipsetRx.mp3SD(:), 'omitnan');

sdtemp = chipsetRx.mp3SD(:);
sdtemp(isnan(sdtemp)) = [];

fig = figure(fig_constant + 91);
clf;
fig.Color = 'white';
histogram(sdtemp, 'Normalization', 'pdf', 'FaceColor',color(1, :), 'BinWidth', 2);
hold on;

p_cov_sat = gobjects(1, 1); % 핸들 배열 초기화
for i = 1:1
    p_cov_sat(i) = histogram(nan, ...
                        'FaceColor', colors(1, :)); % 굵은 선을 범례에 사용
    hold on;
end

   % 동적으로 생성된 legend 적용 및 위치 설정, LaTeX 해석을 사용
lgd = legend(p_cov_sat, {['Single Diff MP Error STD = ' num2str(sig_singleDiff) 'm']}, ...
             'Location', 'northwest', 'Interpreter', 'latex'); % 범례에 LaTeX 적용
lgd.FontSize = 14;   % 글꼴 크기 설정
lgd.FontWeight = 'bold';  % 글꼴 굵기 설정

% legend(['Double Diff. MP. STD = ' num2str(sig_doubleDiff)], ['Single Diff. MP. STD = ' num2str(sig_singleDiff)])
grid on
xlabel('Multipath Error (m)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('PDF', 'FontSize', 14, 'FontWeight', 'bold');
set(gca, 'FontSize', 14);
xlim([-60,60])
ylim([0, 0.1])


save_file = fullfile([save_dir, 'multipath_histo_l5.fig']);
savefig(fig, save_file);

save_file = fullfile([save_dir, 'multipath_histo_l5.png']);
saveas(fig, save_file);

modified_base_dataset = convenRx;
modified_rover_dataset = chipsetRx; 

end

