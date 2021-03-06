clear all; close all;
function_dir = '/home/s/Documents/School/Coterm/Winter/AA277/Project/mdp_impl/helper_fns';
% Add Director path for all commonly used functions and constatns
addpath(function_dir);
% Load file using the described orbital constants
orbital_constants;

% Forward Search Test
gamma = 0.99;
d_solve = 3;
N_a_max = 3;

n_images = 100;
rewards = ones(n_images,1);

% Altitude of orbit (km)
h = 500;
% Radius of orbit (km)
r = h + r_e;
% Inclination of polar orbit (radians)
i = deg2rad(90);
% Eccentricity of circular orbit
e = 0;

%Max Slew rate (rad/s)
slew_rate_max = deg2rad(1);
%Duty Cycle
DC = 0.1;
%Image size (normalized by total storage capacity)
im_sz = 0.01;
%Constant Data Rate (normalized by total storage capacity)
data_rate = 0.000001;
%Downlink Rate
%TODO, make sure this is correct. Paper is slightly unclear
dl_rate = 4 * im_sz;
%Minimum power (normalized by total energy capacity)
p_min = 0.3;
%Max data (normalized to total data storage)
d_max = 0.75;

%Planning horizon (seconds)
plan_horizon = 24 * 60 * 60 * 5;

a = r;
e = 0;
Omega = deg2rad(90);
omega = deg2rad(45);
incl = deg2rad(90);
nu0 = 0;
t = linspace(0, plan_horizon, 10000);
epsilon = 10^(-10);
start_date = [3 5 2018];
[lat, lon, h] = orbit_propagation(a, e, Omega, omega, incl, nu0, t, start_date, epsilon);

long_geod = zeros(200, 1);
lat_geod = linspace(-90, 90, 200);
plot_ground_track(lat, lon)

% figure
% [xE , yE, zE] = ellipsoid(0, 0, 0, r_e , r_e, r_e, 20);
% surface(xE, yE , zE ,'FaceColor','blue','EdgeColor','black');
% axis  equal;
% view (3);
% grid on;
% hold on
% plot3(lat, lon, h, 'g');
% 
% figure
% plot(lat, lon)
% hold on
% plot(lat, h)