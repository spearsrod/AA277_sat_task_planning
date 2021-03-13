function can_collect = can_collect_image(opp_general, I_c, p, p_min, d, d_max)
type = opp_general.type;
opp_geod = opp_general.l_geod;

% size(opp_geod)
% im_taken_sz = size(I_c)
if(type ~= "image")
    can_collect = false;
elseif(size(I_c, 1) > 0 && ismember(opp_geod.', I_c.', 'rows'))
    can_collect = false;
elseif(p <= p_min)
    can_collect = false;
elseif(d >= d_max)
    can_collect = false;
else
    can_collect = true;
end