function r_eci = ecef2eci(r_ecef, gmst)
R_mat = crf2trf(-gmst);
r_eci = R_mat * r_ecef;
end