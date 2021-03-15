function a = MA_select_action_naive(s, params)
    image_opps = params.Image_Opps;
    gstation_opps = params.Station_Opps;
    comms_opps = params.Comms_Opps;
    N_max = params.N_max;
    A = get_MA_action_space(s, image_opps, gstation_opps, comms_opps, N_max, params);
    a = A{1};
    cur_t = a.start.t;
    if a.general.type == 'image' || a.general.type == 'station' || a.general.type == 'comms'
        s_prime = dynamics_update(s, a, params);
        if (s_prime.p <= params.p_min) || (s_prime.d > params.d_max) || (params.comms_reward < -1e5)
            a = get_nil_action(cur_t, s);
        end
    else
        a = get_nil_action(cur_t, s);
    end   
end