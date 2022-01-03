function make_psth(nwb, options)
% MAKE_PSTH is a wrapper function for the psth function from
% distributed_coding_matnwb github repo. This function passes on the
% relevant arguments and updates the figure and subplot headings as
% necessary.
% ARGUMENTS
% nwb   -       Input NWB file
% unit_id -     Unit Id of unit in Units table
% unit_info -   Structure with details describing unit. Fields include area
%               and probe. If none provided, other details will be used for
%               figure title.
% align_to -    Trial event to which all trials are aligned (by default,
%               start_time)
% group_by -    name of the data type to group (by default, no grouping)
% before_time - left open range of time interval. Generally, it is negative
%               (by default before_time = -0.5 s)
% after_time -  right open range of time interval and must be greater than
%               before_time (by default after_time = 1.0 s)
% n_bins -      number of histogram bins (by default n_bins = 30)
% psth_plot_option - Plot option to whether plot histogram or smoothed
%                    gaussian plot (by default gaussian`)
%                    Available options are `histogram`, and
%                    `gaussian`
% std -         standard deviation of Gaussian filter
%               (by default std = 0.05)
%%
    arguments
        nwb {mustBeA(nwb, "NwbFile")}
        options.unit_id uint16
        options.unit_info struct
        options.align_to char = 'start_time'
        options.group_by char = 'no-condition'
        options.before_time double = -0.5
        options.after_time double = 1.0
        options.n_bins double = 30
        options.psth_plot_option char = 'gaussian'
        options.std double = 0.05
    end
% Unpack ptions
unit_info = options.unit_info;
group_by = options.group_by;
% Make psth and get figure handle
fig_handle = psth(...
   nwb, ...
   unit_id = options.unit_id, ...
   align_to = options.align_to, ...
   group_by = options.group_by, ...
   before_time = options.before_time, ...
   after_time = options.after_time, ...
   n_bins = options.n_bins, ...
   psth_plot_option = options.psth_plot_option, ...
   std = options.std);
% Update title
fig_handle.Children(1).String = ['PSTH for unit in region ', unit_info.area, ...
                                '; Probe ',num2str(unit_info.probe)];
% Update subplot headings, if necessary
label_dict = containers.Map({'feedback_type', 'response_choice'}, ...
                        {{'Punishment','Reward'}, {'Right','No-Go','Left'}});
if isKey(label_dict, group_by)
    for i = 2:length(fig_handle.Children)-1
        labels = label_dict(group_by);
        fig_handle.Children(i).Title.String = [replace(group_by, '_', ' '), ...
                                ' = ',labels{length(fig_handle.Children)-i}];
    end
end
end
