%% REF position
% data_ref_dir = './data/pos/receiver_opensky_0507.csv';
% [reflat, reflon, refalt] = get_ref_pos(data_ref_dir );

%% REf
%%
% 기준점 (deg, deg, m)

% 
% 
% ref_lla = [36.372326524999998, 127.3587056194444, 127.3587056194444];
% % CSV 읽기
% 
% ppp_sol = [36.372274697222224, 127.3587501555556, 88.318899999999999]; % 7 hours 
% ppp_sol_enu = wgslla2enu(ppp_sol(1), ppp_sol(2), ppp_sol(3), reflat, reflon, refalt);


%% read RTKLIB .pos file
% dataname = 'data_04';
% base_name = 'receiver_opensky'; 
% rover_name = 'smartphone_opensky';
% gt_rover_lla = [36.3723265888842	127.358739150987	90.6336985616905]; % data_original (0409 and 0429)
% gt_base_lla = [36.3723265888889	127.358705720794	90.6336978571429];
% t_converge = 3600*1.5;



dataname = 'data_0507';
base_name = 'receiver_opensky_0507'; 
rover_name = 'smartphone_opensky_0507';
gt_base_lla = [36.3722758811541	127.358701076304	88.5161483425414]; % data 0507
gt_rover_lla = [36.3722758811494	127.358734506487	88.5161490465186]; 
% t_converge = 3600*4;


nav_type = 'ppp';
% nav_type = 'spp';


folder_dir = fullfile('./data/pos', dataname);






gt_base_enu = [0 0 0]; gt_rover_enu = [3 0 0];

cal_gt  = 0;

if cal_gt
    gt_base_lla = get_ref_pos(pos_base_lla);
    [lat, lon, h ]= enu2wgslla(gt_rover_enu', gt_base_lla(1), gt_base_lla(2), gt_base_lla(3));
    gt_rover_lla = [lat lon h];
end


% -- PPP --- 
if nav_type == 'ppp' 
    base_filepath =  fullfile(folder_dir,strcat(base_name,'.csv'));
    pos_base_lla = parse_ppp_file(base_filepath);
    rover_filepath =  fullfile(folder_dir,strcat(rover_name,'.csv'));
    pos_rover_lla = parse_ppp_file(rover_filepath);
end


% -- SPP --- 
if nav_type == 'spp' 
    base_filepath =  fullfile(folder_dir,strcat(base_name,'.pos'));
    pos_base_lla = parse_rtkpos_file(base_filepath);
    rover_filepath =  fullfile(folder_dir,strcat(rover_name,'.pos'));
    pos_rover_lla = parse_rtkpos_file(rover_filepath);
end

save_dir = fullfile(folder_dir, 'figures');
if ~exist(save_dir, 'dir') 
    mkdir(save_dir)
end





%%  enu 계산
t_base = pos_base_lla.time;
t_rover = pos_rover_lla.time;

t_max = min(t_rover(end), t_base(end));


pos_base_enu = lla2enu(pos_base_lla, gt_base_lla);
pos_rover_enu = lla2enu(pos_rover_lla, gt_base_lla);

error_base = pos_base_enu - gt_base_enu;

error_rover = pos_rover_enu - gt_rover_enu;








%% %%  ppp 수렴 후 enu



% error_data = error_rover;
% t_data = t_rover;

error_data = error_base;
t_data = t_base;


% t_start = 0;
t_start = 120;

indices = (t_data > t_start) & (t_data < t_max);


enu_converge = error_data(indices,  :);
std_enu = std(enu_converge);
fprintf("std_e: %2.3f | std_n: %2.3f | std_u: %2.3f\n", std_enu(1), std_enu(2), std_enu(3));


hor = sqrt(enu_converge(:,1).^2 + enu_converge(:,2).^2);
ver = abs(enu_converge(:,3));

mean(hor)
mean(ver)


figure;
plot(t_data(indices)/3600, enu_converge)



%% Error over time

% t_converge = 1;

figure(100);clf; hold on; set(gca, 'FontSize', 14)
str_rover = sprintf("Smartphone: %.2f m" , mean(rms_rover(t_converge:end)));
str_base = sprintf("Receiver: %.2f m" , mean(rms_base(t_converge:end)));
plot(t_rover./3600, rms_rover, 'DisplayName', str_rover, 'Color', colors(1,:), 'LineWidth', 2.0);
plot(t_base./3600, rms_base, 'DisplayName', str_base, 'Color', colors(5,:), 'LineWidth', 2.0);
xlabel('Time (hour)');
ylabel('3D RMS Error (m)');
xlim([0 (t_max/3600)]);
grid on; legend; hold off;


% savefig(gcf, fullfile(save_dir, 'SPP_errors_time_0507.fig'));
% saveas(gcf,fullfile(save_dir, 'SPP_errors_time_0507.png') )

savefig(figure(100), fullfile(save_dir, [nav_type, '_rms_error',  '.fig']));
saveas(figure(100), fullfile(save_dir, [nav_type, '_rms_error', '.png']) )





%% PPP error ENU (to see the convergence)


fig1 = figure; 
sgtitle("ENU Errors")
set(gcf, 'Position', [100 100 500 600]);


subplot(3,1,1); hold on; grid on; 
set(gca, 'FontSize', 13);
plot(t_base./3600, e_base(:,1), 'Color',colors(5,:), 'DisplayName', 'Receiver', 'LineWidth', 2.5);
plot(t_rover./3600, e_rover(:,1), 'Color',colors(1,:), 'DisplayName', 'Smartphone', 'LineWidth', 2.5);
ylabel('Error in E (m)'); legend('Location', 'Northeast');xlim([0, t_max./3600]);

subplot(3,1,2); hold on; grid on;
set(gca, 'FontSize', 13);
plot(t_base./3600, e_base(:,2), 'Color',colors(5,:), 'DisplayName', 'Receiver', 'LineWidth', 2.5);
plot(t_rover./3600, e_rover(:,2), 'Color',colors(1,:), 'DisplayName', 'Smartphone', 'LineWidth', 2.5);
ylabel('Error in N (m)'); xlim([0, t_max./3600]);

subplot(3,1,3); hold on; grid on;
set(gca, 'FontSize', 13);
plot(t_base./3600, e_base(:,3), 'Color',colors(5,:), 'DisplayName', 'Receiver', 'LineWidth', 2.5);
plot(t_rover./3600, e_rover(:,3), 'Color',colors(1,:), 'DisplayName', 'Smartphone', 'LineWidth', 2.5);
ylabel('Error in U (m)'); 
xlabel('Time (hours)'); xlim([0, t_max./3600]);

hold off; 
% 
% 
savefig(gcf, fullfile(save_dir, [nav_type, '_errors_enu', '.fig']));
saveas(gcf,fullfile(save_dir, [nav_type, '_errors_enu', '.png']) )


%% SPP Trajectory 

% fig2 = figure(5873); 
set(fig2, "Position", [100 100 700 500])
clf; hold on; grid on;
title("Trajectory ");
scatter(pos_rover_enu(:,1), pos_rover_enu(:,2), 50, 'o',  'DisplayName', 'Est-Smartphone', 'MarkerEdgeColor', colors(1,:));
scatter(pos_base_enu(:,1), pos_base_enu(:,2), 50,'o',  'DisplayName', 'Est-Receiver', 'MarkerEdgeColor', colors(5,:), 'MarkerFaceColor', colors(5,:));

scatter(gt_rover_enu(:,1), gt_rover_enu(:,2), 100,'filled', 'k^', 'DisplayName', 'True-Smartphone')
scatter(gt_base_enu(:,1), gt_base_enu(:,2), 100, 'filled', 'r^',  'DisplayName', 'True-Receiver');

xlabel('East (m)'); ylabel('North (m)'); 
legend('Location', 'northeastoutside');
axis equal;
set(gca, 'fontsize', 13);
xlim

savefig(gcf, fullfile(save_dir, [nav_type, '_trajectory', '.fig']));
saveas(gcf,fullfile(save_dir, [nav_type, '_trajectory' , '.png']) )



%% calculate enu 

spp_enu = lla2enu(pos_data_spp, ref_lla);


%%
colors = lines(5);

figure(1); clf; 
grid on;hold on; view(60, 30); 
plot3(enu(:,1), enu(:,2), enu(:,3), 'o', 'Color',colors(1,:));
plot3(ppp_sol_enu, 'ko', 'MarkerSize', 10, 'MarkerFaceColor','k');
xlabel('East (m)');
ylabel('North (m)');
zlabel('Up (m)');

set(gca, 'FontSize', 15);


set(gca, 'FontSize', 15);
% title('ENU Position Trajectory');
% savefig(1, fullfile(save_dir, [file_name,'_enu.fig'] ));
% saveas(1, fullfile(save_dir, [file_name,'_enu.png'] ));





%%

% 3D 궤적 플롯

% 
% figure(1); clf; hold on;
% % [img, map] =imread("./map.png");
% % imshow(img, map); 
% plot(enu_ppp(:,1), enu_ppp(:,2), '.', 'Color',colors(3,:),'MarkerSize', 12, 'DisplayName', 'PPP');
% plot(enu(:,1), enu(:,2), '.', 'Color',colors(4,:), 'MarkerSize', 12, 'DisplayName', 'SPP');
% set(gcf, 'Color', 'none');      % figure 배경
% set(gca, 'Color', 'none');      % axes 배경
% 
% xlabel('East (m)');
% ylabel('North (m)');
% zlabel('Up (m)');
% grid on; hold off;
% % view(60, 30)
% view(0, 90); legend('Location','northwest');
% 
% set(gca, 'FontSize', 15);
% % title('ENU Position Trajectory');
% savefig(1, fullfile(save_dir, [file_name,'_enu_both.fig'] ));
% saveas(1, fullfile(save_dir, [file_name,'_enu_both.png'] ));



%%









savefig(1, fullfile(save_dir, [file_name,'_enu.fig'] ));
saveas(1, fullfile(save_dir, [file_name,'_enu.png'] ));

savefig(2, fullfile(save_dir, 'rms_error.fig'));
saveas(2, fullfile(save_dir, 'rms_error.png'));

savefig(3, fullfile(save_dir, 'horizontal_error.fig'));
saveas(3, fullfile(save_dir, 'horizontal_error.png'));

savefig(4, fullfile(save_dir, 'vertical_error.fig'));
saveas(4, fullfile(save_dir, 'vertical_error.png'));


function ref_lla = get_ref_pos(data)
    
   
    figure('Visible','on'); hold on; grid on;
    subplot(1,3,1)
    plot(data.lat)
    subplot(1,3,2)
    plot( data.lon)
    subplot(1,3,3)
    plot(data.height)
    hold off;

    i_start = 100;
    reflat = mean(data.lat(i_start:end,:));
    reflon = mean(data.lon(i_start:end,:));
    refalt = mean(data.height(i_start:end,:));

    ref_lla = [reflat reflon refalt];

end

function pos_data = parse_rtkpos_file(filepath)
    % RTKLIB .pos 파일에서 헤더 제외하고 데이터만 파싱
    fid = fopen(filepath, 'r');
    if fid == -1
        error('파일 열기 실패: %s', filepath);
    end

    % 헤더 넘기기: '%'로 시작하는 줄 무시
    line = fgetl(fid);
    while ischar(line) && startsWith(strtrim(line), '%')
        line = fgetl(fid);
    end
    
    % 데이터 파싱 시작
    t_list = [];
    lat_list = [];
    lon_list = [];
    h_list = [];

    % 데이터 읽기
    while ischar(line)
        if isempty(strtrim(line))
            line = fgetl(fid);
            continue;
        end

        % 시간, 위도, 경도, 고도만 파싱
        tokens = textscan(line, '%s %s %f %f %f', 1);
        dt = datetime(strcat(tokens{1}, {' '}, tokens{2}), 'InputFormat', 'yyyy/MM/dd HH:mm:ss.SSS');
        t_list(end+1,1)   = datenum(dt);   % MATLAB datenum
        

        lat_list(end+1,1) = tokens{3};
        lon_list(end+1,1) = tokens{4};
        h_list(end+1,1)   = tokens{5};

        line = fgetl(fid);
    end
    fclose(fid);
    t_list = (t_list - t_list(1))*86400;

    % 컬럼 이름 정의 (RTKLIB 포맷 기준)
    pos_data = struct();
    pos_data.time   = t_list;  % MATLAB datenum
    pos_data.lat    = lat_list;
    pos_data.lon    = lon_list;
    pos_data.height = h_list;
   
end

function data = parse_ppp_file(filepath)
    data_raw = readtable(filepath);
    data.lat = data_raw.latitude_decimal_degree;
    data.lon = data_raw.longitude_decimal_degree;
    data.height = data_raw.ellipsoidal_height_m;
    data.time = (data_raw.decimal_hour - data_raw.decimal_hour(1))*3600;

end

function enu = lla2enu(data, ref_lla)
    N = length(data.height);
    enu = nan(N, 3);
    for i = 1:N
        lat = data.lat(i);
        lon = data.lon(i);
        alt = data.height(i);    
        enu(i, :) = wgslla2enu(lat, lon, alt, ref_lla(1), ref_lla(2), ref_lla(3));
    end
end
