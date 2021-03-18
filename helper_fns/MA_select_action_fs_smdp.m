function [a_star, v_star] = MA_select_action_fs_smdp(s, d_solve, params)
    sat_idx = s.sat_idx;
    image_opps = params.Image_Opps;
    gstation_opps = params.Station_Opps;
    comms_opps = params.Comms_Opps;
    N_max = params.N_max;
    gamma = params.gamma;
    cur_t = s.t;
    if(d_solve == 0)
        a_star = get_nil_action(cur_t, cur_t, s);
        v_star = 0;
        return
    end
    a_star = get_nil_action(cur_t, cur_t, s);
    v_star = -inf;
    %TODO add sun-pointing to action space
    A = get_MA_action_space(s, image_opps, gstation_opps, comms_opps, N_max, params);
    for idx = 1:size(A, 2)
        cur_a = A{idx};
        cur_v = reward_function(s, cur_a, params);
        s_prime = dynamics_update(s, cur_a, params);
        [a_prime, v_prime] = MA_select_action_fs_smdp(s_prime, d_solve - 1, params);
        cur_v = cur_v + gamma^(cur_a.start.t - s.t)*v_prime;
        if(cur_v > v_star)
            a_star = cur_a;
            v_star = cur_v;
        end
    end
%     if(v_star < 0 && v_star ~= -inf)
%         v_prime_alt = v_star
%         alt_state = s
%         action_type_alt = a_star.general.type
%         n_actions_alt = size(A,2)
%         cur_a_alt = A{end};
%         atl_cur_v = reward_function(alt_state, cur_a_alt, params);
%         s_prime_alt = dynamics_update(alt_state, cur_a_alt, params);
%         [alt_a, alt_v] = MA_select_action_fs_smdp(s_prime_alt, d_solve - 1, params);
%         atl_cur_v = atl_cur_v + gamma^(cur_a_alt.start.t - alt_state.t)*alt_v;
%         alt_type = alt_a.general.type
%         atl_cur_v = atl_cur_v
%     end
end
