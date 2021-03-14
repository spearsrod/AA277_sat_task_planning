function new_s = comms_update(s_0, first_comm, params)
Images = params.Images;
R = params.rewards;
% Extract state variables
t = s_0.t;
tp_s = s_0.tp_s;
I_c = s_0.I_c;
d = s_0.d;
p = s_0.p;

R_s = s.rewards;

t_end = first_comm.t_end;
I_new = first_comm.I_c;
I_fut = first_com.I_fut;
t_I_fut = first_com.t_I_fut;

new_s.tp_s = tp_s;
new_s.t = t_end;
new_s.I_c = I_c;
for idx = 1:size(I_new, 2)
    I_new_cur = I_new(:,idx);
    if(~ismember(I_new_cur.', I_c.', 'rows'))
        new_s.I_c = [new_s.I_c I_new_cur];
    end
end

R_s_new = R_s;
for idx = 1:size(I_fut, 2)
    I_fut_cur = I_fut(:,idx);
    t_I_fut_cur = t_I_fut(idx);
    [~, index] = ismember(I_fut_cur.', Images.', 'rows');
    R_s_new(index) = min([(1 - gamma^(t_I_fut_cur - t_end))*R(index) R_s(index)];
end
new_s.rewards = R_s_new;

% Arbitrary constant for now
comms_data = 0.001;
new_s.d = d + comms_data;
comms_power = 0;
new_s.p = p - comms_power;

new_s.opp_prev = s_0.opp_prev;
end