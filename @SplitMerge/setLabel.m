% Set the selected clusters labels:
function setLabel(app,which)
    %[~,idx] = intersect(app.Data.spikes.labels(:,1),app.Data.Selected,'stable');
    idx = find(app.Data.spikes.labels(:,1) == app.Data.Selected);
    if length(idx) > 1
        app.Data.spikes.labels(idx(2:end),:) = [];
        idx = idx(1);
    end
    app.Data.spikes.labels(idx,2) = which;

    %pushHistory(app,'l',selected,which);
end
