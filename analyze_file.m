clear all; close all; clc

% load('200_img.mat');
load('comm_reward_study_2.mat');

best_fs_reward = 0;
best_rule_reward = 0;
best_mcts_reward = 0;

for i = 1:length(N_SATS_VEC)
    
    n_images = N_IMAGE_VEC(i);
    comms_reward = COMMS_REWARD_VEC(i);
    n_sats = N_SATS_VEC(i);
    
    comms_idx = find(comms_reward_vec == comms_reward);
    image_idx = find(n_image_vec == n_images);
    sats_idx = find(n_sats_vec == n_sats);
    
    fs_rewards = reshape(SWEEP_RESULTS.FS_results(image_idx, comms_idx, sats_idx, :), [num_sims, 1]);
    if mean(fs_rewards) > best_fs_reward
        reward_vec_fs = fs_rewards;
        sim_time_fs = reshape(SWEEP_RESULTS.FS_time(image_idx, comms_idx, sats_idx, :), [num_sims, 1]);
        best_fs_reward = mean(fs_rewards);
        SWEEP_RESULTS.best_FS_rewards = reward_vec_fs;
        SWEEP_RESULTS.best_FS_n_image = n_images;
        SWEEP_RESULTS.best_FS_COMMS = comms_reward;
        SWEEP_RESULTS.best_FS_n_sats = n_sats;
    end
    
%     mcts_rewards = reshape(SWEEP_RESULTS.MCTS_results(image_idx, comms_idx, sats_idx, :), [num_sims, 1]);
%     if mean(mcts_rewards) > best_mcts_reward
%         reward_vec_mcts = mcts_rewards;
%         sim_time_mcts = reshape(SWEEP_RESULTS.MCTS_time(image_idx, comms_idx, sats_idx, :), [num_sims, 1]);
%         best_mcts_reward = mean(mcts_rewards);
%         SWEEP_RESULTS.best_MCTS_rewards = reward_vec_mcts;
%         SWEEP_RESULTS.best_MCTS_n_image = n_images;
%         SWEEP_RESULTS.best_MCTS_COMMS = comms_reward;
%         SWEEP_RESULTS.best_MCTS_n_sats = n_sats;
%     end
%     
    rule_rewards = reshape(SWEEP_RESULTS.RULE_results(image_idx, comms_idx, sats_idx, :), [num_sims, 1]);
    if mean(rule_rewards) > best_rule_reward
        reward_vec_rule = rule_rewards;
        sim_time_rule = reshape(SWEEP_RESULTS.RULE_time(image_idx, comms_idx, sats_idx, :), [num_sims, 1]);
        best_rule_reward = mean(rule_rewards);
        SWEEP_RESULTS.best_Rule_rewards = reward_vec_rule;
        SWEEP_RESULTS.best_Rule_n_image = n_images;
        SWEEP_RESULTS.best_Rule_COMMS = comms_reward;
        SWEEP_RESULTS.best_Rule_n_sats = n_sats;
    end
end

    

    subplot(1,3,1)
    plot([1:num_sims]', reward_vec_rule, 'b.-', 'markersize', 25, 'linewidth', 1.5, 'DisplayName','Rule'); hold on;

    subplot(1,3,2)
    plot([1:num_sims]', sim_time_rule, 'b.-', 'markersize', 25, 'linewidth', 1.5); hold on;

    subplot(1,3,3)
    plot([1:num_sims]', reward_vec_rule./sim_time_rule, 'b.-', 'markersize', 25, 'linewidth', 1.5); hold on;

    subplot(1,3,1)
    plot([1:num_sims]', reward_vec_fs, 'k*-', 'markersize', 10, 'linewidth', 1.5, 'DisplayName','SMDP-FS'); hold on;

    subplot(1,3,2)
    plot([1:num_sims]', sim_time_fs, 'k*-', 'markersize', 10, 'linewidth', 1.5); hold on;

    subplot(1,3,3)
    plot([1:num_sims]', reward_vec_fs./sim_time_fs, 'k*-', 'markersize', 10, 'linewidth', 1.5); hold on;

%     subplot(1,3,1)
%     plot([1:num_sims]', reward_vec_MCTS, 'bd-', 'markersize', 10, 'linewidth', 1.5, 'DisplayName','SMDP-MCTS'); hold on;
% 
%     subplot(1,3,2)
%     plot([1:num_sims]', sim_time_MCTS, 'bd-', 'markersize', 10, 'linewidth', 1.5); hold on;
% 
%     subplot(1,3,3)
%     plot([1:num_sims]', reward_vec_MCTS./sim_time_MCTS, 'bd-', 'markersize', 10, 'linewidth', 1.5); hold on;
%  
    
    subplot(1,3,1)
    ylabel('Total Reward')
    set(gca, 'fontsize', 15)
    legend('location', 'west')
    
    subplot(1,3,2)
    xlabel('Simulation Number')
    ylabel('Runtime (s)')
    set(gca, 'fontsize', 15)
    
    subplot(1,3,3)
    ylabel('Time-Normalized Reward (s^{-1})')
    set(gca, 'fontsize', 15)
    
    
    figure(2)
    for s = 1:length(n_sats_vec)
         subplot(1,2,1)
         plot(comms_reward_vec(2:end), reshape(mean(SWEEP_RESULTS.FS_results(1,2:end,s,:), 4), [length(comms_reward_vec)-1, 1]), '*-', 'markersize', 10, 'linewidth', 1.25,  'displayname', ['FS, ' num2str(n_sats_vec(s)) ' Satellites']); hold on
         plot(comms_reward_vec(2:end), reshape(mean(SWEEP_RESULTS.RULE_results(1,2:end,s,:), 4), [length(comms_reward_vec)-1, 1]), '.-', 'markersize', 25, 'linewidth', 1.25,  'displayname', ['Rule, ' num2str(n_sats_vec(s)) ' Satellites']); hold on
         subplot(1,2,2)
         plot(comms_reward_vec(2:end), reshape(mean(SWEEP_RESULTS.FS_num_images(1,2:end,s,:), 4), [length(comms_reward_vec)-1, 1]), '*-', 'markersize', 10, 'linewidth', 1.25,  'displayname', ['# Satellites: ' num2str(n_sats_vec(s))]); hold on
         plot(comms_reward_vec(2:end), reshape(mean(SWEEP_RESULTS.RULE_num_images(1,2:end,s,:), 4), [length(comms_reward_vec)-1, 1]), '.-', 'markersize', 25, 'linewidth', 1.25,  'displayname', ['Rule, ' num2str(n_sats_vec(s)) ' Satellites']); hold on
    end
    subplot(1,2,1)
    legend('location', 'best')
%     title('FS Communication Reward Tuning')
    ylabel('Total Reward')
    xlabel('Communication Reward')
    set(gca, 'fontsize', 15)
    
    subplot(1,2,2)
    ylabel('Total Unique Photos Taken')
    xlabel('Communication Reward')
    set(gca, 'fontsize', 15)
        