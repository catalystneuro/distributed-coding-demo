function idx = probePathToIdx(probe_path, probe_list)
% PROBEPATHTOIDX converts an HDF5 path to an indicated probe to an
% enumerated categorical variable using provided probe_list cell array.
slash_idx = find(probe_path=='/');
probe = probe_path(slash_idx(end)+1:end);
idxC = strfind(probe_list,probe);
idx = find(not(cellfun('isempty',idxC)));
end 