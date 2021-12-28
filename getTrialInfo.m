function info = getTrialInfo(nwb_file, trial)

choiceTypes = {'Right','No-Go','Left'};
feedbackTypes = {'Punishment','','Reward'};
info = struct();
trial_start_time = nwb_file.intervals_trials.start_time.data(trial);
info.stim_contrast_left = nwb_file.intervals_trials.vectordata.get('visual_stimulus_left_contrast').data(trial);
info.stim_contrast_right = nwb_file.intervals_trials.vectordata.get('visual_stimulus_right_contrast').data(trial);
go_time = nwb_file.intervals_trials.vectordata.get('go_cue').data(trial) - trial_start_time;
choice = nwb_file.intervals_trials.vectordata.get('response_choice').data(trial);
info.response_choice = choiceTypes{choice+2};
info.response_time = nwb_file.intervals_trials.vectordata.get('response_time').data(trial) - trial_start_time;
info.reaction_time = info.response_time - go_time;
feedback = nwb_file.intervals_trials.vectordata.get('feedback_type').data(trial);
info.feedback_type = feedbackTypes{feedback+2};
end