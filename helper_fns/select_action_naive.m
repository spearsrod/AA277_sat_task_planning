function a = select_action_naive(s, params)
    image_opps = params.Image_Opps;
    gstation_opps = params.Station_Opps;
    N_max = params.N_max;
    A = get_action_space(s, image_opps, gstation_opps, N_max, params);
    a = A{1};
    cur_t = s.t;
    if a.general.type == 'image' || a.general.type == 'station'
        s_prime = dynamics_update(s, a, params);
        if (s_prime.p <= params.p_min) || (s_prime.d > params.d_max)
            a = get_nil_action(cur_t);
        end
    else
        a = get_nil_action(cur_t);
    end   
end