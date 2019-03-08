% Cell selection callback: FileTable
function FileTableCellSelection(app, event)
    indices = event.Indices;
    if indices(1) > 0 && indices(1) <= length(app.FileTable.Data)
        app.Data.activeFile = app.FileTable.Data{indices(1)};
        disp(['Active file: ' app.Data.activeFile])
        app.UnitsPanel.Title = 'Loading file...';
        app.UnitsPanel.Visible = 'off';
        drawnow;
        LoadFile(app);
    else
        warning('File selection out of bounds');
    end
end