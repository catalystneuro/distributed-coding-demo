function unit_info = getUnitInfo(nwb_file)
% GETUNITINFO fetches information about valid units from the
% provided NWB file. Multi-unit activity and noise are non-valid, in line
% with Steinmetz et al., (2019).
%   UNIT_INFO = GETUNITINFO(NWB) returns a structure with the following
%   properties of each valid neuron. 
%       original_id - original index of recorded unit before selecting
%       valid unit subset
%       depth - recording depth of unit (µm)
%       area - brain region of provenance for recorded unit
%
%%% Electrode details
probe_list = keys(nwb_file.general_extracellular_ephys.map);
% electrode location
electrode_area = nwb_file.general_extracellular_ephys_electrodes.vectordata.get('location').data(:);
%%% All unit/cluster details
% get cluster annotations
annot = nwb_file.units.vectordata.get('phy_annotations').data(:);
% exclude MUA and noise (as in Steinmetz et al 2019 paper)
valid_units = find(annot>=2);
% recording probe
probe_all = arrayfun( ...
    @(x) probePathToIdx(x.path, probe_list), ...
    nwb_file.units.electrode_group.data ...
);
% cluster channel
channel_all = nwb_file.units.vectordata.get('peak_channel').data(:);
% cluster depth (0 = deepest, 3820 = shallowest; scale um)
depth_all = nwb_file.units.vectordata.get('cluster_depths').data(:)';
% get details for valid units
depth_valid = depth_all(valid_units);
probe_valid = probe_all(valid_units);
area_valid = electrode_area(channel_all(valid_units));
% create structure
unit_info = struct( ...
    'original_id', num2cell(valid_units), ...
    'depth', num2cell(depth_valid), ...
    'probe', num2cell(probe_valid), ...
    'area', area_valid ...
);
end
    
