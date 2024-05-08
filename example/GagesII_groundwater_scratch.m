%% TOSSH workflow for USGS Gages-I data, groundwater signatures
%
%   This script is adapated based on the example workflows to calculate
%   McMillan groundwater signatures for USGS Gages-II stations based on
%   streamflow timeseries. For now, only signatures that only require
%   streamflow data are calcualted.

close all
% clear all
clc

%% Check if required MATLAB toolboxes are installed
% Required are:
%   - MATLAB (TOSSH was developed using Matlab R2020a)
%   - Statistics and Machine Learning Toolbox
%   - Optimization Toolbox
% We can check which toolboxes we have installed using "ver".
% ver

%% Add directories to path
% We navigate to the TOSSH directory and add it to the Matlab path. 
% If we already are in this directory, we can use the pwd command:
% mydir = pwd;
% Alternatively, we can specify my_dir manually:
% mydir = 'D:/Sebastian/Documents/MATLAB/TOSSH';

% path_observed_time_series = "E:/SDSU_GEOG/Thesis/Data/CAMELS/camels-20230412T1401Z/basin_timeseries_v1p2_metForcing_obsFlow/basin_dataset_public_v1p2/usgs_streamflow/"

% mydir = 'E:/SDSU_GEOG/Thesis/Data/Gages-II/usgs_streamflow_2/mm_day';
mydir = 'E:/SDSU_GEOG/Thesis/Data/Signatures/camels_data_prepped'
cd(mydir)
addpath(genpath(mydir));

%% Input data
% Every signature requires a streamflow (Q) time series and a corresponding 
% date vector (t). The date vector should be in datetime format, but 
% datenum format is also accepted and internally converted. Here is an 
% example of Q and t vectors in the correct format:
%Q = [1.14;1.07;2.39;2.37;1.59;1.25;1.35;1.16;1.27;1.14]; 
%t = [datetime(1999,10,1,0,0,0):datetime(1999,10,10,0,0,0)]';

% Typically, users will have their own data which they want to analyse. 
% We provide an example file to get a more realistic time series.
% The example file also contains precipitation (P), potential
% evapotranspiration (PET), and temperature (T) data, which are required 
% for some signatures. The paths are relative and assume that we are in 
% the TOSSH directory.
% path = './example/example_data/'; % specify path
% data = load(strcat(path,'33029_daily.mat')); % load data

% % load example data for now, make sure in double and datetime formats
% data = load('./matdata_test_2.mat'); % load data
% t = datetime(data.datetime);
% Q = data.Q; % streamflow [mm/day]


% % Load the CSV file into a table
% filename_test = '01017550.csv';
% opts = detectImportOptions(filename_test)
% 
% % filename_new = '01021470.csv'
% filename_new = '04136000.csv'
% data = readtable(filename_new, opts);
% 
% % Access the columns by variable names
% t = datetime(data.datetime);
% Q = data.q_mm_day;

% worflow for CAMELS streamflow data instead, where just have exported
% daily flow data;

% filename_camels = '5057200.csv'
% data_flow = readtable(filename_camels)
% Q = data_flow.Var1

subdir_flow = 'streamflow_1989_2009';
filename_camels_flow = fullfile(subdir_flow, '5057200.csv');
data_flow = readtable(filename_camels_flow);
Q = data_flow.Var1;

subdir_precip = 'precipitation_1989_2009';
filename_camels_precip = fullfile(subdir_precip, '5057200.csv'); 
data_precip = readtable(filename_camels_precip);
P = data_precip.Var1;

start_date = datetime(1989, 10, 1);
end_date = datetime(2009, 9, 30);
% Calculate the total number of days
total_days = days(end_date - start_date) + 1;
% Generate daily datetimes
t = start_date + caldays(0:total_days-1);


% Add more variable assignments as needed

% Now you can work with the variables

% P = data.P; % precipitation [mm/day]
% Note: PET and T example data are provided but not used here.
% PET = data.PET; % potential evapotranspiration [mm/day]
% T = data.T; % temperature [degC]

%% Plot data
% We can plot the data to get a first idea of the hydrograph.
figure('pos',[100 100 350 200])
plot(t,Q,'k-','linewidth',1.0)
xlabel('Date')
ylabel('Streamflow [mm/day]')

% More information on the input data can be found here:
% https://TOSSHtoolbox.github.io/TOSSH/p1_overview.html.

%% Calculate signatures

recession_length = 5;
n_start = 1;
eps = 0;

% Some signatures can be calculated using different methods and/or
% parameter values. For example, there are different options to calculate 
% the baseflow index (BFI). The default method is the UKIH smoothed minima 
% method with a parameter of 5 days.
BFI_UKIH = sig_BFI(Q,t, 'plot_results',true);
% Alternatively, we can use the Lyne-Hollick filter with a filter parameter 
% of 0.925.
BFI_LH = sig_BFI(Q,t,'method','Lyne_Hollick','plot_results',true);
% We can also change the parameter value of the UKIH method to 10 days.
BFI_UKIH10 = sig_BFI(Q,t,'method','UKIH','parameters',10);
% As we can see, all three options lead to slightly different values.
% More details and examples on the different methods/parameters can be
% found in the code of each function (e.g. sig_BFI.m).

Recession_a_Seasonality = sig_SeasonalVarRecessions(Q,t, 'plot_results', true, 'eps',eps,'recession_length',recession_length,'n_start',n_start)

MRC_num_segments = sig_MRC_SlopeChanges(Q,t, 'plot_results', true, 'eps',eps,'recession_length',recession_length,'n_start',n_start)

Spearmans_rho = sig_RecessionUniqueness(Q,t, 'plot_results', true, 'eps',eps,'recession_length',recession_length,'n_start',n_start)

VariabilityIndex = sig_VariabilityIndex(Q,t)

BaseflowRecessionK = sig_BaseflowRecessionK(Q, t, 'plot_results', true, 'eps',eps,'recession_length',recession_length,'n_start',n_start)

EventRR = sig_EventRR(Q,t,P, 'plot_results', true)

[RecessionParametersTemp,~,~,RecessionParameters_error_str_temp] = ...
    sig_RecessionAnalysis(Q,t, 'plot_results', true, 'eps',eps,'recession_length',recession_length,'n_start',n_start);
RecessionParameters(1) = median((RecessionParametersTemp(:,1)),'omitnan');
RecessionParameters(2) = median(RecessionParametersTemp(:,2),'omitnan');
RecessionParametersT0Temp = 1./(RecessionParametersTemp(:,1).*median(Q(Q>0),'omitnan').^(RecessionParametersTemp(:,2)-1));
ReasonableT0 = and(RecessionParametersTemp(:,2)>0.5,RecessionParametersTemp(:,2)<5);
RecessionParameters(3) = median(RecessionParametersT0Temp(ReasonableT0),'omitnan');
RecessionParameters_error_str = RecessionParameters_error_str_temp;
[MRC_num_segments,Segment_slopes,~,MRC_num_segments_error_str] = ...
    sig_MRC_SlopeChanges(Q,t,'plot_results',true,'eps',eps,'recession_length',recession_length,'n_start',n_start);
First_Recession_Slope = Segment_slopes(1);
if length(Segment_slopes) >= 2
    Mid_Recession_Slope = Segment_slopes(2);
end
