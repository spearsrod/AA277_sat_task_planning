function r_z = R_z(alpha)
    % This function creates the rotation vector Rz for some angle alpha
    % This matrix is used for the conversion between perifocal to earth
    % centered coordinates.
    r_z = [cos(alpha) sin(alpha) 0; -sin(alpha) cos(alpha) 0; 0 0 1];
end