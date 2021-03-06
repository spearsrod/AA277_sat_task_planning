function E = kepler_nu2E(nu, e)
    % Kepler's equation from the true anomaly to the eccentric anomaly
    % Accepts:
    %   nu: The true anomaly in radians
    %   e: The eccentricity
    % Returns:
    %   E: The eccentric anomaly in radians
    E = acos((e + cos(nu))/(1 + e*cos(nu)));
    if(mod(nu, 2*pi) > pi)
        E = -E;
    end
end