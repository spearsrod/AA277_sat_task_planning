clear all; close all; clc
function_dir = 'helper_fns';
% Add Director path for all commonly used functions and constatns
addpath(function_dir);
% Load file using the described orbital constants
orbital_constants;

% Set planning horizon with 5 second increments.
n_days = 1;
plan_horizon = 24 * 60 * 60 * n_days;
t = [0:5:plan_horizon];

% Determine orbit over desired time period
% Altitude of orbit (km)
h = 500;
% Radius of orbit (km)
r = h + r_e;
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
params.gamma = 0.99;
params.p_min = 0.3;
params.d_max = 0.75;
d_solve = 6;

% Get image opportunity locations
n_images = 100;
params.Images = generate_image_locations(n_images);
params.Gstations = [78.2298391 -72.0167; 15.3924483 2.5333; 0 0];
%params.Gstations = get_USGS_Landsat_Groundstations();

params.rewards = ones(1, n_images);
% Image capture requires 30 seconds
image_duration = 30;
% Minimum elevation for ground station contact
min_elev = 5;
% Set max and min look angles required for successfull imaging
look_angle_min = 5;
look_angle_max = 50;
params.Image_Opps = collect_image_opportunities(sat_ecef, sat_geod, t,...
    params.Images, look_angle_min, look_angle_max, image_duration);
params.Station_Opps = collect_groundlink_opportunities(sat_ecef, t,...
    params.Gstations, min_elev, image_duration);
params.slew_rate = 1;
params.t0 = 0;

policy = smdp_rule_based(s_0, d_solve, params);

[total_reward, I_c, n_ground_links, n_actions] = parse_policy(policy, params);
total_reward
n_ground_links
n_actions