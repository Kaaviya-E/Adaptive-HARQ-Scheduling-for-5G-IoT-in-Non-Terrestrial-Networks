% get_required_repetitions.m
function n_rep = get_required_repetitions(SNR_dB, TBS, target_BLER)
    % Lookup table from Figure 7 (TBS=144) and Figure 8 (TBS=504)
    % Format: [SNR, n_rep for BLER=0.1]
    
    if TBS == 144
        lookup = [-5, 16; 0, 8; 5, 4; 10, 2];
    else % TBS == 504
        lookup = [-10, 32; -5, 16; 0, 8; 5, 4];
    end
    
    % Interpolate
    n_rep = interp1(lookup(:,1), lookup(:,2), SNR_dB, 'linear', 'extrap');
    n_rep = round(n_rep);
    n_rep = max(1, n_rep); % At least 1 repetition
end