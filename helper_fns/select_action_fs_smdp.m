function [a_star, v_star] = select_action_fs_smdp(s, d_solve, params)
    if(d_solve == 0)
        a_star = 'NIL';
        v_star = 0;
        return
    end
    a_star = 'NIL';
    v_star = -inf;
    %TODO define this function
    action_space = get_action_space(s);
    for idx = 1:size(action_space, 2)
        cur_a = action_space{idx};
        cur_v = reward_function(s, cur_a, params);
        s_prime = dynamics_update(s, cur_a, params);
        [a_prime, v_prime] = select_action_fs_smdp(s_prime, d_solve - 1, params);
        cur_v = cur_v + params.gamma^(cur_a.t_s - s.t)*v_prime;
        if(cur_v > v_star)
            a_star = cur_a;
            v_star = cur_v;
        end
    end
end
