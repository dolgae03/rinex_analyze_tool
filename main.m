% Clear existing paths and variables
clear;

% Add paths for src and utils folders
addpath('./src/carrier');
addpath('./src/doppler');
addpath('./src/sat_num');
addpath('./src/multipath');
addpath('./src/snr');
addpath('./src');
addpath('./utils');
addpath('./navutils');


RCV_TYPE_SMARTPHONE = 0;
RCV_TYPE_RECEIVER = 1;

global color_palette

color_list = lines(5);
% color_palette = colors([1, 2, 5, 3, 5], :); % report
% color_palette = color_list([5, 5, 5, 5, 5], :); % receiver
color_palette = color_list([1, 1, 1, 1, 1], :); % opensky - smartphone
% color_palette = color_list([2, 2, 2, 2, 2], :); % URBAN
% color_palette = color_list([3, 3, 3, 3, 3], :); % opensky - smartphone



% Define the paths
obs_folder = '.\data\obs\mp_calculated';
result_folder = '.\data\result';

% Get list of .mat files in obs_folder
% files = find_all_files_with_extension(obs_folder, '.mat'); rcv_type =RCV_TYPE_SMARTPHONE;
% files = {'.\data\obs\mp_calculated\smartphone_urban'}; rcv_type =RCV_TYPE_SMARTPHONE;
% files = {'.\data\obs\mp_calculated\smartphone_opensky_sync'}; rcv_type =RCV_TYPE_SMARTPHONE;
% files = {'.\data\obs\mp_calculated\smartphone_opensky'}; rcv_type =RCV_TYPE_SMARTPHONE;
% files = {'.\data\obs\mp_calculated\smartphone_opensky_carrier'}; rcv_type =RCV_TYPE_SMARTPHONE;
files = {'.\data\obs\mp_calculated\receiver_opensky'}; rcv_type =RCV_TYPE_RECEIVER;

% obs_folder = '.\data\obs';
% result_folder = '.\data\result';
% files = {'.\data\obs\midterm_receiver'}; rcv_type =RCV_TYPE_RECEIVER;
% files = {'.\data\obs\midterm_smartphone'}; rcv_type =RCV_TYPE_SMARTPHONE;
% files = {'.\data\obs\smartphone_opensky_carrier'}; rcv_type =RCV_TYPE_SMARTPHONE;
% files = {'.\data\obs\smartphone_opensky'}; rcv_type =RCV_TYPE_SMARTPHONE;


% for i = 1:length(files)
%     file_path = fullfile(files{i});
%     preprocess_dataset_multipath(file_path, rcv_type);
% end

% Process each .mat file
for i = 1:length(files)
    %% Get full file path
    % file_path = fullfile(obs_folder, files(i).name);
    file_path = files{i};
    file_path = fullfile(file_path);  % Normalize

    % 정확한 relative path 추출
    relative_path = strrep(file_path, [obs_folder, filesep], '');
    [relative_dir, file_name, ~] = fileparts(relative_path);

    % 결과 폴더 경로: result/relative_dir/file_name/
    specific_result_folder = fullfile(result_folder, relative_dir, file_name, 'figures_ppt');
    
    % Load the dataset object from the .mat file
    dataset = load(file_path).dataset;
%     dataset = load(file_path);
    
    % Create the specific result folder if it doesn't exist
    if ~exist(specific_result_folder, 'dir')
        mkdir(specific_result_folder);
    end
    
    start = 10;
    duration = double(dataset.time_GPS(end))-30;
%     start = 30*60;
%     duration = 180*60;

    %% plot carrier
    snr_folder = fullfile(specific_result_folder, 'carrier');
    if ~exist(snr_folder, 'dir')
        mkdir(snr_folder);
    end

    for target_frequency = [1]
%         plot_cycle_slip_cmc(dataset, start, duration, snr_folder, target_frequency);
%         plot_cycle_slip_skyplot(dataset, start, duration, snr_folder, target_frequency);
    end

    %% plot snr
    snr_folder = fullfile(specific_result_folder, 'snr');
    if ~exist(snr_folder, 'dir')
        mkdir(snr_folder);
    end

%     plot_snr_elevation_skyplot(dataset, start, duration, snr_folder);
%     plot_snr_elevation_graph(dataset, start, duration, snr_folder);
%     plot_snr_elevation_constellation(dataset, start, duration, snr_folder);
%     plot_snr_time(dataset, start, duration, snr_folder);
    % 
    %% Plot visiblility

    snr_folder = fullfile(specific_result_folder, 'visible');
    if ~exist(snr_folder, 'dir')
        mkdir(snr_folder);
    end
% 
%     plot_visible_sat_num(dataset, start, duration, snr_folder);
%     plot_visible_sat_sum_num(dataset, start, duration, snr_folder);
%     plot_visible_skyplot(dataset, start, duration, snr_folder);
%     plot_visible_prn(dataset, start, duration, snr_folder);

    %% Plot Multipath

    snr_folder = fullfile(specific_result_folder, 'multipath');
    if ~exist(snr_folder, 'dir')
        mkdir(snr_folder);
    end

    for target_frequency = [1]
%            sv_exclude = 14;
%         dataset.mp1(:, sv_exclude) = nan;
%         dataset.mp5(:, sv_exclude) = nan;
%         plot_multipath_snr(dataset, start, duration, snr_folder, target_frequency);
%         plot_multipath_elevation(dataset, start, duration, snr_folder, target_frequency);
%         plot_multipath_time(dataset, start, duration, snr_folder, target_frequency);
%         plot_multipath_snr_error(dataset, start, duration, snr_folder, target_frequency);
%         plot_multipath_elevation_error(dataset, start, duration, snr_folder, target_frequency);
%      
        plot_multipath_histogram(dataset, start, duration, snr_folder, target_frequency, rcv_type);
    end

    %% Doppler

    snr_folder = fullfile(specific_result_folder, 'doppler');
    if ~exist(snr_folder, 'dir')
        mkdir(snr_folder);
    end
% 
%     plot_doppler_by_time(dataset, start, duration, snr_folder, rcv_type);
%     plot_doppler_by_snr(dataset, start, duration, snr_folder, rcv_type);

    %% Doppler - phone vs rcv difference

    file_path_rcv= '.\data\obs\receiver_opensky.mat';
    dataset_rcv = load(file_path_rcv);
%     plot_doppler_diff_by_time(dataset,dataset_rcv, start, duration, snr_folder);
%     plot_doppler_diff_histogram(dataset,dataset_rcv, start, duration, snr_folder);

end

%% Helper

function rinex_files = find_all_files_with_extension(root_dir, extension)
    % 특정 디렉토리와 모든 하위 디렉토리에서 주어진 확장자의 파일을 찾음
    % root_dir: 탐색을 시작할 최상위 디렉토리
    % extension: 찾을 파일의 확장자 (예: '.21o')
    
    % 초기화
    rinex_files = {};  % 셀 배열로 초기화하여 각 파일 경로를 저장
    
    % 현재 디렉토리의 모든 파일과 폴더 가져오기
    items = dir(root_dir);
    
    % 각 항목 검사
    for i = 1:length(items)
        % 현재 항목의 전체 경로
        current_path = fullfile(root_dir, items(i).name);
        
        % 디렉토리인지 검사
        if items(i).isdir
            % '.' 와 '..' 디렉토리는 건너뜀
            if ~ismember(items(i).name, {'.', '..'})
                % 하위 디렉토리에서 재귀적으로 호출
                subdir_files = find_all_files_with_extension(current_path, extension);
                rinex_files = [rinex_files, subdir_files];  % 셀 배열 결합
            end
        elseif endsWith(items(i).name, extension)
            % 파일 확장자가 일치하는 경우, 파일 경로 추가
            rinex_files{end + 1} = current_path;
        end
    end
end

function preprocess_dataset_multipath(file_path, rcv_type)
    %% Get full file path
    % file_path = fullfile(obs_folder, files(i).name);
    RCV_TYPE_SMARTPHONE = 0;
    RCV_TYPE_RECEIVER = 1;

    [folder, base, ~] = fileparts(file_path);


    % Load the dataset object from the .mat file
    dataset = load(file_path);
    
    if (rcv_type == RCV_TYPE_SMARTPHONE)
        dataset = preprocess_dataset(dataset, [[103, 121], [151, 180]]);
    end
    dataset = calculate_multipath_cmc(dataset);

    %save
    savename = fullfile(folder,'mp_calculated', [base, '.mat']);
%     save(savename, 'dataset');
    fprintf("Preprocessed <%s> for MP\n", savename);
end
