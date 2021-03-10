function A = get_action_space(s, image_opps, gstation_opps, N_max, params)
A = {};
space_size = 0;
t = s.t;
opp_prev = s.opp_prev;
slew_rate = params.slew_rate;
t0_gmst = params.t0;
for idx = 1:size(image_opps, 2)
    opp_cur = image_opps{idx};
    t_s = opp_cur.start.t;
    if(t_s <= t)
        continue
    end
    if(agility_constraint_fn(opp_prev, opp_cur, t0_gmst, slew_rate))
        A{space_size + 1} = opp_cur;
        space_size = space_size + 1;
    end
end
for idx = 1:size(gstation_opps, 2)
    opp_cur = gstation_opps{idx};
    t_s = opp_cur.start.t;
    if(t_s <= t)
        continue
    end
    if(agility_constraint_fn(opp_prev, opp_cur, t0_gmst, slew_rate))
        A{space_size + 1} = opp_cur;
        space_size = space_size + 1;
    end
end
A = sort_actions_by_time(A);
if(size(A, 2) > N_max)
    A = A(1:N_max);
end
end