% 기준점 (deg, deg, m)
reflat = 36.37227643;
reflon = 127.3587011;
refalt = 88.5383;


% CSV 읽기
data = readtable('./data/pos/GEOP126A.csv');

% 데이터 크기
N = height(data);
enu = zeros(N, 3);

% 각 epoch마다 ENU 좌표 계산
for i = 1:N
    lat = data.latitude_decimal_degree(i);
    lon = data.longitude_decimal_degree(i);
    alt = data.ellipsoidal_height_m(i);

    enu(i, :) = wgslla2enu(lat, lon, alt, reflat, reflon, refalt);
end

% East 방향으로 1m 이동 (서쪽으로)
enu(:,1) = enu(:,1) - 3;

% 3D 궤적 플롯
figure(1);
plot3(enu(:,1), enu(:,2), enu(:,3), 'o-');
xlabel('East (m)');
ylabel('North (m)');
zlabel('Up (m)');
grid on;
title('Figure 1: ENU Position Trajectory');

% RMS 오차 계산 (ENU에서 원점까지의 거리)
rms_error = sqrt(sum(enu.^2, 2));

% 시간 축 데이터
time = data.decimal_hour;

% RMS 오차 Plot
figure(2);
plot(time, rms_error, 'b.-');
xlabel('Decimal Hour');
ylabel('3D RMS Error (m)');
title('Figure 2: 3D RMS Error Over Time');
grid on;

% 수평 오차: sqrt(E^2 + N^2)
horizontal_error = sqrt(enu(:,1).^2 + enu(:,2).^2);

% 수직 오차: abs(U)
vertical_error = abs(enu(:,3));

% 수평 오차 Plot
figure(3);
plot(time, horizontal_error, 'r.-');
xlabel('Decimal Hour');
ylabel('Horizontal Error (m)');
title('Figure 3: Horizontal Position Error Over Time');
grid on;

% 수직 오차 Plot
figure(4);
plot(time, vertical_error, 'g.-');
xlabel('Decimal Hour');
ylabel('Vertical Error (m)');
title('Figure 4: Vertical Position Error Over Time');
grid on;

save_dir = './data/result/pos';
if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end

savefig(1, fullfile(save_dir, 'figure1_enu_trajectory.fig'));
saveas(1, fullfile(save_dir, 'figure1_enu_trajectory.png'));

savefig(2, fullfile(save_dir, 'figure2_rms_error.fig'));
saveas(2, fullfile(save_dir, 'figure2_rms_error.png'));

savefig(3, fullfile(save_dir, 'figure3_horizontal_error.fig'));
saveas(3, fullfile(save_dir, 'figure3_horizontal_error.png'));

savefig(4, fullfile(save_dir, 'figure4_vertical_error.fig'));
saveas(4, fullfile(save_dir, 'figure4_vertical_error.png'));
