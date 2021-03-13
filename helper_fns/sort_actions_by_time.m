function A_sorted = sort_actions_by_time(A)
ts = [];
for idx = 1:size(A,2)
    t_s = A{idx}.start.t;
    ts = [ts t_s];
end
[~, IDX] = sort(ts);
A_sorted = A(IDX);
end