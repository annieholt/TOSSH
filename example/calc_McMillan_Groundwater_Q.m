function [results] = calc_McMillan_Groundwater_Q(csv_filename)
    close all
    clc

    % Add directories to path
    mydir = 'E:/SDSU_GEOG/Thesis/Data/Gages-II/usgs_streamflow_2/mm_day';
    cd(mydir)
    addpath(genpath(mydir));

    % Load the CSV file into a table
    opts = detectImportOptions('01017550.csv');
    data = readtable(csv_filename, opts);

    % Access the columns by variable names
    t = datetime(data.datetime);
    Q = data.q_mm_day;
    % Add more variable assignments as needed

    % % Plot data
    % figure('pos',[100 100 350 200])
    % plot(t, Q, 'k-', 'linewidth', 1.0)
    % xlabel('Date')
    % ylabel('Streamflow [mm/day]')

    % Initialize results structure
    results = struct();

    % fill variables with NaNs for now
    Mid_Recession_Slope = NaN;
    Recession_a_Seasonality = NaN;
    Recession_a_Seasonality_error_str = strings;
    RecessionParameters = NaN;
    RecessionParameters_error_str = strings;
    MRC_num_segments = NaN;
    MRC_num_segments_error_str = strings;
    BFI = NaN;
    BFI_error_str = strings;
    BaseflowRecessionK = NaN;
    BaseflowRecessionK_error_str = strings;
    First_Recession_Slope = NaN;
    Mid_Recession_Slope = NaN;
    Spearmans_rho = NaN;
    Spearmans_rho_error_str = strings;
    VariabilityIndex = NaN;
    VariabilityIndex_error_str = strings;

    %% Calculate signatures and store in results
    % Section: Storage (especially groundwater)
    [Recession_a_Seasonality,~,Recession_a_Seasonality_error_str] = ...
        sig_SeasonalVarRecessions(Q,t);
   
    [RecessionParametersTemp,~,~,RecessionParameters_error_str_temp] = ...
        sig_RecessionAnalysis(Q,t);
    RecessionParameters(1) = median((RecessionParametersTemp(:,1)),'omitnan');
    RecessionParameters(2) = median(RecessionParametersTemp(:,2),'omitnan');
    RecessionParametersT0Temp = 1./(RecessionParametersTemp(:,1).*median(Q(Q>0),'omitnan').^(RecessionParametersTemp(:,2)-1));
    ReasonableT0 = and(RecessionParametersTemp(:,2)>0.5,RecessionParametersTemp(:,2)<5);
    RecessionParameters(3) = median(RecessionParametersT0Temp(ReasonableT0),'omitnan');
    RecessionParameters_error_str = RecessionParameters_error_str_temp;
    [MRC_num_segments,Segment_slopes,~,MRC_num_segments_error_str] = ...
        sig_MRC_SlopeChanges(Q,t);
    First_Recession_Slope = Segment_slopes(1);
    if length(Segment_slopes) >= 2
        Mid_Recession_Slope = Segment_slopes(2);
    end
    [Spearmans_rho,~,Spearmans_rho_error_str] = sig_RecessionUniqueness(Q,t);
    [VariabilityIndex,~,VariabilityIndex_error_str] = sig_VariabilityIndex(Q,t);

    % Section: Baseflow
    [BFI,~,BFI_error_str] = sig_BFI(Q,t,'method','UKIH');
    [BaseflowRecessionK,~,BaseflowRecessionK_error_str] = ...
        sig_BaseflowRecessionK(Q, t);


    % add results to struct array
    results.Recession_a_Seasonality = Recession_a_Seasonality;
    results.Recession_a_Seasonality_error_str = Recession_a_Seasonality_error_str;

    results.RecessionParameters = RecessionParameters;
    results.RecessionParameters_error_str = RecessionParameters_error_str;

    results.MRC_num_segments = MRC_num_segments;
    results.MRC_num_segments_error_str = MRC_num_segments_error_str;

    results.BFI = BFI;
    results.BFI_error_str = BFI_error_str;

    results.BaseflowRecessionK = BaseflowRecessionK;
    results.BaseflowRecessionK_error_str = BaseflowRecessionK_error_str;

    results.First_Recession_Slope = First_Recession_Slope;

    results.Mid_Recession_Slope = Mid_Recession_Slope;

    results.Spearmans_rho = Spearmans_rho;
    results.Spearmans_rho_error_str = Spearmans_rho_error_str;

    results.VariabilityIndex = VariabilityIndex;
    results.VariabilityIndex_error_str = VariabilityIndex_error_str;


end
