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

load('running_sim.mat')

cur_sweep_i = sweep_i;

%% Run & Solve

for sweep_i = cur_sweep_i:N_SWEEPS_FS
    d_solve = D_SOLVE_VEC(sweep_i);
    general_params.N_max = N_A_MAX_VEC(sweep_i);
    general_params.gamma = GAMMA_VEC(sweep_i);
    
    %reset seed to have consistency between parameter iterations
    seed = 277;
    rng(seed);

    for simulation = 1:num_sims
        % Get new image opportunity locations
        new_seed = randi(1000);
        Images = generate_image_locations(n_images, new_seed);
%         params.Image_Opps = collect_image_opportunities(sat_ecef, sat_geod, t,...
%         params.Images, look_angle_min, look_angle_max, image_duration);
    
        general_params.Images = Images;
        params = get_mcts_params(orbits, t, general_params, comms_reward);

        if run_FS   
            tic
            policies_FS = MA_smdp_forward_search(s_0, d_solve, params);
            sim_time_fs(simulation, 1) = toc;
            [total_reward_FS, I_c, n_ground_links, n_actions, n_comms, n_repeats] = MA_parse_policy(policies_FS, params);
            reward_vec_fs(simulation, 1) = total_reward_FS;
            total_reward_FS
            n_ground_links
            n_actions
        end

        if run_Rule
            tic
            policies_Rule = MA_smdp_rule_based(s_0, d_solve, params);
            sim_time_rule(simulation, 1) = toc;
%             [total_reward_Rule, I_c, n_ground_links, n_actions] = parse_policy(policy_Rule, params);
            [total_reward_Rule, I_c, n_ground_links, n_actions, n_comms, n_repeats] = MA_parse_policy(policies_Rule, params);
            reward_vec_rule(simulation, 1) = total_reward_Rule;
            total_reward_Rule
            n_ground_links
            n_actions
        end

        if run_MCTS
            tic
            policies_MCTS = MA_smdp_MCTS(s_0, d_solve, params);
            sim_time_MCTS(simulation, 1) = toc;
%             [total_reward_MCTS, I_c, n_ground_links, n_actions] = parse_policy(policy_MCTS, params);
            [total_reward_MCTS, I_c, n_ground_links, n_actions, n_comms, n_repeats] = MA_parse_policy(policies_MCTS, params);
            reward_vec_MCTS(simulation, 1) = total_reward_MCTS;
            total_reward_MCTS
            n_ground_links
            n_actions
        end
        if(log_results)
            save('running_sim.mat')
        end
    end

    if run_param_sweep && run_FS && (mean(reward_vec_fs) > mean(SWEEP_RESULTS.best_FS_rewards))
        SWEEP_RESULTS.best_FS_gamma = general_params.gamma;
        SWEEP_RESULTS.best_FS_d_solve = d_solve;
        SWEEP_RESULTS.best_FS_NA = general_params.N_max;
        SWEEP_RESULTS.best_FS_rewards = reward_vec_fs;
    end
    
    if run_param_sweep && run_MCTS && (mean(reward_vec_MCTS) > mean(SWEEP_RESULTS.best_MCTS_rewards))
        SWEEP_RESULTS.best_MCTS_gamma = general_params.gamma;
        SWEEP_RESULTS.best_MCTS_d_solve = d_solve;
        SWEEP_RESULTS.best_MCTS_NA = general_params.N_max;
        SWEEP_RESULTS.best_MCTS_rewards = reward_vec_MCTS;
    end

end

%% plot results

if generate_plots
    if run_Rule
        subplot(1,3,1)
        plot([1:num_sims]', reward_vec_rule, 'b.-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','Rule'); hold on;
        
        subplot(1,3,2)
        plot([1:num_sims]', sim_time_rule, 'b.-', 'markersize', 25, 'linewidth', 1.5); hold on;
        
        subplot(1,3,3)
        plot([1:num_sims]', reward_vec_rule./sim_time_rule, 'b.-', 'markersize', 25, 'linewidth', 1.5); hold on;
    end
    if run_FS
        subplot(1,3,1)
        plot([1:num_sims]', reward_vec_fs, 'k*-', 'markersize', 10, 'linewidth', 1.5, 'DisplayName','SMDP-FS'); hold on;
        
        subplot(1,3,2)
        plot([1:num_sims]', sim_time_fs, 'k*-', 'markersize', 10, 'linewidth', 1.5); hold on;
        
        subplot(1,3,3)
        plot([1:num_sims]', reward_vec_fs./sim_time_fs, 'k*-', 'markersize', 10, 'linewidth', 1.5); hold on;
    end
    if run_MCTS
        subplot(1,3,1)
        plot([1:num_sims]', reward_vec_MCTS, 'bd-', 'markersize', 10, 'linewidth', 1.5, 'DisplayName','SMDP-MCTS'); hold on;
        
        subplot(1,3,2)
        plot([1:num_sims]', sim_time_MCTS, 'bd-', 'markersize', 10, 'linewidth', 1.5); hold on;
        
        subplot(1,3,3)
        plot([1:num_sims]', reward_vec_MCTS./sim_time_MCTS, 'bd-', 'markersize', 10, 'linewidth', 1.5); hold on;
    end
    
    subplot(1,3,1)
    ylabel('Total Reward')
    set(gca, 'fontsize', 15)
    legend('location', 'northwest')
    
    subplot(1,3,2)
    xlabel('Simulation Number')
    ylabel('Runtime (s)')
    set(gca, 'fontsize', 15)
    
    subplot(1,3,3)
    ylabel('Time-Normalized Reward (s^{-1})')
    set(gca, 'fontsize', 15)
end

