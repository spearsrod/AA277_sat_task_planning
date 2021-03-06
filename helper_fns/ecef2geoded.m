function [phi_geod, lam_geod, h_geod] = ecef2geoded(r_ecef, epsilon)
    [phi_geoc, lam_geoc, h_geoc] = ecef2geocentric(r_ecef);
    lam_geod = lam_geoc;
    phi_geod_i = deg2rad(phi_geoc);
    % Radius of Earth in km
    r_e = 6378;
    e_e = 0.0818;
    r_xy = norm([r_ecef(1) r_ecef(2)]);
    while true
        N_i = r_e/sqrt(1 - e_e^2 * sin(phi_geod_i)^2);
        phi_geod = atan((r_ecef(3) + N_i * e_e^2 * sin(phi_geod_i))/r_xy);
        delta = phi_geod - phi_geod_i;
        phi_geod_i = phi_geod;
        if(abs(delta) < epsilon)
            h_geod = r_xy / cos(phi_geod) - N_i;
            phi_geod = rad2deg(phi_geod);
            break
        end
    end
end