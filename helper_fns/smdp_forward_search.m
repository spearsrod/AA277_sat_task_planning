function policy = smdp_forward_search(s_0, d_solve, params)
    policy = {};
    [a, v] = select_action_fs_smdp(s_0, d_solve, params);
    s = dynamics_update(s_0, a, params);
    policy{1} = {s_0, a};
    while(not(v == -inf))
        [a, v] = select_action_fs_smdp(s, d_solve, params);
        %TODO: preallocate this policy size
        cur_size = size(policy, 2);
        policy{cur_size + 1} = {s, a};
        s = dynamics_update(s, a, params);
        if(mod(cur_size, 5) == 0)
            cur_size
        end
    end
end