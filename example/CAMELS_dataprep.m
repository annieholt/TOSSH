function [results_daily] = CAMELS_dataprep()
% Loading the data might take a few minutes.
CAMELS_data = loadCAMELSstruct(); 
% Note that you can also save the struct file to avoid loading the data
% anew every time you want to work with them.

%% Prep Data Structure for signature calculation
% To use the calculation function calc_Addor.m, we need to create cell
% arrays containing the time series. We use cell arrays since some time
% series might have different lengths. While the length of each row in the 
% cell array can vary, the cell arrays containing the t, Q, P, and PET data
% need to have exactly the same dimensions. We first initialise the cell
% arrays.
n_CAMELS = length(CAMELS_data.gauge_id);

t_mat = cell(n_CAMELS,1);
Q_mat = cell(n_CAMELS,1);
P_mat = cell(n_CAMELS,1);
PET_mat = cell(n_CAMELS,1);
% We then loop over all catchments and extract the time series for each
% catchment. We crop each time series to be from October 1989 to September 
% 2009 (see Addor et al., 2017). 
fprintf('Creating data matrix...\n')
for i = 1:n_CAMELS 
    
    if mod(i,100) == 0 % check progress
        fprintf('%.0f/%.0f\n',i,n_CAMELS)
    end
    
    t = datetime(CAMELS_data.Q{i}(:,1),'ConvertFrom','datenum');
    Q = CAMELS_data.Q{i}(:,2);    
    P = CAMELS_data.P{i}(:,2);
    PET = CAMELS_data.PET{i}(:,2);

    % get subperiod, here from 1 Oct 1989 to 30 Sep 2009
    indices = 1:length(t); 
    start_ind = indices(t==datetime(1989,10,1));
    % in case time series starts after 1 Oct 1989
    if isempty(start_ind); start_ind = 1; end 
    end_ind = indices(t==datetime(2009,9,30));    
    t = t(start_ind:end_ind);
    Q = Q(start_ind:end_ind);
    P = P(start_ind:end_ind);
    PET = PET(start_ind:end_ind);
    % calculate completeness during sub-period
    flow_perc_complete = 100*(1-sum(isnan(Q))./length(Q));
    CAMELS_data.flow_perc_complete(i) = flow_perc_complete;
    
     % add results to struct array, containing all catchment datasets
    results_daily.t_mat{i} = t;
    results_daily.Q_mat{i} = Q;
    results_daily.P_mat{i} = P;
    results_daily.PET_mat{i} = PET;

end
end