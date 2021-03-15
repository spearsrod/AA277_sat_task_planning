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

t_s = a.start.t;
action_type = a.general.type;
if(action_type == "NIL")
    r = 1/(10^4) * (t_s - t);
elseif(action_type == "image" && (size(I_c, 1) == 0 || not(ismember(a.general.l_geod.', I_c.', 'rows'))))
    [~, index] = ismember(a.general.l_geod.', Images.', 'rows');
    r = gamma^(t_s - t) * R_s(index);
elseif(action_type == "station")
    r = 0.1 * (t_s - t);
elseif(action_type == "comms")
    %TODO set this to something more reasonable
    r = comms_reward;
else
    r = 0;
end
if(p <= p_min)
    r = r - 10^4;
elseif(d >= d_max)
    r = r - 10^4;
end
