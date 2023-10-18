function [results] = CAMELS_groundwater() 
% calculate McMillan_Groundwater signature for CAMELS catchments
CAMELS_data = CAMELS_dataprep();
n_CAMELS = 3;

test = class(CAMELS_data)
test2 = class(CAMELS_data.Q_mat)
fprintf('%.0f/%.0f\n',test, test2)

save('C:/Users/holta/Documents/CAMELS_data.mat','CAMELS_data')

% create consistent cell arrays, calcualte signatures
for i = 1:n_CAMELS
    Q_mat = CAMELS_data.Q_mat{1, i};
    t_mat = CAMELS_data.t_mat{1, i};
    P_mat = CAMELS_data.P_mat{1, i};
    PET_mat = CAMELS_data.PET_mat{1, i};

    test = class(Q_mat)
    fprintf('%.0f/%.0f\n',test)
    
    % results = calc_McMillan_Groundwater(Q_mat,t_mat,P_mat,PET_mat);
    % fprintf('Calculated groundwater signatures...\n')
end
end
