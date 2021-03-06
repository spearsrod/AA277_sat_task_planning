function M = kepler_E2M(E, e)
    % Kepler's equation from the eccentric anomaly to the mean anomaly
    % Accepts:
    %   E: The eccentric anomaly in radians
    %   e: The eccentricity
    % Returns:
    %   M: The mean anomaly in radians
    M = E - e*sin(E);
end