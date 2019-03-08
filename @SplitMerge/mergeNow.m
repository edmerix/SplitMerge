function mergeNow(app,~)
    if length(app.Data.Selected) < 2
        uialert(app.UIFigure,'Must select at least 2 clusters to merge','Cannot merge');
        return;
    end

    app.MergeButton.Enable = 'off';
    app.GarbageButton.Enable = 'off';

    for s = 2:length(app.Data.Selected)
        if app.Settings.Debugging
            disp([9 'Merging ' num2str(app.Data.Selected(s)) ' with ' num2str(app.Data.Selected(1))])
        end
        % dependent on merge_clusters from UMS:
        app.Data.spikes = merge_clusters(app.Data.spikes,app.Data.Selected(1),app.Data.Selected(s));

        %pushHistory(app,'m',app.Data.Selected(s),app.Data.Selected(1));
    end
    app.Data.modified = ones(1,length(app.Data.modified)); % one flag for each tab
    app.MergeButton.Enable = 'on';
    app.GarbageButton.Enable = 'on';
    
    refreshScreen(app);
end