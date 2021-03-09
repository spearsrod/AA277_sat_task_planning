function [lat, lon, h, r_xyz] = orbit_propagation(a, e, Omega, omega, incl, nu0, t, start_date, epsilon)
% Compute the ground track of an orbiting satellite with given orbital
% parameters, an initial true anomaly, and series of time steps.
% Accepts:
%       a: The semi-major axis of the orbit
%       e: The eccentricity of the orbit
%       Omega: The Right ascension of the ascending node
%       omega: The argument of periapsis
%       incl: The inclination
%       nu0: The initial true anomaly of the orbit
%       t: The series of time samples to calculate the orbit for
%       epsilon: The convergence value to use for the numerical
%       Newton-Raphson method of computing the eccentric anomaly from mean
%       anomaly.
% Returns:
%
%% Propagate Orbit in Perifocal Coordinates
% Initial Eccentric Anomaly
E0 = kepler_nu2E(nu0, e);
% Initial Mean Anomaly
M0 = kepler_E2M(E0, e);
% Gravitational parameter of the Earth
r_e = 6378;
G_km = 6.6743 * 10^(-20);
M_e = 5.9720e+24;
mu = M_e * G_km;
% Mean motion of the satellite
eta = sqrt(mu/(a^3));
% Vector of future mean anomalies
M  = M0 + eta * t;
% Calculate future true anomalies
nu = zeros(size(M));
E = zeros(size(M));
for idx = 1:size(M,2)
    cur_E =  newton_raphson(M(idx), e, epsilon);
    cur_nu = kepler_E2nu(cur_E, e);
    nu(idx) = cur_nu;
    E(idx) = cur_E;
end
r = path_equation(e, a, nu);
r_pqw = [r.*cos(nu); r.*sin(nu); zeros(size(nu))];
%% Convert Perifocal Coordinates to Earth Centered Inertial Coordinates
r_ijk = pqw2ijk(r_pqw, Omega, omega, incl);

%% Convert ECI coordinates to Earth Centered Earth Fixed Coordinates
gmst = ut2gmst(start_date , t);
r_xyz = zeros(size(r_ijk));
lat = zeros(size(nu));
lon = zeros(size(nu));
h = zeros(size(nu));
for idx = 1:size(r_ijk,2)
    R_mat = crf2trf(gmst(idx));
    cur_r_xyz = R_mat * r_ijk(:,idx);
    r_xyz(:,idx) = cur_r_xyz;
    [cur_phi, cur_lam, cur_h] = ecef2geoded(cur_r_xyz, epsilon);
    lat(idx) = cur_phi;
    lon(idx) = cur_lam;
    h(idx) = cur_h;
%     lat(idx) = cur_r_xyz(1);
%     lon(idx) = cur_r_xyz(2);
%     h(idx) = cur_r_xyz(3);
%     lat(idx) = r_ijk(1,idx);
%     lon(idx) = r_ijk(2,idx);
%     h(idx) = r_ijk(3,idx);
%     lat(idx) = r_pqw(1,idx);
%     lon(idx) = r_pqw(2,idx);
%     h(idx) = r_pqw(3,idx);
end
end