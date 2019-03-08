function scaleCheckChg(app,~)
    val = app.ScaleCheck.Value;
    if val ~= app.Settings.ToScale
        app.Settings.ToScale = val;
        if app.Settings.ToScale
            yl = NaN(2,length(app.SpikePanels));
            for u = 1:length(app.SpikePanels)
                yl(:,u) = get(app.SpikePanels{u},'YLim');
            end
            for u = 1:length(app.SpikePanels)
                set(app.SpikePanels{u},'YLim',[min(yl(:)) max(yl(:))])
            end
        else
            for u = 1:length(app.SpikePanels)
                set(app.SpikePanels{u},'YLimMode','auto')
            end
        end
    end
end