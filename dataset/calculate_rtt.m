% calculate_rtt.m
function RTT = calculate_rtt(altitude_km, elevation_deg, payload_type)
    % Calculate distance
    earth_radius = 6371; % km
    elev_rad = deg2rad(elevation_deg);
    
    d = sqrt((earth_radius + altitude_km)^2 - ...
             (earth_radius * cos(elev_rad))^2) - ...
        earth_radius * sin(elev_rad);
    
    % One-way propagation time
    c = 3e8; % speed of light m/s
    t_prop = (d * 1000) / c;
    
    % Add processing delay for transparent payload
    if strcmp(payload_type, 'transparent')
        t_proc = t_prop; % Double the propagation time
    else
        t_proc = 0.001; % 1ms for regenerative
    end
    
    RTT = 2 * t_prop + t_proc; % seconds
end

