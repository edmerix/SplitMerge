function positionComponents(app)
    % The below need repositioning or they end up slightly off.
    app.MergePanel.Position = [app.TabMerge.Position(3)-300 5 300 app.TabMerge.Position(4)-10];

    % percentages for starting position and height, from top to bottom:
    %{
    75, 25 (don't forget the unit selection box too)
    45, 25
    20, 25
    0,  20
    %}

    mergeButtonH = 45;
    availH = app.MergePanel.Position(4) - mergeButtonH;
    app.SelectedUnits.Position = [0.75*app.MergePanel.Position(3) (0.75*availH)+mergeButtonH 0.24*app.MergePanel.Position(3) 0.25*availH-25];
    app.MergedWaves.Position = [1 (0.75*availH-20)+mergeButtonH 0.74*app.MergePanel.Position(3) 0.25*availH];
    app.MergedMissing.Position = [1 (0.45*availH)+mergeButtonH app.MergePanel.Position(3)-5 (0.3*availH)-20];
    app.MergedAC.Position = [1 (0.2*availH)+mergeButtonH app.MergePanel.Position(3)-5 0.25*availH];
    app.MergedFR.Position = [1 mergeButtonH+1 app.MergePanel.Position(3)-5 0.2*availH];

    app.MergeButton.Position = [25+32+10 5 app.MergePanel.Position(3)-87-40 32];
    app.MergeButton.FontWeight = 'bold';
    app.MergeButton.Text = 'Merge selected';
    app.MergeButton.Icon = [app.Data.impath 'merge.png'];

    app.GarbageButton.Position = [15 5 40 32];
    app.GarbageButton.Text = '';
    app.GarbageButton.Tooltip = 'Remove selected';
    app.GarbageButton.Icon = [app.Data.impath 'trash.png'];

    app.GoodButton.Position = [app.MergePanel.Position(3)-10-40 5 40 32];
    app.GoodButton.Text = '';
    app.GoodButton.Tooltip = 'Mark selected as good';
    app.GoodButton.Icon = [app.Data.impath 'good.png'];

    app.Data.FirstLoad = false;
end