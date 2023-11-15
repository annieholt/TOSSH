% Specify the directory path
directory_path = 'E:/SDSU_GEOG/Thesis/Data/Gages-II/usgs_streamflow_2/mm_day';

% Get a list of all CSV files in the directory
csv_files = dir(fullfile(directory_path, '*.csv'));

% Initialize a cell array to store the results for each file
all_results = cell(length(csv_files), 1);

% Loop through each CSV file
for i = 1:length(csv_files)
     % Get the current file name without the path
     file_name = csv_files(i).name;

    % Call the function and store the results
    all_results{i} = calc_McMillan_Groundwater_Q(file_name);
end