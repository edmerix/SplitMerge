function buildSplitTab(app)
% Build split tab components and layout

uigrid = uigridlayout(app.TabSplit,[3 5]);
uigrid.ColumnSpacing = 5;
uigrid.RowSpacing = 0;
uigrid.Padding = [10 10 10 10];
uigrid.RowHeight = {'1x','1x',30};
uigrid.ColumnWidth = {'1x','1x','1x',50,'4x'};

app.SplitChaps.SplitTree = uiaxes(uigrid);
%app.SplitChaps.SplitTree.Position = [1 app.TabSplit.Position(4)/2 2*(app.TabSplit.Position(3)/5) (app.TabSplit.Position(4)/2)-10];
app.SplitChaps.SplitTree.Layout.Row = 1;
app.SplitChaps.SplitTree.Layout.Column = [1 3];

app.SplitChaps.SplitSlider = uislider(uigrid);
app.SplitChaps.SplitSlider.Orientation = 'vertical';
%{
app.SplitChaps.SplitSlider.Position(1) = app.SplitChaps.SplitTree.InnerPosition(1)+app.SplitChaps.SplitTree.InnerPosition(3);
app.SplitChaps.SplitSlider.Position(2) = app.SplitChaps.SplitTree.InnerPosition(2);
app.SplitChaps.SplitSlider.Position(4) =  app.SplitChaps.SplitTree.InnerPosition(4);
%}
app.SplitChaps.SplitSlider.Layout.Row = 1;
app.SplitChaps.SplitSlider.Layout.Column = 4;

app.SplitChaps.SplitSlider.ValueChangedFcn = createCallbackFcn(app, @splitSlide, true);
% Might do ValueChangingFcn for the above just for dragging the
% green line. Only apply changes on ChangedFcn not ChangingFcn.
disableDefaultInteractivity(app.SplitChaps.SplitTree);

app.SplitChaps.SplitWaves = uipanel(uigrid);
app.SplitChaps.SplitWaves.Title = 'Clusters with cutoff at step -';
%app.SplitChaps.SplitWaves.Position = [2*(app.TabSplit.Position(3)/5)+50 4 3*(app.TabSplit.Position(3)/5)-50 app.TabSplit.Position(4)-6];
app.SplitChaps.SplitWaves.Visible = 'on';
app.SplitChaps.SplitWaves.Scrollable = 'on';
app.SplitChaps.SplitWaves.Layout.Row = [1 3];
app.SplitChaps.SplitWaves.Layout.Column = 5;

app.SplitChaps.CurrentWaves = uiaxes(uigrid);
%app.SplitChaps.CurrentWaves.Position = [15 40 (2*app.TabSplit.Position(3)/5)-20 (app.TabSplit.Position(4)/2)-60];
app.SplitChaps.CurrentWaves.Layout.Row = 2;
app.SplitChaps.CurrentWaves.Layout.Column = [1 3];
disableDefaultInteractivity(app.SplitChaps.CurrentWaves);

app.SplitChaps.UnitSelection = uidropdown(uigrid);
%app.SplitChaps.UnitSelection.Position = [20 8 150 30];
app.SplitChaps.UnitSelection.Layout.Row = 3;
app.SplitChaps.UnitSelection.Layout.Column = 1;
app.SplitChaps.UnitSelection.ValueChangedFcn = createCallbackFcn(app, @chooseUnitSplit, true);

app.CommitSplit = uibutton(uigrid, 'push');
%app.CommitSplit.Position = [(2*app.TabSplit.Position(3)/5)-170 8 190 30];
app.CommitSplit.Layout.Row = 3;
app.CommitSplit.Layout.Column = [3 4];
app.CommitSplit.Text = 'Split cluster';
app.CommitSplit.FontWeight = 'bold';
%app.CommitSplit.FontColor = [0.4 0 0];
app.CommitSplit.Icon = [app.Data.impath 'split.png'];
app.CommitSplit.ButtonPushedFcn = createCallbackFcn(app, @splitNow, true);