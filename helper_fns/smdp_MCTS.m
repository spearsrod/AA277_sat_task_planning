function policy = smdp_MCTS(s_0, d, params)
    policy = {};
    n = 0;
    Q = containers.Map;
    N = containers.Map;
    V = {};
    state_str = [num2str(s_0.t) num2str(s_0.tp_s)];
    v = 0;
    
    while n <= params.N_max_sim
        [q, Q, N, V] = MCTS_simulate(s_0, d, params, Q, N, V);
        n = n + 1;
    end
    
    S = Q(state_str);
    curr_max = 0;
    for i = 1:length(S)
        val = S{i}{2};
        if val >= curr_max
            curr_max = val;
            a = S{i}{1};
        end
    end
    
    s = dynamics_update(s_0, a, params);
    state_str = [num2str(s.t) num2str(s.tp_s)];
    policy{length(policy)+1} = {s_0, a};
    
    while q ~= -inf
        n = 0;
        while n <= params.N_max_sim
            [q, Q, N, V] = MCTS_simulate(s, d, params, Q, N, V);
            n = n + 1;
        end
        
        S = Q(state_str);
        curr_max = 0;
        for i = 1:length(S)
            val = S{i}{2};
            if val >= curr_max
                curr_max = val;
                a = S{i}{1};
            end
        end
        r = reward_function(s, a, params)
        policy{length(policy)+1} = {s, a} 
        s = dynamics_update(s, a, params);
        state_str = [num2str(s.t) num2str(s.tp_s)];
         
    end
    
end