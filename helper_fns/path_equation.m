function r = path_equation(e, a, nus)
    % Path equation relating a vector of true anomalies to their
    % corresponding radius magnitudes
    % Accepts:
    %   e: The eccentricity
    %   a: The semi-major axis
    %   nus: A vector of true anomalies to calculate the position magnitude
    %       for.
    % Returns:
    %   r: A vector of position magnitudes
    p = a*(1- e^2);
    r = p./(1 + e*cos(nus));
end