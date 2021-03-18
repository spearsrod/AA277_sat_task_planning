function opps = collect_image_opportunities(sat_ecef, sat_geod, t, images_geod, look_angle_min, look_angle_max, duration)
lat = sat_geod(1,:);
lon = sat_geod(2,:);
opps = {};
opp_size = 0;
for idx = 1:size(images_geod,2)
    cur_lat = images_geod(1,idx);
    cur_lon = images_geod(2,idx);
    [t_start, t_end, start_idx, end_idx, ~] = get_image_opp(sat_ecef, lat, lon, cur_lat, cur_lon, look_angle_min, look_angle_max, duration, t);
    n_opps = size(t_start, 2);
    for idx2 = 1:n_opps
        opp_start.t = t_start(idx2);
        opp_start.sat_ecef = sat_ecef(:,start_idx(idx2));
        opp_end.t = t_end(idx2);
        opp_end.sat_ecef = sat_ecef(:, end_idx(idx2));
        opp_general.type = "image";
        opp_general.l_geod = images_geod(:,idx);
        opp_general.dpdt = -0.0001;
        opp_general.dddt = 0.01/duration;
        
        cur_opp.start = opp_start;
        cur_opp.end = opp_end;
        cur_opp.general = opp_general;
        opps{opp_size + 1} = cur_opp;
        opp_size = opp_size + 1;
    end
end
end