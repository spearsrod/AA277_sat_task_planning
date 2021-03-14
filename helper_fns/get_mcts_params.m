function params = get_mcts_params(orbits, t, general_params, comms_reward)
Images = general_params.Images;
Gstations = general_params.Gstations;
rewards = general_params.rewards;
N_max = 3;
N_max_sim = 500;
c = 1;
gamma = 0.99;
p_min = general_params.p_min;
d_max = general_params.d_max;

% Image capture requires 30 seconds
image_duration = 30;
% Minimum elevation for ground station contact
min_elev = 5;
% Set max and min look angles required for successfull imaging
look_angle_min = 5;
look_angle_max = 50;
n_sats = size(orbits, 2);
min_dist = 5000;
params = cell(1,n_sats);
for idx = 1:n_sats
    sat_ecef = orbits{idx}.sat_ecef;
    sat_geod = orbits{idx}.sat_geod;
    cur_params.Image_Opps = collect_image_opportunities(sat_ecef, sat_geod, t,...
        Images, look_angle_min, look_angle_max, image_duration);
    cur_params.Station_Opps = collect_groundlink_opportunities(sat_ecef, t,...
        Gstations, min_elev, image_duration);
    cur_params.Images = Images;
    cur_params.Gstations = Gstations;
    cur_params.rewards = rewards;
    comms_opps = {};
    for idx2 = 1:n_sats
        if(idx == idx2)
            continue;
        end
        orbit1 = orbits{idx};
        orbit2 = orbits{idx2};
        cur_comms_opps = collect_comms_opportunities(orbit1, orbit2, t, min_dist);
        comms_opps = [comms_opps cur_comms_opps];
    end
    cur_params.Comms_Opps = comms_opps;
    cur_params.slew_rate = 1;
    cur_params.t0 = 0;
    cur_params.N_max = N_max;
    cur_params.gamma = gamma;
    cur_params.p_min = p_min;
    cur_params.d_max = d_max;
    cur_params.comms_reward = comms_reward;
    cur_params.t_final = t(end);
    cur_params.N_max_sim = N_max_sim;
    cur_params.c = c;
    params{idx} = cur_params;
end
end