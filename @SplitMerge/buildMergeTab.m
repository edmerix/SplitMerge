function buildMergeTab(app)

uigrid = uigridlayout(app.TabMerge,[2 9]);
uigrid.ColumnSpacing = 5;
uigrid.RowSpacing = 5;
uigrid.Padding = [5 3 1 5];
uigrid.RowHeight = {24, '1x'};
uigrid.ColumnWidth = {5, 100, 100, 120, '1x', 115, 140, 100, 300};

% Create MergePanel
app.MergePanel = uipanel(uigrid);
app.MergePanel.Title = 'Selected cluster(s)';
%app.MergePanel.Position = [app.TabMerge.Position(3)-300 0 300 app.TabMerge.Position(4)-25];
app.MergePanel.Visible = 'off';
app.MergePanel.Layout.Row = [1 2];
app.MergePanel.Layout.Column = 9;

% Create UnitsPanel
app.UnitsPanel = uipanel(uigrid);
app.UnitsPanel.Title = 'Units';
app.UnitsPanel.Visible = 'off';
app.UnitsPanel.Scrollable = 'on';
app.UnitsPanel.Layout.Row = 2;
app.UnitsPanel.Layout.Column = [1 8];

% Create agg_cutoff value
app.AggCutoff = uispinner(uigrid);
app.AggCutoff.ValueDisplayFormat = 'AggCutoff: %.2f';
app.AggCutoff.Visible = 'off';
app.AggCutoff.Step = 0.01;
app.AggCutoff.Layout.Row = 1;
app.AggCutoff.Layout.Column = 6;

% Create RecalcButton
app.RecalcButton = uibutton(uigrid,'push');
app.RecalcButton.Text = 'Recalculate clusters';
app.RecalcButton.Visible = 'off';
app.RecalcButton.ButtonPushedFcn = createCallbackFcn(app, @recalcClus, true);
app.RecalcButton.Layout.Row = 1;
app.RecalcButton.Layout.Column = 7;

% Create RefreshButton
app.RefreshButton = uibutton(uigrid,'push');
app.RefreshButton.Text = 'Refresh plots';
app.RefreshButton.Visible = 'off';
app.RefreshButton.ButtonPushedFcn = createCallbackFcn(app, @forceRefresh, true);
app.RefreshButton.Layout.Row = 1;
app.RefreshButton.Layout.Column = 8;

% Create scale/colorful/density checkboxes
app.ScaleCheck = uicheckbox(uigrid);
app.ScaleCheck.Text = 'Maintain scale';
app.ScaleCheck.Visible = 'off';
app.ScaleCheck.ValueChangedFcn = createCallbackFcn(app, @scaleCheckChg, true);
app.ScaleCheck.Layout.Row = 1;
app.ScaleCheck.Layout.Column = 2;

app.ColorCheck = uicheckbox(uigrid);
app.ColorCheck.Text = 'Colorful plots';
app.ColorCheck.Visible = 'off';
app.ColorCheck.ValueChangedFcn = createCallbackFcn(app, @colorCheckChg, true);
app.ColorCheck.Layout.Row = 1;
app.ColorCheck.Layout.Column = 3;

app.DensityCheck = uicheckbox(uigrid);
app.DensityCheck.Text = 'Density overlays';
app.DensityCheck.Visible = 'off';
app.DensityCheck.ValueChangedFcn = createCallbackFcn(app, @densityCheckChg, true);
app.DensityCheck.Layout.Row = 1;
app.DensityCheck.Layout.Column = 4;


%% Create SelectedUnits
mergeGrid = uigridlayout(app.MergePanel,[5 4]);
mergeGrid.ColumnSpacing = 5;
mergeGrid.RowSpacing = 1;
mergeGrid.Padding = [3 8 3 3];
mergeGrid.RowHeight = {'1x','1.2x','1.2x','1x',35};
mergeGrid.ColumnWidth = {40,'1x',20,40};

app.SelectedUnits = uilistbox(mergeGrid);
app.SelectedUnits.ValueChangedFcn = createCallbackFcn(app, @UnitSelection, true);
app.SelectedUnits.Position = [0.75*app.MergePanel.Position(3) app.MergePanel.Position(4)-220 0.24*app.MergePanel.Position(3) 200];
app.SelectedUnits.Multiselect = 'on';
app.SelectedUnits.Layout.Row = 1;
app.SelectedUnits.Layout.Column = [3 4];

% Create MergedWaves
app.MergedWaves = uiaxes(mergeGrid);
app.MergedWaves.Layout.Row = 1;
app.MergedWaves.Layout.Column = [1 2];
disableDefaultInteractivity(app.MergedWaves);

% Create MergedMissing
app.MergedMissing = uiaxes(mergeGrid);
app.MergedMissing.Layout.Row = 2;
app.MergedMissing.Layout.Column = [1 4];
disableDefaultInteractivity(app.MergedMissing);

% Create MergedAC
app.MergedAC = uiaxes(mergeGrid);
app.MergedAC.Layout.Row = 3;
app.MergedAC.Layout.Column = [1 4];
disableDefaultInteractivity(app.MergedAC);

% Create MergedFR
app.MergedFR = uiaxes(mergeGrid);
app.MergedFR.Layout.Row = 4;
app.MergedFR.Layout.Column = [1 4];
disableDefaultInteractivity(app.MergedFR);

% Create Buttons in merge panel
app.MergeButton = uibutton(mergeGrid, 'push');
app.MergeButton.Layout.Row = 5;
app.MergeButton.Layout.Column = [2 3];
app.MergeButton.ButtonPushedFcn = createCallbackFcn(app, @mergeNow, true);
app.MergeButton.FontWeight = 'bold';
app.MergeButton.Text = 'Merge selected';
app.MergeButton.Icon = [app.Data.impath 'merge.png'];

app.GarbageButton = uibutton(mergeGrid, 'push');
app.GarbageButton.Layout.Row = 5;
app.GarbageButton.Layout.Column = 1;
app.GarbageButton.ButtonPushedFcn = createCallbackFcn(app, @garbageCollector, true);
app.GarbageButton.Text = '';
app.GarbageButton.Tooltip = 'Remove selected';
app.GarbageButton.Icon = [app.Data.impath 'trash.png'];
    
app.GoodButton = uibutton(mergeGrid, 'state');
app.GoodButton.Layout.Row = 5;
app.GoodButton.Layout.Column = 4;
app.GoodButton.ValueChangedFcn = createCallbackFcn(app, @markGood, true);
app.GoodButton.Text = '';
app.GoodButton.Tooltip = 'Mark selected as good';
app.GoodButton.Icon = [app.Data.impath 'good.png'];

app.Data.FirstLoad = false;