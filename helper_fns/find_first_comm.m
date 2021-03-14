function first_comm = find_first_comm(policies, t, prev_sender)
    first_comm.t_end = inf;
    n_sats = size(policies,2);
    for idx = 1:n_sats
        cur_pol = policies{idx};
        n_actions = size(cur_pol, 2);
        for idx2 = 1:n_actions
            cur_a = cur_pol{idx2}{2};
            a_type = cur_a.general.type;
            if(a_type == "comms")
                t_end = cur_a.end.t;
                if(t_end < t)
                    continue
                end
                if(t_end == t && prev_sender == idx)
                    continue
                end
                if(t_end < first_comm.t_end)
                    first_com.t_end = t_end;
                    cur_s = cur_pol{idx}{1};
                    first_comm.I_c = cur_s.I_c;
                    I_plan = cur_pol{end}{1}.I_c;
                    I_fut = I_plan(:,size(cur_s.I_c, 2) + 1:end);
                    first_comm.I_fut = I_fut;
                    first_comm.target_sat = cur_a.general.target_sat;
                    first_comm.sender_sat = idx;
                end
            end
        end
    end
end