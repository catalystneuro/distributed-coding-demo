function plotRastersAllUnits(nwb_file, trial)
% PLOTRASTERSALLUNITS plots raster plots for all valid units for the
% indicated trial from the provided NWB file. Valid units exclude 
% multi-unit activity and noise, in line with Steinmetz et al., 2019.
% PLOTRASTERSALLUNITS(NWB, TRIAL) Produces a plot with the following
% features:
%   - Different subplots for different recording probes
%   - Row location reflects recorded unit depth
%   - Row color reflects brain region of provenance for recorded unit
%   - Vertical line markers for relevant trial events (stim, tone, move,
%       feedback)
%
% Trial timing details
trial_start_time = nwb_file.intervals_trials.start_time.data(trial);
% stim
stim_time = nwb_file.intervals_trials.vectordata.get('visual_stimulus_time').data(trial) - trial_start_time;
% move
response_time = nwb_file.intervals_trials.vectordata.get('response_time').data(trial) - trial_start_time;
% tone
tone_time = nwb_file.intervals_trials.vectordata.get('go_cue').data(trial) - trial_start_time;
% reward
feedback_time = nwb_file.intervals_trials.vectordata.get('feedback_time').data(trial) - trial_start_time;
% time details for raster plots
before_time = 0;
after_time = 0.25 +feedback_time;
%%% Electrode details
probe_list = keys(nwb_file.general_extracellular_ephys.map);
nprobes = length(probe_list);
% electrode location
electrode_area = nwb_file.general_extracellular_ephys_electrodes.vectordata.get('location').data(:);
%%% All unit/cluster details
% get cluster annotations
annot = nwb_file.units.vectordata.get('phy_annotations').data(:);
% exclude MUA and noise (as in Steinmetz et al 2019 paper)
valid_units = find(annot>=2);
num_units = length(valid_units);
% recording probe
probe_all = arrayfun( ...
    @(x) probePathToIdx(x.path, probe_list), ...
    nwb_file.units.electrode_group.data ...
);
% cluster channel
channel_all = nwb_file.units.vectordata.get('peak_channel').data(:);
% cluster depth (0 = deepest, 3820 = shallowest; scale um)
depth_all = nwb_file.units.vectordata.get('cluster_depths').data(:);
% get details for valid units
depth_unit = depth_all(valid_units);
probe_unit = probe_all(valid_units);
area_unit = electrode_area(channel_all(valid_units));
% fetch raster data
raster_data = get_spike_raster(nwb_file, valid_units, ...
    trial_start_time, before_time, after_time);
%%% Make figure
% list areas
area_list = unique(area_unit);
num_areas = length(area_list);
% palette
palette = hsv(num_areas);
palette = rgb2hsv(palette);
palette(:,2) = 0.6; % reduce saturation
palette = hsv2rgb(palette);
% depth details
min_depth = 0;%microns
max_depth = 3820;% microns
figure;
for p = 1:nprobes
    probe_idxs = find(probe_unit==p);
    subplot(nprobes, 1, p)
    hold on
    % make raster plot
    for i = 1:length(probe_idxs)
        row_data = raster_data{probe_idxs(i)};
        row_loc = depth_unit(probe_idxs(i));
        row_color = palette(strcmp(area_unit(probe_idxs(i)),area_list),:);
        plot(row_data, ones(length(row_data),1) * row_loc, '.', ...
            'Color',row_color)
    end
    % set and get axis limit
    xlim([before_time after_time])
    ylim([min_depth max_depth])
    xl = xlim();
    % mark and label time points
    stim_text_loc = (stim_time-xl(1))/(xl(2)-xl(1));
    resp_text_loc = (response_time-xl(1))/(xl(2)-xl(1));
    tone_text_loc = (tone_time-xl(1))/(xl(2)-xl(1));
    xline([stim_time response_time tone_time])
    xline(feedback_time,'--') % mark feedback with dashed line to limit clutter
    text(stim_text_loc,1.01,'stim','HorizontalAlignment','center','Units','normalized')
    text(resp_text_loc,1.01,'move','HorizontalAlignment','center','Units','normalized')
    text(tone_text_loc,1.01,'tone','HorizontalAlignment','center','Units','normalized')
    
    % set yaxis ticks
    % ticks and labels must be flipped because:
    %   1) depth = 0 is deepest; depth = 3820 = most superficial
    %   2) top of probe should go at top of plot
    set(gca,'yTick', fliplr(3820:-1000:0)); 
    set(gca,'yTickLabel', fliplr(0:1000:3820));
    % set title and axes
    title(probe_list(p),'Units', 'normalized','Position',[0.5 1.05 0]) 
    xlabel('Time (seconds)')
    ylabel('Depth (\mum)')
    
end
% hacking together legend
hold on;
h = zeros(num_areas, 1);
for i =1:num_areas
    h(i) = plot(NaN,NaN,'.','Color',palette(i,:));
end
legend(h, area_list,'Location','southoutside','Orientation','Horizontal');
end
function raster_data = get_spike_raster(nwb_file, valid_units, ...
    trial_start_time, before_time, after_time)
% Get spike time data for all valid units
% read-in all spike times data, minimize I/O for performance
try
    index_data = nwb_file.units.spike_times_index.data.load(:);
    time_data = nwb_file.units.spike_times.data.load(:);
catch
    index_data = nwb_file.units.spike_times_index.data(:);
    time_data = nwb_file.units.spike_times.data(:);
end
% format ragged rows properly, limit spike times to desired period
raster_data = cell(length(valid_units),1);
for i = 1:length(valid_units)
    upper_bound = index_data(valid_units(i));
    if valid_units(i)==1
        lower_bound = 1;
    else
        lower_bound = index_data(valid_units(i)-1)+1;
    end
    spike_times = time_data(lower_bound:upper_bound);
    raster_data{i} = spike_times(...
                       spike_times >= trial_start_time + before_time & ...
                       spike_times <= trial_start_time + after_time) - ...
                       trial_start_time;
end
end




