function A = get_MA_action_space(s, image_opps, gstation_opps, comms_opps, N_max, params)
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
for idx = 1:size(comms_opps, 2)
    opp_cur = comms_opps{idx};
    t_s = opp_cur.start.t;
    if(t_s <= t)
        continue
    end
    A{space_size + 1} = opp_cur;
    space_size = space_size + 1;
    % Assume omnidirectional antenna so no agility constraint.
end
% tmp_A = sort_actions_by_time(A);
% if(size(tmp_A, 2) > N_max)
%     tmp_A = tmp_A(1:N_max);
% end
% A = cell(1, size(tmp_A,2) * 2);
% for idx = 1:size(tmp_A, 2)
%     cur_a = tmp_A{idx};
%     alt_a = get_nil_action(cur_a.start.t, s);
%     A{idx} = cur_a;
%     A{idx + size(tmp_A, 2)} = alt_a;
% end

A = sort_actions_by_time(A);
if(size(A, 2) > N_max)
    A = A(1:N_max);
end
n_actions = size(A,2);
if(n_actions == 0)
    return;
end
A{n_actions + 1} = get_nil_action(A{1}.start.t, A{1}.start.t, s);
end