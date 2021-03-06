function  gmst = ut2gmst(cal , t)
% ut2gmst  Converts  from  UT1  time to GMST
%
% Inputs:
%     cal - vector  containing  simulation  start  date as [YYYY , MM, DD]
%       Note: the  day  should  be a decimal  value  accounting for  the 
%       start time of the  simulation
%       t - current  time in  seconds (from  Simulink  clock  source)
%
% Outputs:
%    gmst - current  Greenwich  Mean  Sidereal  Time [rad]
year = cal(1);
month = cal (2);
startDay = cal (3);
day = startDay + t/86400;
mjd = cal2mjd(month , day, year);
gmst = mjd2gmst2(mjd);
end