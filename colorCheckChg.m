function colorCheckChg(app,~)
    val = app.ColorCheck.Value;
    if val ~= app.Settings.Colorful
        app.Settings.Colorful = val;
        %plot_units(app);
        if app.Settings.Colorful
            for u = 1:length(app.SpikePanels)
                app.SpikePanels{u}.Children(1).Color = app.Data.colors(u,:);
            end
        else
            for u = 1:length(app.SpikePanels)
                app.SpikePanels{u}.Children(1).Color = [0 0.4470 0.7410];
            end
        end
    end
end