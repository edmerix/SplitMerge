% Set the selected clusters labels:
function setLabel(app,which)
    selected = app.Data.Selected;
    [~,idx] = intersect(app.Data.spikes.labels(:,1),selected,'stable');

    app.Data.spikes.labels(idx,2) = which;

    %pushHistory(app,'l',selected,which);
end