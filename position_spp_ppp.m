%% read RTKLIB .pos file
dataname = 'data_04';
% base_name = 'receiver_opensky'; 
file_name = 'smartphone_urban';



nav_type = 'ppp';
% nav_type = 'spp';


folder_dir = fullfile('./data/pos', dataname);
ref_lla = [36.3723265888889	127.358705720794	90.6336978571429];


ppp_filepath =  fullfile(folder_dir,strcat(file_name,'.csv'));
ppp_lla = parse_ppp_file(ppp_filepath);


spp_filepath =  fullfile(folder_dir,strcat(file_name,'.pos'));
spp_lla = parse_rtkpos_file(spp_filepath);


save_dir = fullfile(folder_dir, 'figures');
if ~exist(save_dir, 'dir') 
    mkdir(save_dir)
end

%%
ppp_enu = lla2enu(ppp_lla, ref_lla);
spp_enu = lla2enu(spp_lla, ref_lla);


%%

% 
figure(1); clf; hold on;
plot(ppp_enu(:,1), ppp_enu(:,2), '.', 'Color',colors(3,:),'MarkerSize', 12, 'DisplayName', 'PPP');
plot(spp_enu(:,1), spp_enu(:,2), '.', 'Color',colors(4,:), 'MarkerSize', 12, 'DisplayName', 'SPP');

xlabel('East (m)');
ylabel('North (m)');
zlabel('Up (m)');
grid on; hold off;
% view(60, 30)
view(0, 90); legend('Location','northwest');
axis equal;
% set(gca, 'FontSize', 15);
% title('ENU Position Trajectory');
savefig(gcf, fullfile(save_dir, [file_name,'_ppp_spp.fig'] ));
saveas(gcf, fullfile(save_dir, [file_name,'_ppp_spp.png'] ));


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
