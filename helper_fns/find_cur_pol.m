function pol_idx = find_cur_pol(target_pol, t_comm)
assert(t_comm > 0);
cur_idx = 1;
while(true)
    cur_pol = target_pol{cur_idx};
    pol_t = cur_pol{1}.t;
    if(pol_t > t_comm)
        pol_idx = cur_idx - 1;
        break;
    end
    cur_idx = cur_idx + 1;
end
end