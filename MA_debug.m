clear all; close all; clc

%% Set All Constants

% Add Directory path for all commonly used functions and constatns
function_dir = 'helper_fns';
addpath(function_dir);

% Load file using the described orbital constants
orbital_constants;

load('running_sims6.mat');
h = 500;
% Radius of orbit (km)
r = h + r_e;
% Set orbital parameters
max_orbits = 15;
a = repmat(r, 1, max_orbits);
e = zeros(1, max_orbits);
Omega = deg2rad(rand(1, max_orbits) * 180);
Omega(1) = deg2rad(45);
Omega(2) = deg2rad(0);
Omega(3) = deg2rad(0);
Omega(4) = deg2rad(55);
omega = deg2rad(rand(1, max_orbits) * 180);
omega(1) = deg2rad(0);
omega(2) = deg2rad(0);
omega(3) = deg2rad(30);
omega(4) = deg2rad(15);
incl = deg2rad(rand(1, max_orbits) * 180);
incl(1) = deg2rad(90);
incl(2) = deg2rad(90);
incl(3) = deg2rad(135);
incl(4) = deg2rad(170);
nu = deg2rad(rand(1, max_orbits) * 360);
nu(1) = 0;
nu(2) = deg2rad(0);
nu(3) = deg2rad(0);
nu(4) = deg2rad(10);
n = size(a,2);

OEs = generate_OEs(n, a, e, Omega, omega, incl, nu);
n_days = 0.5;
% Set date of epoch
start_date = [3 5 2018];
[orbits, t] = generate_n_orbits(n, n_days, OEs, start_date);
min_dist = 5000;

params = get_mcts_params(orbits(1:4), t, general_params, comms_reward);
% hi = size(params{1}.Comms_Opps)
% hi2 = size(params{2}.Comms_Opps)
% size(params{3}.Comms_Opps)
figure
% Plot the orbit in geodetic coordinates
hold on;
for idx = 1:4
    cur_orbit = orbits{idx}.sat_geod;
    long_geod = cur_orbit(2,:);
    lat_geod = cur_orbit(1,:);
    plot(long_geod, lat_geod);
end
legend('Sat 1', 'Sat 2', 'Sat 3', 'Sat 4', 'AutoUpdate','off');


% Load and plot MATLAB built-in Earth topography data
load('topo.mat', 'topo');
topoplot = [topo(:, 181:360), topo(:, 1:180)];
contour(-180:179, -90:89, topoplot, [0, 0], 'black');

axis equal
grid on
xlim([-180, 180]);
ylim([-90, 90]);
xlabel('Longitude [\circ]');
ylabel('Latitude [\circ]');

figure
subplot(2,3,1)
plot_comms_opportunities(orbits{1}, orbits{2}, min_dist);
hold on;
plot_comms_opportunities(orbits{2}, orbits{1}, min_dist);
title('Comms Opportunities Between Sats 1,2')
subplot(2,3,2)
plot_comms_opportunities(orbits{1}, orbits{3}, min_dist);
hold on;
plot_comms_opportunities(orbits{3}, orbits{1}, min_dist);
title('Comms Opportunities Between Sats 1,3')
subplot(2,3,3)
plot_comms_opportunities(orbits{1}, orbits{4}, min_dist);
hold on;
plot_comms_opportunities(orbits{4}, orbits{1}, min_dist);
title('Comms Opportunities Between Sats 1,4')
subplot(2,3,4)
plot_comms_opportunities(orbits{2}, orbits{3}, min_dist);
hold on;
plot_comms_opportunities(orbits{3}, orbits{2}, min_dist);
title('Comms Opportunities Between Sats 2,3')
subplot(2,3,5)
plot_comms_opportunities(orbits{2}, orbits{4}, min_dist);
hold on;
plot_comms_opportunities(orbits{4}, orbits{2}, min_dist);
title('Comms Opportunities Between Sats 2,4')
subplot(2,3,6)
plot_comms_opportunities(orbits{3}, orbits{4}, min_dist);
hold on;
plot_comms_opportunities(orbits{4}, orbits{3}, min_dist);
title('Comms Opportunities Between Sats 3,4')

n_sats_vec = [3];

general_params.p_min = 0.3;
general_params.d_max = 0.75;
general_params.N_max_sim = 100;
% general_params.N_max = 3;
% general_params.gamma = 0.99;
d_solve = 3;
% Gstations = [78.2298391 -72.0167; 15.3924483 2.5333; 0 0];
Gstations = get_USGS_Landsat_Groundstations();

% Get image opportunity locations
%n_images = 200;
n_image_vec = [500];%[1000, 500, 200];
% Images = generate_image_locations(n_images);
%rewards = ones(1, n_images);

general_params.Gstations = Gstations;
%general_params.rewards = rewards;
% Initialize the state
%comms_reward = 1;

%% Set Up Simulations & Parameter Sweeps

% USER INPUTS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%flag to run parameter sweeps
run_param_sweep = 1;

%vectors over which to sweep params
gamma_fs = 0.99;
gamma_mcts = 0.99;
d_solve_fs = 3;
d_solve_mcts = 3;
N_a_fs = 3;
N_a_mcts = 3;
comms_reward_vec = [-1e6, 0 10, 50, 100];

%flags to run specific methods
run_FS = 1;
run_Rule = 0;
run_MCTS = 0;

num_sims = 5;%5; %number of simulations run for each method
generate_plots = 1;
log_results = 1;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%setup sweep variables
if run_param_sweep    
    kk = 1;
    for iter1 = 1:length(n_image_vec)
        for iter2 = 1:length(comms_reward_vec)
            for iter3 = 1:length(n_sats_vec)
                    N_IMAGE_VEC(kk, 1) = n_image_vec(iter1);
                    COMMS_REWARD_VEC(kk,1) = comms_reward_vec(iter2);
                    N_SATS_VEC(kk, 1) = n_sats_vec(iter3);
                    kk = kk+1;
            end
        end
    end
    N_SWEEPS_FS = kk - 1;
else
    N_SWEEPS_FS = 1;
    N_IMAGE_VEC = n_image_vec(1);
    COMMS_REWARD_VEC = comms_reward_vec(1);
    N_SATS_VEC = n_sats_vec(1);
end

SWEEP_RESULTS = struct();
SWEEP_RESULTS.best_FS_rewards = 0;
SWEEP_RESULTS.best_MCTS_rewards = 0;
SWEEP_RESULTS.FS_results = zeros(length(n_image_vec), length(comms_reward_vec), length(n_sats_vec), num_sims);
SWEEP_RESULTS.RULE_results = zeros(length(n_image_vec), length(comms_reward_vec), length(n_sats_vec), num_sims);
SWEEP_RESULTS.MCTS_results = zeros(length(n_image_vec), length(comms_reward_vec), length(n_sats_vec), num_sims);
SWEEP_RESULTS.FS_repeats = zeros(length(n_image_vec), length(comms_reward_vec), length(n_sats_vec),  num_sims);
SWEEP_RESULTS.RULE_repeats = zeros(length(n_image_vec), length(comms_reward_vec), length(n_sats_vec), num_sims);
SWEEP_RESULTS.MCTS_repeats = zeros(length(n_image_vec), length(comms_reward_vec), length(n_sats_vec), num_sims);
SWEEP_RESULTS.FS_time = zeros(length(n_image_vec), length(comms_reward_vec), length(n_sats_vec),  num_sims);
SWEEP_RESULTS.RULE_time = zeros(length(n_image_vec), length(comms_reward_vec), length(n_sats_vec), num_sims);
SWEEP_RESULTS.MCTS_time = zeros(length(n_image_vec), length(comms_reward_vec), length(n_sats_vec), num_sims);
SWEEP_RESULTS.FS_unique = zeros(length(n_image_vec), length(comms_reward_vec), length(n_sats_vec),  num_sims);
SWEEP_RESULTS.FS_comms = zeros(length(n_image_vec), length(comms_reward_vec), length(n_sats_vec),  num_sims);
SWEEP_RESULTS.RULE_unique = zeros(length(n_image_vec), length(comms_reward_vec), length(n_sats_vec), num_sims);
SWEEP_RESULTS.MCTS_unique = zeros(length(n_image_vec), length(comms_reward_vec), length(n_sats_vec), num_sims);
SWEEP_RESULTS.FS_comms_times = cell(length(n_image_vec), length(comms_reward_vec), length(n_sats_vec), num_sims);

FS_power = cell(length(n_image_vec), num_sims, length(n_sats_vec), length(comms_reward_vec));
init_pow_sz = size(FS_power);
FS_data = cell(length(n_image_vec), num_sims, length(n_sats_vec), length(comms_reward_vec));

%% Run & Solverewards
total_time = 0;

for sweep_i = 1:N_SWEEPS_FS
    n_images = N_IMAGE_VEC(sweep_i);
    comms_reward = COMMS_REWARD_VEC(sweep_i);
    n_sats = N_SATS_VEC(sweep_i);
    
    comms_idx = find(comms_reward_vec == comms_reward);
    image_idx = find(n_image_vec == n_images);
    sats_idx = find(n_sats_vec == n_sats);
    
    %reset seed to have consistency between parameter iterations
    seed = 14;
    rng(seed);
    
    reward_vec_fs = zeros(num_sims, 1);
    reward_vec_rule = zeros(num_sims, 1);
    reward_vec_MCTS = zeros(num_sims, 1);
    sim_time_fs = zeros(num_sims, 1);
    sim_time_rule = zeros(num_sims, 1);
    sim_time_MCTS = zeros(num_sims, 1);
    
    t0 = 0;
    rewards = ones(1, n_images) * 1;
    general_params.rewards = rewards;
    s_0 = MA_initialize_state(orbits, t0, rewards);
    
    cur_orbits = orbits(1:n_sats);
    cur_s_0 = s_0(1:n_sats);

    for simulation = 1:num_sims
        percent_done = ((sweep_i - 1) * num_sims + (simulation - 1)) / (N_SWEEPS_FS * num_sims) * 100
        if((sweep_i - 1) * num_sims + (simulation - 1) > 0)
            run_time = total_time
            est_rem_time = run_time / percent_done * 100 - run_time
        end
        % Get new image opportunity locations
        new_seed = randi(1000);
        Images = generate_image_locations(n_images, new_seed);
        plot(Images(2,:), Images(1,:), '*');


        general_params.Images = Images;
        if run_FS
            general_params.gamma = gamma_fs;
            general_params.N_max = N_a_fs;
            d_solve = d_solve_fs;
            params = get_mcts_params(cur_orbits, t, general_params, comms_reward);
%             hmmm1 = size(params{1}.Comms_Opps)
%             hmmm2 = size(params{2}.Comms_Opps)
            size(params{3}.Comms_Opps)
            tic
            policies_FS = MA_smdp_forward_search(cur_s_0, d_solve, params);
            sim_time_fs(simulation, 1) = toc;
            total_time = total_time + sim_time_fs(simulation, 1);
            [total_reward_FS, I_c, n_ground_links, n_actions, n_comms, n_repeats, comms_times, n_photos, n_sun_point] = MA_parse_policy(policies_FS, params);
            [p_t, d_t] = MA_get_profiles(policies_FS, t);
            if(total_reward_FS < 0)
                hmmmmmmm = 1;
            end
%             p_t
%             size(p_t)
%             size(FS_power)
            FS_power{image_idx, sats_idx, simulation, comms_idx} = p_t;
%             size(FS_power)
            FS_data{image_idx, sats_idx, simulation, comms_idx} = d_t;
%             data_sz = size(FS_data)
            reward_vec_fs(simulation, 1) = total_reward_FS;
            SWEEP_RESULTS.FS_results(image_idx, comms_idx, sats_idx, simulation) = total_reward_FS;
            SWEEP_RESULTS.FS_repeats(image_idx, comms_idx, sats_idx, simulation) = n_repeats;
            SWEEP_RESULTS.FS_time(image_idx, comms_idx, sats_idx, simulation) = sim_time_fs(simulation, 1);
            SWEEP_RESULTS.FS_unique(image_idx, comms_idx, sats_idx, simulation) = size(I_c, 2);
            SWEEP_RESULTS.FS_comms(image_idx, comms_idx, sats_idx, simulation) = sum(n_comms);
            SWEEP_RESULTS.FS_comms_times{image_idx, comms_idx, sats_idx, simulation} = comms_times;
            SWEEP_RESULTS.FS_gstations(image_idx, comms_idx, sats_idx, simulation) = sum(n_ground_links);
            SWEEP_RESULTS.FS_images(image_idx, comms_idx, sats_idx, simulation) = sum(n_photos);
            SWEEP_RESULTS.FS_sun_points(image_idx, comms_idx, sats_idx, simulation) = sum(n_sun_point);
%             total_reward_FS
%             n_ground_links
%             n_actions
        end
        status = "FS Done"
        
        if run_Rule
            general_params.gamma = gamma_fs;
            general_params.N_max = N_a_fs;
            d_solve = d_solve_fs;
            params = get_mcts_params(cur_orbits, t, general_params, comms_reward);
            tic
            policies_Rule = MA_smdp_rule_based(cur_s_0, d_solve, params);
            sim_time_rule(simulation, 1) = toc;
            total_time = total_time + sim_time_rule(simulation, 1);
%             [total_reward_Rule, I_c, n_ground_links, n_actions] = parse_policy(policy_Rule, params);
            [total_reward_Rule, I_c, n_ground_links, n_actions, n_comms, n_repeats] = MA_parse_policy(policies_Rule, params);
            cur_comms_reward = comms_reward
            rule_actions = n_actions
            rule_images = size(I_c)
            cur_repeats = n_repeats
            cur_comms = n_comms
            reward_vec_rule(simulation, 1) = total_reward_Rule;
            SWEEP_RESULTS.RULE_results(image_idx, comms_idx, sats_idx, simulation) = total_reward_Rule;
            SWEEP_RESULTS.RULE_repeats(image_idx, comms_idx, sats_idx, simulation) = n_repeats;
            SWEEP_RESULTS.RULE_time(image_idx, comms_idx, sats_idx, simulation) = sim_time_rule(simulation, 1);
%             total_reward_Rule
%             n_ground_links
%             n_actions
        end
        status = "RULE Done"

        if run_MCTS
            general_params.gamma = gamma_mcts;
            general_params.N_max = N_a_mcts;
            d_solve = d_solve_mcts;
            params = get_mcts_params(cur_orbits, t, general_params, comms_reward);
            tic
            policies_MCTS = MA_smdp_MCTS(cur_s_0, d_solve, params);
            sim_time_MCTS(simulation, 1) = toc;
            total_time = total_time + sim_time_MCTS(simulation, 1);
%             [total_reward_MCTS, I_c, n_ground_links, n_actions] = parse_policy(policy_MCTS, params);
            [total_reward_MCTS, I_c, n_ground_links, n_actions, n_comms, n_repeats] = MA_parse_policy(policies_MCTS, params);
            reward_vec_MCTS(simulation, 1) = total_reward_MCTS;
            SWEEP_RESULTS.MCTS_results(image_idx, comms_idx, sats_idx, simulation) = total_reward_MCTS;
            SWEEP_RESULTS.MCTS_repeats(image_idx, comms_idx, sats_idx, simulation) = n_repeats;
            SWEEP_RESULTS.MCTS_time(image_idx, comms_idx, sats_idx, simulation) = sim_time_MCTS(simulation, 1);
%             total_reward_MCTS
%             n_ground_links
%             n_actions
        end
        status = "MCTS Done"
        
        if(log_results)
            save('running_sims11.mat')
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
figure
sgtitle('Constant Comms Reward') 
if generate_plots
    if run_Rule
        subplot(1,3,1)
        plot([1:length(comms_reward_vec)]', SWEEP_RESULTS.RULE_results(1,:,1,1))%, 'b.-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','Rule'); hold on;
%         plot([1:num_sims]', reward_vec_rule, 'b.-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','Rule');
        
        subplot(1,3,2)
        plot([1:length(comms_reward_vec)]', SWEEP_RESULTS.RULE_time(1,:,1,1))%, 'b.-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','Rule'); hold on;
%         plot([1:num_sims]', sim_time_rule, 'b.-', 'markersize', 25, 'linewidth', 1.5); hold on;
        
        subplot(1,3,3)
        plot([1:length(comms_reward_vec)]', SWEEP_RESULTS.RULE_repeats(1,:,1,1))%, 'b.-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','Rule'); hold on;
%         plot([1:num_sims]', reward_vec_rule./sim_time_rule, 'b.-', 'markersize', 25, 'linewidth', 1.5); hold on;
    end
    if run_FS
        subplot(2,3,1)
%         errorbar(x, y, yerr,
%         plot([1:length(comms_reward_vec)], mean(SWEEP_RESULTS.FS_results(1,:,1,:), 4), 'k*-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','FS'); hold on;
        errorbar([1:length(comms_reward_vec)], mean(SWEEP_RESULTS.FS_results(1,:,1,:), 4), std(SWEEP_RESULTS.FS_results(1,:,1,:), 0,4), 'k*-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','FS'); hold on;

        
        subplot(2,3,2)
%         plot([1:length(comms_reward_vec)], mean(SWEEP_RESULTS.FS_time(1,:,1,:), 4), 'k*-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','FS'); hold on;
        errorbar([1:length(comms_reward_vec)], mean(SWEEP_RESULTS.FS_time(1,:,1,:), 4), std(SWEEP_RESULTS.FS_time(1,:,1,:), 0,4), 'k*-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','FS'); hold on;


        subplot(2,3,3)
%         plot([1:length(comms_reward_vec)], mean(SWEEP_RESULTS.FS_repeats(1,:,1,:), 4), 'k*-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','FS'); hold on;
        errorbar([1:length(comms_reward_vec)], mean(SWEEP_RESULTS.FS_repeats(1,:,1,:), 4), std(SWEEP_RESULTS.FS_repeats(1,:,1,:), 0,4), 'k*-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','FS'); hold on;
        
                
        subplot(2,3,4)
%         plot([1:length(comms_reward_vec)], mean(SWEEP_RESULTS.FS_unique(1,:,1,:), 4),'k*-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','FS'); hold on;
        errorbar([1:length(comms_reward_vec)], mean(SWEEP_RESULTS.FS_unique(1,:,1,:), 4), std(SWEEP_RESULTS.FS_unique(1,:,1,:), 0,4), 'k*-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','FS'); hold on;

        
        subplot(2,3,5)
%         plot([1:length(comms_reward_vec)], mean(SWEEP_RESULTS.FS_comms(1,:,1,:), 4), '*-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','FS'); hold on;
%         plot([1:length(comms_reward_vec)], mean(SWEEP_RESULTS.FS_gstations(1,:,1,:), 4), '*-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','FS'); hold on;
%         plot([1:length(comms_reward_vec)], mean(SWEEP_RESULTS.FS_images(1,:,1,:), 4), '*-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','FS'); hold on;
%         plot([1:length(comms_reward_vec)], mean(SWEEP_RESULTS.FS_sun_points(1,:,1,:), 4), '*-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','FS'); hold on;
        errorbar([1:length(comms_reward_vec)], mean(SWEEP_RESULTS.FS_comms(1,:,1,:), 4), std(SWEEP_RESULTS.FS_comms(1,:,1,:), 0, 4), '*-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','FS'); hold on;
        errorbar([1:length(comms_reward_vec)], mean(SWEEP_RESULTS.FS_gstations(1,:,1,:), 4), std(SWEEP_RESULTS.FS_gstations(1,:,1,:), 0, 4), '*-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','FS'); hold on;
        errorbar([1:length(comms_reward_vec)], mean(SWEEP_RESULTS.FS_images(1,:,1,:), 4), std(SWEEP_RESULTS.FS_images(1,:,1,:), 0, 4), '*-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','FS'); hold on;
        errorbar([1:length(comms_reward_vec)], mean(SWEEP_RESULTS.FS_sun_points(1,:,1,:), 4), std(SWEEP_RESULTS.FS_sun_points(1,:,1,:), 0, 4), '*-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','FS'); hold on;
        legend('Comms', 'Stations', 'Images', 'Sun');
 
        subplot(2,3,6)
        n_params = size(SWEEP_RESULTS.FS_comms(1,:,1,1), 2);
        for idx = 1:n_params
            cur_comms_times = SWEEP_RESULTS.FS_comms_times{1, idx, 1, 1};
            n_comms = size(cur_comms_times, 2);
            y = ones(1, n_comms) * idx;
            plot(cur_comms_times, y, '*');
            hold on;
        end
    end
    if run_MCTS
        subplot(1,3,1)
        plot([1:num_sims]', reward_vec_MCTS, 'bd-', 'markersize', 10, 'linewidth', 1.5, 'DisplayName','SMDP-MCTS'); hold on;
        
        subplot(1,3,2)
        plot([1:num_sims]', sim_time_MCTS, 'bd-', 'markersize', 10, 'linewidth', 1.5); hold on;
        
        subplot(1,3,3)
        plot([1:num_sims]', reward_vec_MCTS./sim_time_MCTS, 'bd-', 'markersize', 10, 'linewidth', 1.5); hold on;
    end
    
    subplot(2,3,1)
    title('Total Reward')
    xlabel('Communication Reward')
    ylabel('Total Reward')
    set(gca, 'fontsize', 15)
    legend('location', 'northwest')
    set(gca, 'XTickLabel',comms_reward_vec)
    
    subplot(2,3,2)
    title('Total Runtime')
    xlabel('Communication Reward')
    ylabel('Runtime (s)')
    set(gca, 'fontsize', 15)
    set(gca, 'XTickLabel',comms_reward_vec)
    
    subplot(2,3,3)
    title('Number of Repeated Images')
    xlabel('Communication Reward')
    ylabel('N Repeats')
    set(gca, 'fontsize', 15)
    set(gca, 'XTickLabel',comms_reward_vec)
    
    subplot(2,3,4)
    title('Number of Unique Images')
    xlabel('Communication Reward')
    ylabel('N Images')
    set(gca, 'fontsize', 15)
    set(gca, 'XTickLabel',comms_reward_vec)
    
    subplot(2,3,5)
    title('Number of Actions')
    xlabel('Communication Reward')
    ylabel('N comms')
    set(gca, 'fontsize', 15)
    set(gca, 'XTickLabel',comms_reward_vec)
    
    subplot(2,3,6)
    ylabel('Communication Reward')
    xlabel('Time T')
    title('Times of Communication')
    set(gca, 'fontsize', 15)
end

figure
subplot(1,2,1)
hold on;
for idx = 1:size(comms_reward_vec, 2)
    cur_data = FS_power{1,1,1,idx};
    plot(t, cur_data(1,:));
end
legend('Comms 1', 'Comms 2', 'Comms 3', 'Comms 4', 'Comms 5', 'AutoUpdate','off')
plot(t, ones(size(t)) * general_params.p_min);
xlabel('Time')
ylabel('Power')
title('Power')
ylim([-0.1 1.1])
subplot(1,2,2)
hold on;
for idx = 1:size(comms_reward_vec, 2)
    cur_data = FS_data{1,1,1,idx};
    plot(t, cur_data(1, :));
end
legend('Comms 1', 'Comms 2', 'Comms 3', 'Comms 4', 'Comms 5', 'AutoUpdate','off')

plot(t, ones(size(t)) * general_params.d_max);
title('Data')
xlabel('Time')
ylabel('Data')
ylim([-0.1 1.1])

