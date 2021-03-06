function r_ijk = pqw2ijk(r_pqw, Omega, omega, inclination)
    % This function performs the coordinate transition from perifocal to
    % earth-centered inertial coordinates using the inclination (inclination), right
    % ascension of the ascending node (Omega), and argument of periapsis (omega)
    % Accepts:
    %   x_peri: An R^3 vector in perifocal coordinates
    %   Omega: The right ascension of the ascending node in radians
    %   omega: The argument of periapsis in radians
    %   inclination: The inclination in radians
    % Returns:
    %   x_eci: The R^3 vector in earth-centered inertial coordinates
    R_pqw2ijk = R_z(-Omega) * R_x(-inclination) * R_z(-omega);
    r_ijk = R_pqw2ijk * r_pqw;
end