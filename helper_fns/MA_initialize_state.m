function s_0 = MA_initialize_state(orbits, t0, rewards)
n_sats = size(orbits, 2);
s_0 = cell(1,n_sats);
for idx = 1:n_sats
    s_cur.t = 0;
    s_cur.tp_s = 0;
    s_cur.I_c = [];
    s_cur.d = 0; %TODO: Make sure this is correct
    s_cur.p = 1; %TODO: Make sure this is correct
    s_cur.sat_idx = idx;
    s_cur.rewards = rewards;
    
    r0 = orbits{idx}.sat_ecef(:,1);
    init_start.t = 0;
    init_start.sat_ecef = r0;
    init_end.t = 0;
    init_end.sat_ecef = r0;
    init_general.type = "init";
    
    %Assume initial pointing at nadir
    epsilon = 10^(-10);
    [phi_geod, lam_geod, h_geod] = ecef2geoded(r0, epsilon);
    sub_sat_geod = [phi_geod; lam_geod; 0];
    init_general.l_geod = sub_sat_geod;
    initial_opp.start = init_start;
    initial_opp.end = init_end;
    initial_opp.general = init_general;

    s_cur.opp_prev = initial_opp;
    s_0{idx} = s_cur;
end
end