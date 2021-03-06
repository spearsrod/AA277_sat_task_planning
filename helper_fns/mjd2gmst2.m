function  gmst = mjd2gmst2(mjd)
% mjd2gmst  Converts  UT1  time in MJD to GMST in  radians
%
% Inputs:
%    mjd   - Modified  Julian  Date  Value [d]
%
% Outputs:
%    gmst - Greenwich  Mean  Sidereal  Time [rad]
d = mjd - 51544.5;
% Normalize  by  epoch (Jan. 1, 2000  12:00h)
gmst_deg = 280.4606 + 360.9856473*d;
gmst_rad = pi/180* gmst_deg;
gmst = mod(gmst_rad , 2*pi);
end