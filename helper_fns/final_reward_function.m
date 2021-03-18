function [r, cur_I_c, repeat_image] = final_reward_function(s, a, params, combined_I_c)
Images = params.Images;
p_min = params.p_min;
d_max = params.d_max;
% R_s = s.rewards;
R_s = params.rewards;
gamma = params.gamma;
comms_reward = params.comms_reward;

I_c = s.I_c;
t = s.t;
p = s.p;
d = s.d;
cur_I_c = -1;
repeat_image = 0;
t_s = a.start.t;
t_e = a.end.t;
action_type = a.general.type;
if(action_type == "NIL")
    r = 1/(10^3) * (t_s - t);
    %r = 0;
elseif(action_type == "image" && (size(combined_I_c, 1) == 0 || not(ismember(a.general.l_geod.', combined_I_c.', 'rows'))))
    [~, index] = ismember(a.general.l_geod.', Images.', 'rows');
    r = R_s(index);%gamma^(t_s - t) * R_s(index);
    cur_I_c = a.general.l_geod;
elseif(action_type == "image")
    repeat_image = 1;
    r = 0;
elseif(action_type == "station")
    r = 0.0001 * (t_e - t_s);
    %r = 0;
elseif(action_type == "comms")
    r = 0;
else
    r = 0;
end
if(p <= p_min)
    r = r - 10^4;
    hmmmm = 0
elseif(d >= d_max)
    r = r - 10^4;
    hiii = 0
end