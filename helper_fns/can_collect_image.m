function can_collect = can_collect_image(l, I_c, Images, p, p_min, d, d_max)
if(not(ismember(l, Images)))
    can_collect = false;
elseif(ismember(l, I_c))
    can_collect = false;
elseif(p <= p_min)
    can_collect = false;
elseif(d >= d_max)
    can_collect = false;
else
    can_collect = true;
end