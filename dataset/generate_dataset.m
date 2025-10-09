% generate_dataset.m
clear all; close all; clc;

% Load parameters
simulation_params;

%% Define scenario variations for dataset
scenarios = struct();

% Scenario parameters to vary
scenarios.altitude = [600, 1200]; % km
scenarios.elevation = [10, 30, 50, 70, 90]; % degrees
scenarios.TBS = [144, 504]; % bits
scenarios.payload_type = {'transparent', 'regenerative'};
scenarios.N_TBPHC = [1, 2, 4, 8]; % TBs per HARQ cycle
scenarios.use_bundling = [false, true];
scenarios.n_bundle = [2, 4]; % only used when bundling enabled
scenarios.direction = {'uplink', 'downlink'};

% Initialize dataset
dataset = [];
row_index = 1;

%% Main simulation loop
fprintf('Generating dataset...\n');
total_scenarios = length(scenarios.altitude) * length(scenarios.elevation) * ...
                  length(scenarios.TBS) * length(scenarios.payload_type) * ...
                  length(scenarios.N_TBPHC) * length(scenarios.direction);

progress_count = 0;

for alt = scenarios.altitude
    for elev = scenarios.elevation
        for tbs = scenarios.TBS
            for payload_idx = 1:length(scenarios.payload_type)
                payload = scenarios.payload_type{payload_idx};
                
                % Calculate RTT
                RTT = calculate_rtt(alt, elev, payload);
                
                % Calculate SNR
                [PL_dB, SNR_dB] = calculate_link_budget(params, alt, elev);
                
                % Get required repetitions for this link condition
                n_rep = get_required_repetitions(SNR_dB, tbs, params.target_BLER);
                
                % Skip if repetitions are unrealistic (>128)
                if n_rep > 128
                    continue;
                end
                
                for N_TBPHC = scenarios.N_TBPHC
                    % Check if N_TBPHC is feasible given N_HARQ constraints
                    % From Eq. 11 - simplified check
                    required_HARQ = ceil(N_TBPHC * (1 + RTT/(n_rep * params.SF_duration)));
                    
                    for dir_idx = 1:length(scenarios.direction)
                        direction = scenarios.direction{dir_idx};
                        
                        % Determine max N_HARQ for this system
                        if strcmp(direction, 'uplink')
                            max_N_HARQ = 8; % LTE-M
                        else
                            max_N_HARQ = 8; % Can adjust for NB-IoT (4)
                        end
                        
                        % Skip if required HARQ exceeds max
                        if required_HARQ > max_N_HARQ
                            continue;
                        end
                        
                        % Test both with and without bundling (DL only)
                        bundling_options = [false];
                        if strcmp(direction, 'downlink')
                            bundling_options = scenarios.use_bundling;
                        end
                        
                        for use_bundling = bundling_options
                            
                            bundle_options = [1]; % default
                            if use_bundling
                                bundle_options = scenarios.n_bundle;
                            end
                            
                            for n_bundle = bundle_options
                                
                                % Calculate delays for each TB in the HARQ cycle
                                for j = 1:N_TBPHC
                                    [n_DD2A, n_UG2D] = calculate_variable_delays(...
                                        j, N_TBPHC, n_rep, n_rep, ...
                                        params.n_rep_PUCCH, params.n_rep_PDCCH, ...
                                        params.N_switch, use_bundling, n_bundle);
                                    
                                    % Calculate throughput with variable delays
                                    params.TBS = tbs;
                                    [R_variable, eta_variable] = calculate_throughput(...
                                        params, n_rep, N_TBPHC, direction, true);
                                    
                                    % Calculate throughput with fixed delays (baseline)
                                    [R_fixed, eta_fixed] = calculate_throughput(...
                                        params, n_rep, 1, direction, false);
                                    
                                    % Calculate improvement
                                    throughput_gain_percent = ((R_variable - R_fixed) / R_fixed) * 100;
                                    
                                    % Store in dataset
                                    dataset(row_index).altitude_km = alt;
                                    dataset(row_index).elevation_deg = elev;
                                    dataset(row_index).TBS_bits = tbs;
                                    dataset(row_index).payload_type = payload;
                                    dataset(row_index).RTT_ms = RTT * 1000;
                                    dataset(row_index).path_loss_dB = PL_dB;
                                    dataset(row_index).SNR_dB = SNR_dB;
                                    dataset(row_index).n_repetitions = n_rep;
                                    dataset(row_index).N_TBPHC = N_TBPHC;
                                    dataset(row_index).TB_index = j;
                                    dataset(row_index).direction = direction;
                                    dataset(row_index).use_bundling = use_bundling;
                                    dataset(row_index).n_bundle = n_bundle;
                                    dataset(row_index).n_DD2A = n_DD2A;
                                    dataset(row_index).n_UG2D = n_UG2D;
                                    dataset(row_index).SUF_fixed = eta_fixed;
                                    dataset(row_index).SUF_variable = eta_variable;
                                    dataset(row_index).throughput_fixed_bps = R_fixed;
                                    dataset(row_index).throughput_variable_bps = R_variable;
                                    dataset(row_index).throughput_gain_percent = throughput_gain_percent;
                                    dataset(row_index).N_HARQ_required = required_HARQ;
                                    
                                    row_index = row_index + 1;
                                end
                            end
                        end
                        
                        progress_count = progress_count + 1;
                        if mod(progress_count, 50) == 0
                            fprintf('Progress: %d/%d scenarios completed\n', ...
                                    progress_count, total_scenarios);
                        end
                    end
                end
            end
        end
    end
end

fprintf('Dataset generation complete! Total samples: %d\n', length(dataset));

%% Convert to table for easier manipulation
dataset_table = struct2table(dataset);

% Display first few rows
disp('First 10 rows of dataset:');
disp(dataset_table(1:min(10, height(dataset_table)), :));

%% Save dataset
save('ntn_harq_dataset.mat', 'dataset_table');
writetable(dataset_table, 'ntn_harq_dataset.csv');

fprintf('\nDataset saved as:\n');
fprintf('  - ntn_harq_dataset.mat (MATLAB format)\n');
fprintf('  - ntn_harq_dataset.csv (CSV format)\n');

%% Generate summary statistics
fprintf('\n=== Dataset Summary Statistics ===\n');
fprintf('Total samples: %d\n', height(dataset_table));
fprintf('Altitude range: %d - %d km\n', min(dataset_table.altitude_km), max(dataset_table.altitude_km));
fprintf('Elevation range: %d - %d degrees\n', min(dataset_table.elevation_deg), max(dataset_table.elevation_deg));
fprintf('SNR range: %.2f - %.2f dB\n', min(dataset_table.SNR_dB), max(dataset_table.SNR_dB));
fprintf('Repetitions range: %d - %d\n', min(dataset_table.n_repetitions), max(dataset_table.n_repetitions));
fprintf('Average throughput gain: %.2f%%\n', mean(dataset_table.throughput_gain_percent));
fprintf('Max throughput gain: %.2f%%\n', max(dataset_table.throughput_gain_percent));