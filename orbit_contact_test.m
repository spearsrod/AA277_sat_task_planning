clear all; close all; clc
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

figure
for idx = 1:n
    lat_geod = orbits{idx}.sat_geod(1,:);
    lon_geod = orbits{idx}.sat_geod(2,:);
    plot_ground_track(lat_geod, lon_geod)
    hold on;
end


min_dist = 5000;
image_duration = 30;
opps = collect_comms_opportunities(orbits{1}, orbits{3}, t, min_dist);

figure
plot_comms_opportunities(orbits{1}, orbits{3}, min_dist);
% hold on;
% plot_comms_opportunities(orbits{1}, orbits{3}, min_dist);
% figure
% plot_comms_opportunities(orbits{2}, orbits{1}, min_dist);
% plot_comms_opportunities(orbits{2}, orbits{3}, min_dist);
% hold on;
% figure
% plot_comms_opportunities(orbits{3}, orbits{1}, min_dist);
% plot_comms_opportunities(orbits{3}, orbits{2}, min_dist);
% hold on;