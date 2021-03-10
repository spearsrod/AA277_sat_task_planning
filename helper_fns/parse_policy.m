function [total_reward, loa] = parse_policy(policy, params)
n_actions = size(policy, 2);
total_reward = 0;
for idx = 1:n_actions
    s_cur = policy{idx}{1};
    a_cur = policy{idx}{2};
    if(idx < n_actions)
        r_cur = reward_function(s_cur, a_cur, params);
        total_reward = total_reward + r_cur;
    end
    cur_action = policy{idx}{2}.general.type
end
total_reward
end