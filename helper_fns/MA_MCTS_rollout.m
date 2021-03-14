function q = MA_MCTS_rollout(s, d, params)
    if d == 0
        q = 0;
        return
    else
        image_opps = params.Image_Opps;
        gstation_opps = params.Station_Opps;
        comms_opps = params.Comms_Opps;
        N_max = params.N_max;
        A = get_MA_action_space(s, image_opps, gstation_opps, comms_opps, N_max, params);
        
        if length(A) == 0
            q = 0;
            return
        end
        
        a = A{randi(length(A))}; %sample randomly from A
        r = reward_function(s, a, params);
        s_prime = dynamics_update(s, a, params);
        q = r + params.gamma^(a.start.t - s.t)*MA_MCTS_rollout(s_prime, d-1, params);
    end
end