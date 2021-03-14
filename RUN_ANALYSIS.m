clear all; close all; clc

%% Set All Constants

% Add Directory path for all commonly used functions and constatns
function_dir = 'helper_fns';
addpath(function_dir);

% Load file using the described orbital constants
orbital_constants;

% Set planning horizon with 5 second increments.
n_days = 1;
plan_horizon = 24 * 60 * 60 * n_days;
t = [0:5:plan_horizon];

% Determine orbit over desired time period
h = 500; % Altitude of orbit (km)
r = h + r_e; % Radius of orbit (km)

% Set orbital parameters
a = r;
e = 0;
Omega = deg2rad(90);
omega = deg2rad(45);
incl = deg2rad(90);
nu0 = 0;

% Set numerical convergence constant
epsilon = 10^(-10);

% Set date of epoch
start_date = [3 5 2018];
[lat, lon, h, sat_ecef] = orbit_propagation(a, e, Omega, omega, incl, nu0, t, start_date, epsilon);
sat_geod = [lat; lon; h];

% Initialize the state
t0 = 0;
r0 = sat_ecef(:,1);
s_0 = initialize_state(r0, t0);

% Set problem parameters
params.N_max = 3;
params.N_max_sim = 500;
params.gamma = 0.99;
params.p_min = 0.3;
params.d_max = 0.75;
params.c = 1;
d_solve = 6;

% Get groundstations
params.Gstations = get_USGS_Landsat_Groundstations();
n_images = 100;
params.rewards = ones(1, n_images);

% Image capture requires 30 seconds
image_duration = 30;

% Minimum elevation for ground station contact
min_elev = 5;

% Set max and min look angles required for successfull imaging
look_angle_min = 5;
look_angle_max = 50;

%Set other parameters
params.Station_Opps = collect_groundlink_opportunities(sat_ecef, t,...
    params.Gstations, min_elev, image_duration);
params.slew_rate = 1;
params.t0 = 0;

%% Set Up Simulations & Parameter Sweeps

% USER INPUTS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%flag to run parameter sweeps
run_param_sweep = 0;

%vectors over which to sweep params
gamma_vec = [0.99, 0.995, 0.999];
d_solve_vec = [3, 5, 7];
N_a_max_vec = [3, 4, 5];

%flags to run specific methods
run_FS = 1;
run_Rule = 1;
run_MCTS = 1;

num_sims = 10; %number of simulations run for each method
generate_plots = 1;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%setup sweep variables
if run_param_sweep    
    kk = 1;
    for iter1 = 1:length(gamma_vec)
        for iter2 = 1:length(d_solve_vec)
            for iter3 = 1:length(N_a_max_vec)
                GAMMA_VEC(kk,1) = gamma_vec(iter1);
                D_SOLVE_VEC(kk,1) = d_solve_vec(iter2);
                N_A_MAX_VEC(kk,1) = N_a_max_vec(iter3);
                kk = kk+1;
            end
        end
    end
    N_SWEEPS_FS = kk - 1;
else
    N_SWEEPS_FS = 1;
    GAMMA_VEC = params.gamma;
    D_SOLVE_VEC = d_solve;
    N_A_MAX_VEC = params.N_max;
end

SWEEP_RESULTS = struct();
SWEEP_RESULTS.best_FS_rewards = 0;
SWEEP_RESULTS.best_MCTS_rewards = 0;

%% Run & Solve

for sweep_i = 1:N_SWEEPS_FS
    d_solve = D_SOLVE_VEC(sweep_i);
    params.N_max = N_A_MAX_VEC(sweep_i);
    params.gamma = GAMMA_VEC(sweep_i);
    
    %reset seed to have consistency between parameter iterations
    seed = 277;
    rng(seed);

    for simulation = 1:num_sims
        % Get new image opportunity locations
        new_seed = randi(1000);
        params.Images = generate_image_locations(n_images, new_seed);
        params.Image_Opps = collect_image_opportunities(sat_ecef, sat_geod, t,...
        params.Images, look_angle_min, look_angle_max, image_duration);

        if run_FS   
            tic
            policy_FS = smdp_forward_search(s_0, d_solve, params);
            sim_time_fs(simulation, 1) = toc;
            [total_reward_FS, I_c, n_ground_links, n_actions] = parse_policy(policy_FS, params);
            reward_vec_fs(simulation, 1) = total_reward_FS;
            total_reward_FS
            n_ground_links
            n_actions
        end

        if run_Rule
            tic
            policy_Rule = smdp_rule_based(s_0, d_solve, params);
            sim_time_rule(simulation, 1) = toc;
            [total_reward_Rule, I_c, n_ground_links, n_actions] = parse_policy(policy_Rule, params);
            reward_vec_rule(simulation, 1) = total_reward_Rule;
            total_reward_Rule
            n_ground_links
            n_actions
        end

        if run_MCTS
            tic
            policy_MCTS = smdp_MCTS(s_0, d_solve, params);
            sim_time_MCTS(simulation, 1) = toc;
            [total_reward_MCTS, I_c, n_ground_links, n_actions] = parse_policy(policy_MCTS, params);
            reward_vec_MCTS(simulation, 1) = total_reward_MCTS;
            total_reward_MCTS
            n_ground_links
            n_actions
        end
    end

    if run_param_sweep && run_FS && (mean(reward_vec_fs) > mean(SWEEP_RESULTS.best_FS_rewards))
        SWEEP_RESULTS.best_FS_gamma = params.gamma;
        SWEEP_RESULTS.best_FS_d_solve = d_solve;
        SWEEP_RESULTS.best_FS_NA = params.N_max;
        SWEEP_RESULTS.best_FS_rewards = reward_vec_fs;
    end
    
    if run_param_sweep && run_MCTS && (mean(reward_vec_MCTS) > mean(SWEEP_RESULTS.best_MCTS_rewards))
        SWEEP_RESULTS.best_MCTS_gamma = params.gamma;
        SWEEP_RESULTS.best_MCTS_d_solve = d_solve;
        SWEEP_RESULTS.best_MCTS_NA = params.N_max;
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

