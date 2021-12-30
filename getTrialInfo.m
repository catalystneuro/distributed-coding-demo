function info = getTrialInfo(nwb_file, trial)
% GETTRIALINFO fetches information about the indicated trial from the
% provided NWB file.
%   INFO = GETTRIALINFO(NWB, TRIAL) returns a structure with the following
%   properties of the indicated trial: 
%       stim_contrast_left - Contrast of stimulus on left hemifield (0-1) 
%       stim_contrast_right - Contrast of stimulus on right hemifield (0-1) 
%       response_choice - Animal response registered at end of trial 
%           (right, No Go, or left)
%       response_time - Response time, relative to trial start (secs)
%       reaction_time - Time between go cue and response (secs)
%       feedback_type - Punishment or Reward, for correct or wrong choices
%           accordingly
%
% Define text for categorical numeric variables
choiceTypes = {'Right','No-Go','Left'};
feedbackTypes = {'Punishment','','Reward'};
% Initialize empty structure
info = struct();
% Fetch trial info
trial_start_time = nwb_file.intervals_trials.start_time.data(trial);
% stimulus info
info.stim_contrast_left = nwb_file.intervals_trials.vectordata.get('visual_stimulus_left_contrast').data(trial);
info.stim_contrast_right = nwb_file.intervals_trials.vectordata.get('visual_stimulus_right_contrast').data(trial);
% response info
go_time = nwb_file.intervals_trials.vectordata.get('go_cue').data(trial) - trial_start_time;
choice = nwb_file.intervals_trials.vectordata.get('response_choice').data(trial);
info.response_choice = choiceTypes{choice+2};
info.response_time = nwb_file.intervals_trials.vectordata.get('response_time').data(trial) - trial_start_time;
info.reaction_time = info.response_time - go_time;
% feedback info
feedback = nwb_file.intervals_trials.vectordata.get('feedback_type').data(trial);
info.feedback_type = feedbackTypes{feedback+2};
end