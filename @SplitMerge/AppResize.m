% Resize app: (not currently being called at all because resize is turned off)
function AppResize(app,~)
    app.Settings.Width = app.UIFigure.Position(3);
    app.Settings.Height = app.UIFigure.Position(4);

    app.BrowseButton.Position = [5 app.Settings.Height-30 190 25];
    app.FileTable.Position = [1 1 app.Settings.TreeWidth app.Settings.Height-35];
    app.TabGroup.Position = [app.Settings.TreeWidth 0 app.Settings.Width-app.Settings.TreeWidth app.Settings.Height];
    app.MergePanel.Position = [app.TabMerge.Position(3)-300 0 300 app.TabMerge.Position(4)-25];

    refreshScreen(app);
end