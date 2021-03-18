function policy = single_smdp_forward_search(s_0, d_solve, params)
    policy = {};
    test_count = 0;
    max_count = 20;
    [a, v] = MA_select_action_fs_smdp(s_0, d_solve, params);
    s = dynamics_update(s_0, a, params);
    policy{1} = {s_0, a};
    prev_v = 0;
    s_prev = s;
    while(not(v == -inf))
        prev_v2x = prev_v;
        prev_v = v;
        [a, v] = MA_select_action_fs_smdp(s, d_solve, params);
        %TODO: preallocate this policy size
        cur_size = size(policy, 2);
        policy{cur_size + 1} = {s, a};
        s_2xprev = s_prev;
        s_prev = s;
        s = dynamics_update(s, a, params);
%         if(v < 0)
%             if(v == -inf)
%                 continue;
%             end
%             s_2xprev = s_2xprev
%             prev_2x_a = s_2xprev.opp_prev.general.type
%             pev_v2x = prev_v2x
%             s_prev = s_prev
%             prev_a = s_prev.opp_prev.general.type
%             prev_v = prev_v
%             a.general
%             s_post = s
%             cur_reward = v
%             what = 2;
%             if(test_count > max_count)
%                 break
%             end
%             test_count = test_count + 1;
%         end
    end
end