function d = data_update(d_0, t_s, tp_s, d_dl)
    d = d_0 + (t_s - tp_s)*d_dl;
end