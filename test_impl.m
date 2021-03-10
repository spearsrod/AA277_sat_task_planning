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
plan_horizon = 24 * 60 * 60 * 1;

a = r;
e = 0;
Omega = deg2rad(90);
omega = deg2rad(45);
incl = deg2rad(90);
nu0 = 0;
t = [0:5:plan_horizon];
epsilon = 10^(-10);
start_date = [3 5 2018];
[lat, lon, h, r_ecef] = orbit_propagation(a, e, Omega, omega, incl, nu0, t, start_date, epsilon);

ground_stations = [78.2298391 -72.0167; 15.3924483 2.5333];

% Plot ground track, image locations, and ground stations
n = 100;
image_goed = generate_image_locations(n);
image_lat = image_geod(1,:);
image_lon = image_geod(2,:);
figure
plot(image_lon, image_lat, '.');
hold on;
% Load and plot MATLAB built-in Earth topography data
plot(lon, lat)
load('topo.mat', 'topo');
topoplot = [topo(:, 181:360), topo(:, 1:180)];
contour(-180:179, -90:89, topoplot, [0, 0], 'black');
plot(ground_stations(2,:), ground_stations(1,:), 'g*')


stat_lat = deg2rad(image_lat(1));
stat_lon = deg2rad(image_lon(1));
[elev, renu] = get_elevation(r_ecef, stat_lat, stat_lon);
min_elev = deg2rad(5);
look_angle_max = 50;
look_angle_min = 10;
duration = 30;

[t_start, t_end, start_idx, end_idx, look_angle] = get_image_opp(r_ecef, lat, lon, stat_lat, stat_lon, look_angle_min, look_angle_max, duration, t);




% plot(lon(start_idx), lat(start_idx), '*');
% plot(lon(end_idx), lat(end_idx), '*');
% 
% 
% figure
% plot(elev)
% hold on;
% dist_renu = sqrt(renu(1,:).^2 + renu(2,:).^2 + renu(3,:).^2);
% plot(dist_renu / max(dist_renu));
% plot(start_idx, dist_renu(start_idx)/max(dist_renu), '*')
% plot(end_idx, dist_renu(end_idx)/max(dist_renu), '*')
% [pks, locs] = findpeaks(-dist_renu /max(dist_renu));
% figure
% plot(look_angle)

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