function valid = agility_constraint_fn(opp_prev, opp_cur, t0_gmst, slew_rate)
    t_start = opp_prev.end.t + t0_gmst;
    t_end = opp_cur.start.t + t0_gmst;
    if(t_end - t_start < 0)
        valid = false;
        return
    end
    max_slew_time = 180 / slew_rate;
    if(t_end - t_start > max_slew_time)
        valid = true;
        return
    end
    start_sat_ecef = opp_prev.end.sat_ecef;
    start_loc_geod = opp_prev.general.l_geod;
    start_loc_ecef = geod2ecef(start_loc_geod);
    z_start = compute_los_vec(start_loc_ecef, start_sat_ecef, t_start);
    
    end_sat_ecef = opp_cur.start.sat_ecef;
    end_loc_geod = opp_cur.general.l_geod;
    end_loc_ecef = geod2ecef(end_loc_geod);
    z_end = compute_los_vec(end_loc_ecef, end_sat_ecef, t_end);
    
    slew_time = calc_slew_time(z_start, z_end, slew_rate);

    if(slew_time <= t_end - t_start)
        valid = true;
    else
        valid = false;
    end
end