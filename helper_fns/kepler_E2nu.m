function nu = kepler_E2nu(E, e)
    % Kepler's equation from the eccentric anomaly to the true anomaly
    % Accepts:
    %   E: The eccentric anomaly in radians
    %   e: The eccentricity
    % Returns:
    %   nu: The true anomaly in radians
    nu = acos((cos(E) - e)/(1 - e*cos(E)));
    if(mod(E, 2*pi) > pi)
        nu = -nu;
    end
end