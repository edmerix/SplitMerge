function colorCheckChg(app,~)
    val = app.ColorCheck.Value;
    if val ~= app.Settings.Colorful
        app.Settings.Colorful = val;
        %plot_units(app);
        unq = unique(app.Data.spikes.assigns);
        if app.Settings.Colorful
            for u = 1:length(unq)
                if ~isempty(app.SpikePanels{unq(u)}) && ~isempty(app.SpikePanels{unq(u)}.Children)
                    app.SpikePanels{unq(u)}.Children(1).Color = app.Data.colors(u,:);
                end
            end
        else
            for u = 1:length(unq)
                if ~isempty(app.SpikePanels{unq(u)}) && ~isempty(app.SpikePanels{unq(u)}.Children)
                    app.SpikePanels{unq(u)}.Children(1).Color = [0 0.4470 0.7410];
                end
            end
        end
    end
end
