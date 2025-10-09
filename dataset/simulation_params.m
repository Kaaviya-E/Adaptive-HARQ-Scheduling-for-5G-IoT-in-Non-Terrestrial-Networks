% simulation_params.m
params = struct();

% NTN Configuration
params.satellite_altitude = [600, 1200]; % km (LEO600, LEO1200)
params.elevation_angle = 30; % degrees
params.payload_type = 'transparent'; % or 'regenerative'
params.carrier_freq = 2e9; % 2 GHz

% Link Budget Parameters
params.P_EIRP = 23; % dBm
params.G_T = -4.9; % dB/T
params.bandwidth = 180e3; % 180 kHz
params.atm_loss = 0.07; % dB
params.shadow_margin = 3; % dB
params.scint_loss = 2.2; % dB
params.polar_loss = 0; % dB

% IoT Configuration
params.TBS = [144, 504]; % bits
params.modulation = 'QPSK';
params.num_PRB = 1;
params.target_BLER = 0.1; % 10%

% HARQ Parameters
params.N_HARQ_max = [8, 4]; % LTE-M, NB-IoT
params.n_rep_PDCCH = 1;
params.n_rep_PUCCH = 1;
params.N_switch = 1; % switching subframes
params.SF_duration = 1e-3; % 1 ms

% Delay Parameters (legacy fixed values)
params.n_DD2A_fixed = 3;
params.n_UG2D_fixed = 3;
params.N_DG2D = 1;
params.N_A2G = 1;