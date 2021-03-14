function opps = collect_comms_opportunities(orbit1, orbit2, t, min_dist)
% Computes the contact start and end times of satellite with orbit 1 and
% satellite with orbit 2.
sat_ecef1 = orbit1.sat_ecef;
sat_ecef2 = orbit2.sat_ecef;
orbit_dif = sat_ecef2 - sat_ecef1;
dist = sqrt(orbit_dif(1,:).^2 + orbit_dif(2,:).^2 + orbit_dif(3,:).^2);
contact_idx = find(dist < min_dist);
opps = {};
opp_size = 0;
[t_start, t_end, start_idx, end_idx] = parse_contact_times(contact_idx, t);
n_opps = size(t_start, 2);
for idx = 1:n_opps
    opp_start.t = t_start(idx);
    opp_start.sat_ecef = sat_ecef1(:,start_idx(idx));
    opp_end.t = t_end(idx);
    opp_end.sat_ecef = sat_ecef1(:,end_idx(idx));
    opp_general.type = "comms";
    
    % The geodetic coordinate of the communcating satellite (2)
    opp_general.l_geod = orbit2.sat_geod(:,start_idx(idx));
    opp_general.dpdt = 0;%-0.0001;
    opp_general.dddt = 0;
    opp_general.target_sat = orbit2.sat_idx;

    cur_opp.start = opp_start;
    cur_opp.end = opp_end;
    cur_opp.general = opp_general;
    opps{opp_size + 1} = cur_opp;
    opp_size = opp_size + 1;
end
end