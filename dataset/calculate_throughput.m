% calculate_throughput.m
function [R, eta_SUF] = calculate_throughput(params, n_rep_data, ...
                                             N_TBPHC, direction, ...
                                             use_variable_delays)
    TBS_bits = params.TBS;
    SF_duration = params.SF_duration;
    
    if strcmp(direction, 'downlink')
        if use_variable_delays
            % Eq. 9
            numerator = N_TBPHC;
            denominator = params.n_rep_PDCCH + params.N_DG2D + ...
                         N_TBPHC * n_rep_data + params.n_rep_PUCCH + ...
                         max(params.n_DD2A_fixed, (N_TBPHC-1)*params.n_rep_PUCCH) + ...
                         2*params.N_switch;
        else
            % Legacy: one TB per HARQ cycle (Eq. 7)
            numerator = 1;
            denominator = params.n_rep_PDCCH + n_rep_data + ...
                         params.n_rep_PUCCH + params.N_DG2D + ...
                         params.n_DD2A_fixed + params.N_switch;
        end
    else % uplink
        if use_variable_delays
            % Eq. 10
            numerator = N_TBPHC;
            denominator = params.n_rep_PDCCH + ...
                         max(params.n_UG2D_fixed, (N_TBPHC-1)*params.n_rep_PDCCH) + ...
                         N_TBPHC * n_rep_data + 2*params.N_switch;
        else
            % Legacy (Eq. 8)
            numerator = 1;
            denominator = params.n_rep_PDCCH + n_rep_data + ...
                         params.n_UG2D_fixed + params.N_switch;
        end
    end
    
    eta_SUF = numerator / denominator;
    
    % Data rate (Eq. 2)
    t_TB = n_rep_data * SF_duration;
    R = eta_SUF * TBS_bits / t_TB; % bits per second
end