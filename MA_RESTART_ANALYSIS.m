clear all; close all; clc
%Script for restarting long-running parameter sweeps in case of failure.
%Restarts the sweep index to the most recently run so the seed can be reset
%appropriately.

%% Set All Constants

% Add Directory path for all commonly used functions and constatns
function_dir = 'helper_fns';
addpath(function_dir);

% Load file using the described orbital constants
orbital_constants;

load('running_sims2.mat')

cur_sweep_i = sweep_i;

% %% Run & Solve
% total_time = 0;
% 
% for sweep_i = cur_sweep_i:N_SWEEPS_FS
%     n_images = N_IMAGE_VEC(sweep_i);
%     comms_reward = COMMS_REWARD_VEC(sweep_i);
%     n_sats = N_SATS_VEC(sweep_i);
%     
%     comms_idx = find(comms_reward_vec == comms_reward);
%     image_idx = find(n_image_vec == n_images);
%     sats_idx = find(n_sats_vec == n_sats);
%     
%     %reset seed to have consistency between parameter iterations
%     seed = 277;
%     rng(seed);
%     
%     reward_vec_fs = zeros(num_sims, 1);
%     reward_vec_rule = zeros(num_sims, 1);
%     reward_vec_MCTS = zeros(num_sims, 1);
%     sim_time_fs = zeros(num_sims, 1);
%     sim_time_rule = zeros(num_sims, 1);
%     sim_time_MCTS = zeros(num_sims, 1);
%     
%     cur_orbits = orbits(1:n_sats);
%     cur_s_0 = s_0(1:n_sats);
% 
%     for simulation = 1:num_sims
%         percent_done = ((sweep_i - 1) * num_sims + (simulation - 1)) / (N_SWEEPS_FS * num_sims) * 100
%         if((sweep_i - 1) * num_sims + (simulation - 1) > 0)
%             run_time = total_time
%             est_rem_time = run_time / percent_done * 100
%         end
%         % Get new image opportunity locations
%         new_seed = randi(1000);
%         Images = generate_image_locations(n_images, new_seed);
% 
% 
%         general_params.Images = Images;
%         if run_FS
%             general_params.gamma = gamma_fs;
%             general_params.N_max = N_a_fs;
%             d_solve = d_solve_fs;
%             params = get_mcts_params(cur_orbits, t, general_params, comms_reward);
%             tic
%             policies_FS = MA_smdp_forward_search(cur_s_0, d_solve, params);
%             sim_time_fs(simulation, 1) = toc;
%             total_time = total_time + sim_time_fs(simulation, 1);
%             [total_reward_FS, I_c, n_ground_links, n_actions, n_comms, n_repeats] = MA_parse_policy(policies_FS, params);
%             reward_vec_fs(simulation, 1) = total_reward_FS;
%             SWEEP_RESULTS.FS_results(image_idx, comms_idx, sats_idx, simulation) = total_reward_FS;
%             SWEEP_RESULTS.FS_repeats(image_idx, comms_idx, sats_idx, simulation) = n_repeats;
% %             total_reward_FS
% %             n_ground_links
% %             n_actions
%         end
%         status = "FS Done"
%         
%         if run_Rule
%             general_params.gamma = gamma_fs;
%             general_params.N_max = N_a_fs;
%             d_solve = d_solve_fs;
%             params = get_mcts_params(cur_orbits, t, general_params, comms_reward);
%             tic
%             policies_Rule = MA_smdp_rule_based(cur_s_0, d_solve, params);
%             sim_time_rule(simulation, 1) = toc;
%             total_time = total_time + sim_time_rule(simulation, 1);
% %             [total_reward_Rule, I_c, n_ground_links, n_actions] = parse_policy(policy_Rule, params);
%             [total_reward_Rule, I_c, n_ground_links, n_actions, n_comms, n_repeats] = MA_parse_policy(policies_Rule, params);
%             reward_vec_rule(simulation, 1) = total_reward_Rule;
%             SWEEP_RESULTS.RULE_results(image_idx, comms_idx, sats_idx, simulation) = total_reward_Rule;
%             SWEEP_RESULTS.RULE_repeats(image_idx, comms_idx, sats_idx, simulation) = n_repeats;
% %             total_reward_Rule
% %             n_ground_links
% %             n_actions
%         end
%         status = "RULE Done"
% 
%         if run_MCTS
%             general_params.gamma = gamma_mcts;
%             general_params.N_max = N_a_mcts;
%             d_solve = d_solve_mcts;
%             params = get_mcts_params(cur_orbits, t, general_params, comms_reward);
%             tic
%             policies_MCTS = MA_smdp_MCTS(cur_s_0, d_solve, params);
%             sim_time_MCTS(simulation, 1) = toc;
%             total_time = total_time + sim_time_MCTS(simulation, 1);
% %             [total_reward_MCTS, I_c, n_ground_links, n_actions] = parse_policy(policy_MCTS, params);
%             [total_reward_MCTS, I_c, n_ground_links, n_actions, n_comms, n_repeats] = MA_parse_policy(policies_MCTS, params);
%             reward_vec_MCTS(simulation, 1) = total_reward_MCTS;
%             SWEEP_RESULTS.MCTS_results(image_idx, comms_idx, sats_idx, simulation) = total_reward_MCTS;
%             SWEEP_RESULTS.MCTS_repeats(image_idx, comms_idx, sats_idx, simulation) = n_repeats;
% %             total_reward_MCTS
% %             n_ground_links
% %             n_actions
%         end
%         status = "MCTS Done"
%         
%         if(log_results)
%             save('running_sims2.mat')
%         end
%     end
% 
%     if run_param_sweep && run_FS && (mean(reward_vec_fs) > mean(SWEEP_RESULTS.best_FS_rewards))
%         SWEEP_RESULTS.best_FS_gamma = general_params.gamma;
%         SWEEP_RESULTS.best_FS_d_solve = d_solve;
%         SWEEP_RESULTS.best_FS_NA = general_params.N_max;
%         SWEEP_RESULTS.best_FS_rewards = reward_vec_fs;
%         SWEEP_RESULTS.best_FS_COMMS = comms_reward;
%     end
%     
%     if run_param_sweep && run_MCTS && (mean(reward_vec_MCTS) > mean(SWEEP_RESULTS.best_MCTS_rewards))
%         SWEEP_RESULTS.best_MCTS_gamma = general_params.gamma;
%         SWEEP_RESULTS.best_MCTS_d_solve = d_solve;
%         SWEEP_RESULTS.best_MCTS_NA = general_params.N_max;
%         SWEEP_RESULTS.best_MCTS_rewards = reward_vec_MCTS;
%         SWEEP_RESULTS.best_MCTS_COMMS = comms_reward;
%     end
% 
% end
% 
% %% plot results
% 
% if generate_plots
%     if run_Rule
%         subplot(1,3,1)
%         plot([1:num_sims]', reward_vec_rule, 'b.-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','Rule'); hold on;
%         
%         subplot(1,3,2)
%         plot([1:num_sims]', sim_time_rule, 'b.-', 'markersize', 25, 'linewidth', 1.5); hold on;
%         
%         subplot(1,3,3)
%         plot([1:num_sims]', reward_vec_rule./sim_time_rule, 'b.-', 'markersize', 25, 'linewidth', 1.5); hold on;
%     end
%     if run_FS
%         subplot(1,3,1)
%         plot([1:num_sims]', reward_vec_fs, 'k*-', 'markersize', 10, 'linewidth', 1.5, 'DisplayName','SMDP-FS'); hold on;
%         
%         subplot(1,3,2)
%         plot([1:num_sims]', sim_time_fs, 'k*-', 'markersize', 10, 'linewidth', 1.5); hold on;
%         
%         subplot(1,3,3)
%         plot([1:num_sims]', reward_vec_fs./sim_time_fs, 'k*-', 'markersize', 10, 'linewidth', 1.5); hold on;
%     end
%     if run_MCTS
%         subplot(1,3,1)
%         plot([1:num_sims]', reward_vec_MCTS, 'bd-', 'markersize', 10, 'linewidth', 1.5, 'DisplayName','SMDP-MCTS'); hold on;
%         
%         subplot(1,3,2)
%         plot([1:num_sims]', sim_time_MCTS, 'bd-', 'markersize', 10, 'linewidth', 1.5); hold on;
%         
%         subplot(1,3,3)
%         plot([1:num_sims]', reward_vec_MCTS./sim_time_MCTS, 'bd-', 'markersize', 10, 'linewidth', 1.5); hold on;
%     end
%     
%     subplot(1,3,1)
%     ylabel('Total Reward')
%     set(gca, 'fontsize', 15)
%     legend('location', 'northwest')
%     
%     subplot(1,3,2)
%     xlabel('Simulation Number')
%     ylabel('Runtime (s)')
%     set(gca, 'fontsize', 15)
%     
%     subplot(1,3,3)
%     ylabel('Time-Normalized Reward (s^{-1})')
%     set(gca, 'fontsize', 15)
% end

