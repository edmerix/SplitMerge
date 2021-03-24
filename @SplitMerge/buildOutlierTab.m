function buildOutlierTab(app)
% Build outlier tab and position elements
uigrid = uigridlayout(app.TabOutliers,[5 3]);
uigrid.ColumnSpacing = 5;
uigrid.RowSpacing = 5;
uigrid.Padding = [10 10 10 10];
uigrid.RowHeight = {'1x',40,'1x','1x',30};
uigrid.ColumnWidth = {'2x','2.5x','1x'};

app.OutlierPanels.HistPlot = uiaxes(uigrid);
app.OutlierPanels.HistPlot.Layout.Row = 1;
app.OutlierPanels.HistPlot.Layout.Column = [1 2];
disableDefaultInteractivity(app.OutlierPanels.HistPlot);

app.OutlierPanels.OutlierSlider = uislider(uigrid);
app.OutlierPanels.OutlierSlider.Layout.Row = 2;
app.OutlierPanels.OutlierSlider.Layout.Column = [1 2];
app.OutlierPanels.OutlierSlider.ValueChangedFcn = createCallbackFcn(app, @outlierSlide, true);

app.OutlierPanels.CurrentWaves = uiaxes(uigrid);
app.OutlierPanels.CurrentWaves.Layout.Row = 3;
app.OutlierPanels.CurrentWaves.Layout.Column = 1;
disableDefaultInteractivity(app.OutlierPanels.CurrentWaves);

app.OutlierPanels.DropWaves = uiaxes(uigrid);
app.OutlierPanels.DropWaves.Layout.Row = 4;
app.OutlierPanels.DropWaves.Layout.Column = 1;
disableDefaultInteractivity(app.OutlierPanels.DropWaves);

app.OutlierPanels.PCA = uiaxes(uigrid);
app.OutlierPanels.PCA.Layout.Row = [3 4];
app.OutlierPanels.PCA.Layout.Column = 2;
disableDefaultInteractivity(app.OutlierPanels.PCA);

app.OutlierPanels.Selector = uilistbox(uigrid);
app.OutlierPanels.Selector.Layout.Row = [1 3];
app.OutlierPanels.Selector.Layout.Column = 3;
app.OutlierPanels.Selector.ValueChangedFcn = createCallbackFcn(app, @chooseUnitOutlier, true);

app.OutlierPanels.CutButton = uibutton(uigrid, 'push');
app.OutlierPanels.CutButton.Layout.Row = 5;
app.OutlierPanels.CutButton.Layout.Column = 3;
app.OutlierPanels.CutButton.Text = 'Remove outliers';
app.OutlierPanels.CutButton.Icon = [app.Data.impath 'cut.png'];
app.OutlierPanels.CutButton.ButtonPushedFcn = createCallbackFcn(app, @cutNow, true);
