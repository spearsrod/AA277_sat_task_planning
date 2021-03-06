function [total_reward, combined_I_c, n_ground_links, n_actions, n_comms, n_repeat_images, comms_times, n_photos, n_sun_point] = MA_parse_policy(policies, params)
n_sats = size(policies, 2);
combined_I_c = [];
total_reward = 0;
n_ground_links = zeros(1,n_sats);
n_comms = zeros(1,n_sats);
n_actions = zeros(1, n_sats);
n_photos = zeros(1, n_sats);
n_sun_point = zeros(1, n_sats);
n_repeat_images = 0;
comms_times = [];
for idx = 1:n_sats
    policy = policies{idx};
    cur_actions = size(policy, 2);
    cur_reward = 0;
    cur_ground_links = 0;
    cur_comms = 0;
    cur_photos = 0;
    cur_sun_point = 0;
    for idx2 = 1:cur_actions
        s_cur = policy{idx2}{1};
        a_cur = policy{idx2}{2};
        if(idx2 < cur_actions)
            [r_cur, I_c_new, repeat_image] = final_reward_function(s_cur, a_cur, params{idx}, combined_I_c);
            n_repeat_images = n_repeat_images + repeat_image;
            if(size(I_c_new, 1) == 3)
                combined_I_c = [combined_I_c I_c_new];
            end
            cur_reward = cur_reward + r_cur;
        end
        cur_action = policy{idx2}{2}.general.type;
        if(cur_action == "station")
            cur_ground_links = cur_ground_links + 1;
        end
        if(cur_action == "comms")
            cur_comms = cur_comms + 1;
            cur_time = a_cur.start.t;
            comms_times = [comms_times cur_time];
        end
        if(cur_action == "image")
            cur_photos = cur_photos + 1;
        end
        if(cur_action == "NIL")
            cur_sun_point = cur_sun_point + 1;
        end
    end
    n_ground_links(idx) = cur_ground_links;
    n_comms(idx) = cur_comms;
    n_actions(idx) = cur_actions;
    
    n_photos(idx) = cur_photos;
    n_sun_point(idx) = cur_sun_point;
    total_reward = total_reward + cur_reward;
end
end