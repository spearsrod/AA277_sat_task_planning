function plot_ground_track(lat_geod, long_geod)
% Plot the orbit in geodetic coordinates
figure
plot(long_geod, lat_geod);
hold on;
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
end