function tabChange(app, event)
    if app.Settings.Debugging
        disp(['Changing tab to ' event.NewValue.Tag])
    end
    app.refreshScreen();
end