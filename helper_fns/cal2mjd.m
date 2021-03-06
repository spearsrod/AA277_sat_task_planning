function  mjd = cal2mjd(M, D, Y)
% cal2mjd  Converts  UT1  time in  calendar  form to UT1  time inMJD
%
% Inputs:
%    M    - calendar  month
%    D    - calendar  day
%    Y    - calendar  year
%
% Outputs:
%    mjd - Modified  Julian  Date  value [d]
if M  <= 2
    y = Y - 1;
    m = M + 12;
else
    y = Y;
    m = M;
end
% Account  for  leap  days
B = Y/400 - Y/100 + Y/4;
mjd = 365*y - 679004 + floor(B) + floor (30.6001*(m + 1)) + D;
end