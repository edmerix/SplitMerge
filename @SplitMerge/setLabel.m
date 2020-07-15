% Set the selected clusters labels:
function setLabel(app,which)
    [~,idx] = intersect(app.Data.spikes.labels(:,1),app.Data.Selected,'stable');
    %idx = app.Data.spikes.labels(:,1) == app.Data.Selected;
    app.Data.spikes.labels(idx,2) = which;

    for i = 1:length(app.Data.Selected)
        ids = find(app.Data.spikes.labels(:,1) == app.Data.Selected(i));
        if length(ids) > 1
            app.Data.spikes.labels(ids(2:end),:) = [];
        end
    end
    app.Data.modifyList = [app.Data.modifyList app.Data.Selected];
    %pushHistory(app,'l',selected,which);
end
