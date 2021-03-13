function [total_reward, I_c, n_ground_links, n_actions] = parse_policy(policy, params)
n_actions = size(policy, 2);
total_reward = 0;
n_ground_links = 0;
for idx = 1:n_actions
    s_cur = policy{idx}{1};
    a_cur = policy{idx}{2};
    if(idx < n_actions)
        r_cur = reward_function(s_cur, a_cur, params);
        total_reward = total_reward + r_cur;
    end
    cur_action = policy{idx}{2}.general.type;
    if(cur_action == "station")
        n_ground_links = n_ground_links + 1;
    end
end
I_c = policy{end}{1}.I_c;
end