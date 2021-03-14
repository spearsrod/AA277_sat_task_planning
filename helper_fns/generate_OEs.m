function OEs = generate_OEs(n, rs, es, Omegas, omegas, incls, nus)
% Determine orbit over desired time period
OEs = cell(1,n);
for idx = 1:n
    cur_orbit = get_orbit_struct(rs(idx), es(idx), Omegas(idx), omegas(idx), incls(idx), nus(idx));
    OEs{idx} = cur_orbit;
end
end