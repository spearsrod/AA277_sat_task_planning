function policy = smdp_rule_based(s_0, d_solve, params)
   policy = {};
   a = select_action_naive(s_0, params);
   s = dynamics_update(s_0, a, params);
   policy{1} = {s_0, a};
   
   image_opps = params.Image_Opps;
   gstation_opps = params.Station_Opps;
   N_max = params.N_max;
   A = get_action_space(s, image_opps, gstation_opps, N_max, params);
   
   counter = 2;
   while size(A, 2) ~= 0
       a = select_action_naive(s, params);
       policy{counter} = {s, a};
       s = dynamics_update(s, a, params);
       counter = counter + 1;
       A = get_action_space(s, image_opps, gstation_opps, N_max, params);
   end
end