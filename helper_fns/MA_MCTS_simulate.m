function [q, Q, N, V] = MA_MCTS_simulate(s, d, params, Q, N, V)
    if d == 0
        q = 0;
        return
    end
    
    state_str = [num2str(s.t) num2str(s.tp_s)];
    
    if ~stateVisited(s, V)
        image_opps = params.Image_Opps;
        gstation_opps = params.Station_Opps;
        comms_opps = params.Comms_Opps;
        N_max = params.N_max;
        A = get_MA_action_space(s, image_opps, gstation_opps, comms_opps, N_max, params);

        Q(state_str) = {};
        
        for i = 1:length(A)
            a = A{i};
            S = Q(state_str);
            S{length(S)+1} = {a, 0, 1};
            Q(state_str) = S;
        end
        V{length(V)+1} = s;
        q = MA_MCTS_rollout(s, d, params);
        return
    end
    
    S = Q(state_str);
    
    if length(S) == 0
        q = -inf;
        return
    end
    
    curr_max = 0;
    Sum = 0;
    for i = 1:length(S)
        Sum = Sum + S{i}{3};
    end
    for i = 1:length(S)
        val = S{i}{2} + params.c*sqrt(log(Sum) / S{i}{3});
        if val >= curr_max
            curr_max = val;
            a = S{i}{1};
        end
    end
    
    r = reward_function(s, a, params);
    s_prime = dynamics_update(s, a, params);
    [q_prime, Q, N, V] = MA_MCTS_simulate(s_prime, d-1, params, Q, N, V);
    q = params.gamma^(a.start.t - s.t)*q_prime;
    
    for i = 1:length(S)
        if S{i}{1}.start.t == a.start.t && S{i}{1}.end.t == a.end.t
            S{i}{3} = S{i}{3} + 1;
            S{i}{2} = S{i}{2} + ((q - S{i}{2})/(S{i}{3}));
        end
    end
end