function r_x = R_x(alpha)
    % This function creates the rotation vector Rx for some angle alpha
    % This matrix is used for the conversion between perifocal to earth
    % centered coordinates.
    r_x = [1 0 0; 0 cos(alpha) sin(alpha); 0 -sin(alpha) cos(alpha)];
end