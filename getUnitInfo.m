function unit_info = getUnitInfo(nwb_file)
% create empty structure
unit_info = struct;
%%% Electrode details
probe_list = keys(nwb_file.general_extracellular_ephys.map);
% electrode location
electrode_area = nwb_file.general_extracellular_ephys_electrodes.vectordata.get('location').data(:);
%%% All unit/cluster details
% get cluster annotations
annot = nwb_file.units.vectordata.get('phy_annotations').data(:);
% exclude MUA and noise (as in Steinmetz et al 2019 paper)
unit_info.valid_units = find(annot>=2);
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
unit_info.depth_valid = depth_all(unit_info.valid_units);
unit_info.probe_valid = probe_all(unit_info.valid_units);
unit_info.area_valid = electrode_area(channel_all(unit_info.valid_units));
end
function idx = probePathToIdx(probe_path, probe_list)
slash_idx = find(probe_path=='/');
probe = probe_path(slash_idx(end)+1:end);
idxC = strfind(probe_list,probe);
idx = find(not(cellfun('isempty',idxC)));
end