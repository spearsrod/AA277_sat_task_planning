function  rot = crf2trf(gmst)
% crf2trf  Creates a rotation  matrix  between  CRF  and  TRFsystems
%
% Inputs:
%    gmst - Greenwich  Mean  Sidereal  Time [rad]
%
% Outputs:
%    rot   - rotation  matrix  from  celestial  to  terrestrialreference  frames
rot = R_z(gmst);
end