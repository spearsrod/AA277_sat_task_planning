function E = newton_raphson(M, e, epsilon)
    % Function to perform an iterative estimate on the eccentric anomaly
    % Accepts:
    %   M: The mean anomaly in radians
    %   e: The eccentricity
    %   epsilon: The update magnitude used to stop the iterations
    % Returns:
    %   E: The estimated eccentric anomaly
    
    % Set the initial value of E using the eccentricity. 
    if(e < 0.5)
        E = M;
    else
        E = pi;
    end
    % Update loop to estimate E until the update value delta has a smaller
    % magnitude than epsilon
    while true
        delta = -(E - e * sin(E) - M) / (1 - e * cos(E));
        E = E + delta;
        if(abs(delta) < epsilon)
            break
        end
    end
end