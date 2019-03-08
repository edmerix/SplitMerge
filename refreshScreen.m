function refreshScreen(app,~)
    if isfield(app.Data,'spikes')
        app.Data.colors = makeColors(app,length(unique(app.Data.spikes.assigns)));
        %refreshEditTimes(app); % update the file modification times
        %(Only need to refreshEditTimes upon saving, not all modifications)
        switch app.TabGroup.SelectedTab.Tag
            case 'merge'
                plotUnits(app);
            case 'split'
                splitLoad(app,[]);
            case 'outliers'
                outlierLoad(app,[]);
            case 'deets'
                deetLoad(app,[]);
            case 'pca'
                pcaLoad(app,[]);
            case 'noise'
                noiseLoad(app,[]);
            otherwise
                disp([9 'Unknown tab: ' app.TabGroup.SelectedTab.Tag])
        end
    else
        if app.Settings.Debugging
            disp([9 'Yet to load a file, not plotting'])
        end
    end
end