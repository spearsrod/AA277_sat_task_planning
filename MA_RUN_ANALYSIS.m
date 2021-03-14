clear all; close all; clc

%% Set All Constants

% Add Directory path for all commonly used functions and constatns
function_dir = 'helper_fns';
addpath(function_dir);

% Load file using the described orbital constants
orbital_constants;


h = 500;
% Radius of orbit (km)
r = h + r_e;
% Set orbital parameters
n_orbits = 3;
a = repmat(r, 1, n_orbits);
e = zeros(1, n_orbits);
Omega = deg2rad([0, 100, 180]);
omega = deg2rad(repmat(45, 1, n_orbits));
incl = deg2rad([90, 60, 135]);
nu = deg2rad([0, 45, 120]);
n = size(a,2);

OEs = generate_OEs(n, a, e, Omega, omega, incl, nu);
n_days = 1;
% Set date of epoch
start_date = [3 5 2018];
[orbits, t] = generate_n_orbits(n, n_days, OEs, start_date);

general_params.p_min = 0.3;
general_params.d_max = 0.75;
general_params.N_max_sim = 500;
general_params.N_max = 3;
general_params.gamma = 0.99;
d_solve = 3;
% Gstations = [78.2298391 -72.0167; 15.3924483 2.5333; 0 0];
Gstations = get_USGS_Landsat_Groundstations();

% Get image opportunity locations
n_images = 500;
% Images = generate_image_locations(n_images);
rewards = ones(1, n_images);

general_params.Gstations = Gstations;
general_params.rewards = rewards;
% Initialize the state
t0 = 0;
s_0 = MA_initialize_state(orbits, t0, rewards);
comms_reward = 1;

%% Set Up Simulations & Parameter Sweeps

% USER INPUTS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%flag to run parameter sweeps
run_param_sweep = 0;

%vectors over which to sweep params
gamma_vec = [0.99, 0.995, 0.999];
d_solve_vec = [3, 5, 7];
N_a_max_vec = [3, 4, 5];
comms_reward_vec = [-5, -0.5, 0, 0.5, 1, 20];

%flags to run specific methods
run_FS = 1;
run_Rule = 1;
run_MCTS = 1;

num_sims = 2;%10; %number of simulations run for each method
generate_plots = 1;
log_results = 1;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%setup sweep variables
if run_param_sweep    
    kk = 1;
    for iter1 = 1:length(gamma_vec)
        for iter2 = 1:length(d_solve_vec)
            for iter3 = 1:length(N_a_max_vec)
                for iter4 = 1:length(comms_reward_vec)
                    GAMMA_VEC(kk,1) = gamma_vec(iter1);
                    D_SOLVE_VEC(kk,1) = d_solve_vec(iter2);
                    N_A_MAX_VEC(kk,1) = N_a_max_vec(iter3);
                    COMMS_REWARD_VEC(kk,1) = comms_reward_vec(iter4);
                    kk = kk+1;
                end
            end
        end
    end
    N_SWEEPS_FS = kk - 1;
else
    N_SWEEPS_FS = 1;
    GAMMA_VEC = general_params.gamma;
    D_SOLVE_VEC = d_solve;
    N_A_MAX_VEC = general_params.N_max;
    COMMS_REWARD_VEC = 0;
end

SWEEP_RESULTS = struct();
SWEEP_RESULTS.best_FS_rewards = 0;
SWEEP_RESULTS.best_MCTS_rewards = 0;
SWEEP_RESULTS.FS_results = zeros(length(gamma_vec), length(d_solve_vec), length(N_a_max_vec), length(comms_reward_vec), num_sims);
SWEEP_RESULTS.RULE_results = zeros(length(gamma_vec), length(d_solve_vec), length(N_a_max_vec), length(comms_reward_vec), num_sims);
SWEEP_RESULTS.MCTS_results = zeros(length(gamma_vec), length(d_solve_vec), length(N_a_max_vec), length(comms_reward_vec), num_sims);
SWEEP_RESULTS.FS_repeats = zeros(length(gamma_vec), length(d_solve_vec), length(N_a_max_vec), length(comms_reward_vec), num_sims);
SWEEP_RESULTS.RULE_repeats = zeros(length(gamma_vec), length(d_solve_vec), length(N_a_max_vec), length(comms_reward_vec), num_sims);
SWEEP_RESULTS.MCTS_repeats = zeros(length(gamma_vec), length(d_solve_vec), length(N_a_max_vec), length(comms_reward_vec), num_sims);

%% Run & Solve

for sweep_i = 1:N_SWEEPS_FS
    d_solve = D_SOLVE_VEC(sweep_i);
    general_params.N_max = N_A_MAX_VEC(sweep_i);
    general_params.gamma = GAMMA_VEC(sweep_i);
    comms_reward = COMMS_REWARD_VEC(sweep_i);
    gamma_idx = find(gamma_vec == general_params.gamma);
    d_solve_idx = find(d_solve_vec == d_solve);
    N_a_max_idx = find(N_a_max_vec == general_params.N_max);
    comms_idx = find(comms_reward_vec == comms_reward);
    
    %reset seed to have consistency between parameter iterations
    seed = 277;
    rng(seed);
    
    reward_vec_fs = zeros(num_sims, 1);
    reward_vec_rule = zeros(num_sims, 1);
    reward_vec_mcts = zeros(num_sims, 1);
    sim_time_fs = zeros(num_sims, 1);
    sim_time_rule = zeros(num_sims, 1);
    sim_time_mcts = zeros(num_sims, 1);

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
            SWEEP_RESULTS.FS_results(gamma_idx, d_solve_idx, N_a_max_idx, comms_idx, simulation) = total_reward_FS;
            SWEEP_RESULTS.FS_repeats(gamma_idx, d_solve_idx, N_a_max_idx, comms_idx, simulation) = n_repeats;
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
            SWEEP_RESULTS.RULE_results(gamma_idx, d_solve_idx, N_a_max_idx, comms_idx, simulation) = total_reward_Rule;
            SWEEP_RESULTS.RULE_repeats(gamma_idx, d_solve_idx, N_a_max_idx, comms_idx, simulation) = n_repeats;
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
            SWEEP_RESULTS.MCTS_results(gamma_idx, d_solve_idx, N_a_max_idx, comms_idx, simulation) = total_reward_MCTS;
            SWEEP_RESULTS.MCTS_repeats(gamma_idx, d_solve_idx, N_a_max_idx, comms_idx, simulation) = n_repeats;
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
        SWEEP_RESULTS.best_FS_COMMS = comms_reward;
    end
    
    if run_param_sweep && run_MCTS && (mean(reward_vec_MCTS) > mean(SWEEP_RESULTS.best_MCTS_rewards))
        SWEEP_RESULTS.best_MCTS_gamma = general_params.gamma;
        SWEEP_RESULTS.best_MCTS_d_solve = d_solve;
        SWEEP_RESULTS.best_MCTS_NA = general_params.N_max;
        SWEEP_RESULTS.best_MCTS_rewards = reward_vec_MCTS;
        SWEEP_RESULTS.best_MCTS_COMMS = comms_reward;
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

