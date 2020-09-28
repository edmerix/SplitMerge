function markBad(app,~)
    if app.Settings.Debugging
        ids = app.Data.Selected;
        disp([9 'Setting unit(s) ' num2str(ids) ' as "bad"'])
    end

    setLabel(app,1); % bit silly, to wrap this function. But might come in handy later.
    app.Data.modified(1) = 1;
    app.refreshScreen();
end
