function plot_comms_opportunities(orbit1, orbit2, min_dist)
% Computes the contact start and end times of satellite with orbit 1 and
% satellite with orbit 2.
sat_ecef1 = orbit1.sat_ecef;
sat_ecef2 = orbit2.sat_ecef;
orbit_dif = sat_ecef2 - sat_ecef1;
dist = sqrt(orbit_dif(1,:).^2 + orbit_dif(2,:).^2 + orbit_dif(3,:).^2);
contact_idx = find(dist < min_dist);
size(contact_idx)
sat_geod1 = orbit1.sat_geod;
contact_geod = sat_geod1(:,dist < min_dist);
long_geod = contact_geod(2,:);
lat_geod = contact_geod(1,:);
plot(long_geod, lat_geod, '.');
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