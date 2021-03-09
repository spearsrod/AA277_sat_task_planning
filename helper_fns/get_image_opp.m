function  [t_start, t_end, start_idx, end_idx, look_angle] = get_image_opp(r_ecef, lat, lon, stat_lat, stat_lon, look_angle_min, look_angle_max, duration, t)
r_e = 6378;
e_E = 0.0818;
N = r_e / sqrt(1 - e_E^2 * sin(stat_lat)^2);
r_xyz_stat = geod2ecef([stat_lat; stat_lon; 0]);
r_dif = r_ecef - r_xyz_stat;

R_xyz2enu = [-sin(stat_lon) -sin(stat_lat)*cos(stat_lon) cos(stat_lat)*cos(stat_lon); ...
    cos(stat_lon) -sin(stat_lat)*sin(stat_lon) cos(stat_lat)*sin(stat_lon); ...
    0 cos(stat_lat) sin(stat_lat)];
r_enu = R_xyz2enu * r_dif;

[elev, renu] = get_elevation(r_ecef, stat_lat, stat_lon);
dist_renu = sqrt(renu(1,:).^2 + renu(2,:).^2 + renu(3,:).^2);

sub_sat_point = [deg2rad(lat); deg2rad(lon); zeros(size(lat))];
sub_sat_ecef = geod2ecef(sub_sat_point);

sub_sat_dif = sub_sat_ecef - r_ecef;
nadir_dir = (sub_sat_dif)./sqrt(sub_sat_dif(1,:).^2 + sub_sat_dif(2,:).^2 + sub_sat_dif(3,:).^2);

station_dif = r_xyz_stat - r_ecef;
location_dir = (station_dif)./sqrt(station_dif(1,:).^2 + station_dif(2,:).^2 + station_dif(3,:).^2);

look_angle = rad2deg(acos(dot(nadir_dir, location_dir, 1)));

[pks, locs] = findpeaks(-dist_renu);
t_start = [];
t_end = [];
start_idx = [];
end_idx = [];
all_idx = [];
for idx = 1:size(pks, 2)
    cur_idx = locs(idx);
    cur_start = t(cur_idx) - duration / 2;
    cur_end = t(cur_idx) + duration / 2;
    t_idx = find(t > cur_start & t < cur_end);
    cur_look_angles = look_angle(t > cur_start & t < cur_end);
    if(min(cur_look_angles) >= look_angle_min && max(cur_look_angles) <= look_angle_max)
        t_start = [t_start cur_start];
        t_end = [t_end cur_end];
        start_idx = [start_idx t_idx(1)];
        end_idx = [end_idx t_idx(end)];
    end
end
end