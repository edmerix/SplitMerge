% Cell selection callback: FileTable
function FileTableCellSelection(app, event)
    if ~app.Data.Fresh
        selection = uiconfirm(app.UIFigure,...
            'You have edits to the current file, are you sure you want to change channel?',...
            'Unsaved edits!',...
            'Options',{'Discard changes','Cancel'},...
            'DefaultOption',2,'CancelOption',2);
    else
        selection = 'Discard changes';
    end
    if strcmp(selection,'Discard changes')
        app.Data.activeFile = event.Value;
        disp(['Active file: ' app.Data.activeFile])
        app.UnitsPanel.Title = 'Loading file...';
        app.UnitsPanel.Visible = 'off';
        drawnow;
        LoadFile(app);
    else
        app.FileTable.Value = app.Data.activeFile;
    end
end
