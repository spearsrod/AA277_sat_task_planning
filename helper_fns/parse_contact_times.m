function [t_start, t_end, start_idx, end_idx] = parse_contact_times(contact_idx, t)
t_start = [];
t_end = [];
start_idx = [];
end_idx = [];
prev_idx = -1;
for idx = 1:size(contact_idx, 2)
    cur_idx = contact_idx(idx);
    if(idx == size(contact_idx, 2))
        t_end = [t_end t(cur_idx)];
        end_idx = [end_idx cur_idx];
    end
    if(cur_idx == prev_idx + 1)
        prev_idx = cur_idx;
        continue;
    else
        t_start = [t_start t(cur_idx)];
        start_idx = [start_idx cur_idx];
        if(prev_idx ~= -1)
            t_end = [t_end t(prev_idx)];
            end_idx = [end_idx prev_idx];
        end
    end
    prev_idx = cur_idx;
end
end