function [p_t, d_t] = MA_get_profiles(policies, t)
n_sats = size(policies, 2);
p_t = zeros(n_sats, size(t, 2));
d_t = zeros(n_sats, size(t, 2));
t_prev = 0;
for idx = 1:n_sats
    n_actions = size(policies{idx},2);
    for idx2 = 2:n_actions
        cur_state = policies{idx}{idx2}{1};
        cur_d = cur_state.d;
        cur_p = cur_state.p;
        cur_t = cur_state.t;
        t_idx = find(t > t_prev & t <= cur_t);
        p_t(idx, t_idx) = ones(size(t_idx)) * cur_p;
        d_t(idx, t_idx) = ones(size(t_idx)) * cur_d;
        t_prev = cur_t;
    end
end
end