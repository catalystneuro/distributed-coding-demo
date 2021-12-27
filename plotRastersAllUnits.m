function plotRastersAllUnits(nwb_file, trial)

%trial timing details; 
trial_start_time = nwb_file.intervals_trials.start_time.data(trial);
% stim
stim_time = nwb_file.intervals_trials.vectordata.get('visual_stimulus_time').data(trial) - trial_start_time;
% move
response_time = nwb_file.intervals_trials.vectordata.get('response_time').data(trial) - trial_start_time;
% tone
tone_time = nwb_file.intervals_trials.vectordata.get('go_cue').data(trial) - trial_start_time;
% reward
feedback_time = nwb_file.intervals_trials.vectordata.get('feedback_time').data(trial) - trial_start_time;

probe_list = keys(nwb_file.general_extracellular_ephys.map);
nprobes = length(probe_list);

% exclude MUA and noise (as in Steinmetz et al 2019 paper)
annot = nwb_file.units.vectordata.get('phy_annotations').data(:);
valid_units = find(annot>=2);

% getting number of units
num_units = length(valid_units);

before_time = 0;
after_time = 1 +feedback_time;

%get unit depth (0 = deepest, 3820 = shallowest; scale um)
depths_all = nwb_file.units.vectordata.get('cluster_depths').data(:);

raster_data = {};
depth_unit = zeros(1,num_units);
probe_prov = zeros(1,num_units);

for n = 1:num_units
    % get unit probe provenance
    probe_path = nwb_file.units.electrode_group.data(valid_units(n)).path;
    slash_idx = find(probe_path=='/');
    probe = probe_path(slash_idx(end)+1:end);
    idxC = strfind(probe_list,probe);
    probe_prov(n) = find(not(cellfun('isempty',idxC)));
    depth_unit(n) = depths_all(valid_units(n));

    % get spike times
    spike_times = util.read_indexed_column(nwb_file.units.spike_times_index, ...
                                           nwb_file.units.spike_times, ...
                                           valid_units(n));
    raster_data{end+1} = spike_times(...
                       spike_times >= trial_start_time + before_time & ...
                       spike_times <= trial_start_time + after_time) - ...
                       trial_start_time;
end
% make figure
min_depth = 0;% microns
max_depth = 3820;% microns
figure;
for p = 1:nprobes
    probe_idxs = find(probe_prov==p);
    subplot(nprobes, 1, p)
    hold on
    % make raster plot
    for i = 1:length(probe_idxs)
        row_data = raster_data{probe_idxs(i)};
        row_loc = depth_unit(probe_idxs(i));
        plot(row_data, ones(length(row_data),1) * row_loc, '.', ...
            'Color','#add8e6')
    end
    % set and get axis limit
    xlim([before_time after_time])
    ylim([min_depth max_depth])
    yl = ylim();
    xl = xlim();
    % mark and label time points
    stim_text_loc = (stim_time-xl(1))/(xl(2)-xl(1));
    resp_text_loc = (response_time-xl(1))/(xl(2)-xl(1));
    tone_text_loc = (tone_time-xl(1))/(xl(2)-xl(1));
    xline([stim_time response_time tone_time feedback_time])
    text(stim_text_loc,1.01,'stim','HorizontalAlignment','center','Units','normalized')
    text(resp_text_loc,1.01,'move','HorizontalAlignment','center','Units','normalized')
    text(tone_text_loc,1.01,'tone','HorizontalAlignment','center','Units','normalized')
    % set yaxis ticks
    set(gca,'yTick', fliplr(3820:-1000:0));
    set(gca,'yTickLabel', fliplr(0:1000:3820));
    % set title and axes
    title(probe_list(p),'Units', 'normalized','Position',[0.5 1.05 0]) 
    xlabel('Time (seconds)')
    ylabel('Depth (\mum)')
end
