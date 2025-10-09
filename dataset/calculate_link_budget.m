% calculate_pathloss.m
function [PL_dB, SNR_dB] = calculate_link_budget(params, altitude_km, elevation_deg)
    % Calculate distance
    earth_radius = 6371;
    elev_rad = deg2rad(elevation_deg);
    d_km = sqrt((earth_radius + altitude_km)^2 - ...
                (earth_radius * cos(elev_rad))^2) - ...
           earth_radius * sin(elev_rad);
    
    % Free space path loss (Eq. 19)
    f_GHz = params.carrier_freq / 1e9;
    PL_dB = 32.45 + 20*log10(f_GHz) + 20*log10(d_km);
    
    % Total losses
    total_loss_dB = PL_dB + params.atm_loss + params.shadow_margin + ...
                    params.scint_loss + params.polar_loss;
    
    % SNR calculation (Eq. 18)
    k = 1.38e-23; % Boltzmann constant
    SNR_linear = (10^(params.P_EIRP/10) * 1e-3) * ...
                 (10^(params.G_T/10)) / ...
                 (10^(total_loss_dB/10) * k * 290 * params.bandwidth);
    
    SNR_dB = 10*log10(SNR_linear);
end