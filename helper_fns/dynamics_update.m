function s = dynamics_update(s_0, a, params)
Images = params.Images;
Gstations = params.Groundstations;
p_min = params.p_min;
d_max = params.d_max;

% Extract state variables
t = s_0.t;
tp_s = s_0.tp_s;
I_c = s_0.I_c;
d = s_0.d;
p = s_0.p;

% Extract action variables
t_s = a.t_s;
t_e = a.t_e;
l = a.l;

s.t = t_s;
if(ismember(l, Images) || ismember(l, Gstations))    
    s.tp_s = s.t;
else
    s.tp_s = s.tp_s;
end
if(can_collect_image(l, I_c, p, p_min, d, d_max))
    s.I_c = [I_c l];
else
    s.I_c = I_c;
end

end