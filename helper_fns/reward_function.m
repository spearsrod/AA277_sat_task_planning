function r = reward_function(s, a, params)
Images = params.Images;
p_min = params.p_min;
d_max = params.d_max;
R_s = s.rewards;
gamma = params.gamma;
comms_reward = params.comms_reward;
t_final = params.t_final;

I_c = s.I_c;
t = s.t;
p = s.p;
d = s.d;
n_prev_comms = s.n_prev_comms;
comms_multiplier = 1e2;

t_s = a.start.t;
t_e = a.end.t;
action_type = a.general.type;
if(action_type == "NIL")
    r = 1/(10^3) * (t_s - t);
    %r = 0;
elseif(action_type == "image" && (size(I_c, 1) == 0 || not(ismember(a.general.l_geod.', I_c.', 'rows'))))
    [~, index] = ismember(a.general.l_geod.', Images.', 'rows');
    r = gamma^(t_s - t) * R_s(index);
elseif(action_type == "image" && (ismember(a.general.l_geod.', I_c.', 'rows')))
    [~, index] = ismember(a.general.l_geod.', Images.', 'rows');
    r = 0;%-1e3;%gamma^(t_s - t) * R_s(index);
elseif(action_type == "station")
    r = 0.0001 * (t_e - t_s);
    %r = 0;
elseif(action_type == "comms")
    %TODO set this to something more reasonable
    r = comms_reward - n_prev_comms * abs(10);
    %r = comms_reward;
    %r = comms_reward - t_s / t_final * 40;
else
    r = 0;
end
if(p <= p_min)
    r = r - 10^4;
elseif(d >= d_max)
    r = r - 10^4;
end
