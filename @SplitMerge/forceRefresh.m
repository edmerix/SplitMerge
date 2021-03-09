function forceRefresh(app,~)
    app.Data.modified = ones(size(app.Data.modified));
    app.Data.modifyList = unique(app.Data.spikes.assigns);
    app.refreshScreen();
end
