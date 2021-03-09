function [t_start, t_end, start_idx, end_idx] = get_covered_times(r_ecef, t, stat_lat, stat_lon, min_elev)
%This function determines the range of times that the satellite is above a
%certain elevation threshold for a certain point on the Earth's surface.
% Accepts:
%   r_ecef: An array of satellite positions in the ECEF coordinate frame
%       over a desired time window.
%   t: The times associated with each element in the r_ecef array
%   stat_lat: The latitude of the surface point in radians
%   stat_lon: The longitude of the surface point in radians
%   min_elev: The minimum elevation required for the satellite to take a
%       photo or communicate with a ground station in radians.
%   Returns:
%       t_start: An array of start times for coverage. Each index
%           corresponds to the start time of a unique pass
%       t_end: An array of end times for coverage: Each index corresponds
%           to the end time of a unique pass.
r_e = 6378;
e_E = 0.0818;
N = r_e / sqrt(1 - e_E^2 * sin(stat_lat)^2);
r_xyz_stat = N * [cos(stat_lat)*cos(stat_lon); cos(stat_lat)*sin(stat_lon); sin(stat_lat)];
r_dif = r_ecef - r_xyz_stat;

R_xyz2enu = [-sin(stat_lon) -sin(stat_lat)*cos(stat_lon) cos(stat_lat)*cos(stat_lon); ...
    cos(stat_lon) -sin(stat_lat)*sin(stat_lon) cos(stat_lat)*sin(stat_lon); ...
    0 cos(stat_lat) sin(stat_lat)];
r_enu = R_xyz2enu * r_dif;

elev = atan(r_enu(3,:) ./ sqrt(r_enu(1,:).^2 + r_enu(2,:).^2));
covered_idx = find(elev > min_elev);
t_start = [];
t_end = [];
start_idx = [];
end_idx = [];
prev_idx = -1;
for idx = 1:size(covered_idx, 2)
    cur_idx = covered_idx(idx);
    if(cur_idx == size(elev, 3))
        t_end = [t_end t(cur_idx)];
        end_idx = [end_idx cur_idx];
    end
    if(cur_idx == prev_idx + 1)
        prev_idx = cur_idx;
        continue;
    else
        t_start = [t_start t(cur_idx)];
        start_idx = [start_idx cur_idx];
        if(prev_idx ~= -1)
            t_end = [t_end t(prev_idx)];
            end_idx = [end_idx prev_idx];
        end
    end
    prev_idx = cur_idx;
end
end