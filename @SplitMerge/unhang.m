function unhang(app,~)
close(app.Data.loader);
app.MergeButton.Enable = 'on';
app.GarbageButton.Enable = 'on';
try
    app.refreshScreen();
catch
    warning('Returned control to user but failed the automatic screen refresh')
    close(app.Data.loader);
end