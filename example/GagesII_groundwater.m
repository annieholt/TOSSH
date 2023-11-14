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

mydir = 'E:/SDSU_GEOG/Thesis/Data/Gages-II/usgs_streamflow/mm_day';
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


% Load the CSV file into a table
filename_test = '01607500.csv';
opts = detectImportOptions(filename_test)
data = readtable(filename_test, opts);

% Access the columns by variable names
t = datetime(data.datetime);
Q = data.q_mm_day;
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

Recession_a_Seasonality = sig_SeasonalVarRecessions(Q,t, 'plot_results', true)

MRC_num_segments = sig_MRC_SlopeChanges(Q,t, 'plot_results', true)

Spearmans_rho = sig_RecessionUniqueness(Q,t, 'plot_results', true)

VariabilityIndex = sig_VariabilityIndex(Q,t)

BaseflowRecessionK = sig_BaseflowRecessionK(Q, t, 'plot_results', true)


RecessionParametersTemp = sig_RecessionAnalysis(Q,t, 'plot_results', true)
RecessionParameters_1 = median((RecessionParametersTemp(:,1)),'omitnan');
RecessionParameters_2 = median(RecessionParametersTemp(:,2),'omitnan');
% 
% RecessionParametersT0Temp = 1./(RecessionParametersTemp(:,1).*median(Q_mat{i}(Q_mat{i}>0),'omitnan').^(RecessionParametersTemp(:,2)-1));
% ReasonableT0 = and(RecessionParametersTemp(:,2)>0.5,RecessionParametersTemp(:,2)<5);
% RecessionParameters(i,3) = median(RecessionParametersT0Temp(ReasonableT0),'omitnan');

% RecessionParameters_error_str(i) = RecessionParameters_error_str_temp;
% [MRC_num_segments(i),Segment_slopes,~,MRC_num_segments_error_str(i)] = ...
%         sig_MRC_SlopeChanges(Q_mat{i},t_mat{i},'plot_results',plot_results,'eps',eps,'recession_length',recession_length,'n_start',n_start);
% First_Recession_Slope(i) = Segment_slopes(1);
% if length(Segment_slopes) >= 2
%         Mid_Recession_Slope(i) = Segment_slopes(2);
% end

