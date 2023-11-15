% Specify the directory path
directory_path = 'E:/SDSU_GEOG/Thesis/Data/Gages-II/usgs_streamflow_2/mm_day';

% where to save results
out_path = 'E:/SDSU_GEOG/Thesis/Data/Signatures/gages_II';

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

     % Convert the structure to a table
     out_table = struct2table(all_results{i}, "AsArray",true)

     % Extract the numeric part from the file name
     gauge_id_extract = regexp(file_name, '\d+', 'match');
     gauge_id = str2double(gauge_id_extract{1});

     % Save the data to a CSV file with a name based on the numeric part
     output_file_name = fullfile(out_path, sprintf('output_%d.csv', gauge_id));
     writetable(out_table, output_file_name);

end
