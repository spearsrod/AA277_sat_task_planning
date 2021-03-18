function s_0 = initialize_state(r0, t0)
% Function to initialize the state of the satellite at the inital condition
%   Accepts:
%       r0: The initial position of the satellite in ECEF coordinates
%       t0: The initial epoch in mjd. Currently does not do anything
%       because the rest of the sim is based off the time of the planning
%       horizon, without any reference to GMST. This will need to be
%       changed.
%   Returns:
%       s_0: The initial state with the initial time, full power, empty
%       data, and a dummy previous action. Satellite point is initialized
%       to the nadir direction.
s_0.t = 0;
s_0.tp_s = 0;
s_0.I_c = [];
s_0.d = 0; %TODO: Make sure this is correct
s_0.p = 1; %TODO: Make sure this is correct
s_0.n_prev_comms = 0;

init_start.t = 0;
init_start.sat_ecef = r0;
init_end.t = 0;
init_end.sat_ecef = r0;
init_general.type = "init";

%Assume initial pointing at nadir
epsilon = 10^(-10);
[phi_geod, lam_geod, h_geod] = ecef2geoded(r0, epsilon);
sub_sat_geod = [phi_geod; lam_geod; 0];
init_general.l_geod = sub_sat_geod;

initial_opp.start = init_start;
initial_opp.end = init_end;
initial_opp.general = init_general;

s_0.opp_prev = initial_opp;
end