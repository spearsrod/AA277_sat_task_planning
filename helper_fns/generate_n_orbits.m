function [orbits, t] = generate_n_orbits(n, n_days, OEs, start_date)
% Set planning horizon with 5 second increments.
plan_horizon = 24 * 60 * 60 * n_days;
t = [0:5:plan_horizon];
% Set numerical convergence constant
epsilon = 10^(-10);

orbits = cell(1,n);
for idx = 1:n
    cur_OE = OEs{idx};
    a = cur_OE.a;
    e = cur_OE.e;
    Omega = cur_OE.Omega;
    omega = cur_OE.omega;
    incl = cur_OE.incl;
    nu0 = cur_OE.nu;
    [lat, lon, h, sat_ecef] = orbit_propagation(a, e, Omega, omega, incl, nu0, t, start_date, epsilon);
    sat_geod = [lat; lon; h];
    cur_orbit.sat_ecef = sat_ecef;
    cur_orbit.sat_geod = sat_geod;
    cur_orbit.sat_idx = idx;
    orbits{idx} = cur_orbit;
end
end