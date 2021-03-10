function opps = collect_groundlink_opportunities(sat_ecef, t, gstation_geod, min_elev, image_duration)
opps = {};
opp_size = 0;
for idx = 1:size(gstation_geod,2)
    cur_lat = gstation_geod(1,idx);
    cur_lon = gstation_geod(2,idx);
    [t_start, t_end, start_idx, end_idx] = get_covered_times(sat_ecef, t, cur_lat, cur_lon, deg2rad(min_elev));
    size(t_start)
    size(t_end)
    n_opps = size(t_start, 2);
    for idx2 = 1:n_opps
        opp_start.t = t_start(idx2);
        opp_start.sat_ecef = sat_ecef(:,start_idx(idx2));
        opp_end.t = t_end(idx2);
        opp_end.sat_ecef = sat_ecef(:,end_idx(idx2));
        opp_general.type = string('station');
        opp_general.l_geod = gstation_geod(:,idx);
        opp_general.dpdt = 0;%-0.0001;
        opp_general.dddt = -0.01/image_duration*4;
        
        cur_opp.start = opp_start;
        cur_opp.end = opp_end;
        cur_opp.general = opp_general;
        opps{opp_size + 1} = cur_opp;
        opp_size = opp_size + 1;
    end
end
end