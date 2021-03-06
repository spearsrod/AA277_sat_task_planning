function [phi, lambda, h] = ecef2geocentric(r_ecef)
    % This function converts a position vector ECEF coordinates
    % to geocentric coordinates under the sperical earth assumption.
    % Accepts
    %   r_ecef: A position vector in ecef coordinates
    % Returns:
    %   phi: The latitude of the position in degrees
    %   lambda: The longitude of the position in degrees
    phi = rad2deg(asin(r_ecef(3) / norm(r_ecef)));
    lambda = rad2deg(atan2(r_ecef(2), r_ecef(1)));
    % Radius of Earth in km
    r_e = 6378;
    h = norm(r_ecef) - r_e;
end