% Browse button pushed function
function BrowsePushed(app, ~)

    app.UIFigure.Visible = 'off'; % ugly requirement
    pth = uigetdir();
    app.UIFigure.Visible = 'on';

    if pth ~= 0
        app.Data.FilePath = pth;
        LoadDirectory(app)
    else
        disp('No directory selected');
    end
end