function [elevation, r_enu] = get_elevation(r_ecef, stat_lat, stat_lon)
r_e = 6378;
e_E = 0.0818;
N = r_e / sqrt(1 - e_E^2 * sin(stat_lat)^2);
r_xyz_stat = N * [cos(stat_lat)*cos(stat_lon); cos(stat_lat)*sin(stat_lon); sin(stat_lat)];
r_dif = r_ecef - r_xyz_stat;

R_xyz2enu = [-sin(stat_lon) -sin(stat_lat)*cos(stat_lon) cos(stat_lat)*cos(stat_lon); ...
    cos(stat_lon) -sin(stat_lat)*sin(stat_lon) cos(stat_lat)*sin(stat_lon); ...
    0 cos(stat_lat) sin(stat_lat)];
r_enu = R_xyz2enu * r_dif;

elevation = atan(r_enu(3,:) ./ sqrt(r_enu(1,:).^2 + r_enu(2,:).^2));
end