function s = MA_dynamics_update(s_0, a, params)
p_min = params.p_min;
d_max = params.d_max;

n_sats = size(s_0, 2);
for idx = 1:n_sats
    cur_a = a{idx};
    cur_s0 = s{idx};
    a_type = cur_a.general.type;
    if(cur_a == "comms")
    else
        cur_s = dynamics_update(s_0, cur_a, params);
    end
end

% Extract state variables
t = s_0.t;
tp_s = s_0.tp_s;
I_c = s_0.I_c;
d = s_0.d;
p = s_0.p;

% Extract action variables
t_s = a.start.t;
t_e = a.end.t;
action_type = a.general.type;
s.t = t_s;

if(action_type == "image") || (action_type == "station")    
    s.tp_s = t;
    if(can_collect_image(a.general, I_c, p, p_min, d, d_max))
        action_geod = a.general.l_geod;
        s.I_c = [I_c action_geod];
    else
        s.I_c = I_c;
    end
else
    s.tp_s = tp_s;
    s.I_c = I_c;
end

% TODO add dp to the opportunity structs
s.p = s_0.p + (t_e - t_s) * a.general.dpdt + (t_s - tp_s) * 0;% * 0.000001;
s.d = s_0.d + (t_e - t_s) * a.general.dddt + (t_s - tp_s) * 0.000001;

s.opp_prev = a;
end