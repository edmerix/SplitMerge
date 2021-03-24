function buildPCAtab(app)
% Build PCA tab and position elements (just buttons at the moment...)
uigrid = uigridlayout(app.TabPCA,[4 4]);
uigrid.ColumnSpacing = 15;
uigrid.RowSpacing = 15;
uigrid.Padding = [20 20 20 20];
%uigrid.RowHeight = {'1x','1x','1x','1x'};
%uigrid.ColumnWidth = {'1x','1x','1x','1x'};

app.PCAPanels.PCBtn = uibutton(uigrid, 'push');
app.PCAPanels.PCBtn.Layout.Row = 1;
app.PCAPanels.PCBtn.Layout.Column = [1 2];
app.PCAPanels.PCBtn.Text = {'Within-app PCA plot de-activated due to lagginess','Click anywhere to show PCA plot in a separate window'};
app.PCAPanels.PCBtn.ButtonPushedFcn = createCallbackFcn(app, @plotPCA, true);

app.PCAPanels.PCtimeBtn = uibutton(uigrid, 'push');
app.PCAPanels.PCtimeBtn.Layout.Row = 1;
app.PCAPanels.PCtimeBtn.Layout.Column = [3 4];
app.PCAPanels.PCtimeBtn.Text = 'PCA through time explorer';
app.PCAPanels.PCtimeBtn.ButtonPushedFcn = createCallbackFcn(app, @pcaTimeSlider, true);

app.PCAPanels.PCprojectionBtn = uibutton(uigrid, 'push');
app.PCAPanels.PCprojectionBtn.Layout.Row = 2;
app.PCAPanels.PCprojectionBtn.Layout.Column = [2 3];
app.PCAPanels.PCprojectionBtn.Text = 'Plot all projections of PC scores';
app.PCAPanels.PCprojectionBtn.ButtonPushedFcn = createCallbackFcn(app, @pcaFullPlot, true);