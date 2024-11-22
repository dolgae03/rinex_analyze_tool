% Clear existing paths and variables
clear;
clc;

% Add paths for src and utils folders
addpath('./src/doppler');
addpath('./src/sat_num');
addpath('./src/multipath');
addpath('./src/snr');
addpath('./src');
addpath('./utils');
addpath('./navutils');



% Define the paths
obs_folder = './data/obs';
result_folder = './data/result';

% Get list of .mat files in obs_folder
files = dir(fullfile(obs_folder, '*.mat'));

% Process each .mat file
for i = 1:length(files)
    % Get full file path
    file_path = fullfile(obs_folder, files(i).name);
    
    % Load the dataset object from the .mat file
    dataset = load(file_path);
    
    % Remove the .mat extension and create a specific result folder for this file
    [~, name, ~] = fileparts(files(i).name);
    specific_result_folder = fullfile(result_folder, name);
    
    % Create the specific result folder if it doesn't exist
    if ~exist(specific_result_folder, 'dir')
        mkdir(specific_result_folder);
    end

    max_length = length(dataset.pr1) - 50;
    
    % Call plot_visible_sat_num function with dataset and specific result folder
    % 
    % % 
    % plot_pr_carrier_diff(dataset, 10, max_length, specific_result_folder);
    % % continue

    % %% plot snr
    snr_folder = fullfile(specific_result_folder, 'snr');
    if ~exist(snr_folder, 'dir')
        mkdir(snr_folder);
    end
    % 
    % plot_snr_elevation_skyplot(dataset, 10, max_length, snr_folder);
    % plot_snr_elevation_graph(dataset, 10, max_length, snr_folder);
    % plot_snr_elevation_constellation(dataset, 10, max_length, snr_folder);
    % plot_snr_time(dataset, 10, max_length, snr_folder);
    % % 
    %% Plot visiblility

    % snr_folder = fullfile(specific_result_folder, 'visible');
    % if ~exist(snr_folder, 'dir')
    %     mkdir(snr_folder);
    % end

    % plot_visible_sat_num(dataset, 10, max_length, snr_folder);
    plot_visible_sat_sum_num(dataset, 10, max_length, snr_folder);
    % plot_visible_skyplot(dataset, 10, max_length, snr_folder);
    plot_visible_prn(dataset, 10, max_length, snr_folder);
    % 
    %% Plot Multipath

    % snr_folder = fullfile(specific_result_folder, 'multipath');
    % if ~exist(snr_folder, 'dir')
    %     mkdir(snr_folder);
    % end
    % 
    % baseline_dataset = load('./data/obs/sync_baseline.mat');
    % rover_dataset = load('./data/obs/sync_rover.mat');
    % [modified_baseline, modified_rover] = preprocess_multipath(baseline_dataset, rover_dataset, 10, max_length, snr_folder);

    % %% SD
    % snr_folder_temp = fullfile(snr_folder, 'chipset_sd');
    % if ~exist(snr_folder_temp, 'dir')
    %     mkdir(snr_folder_temp);
    % end
    % modified_rover.mp = modified_rover.mp1SD;
    % plot_multipath_snr(modified_rover, 10, max_length, snr_folder_temp);
    % plot_multipath_elevation(modified_rover, 10, max_length, snr_folder_temp);
    % plot_multipath_time(modified_rover, 10, max_length, snr_folder_temp);
    % plot_multipath_snr_error(modified_rover, 10, max_length, snr_folder_temp);
    % plot_multipath_elevation_error(modified_rover, 10, max_length, snr_folder_temp);
    % 
    % % %% DD
    % snr_folder_temp = fullfile(snr_folder, 'chipset_dd');
    % if ~exist(snr_folder_temp, 'dir')
    %     mkdir(snr_folder_temp);
    % end
    % modified_rover.mp = modified_rover.mp1DD;
    % plot_multipath_snr(modified_rover, 10, max_length, snr_folder_temp);
    % plot_multipath_elevation(modified_rover, 10, max_length, snr_folder_temp);
    % plot_multipath_time(modified_rover, 10, max_length, snr_folder_temp);
    % 
    % %% No Difference Baseline
    % snr_folder_temp = fullfile(snr_folder, 'baseline');
    % if ~exist(snr_folder_temp, 'dir')
    %     mkdir(snr_folder_temp);
    % end
    % modified_baseline.mp = modified_baseline.mp1;
    % plot_multipath_snr(modified_baseline, 10, max_length, snr_folder_temp);
    % plot_multipath_elevation(modified_baseline, 10, max_length, snr_folder_temp);
    % plot_multipath_time(modified_baseline, 10, max_length, snr_folder_temp);
    % plot_multipath_snr_error(modified_baseline, 10, max_length, snr_folder_temp);
    % plot_multipath_elevation_error(modified_baseline, 10, max_length, snr_folder_temp);
    % 
    % %% Doppler
    % 
    % snr_folder = fullfile(specific_result_folder, 'doppler');
    % if ~exist(snr_folder, 'dir')
    %     mkdir(snr_folder);
    % end
    % 
    % plot_doppler_by_time(dataset, 10, max_length, snr_folder);
    % plot_doppler_by_snr(dataset, 10, max_length, snr_folder);

    % plot_multipath(dataset, 10, max_length, specific_result_folder);
end