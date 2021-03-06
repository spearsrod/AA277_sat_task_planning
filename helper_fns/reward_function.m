function r = reward_function(s, a, params)
Images = params.Images;
Groundstations = params.Groundstations;
I_c = s.I_c;
l = a.l;
t_s = a.t_s;
t = s.t;
p_min = params.p_min;
d_max = params.d_max;
R = params.rewards;
gamma = params.gamma;
if(ismember(l, Images) && not(ismember(l, I_c))
    r = gamma^(ts - t) * R(l);
elseif(islmember(l, Groundstations))
    r = 0.1 * (t_s - t);
elseif(not(ismember(l, Images)) || not(ismember(l, Groundstations)))
    r = 1/(10^4) * (t_s - t);
elseif(p <= p_min)
    r = -10^4;
elseif(d >= d_max)
    r = -10^4;
else
    r = 0;
end