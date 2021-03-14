clear all; close all; clc;
function_dir = 'helper_fns';
% Add Director path for all commonly used functions and constatns
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

% 
% min_dist = 5000;
% image_duration = 30;
% opps = collect_comms_opportunities(orbits{1}, orbits{2}, t, min_dist);

general_params.p_min = 0.3;
general_params.d_max = 0.75;
Gstations = [78.2298391 -72.0167; 15.3924483 2.5333; 0 0];
% Get image opportunity locations
n_images = 1000;
Images = generate_image_locations(n_images);
rewards = ones(1, n_images);
general_params.Images = Images;
general_params.Gstations = [78.2298391 -72.0167; 15.3924483 2.5333; 0 0];
general_params.rewards = ones(1, n_images);
comms_reward = 0;
params = get_fs_params(orbits, t, general_params, comms_reward);

% Initialize the state
t0 = 0;
s_0 = MA_initialize_state(orbits, t0, rewards);
d_solve = 3;
policies = MA_smdp_forward_search(s_0, d_solve, params);

[total_reward, I_c, n_ground_links, n_actions, n_comms, n_repeats] = MA_parse_policy(policies, params);
total_reward
n_ground_links
n_actions
n_comms
n_repeats