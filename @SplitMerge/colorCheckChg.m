function colorCheckChg(app,~)
    val = app.ColorCheck.Value;
    if val ~= app.Settings.Colorful
        app.Settings.Colorful = val;
        %plot_units(app);
        unq = unique(app.Data.spikes.assigns);
        if app.Settings.Colorful
            for u = 1:length(unq)
                if ~isempty(app.SpikePanels{unq(u)}) && ~isempty(app.SpikePanels{unq(u)}.Children)
                    ch = app.SpikePanels{unq(u)}.Children;
                    for c = 1:length(ch) % why no vectorization of graphics objects in matlab?
                        if strcmpi(ch(c).Type,'line')
                            app.SpikePanels{unq(u)}.Children(c).Color = app.Data.colors(u,:);
                        end
                    end
                end
            end
        else
            for u = 1:length(unq)
                if ~isempty(app.SpikePanels{unq(u)}) && ~isempty(app.SpikePanels{unq(u)}.Children)
                    ch = app.SpikePanels{unq(u)}.Children;
                    for c = 1:length(ch) % why no vectorization of graphics objects in matlab?
                        if strcmpi(ch(c).Type,'line')
                            app.SpikePanels{unq(u)}.Children(c).Color = [0 0.4470 0.7410];
                        end
                    end
                end
            end
        end
    end
end
