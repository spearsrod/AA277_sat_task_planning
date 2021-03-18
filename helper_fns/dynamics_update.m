function s = dynamics_update(s_0, a, params)
p_min = params.p_min;
d_max = params.d_max;

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
s.t = t_e;
s.rewards = s_0.rewards;
s.sat_idx = s_0.sat_idx;
s.n_prev_comms = s_0.n_prev_comms;

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
if(action_type == "comms")
    s.n_prev_comms = s.n_prev_comms + 1;
end

% TODO add dp to the opportunity structs
if(action_type == "NIL")
%     t_s_cur = t_s
%     t_now = t
    s.p = min([max([0, s_0.p + (t - tp_s) * a.general.dpdt]), 1]);
else
    s.p = min([max([0, s_0.p + (t_e - t_s) * a.general.dpdt - (t_s - tp_s) * 0.000001]), 1]);
end
s.d = min([max([0, s_0.d + (t_e - t_s) * a.general.dddt + (t_s - tp_s) * 0.000001]), 1]);

s.opp_prev = a;
end