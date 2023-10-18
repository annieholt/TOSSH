function [results] = CAMELS_groundwater_2() 
% calculate McMillan_Groundwater signature for CAMELS catchments
CAMELS_data_all = loadCAMELSstruct();
CAMELS_data = CAMELS_dataprep();
n_CAMELS = 671
for i = 1:n_CAMELS
    Q_mat = {CAMELS_data.Q_mat{1,i}};
    t_mat = {CAMELS_data.t_mat{1,i}};
    P_mat = {CAMELS_data.P_mat{1,i}};
    PET_mat = {CAMELS_data.PET_mat{1,i}};

    gauge_id = CAMELS_data_all.gauge_id(i,1);
    gauge_lat = CAMELS_data_all.gauge_lat(i,1);
    gauge_lon = CAMELS_data_all.gauge_lon(i,1);
    
    results.sigs{i} = calc_McMillan_Groundwater(Q_mat,t_mat,P_mat,PET_mat);
    results.gauge_id{i} = gauge_id;
    results.gauge_lat{i} = gauge_lat;
    results.gauge_lon{i} = gauge_lon;
    
end
