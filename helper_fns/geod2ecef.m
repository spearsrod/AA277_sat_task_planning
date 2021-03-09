function r_xyz = geod2ecef(r_geod)
% Function to convert a set of geodetic coordinates to ECEF coordinates
% Accepts:
%   r_geod: An array of positions in geodetic coordinates
lat = r_geod(1,:);
lon = r_geod(2,:);
h = r_geod(3,:);

r_e = 6378;
e_E = 0.0818;
% Calculate the modified radius of the Earth using the geodetic model
N = r_e ./ sqrt(1 - e_E^2 * sin(lat).^2);
r_xyz = [(N+h) .* cos(lat).*cos(lon); (N+h) .* cos(lat).*sin(lon); (N.*(1-e_E^2) + h).*sin(lat)];
end