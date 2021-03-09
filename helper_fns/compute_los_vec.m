function z_los = compute_los_vec(r_loc_ecef, r_sat_ecef, t_gmst)
r_loc_eci = ecef2eci(r_loc_ecef, t_gmst);
r_sat_eci = ecef2eci(r_sat_ecef, t_gmst);
z_los = r_loc_eci - r_sat_eci;
z_los = z_los / norm(z_los);
end