function policies = MA_smdp_rule_based(s_0, d_solve, params)
    n_sats = size(s_0, 2);
    policies = cell(1, n_sats);
    t = 0;
    prev_sender = -1;
    for idx = 1:n_sats
        sat_idx = 1;
        cur_s0 = s_0{idx};
        cur_params = params{idx};
        cur_policy = single_smdp_rule_based(cur_s0, d_solve, cur_params);
        policies{idx} = cur_policy;
    end
    while(true)
        first_comm = find_first_comm(policies, t, prev_sender);
        if(first_comm.t_end == inf)
            break;
        end
        prev_sender = first_comm.sender_sat;
        target_sat = first_comm.target_sat;
        t_comm = first_comm.t_end;
        target_pol = policies{target_sat};
        pol_idx = find_cur_pol(target_pol, t_comm);
        cur_s = target_pol{pol_idx}{1};
        cur_params = params{target_sat};
        new_s = comms_update(cur_s, first_comm, cur_params);
        future_pol = single_smdp_rule_based(new_s, d_solve, cur_params);
        new_pol = [target_pol{1:pol_idx - 1}, future_pol];
        policies{target_sat} = new_pol;
        t = t_end;
    end
end