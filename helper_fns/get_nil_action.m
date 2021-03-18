function a_nil = get_nil_action(t, t_end, s)
prev_sat_ecef = s.opp_prev.end.sat_ecef;
prev_geod = s.opp_prev.general.l_geod;
opp_start.t = t;
opp_start.sat_ecef = prev_sat_ecef;
opp_end.t = t_end;
opp_end.sat_ecef = prev_sat_ecef;
opp_general.type = "NIL";
opp_general.l_geod = prev_geod;
opp_general.dpdt = 0.0001;
opp_general.dddt = 0.000001;

a_nil.start = opp_start;
a_nil.end = opp_end;
a_nil.general = opp_general;
end