function r = reward_function(s, a, params)
Images = params.Images;
p_min = params.p_min;
d_max = params.d_max;
R = params.rewards;
gamma = params.gamma;

I_c = s.I_c;
t = s.t;
p = s.p;
d = s.d;

t_s = a.start.t;
action_type = a.general.type;
if(action_type == string('NIL'))
    r = 1/(10^4) * (t_s - t);
elseif(action_type == string('image') && (size(I_c, 1) == 0 || not(ismember(a.general.l_geod.', I_c.', 'rows'))))
    [isimage, index] = ismember(a.general.l_geod.', Images.', 'rows');
    r = gamma^(t_s - t) * R(index);
elseif(action_type == string('station'))
    r = 0.1 * (t_s - t);
else
    r = 0;
end
if(p <= p_min)
    r = r - 10^4;
elseif(d >= d_max)
    r = r - 10^4;
end