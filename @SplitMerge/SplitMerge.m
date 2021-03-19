classdef SplitMerge < matlab.apps.AppBase
    % SplitMerge class/figure.
    % A better GUI for review/tweaking of ultramegasort 2000 data, making
    % use of UIFigure, UIAxes, etc.
    %
    % NOTE: due to its use of Scrollable panels (plus some other features),
    % SplitMerge only works in Matlab r2018b (and maybe later versions,
    % though untested). It should only be minor tweaks to remove these
    % features for backwards compatibility, though channels with many
    % clusters will likely become unwieldy.
    %
    % The rest of this help section needs to be written properly, but for
    % now, type SplitMerge('help') for the most basic of info (allowable
    % input arguments).
    %
    % Merricks, EM. 2018-12-04

    % Properties that correspond to app components
    properties (Access = public)
        % some of these can become private properties instead, later
        % also, some of these can become structs of the others, e.g. a
        % group of all buttons.
        UIFigure        matlab.ui.Figure
        UIGrid          
        FileTable       matlab.ui.control.ListBox
        MergePanel      matlab.ui.container.Panel
        BrowseButton    matlab.ui.control.Button
        TabGroup        matlab.ui.container.TabGroup
        TabMerge        matlab.ui.container.Tab
        TabSplit        matlab.ui.container.Tab
        TabOutliers     matlab.ui.container.Tab
        TabDetails      matlab.ui.container.Tab
        TabPCA          matlab.ui.container.Tab
        TabNoise        matlab.ui.container.Tab
        UnitsPanel      matlab.ui.container.Panel
        SelectedUnits   matlab.ui.control.ListBox
        MergedWaves     matlab.ui.control.UIAxes
        MergedMissing   matlab.ui.control.UIAxes
        MergedAC        matlab.ui.control.UIAxes
        MergedFR        matlab.ui.control.UIAxes
        MergeButton     matlab.ui.control.Button
        GarbageButton   matlab.ui.control.Button
        GoodButton      matlab.ui.control.StateButton
        AggCutoff       matlab.ui.control.Spinner
        RecalcButton    matlab.ui.control.Button
        RefreshButton   matlab.ui.control.Button
        ColorCheck      matlab.ui.control.CheckBox
        ScaleCheck      matlab.ui.control.CheckBox
        DensityCheck    matlab.ui.control.CheckBox
        SaveButton      matlab.ui.control.Button
        CommitSplit     matlab.ui.control.Button

        % groups of UI items:
        SplitChaps
        SpikePanels     cell
        OutlierPanels
        DeetPanels
        PCAPanels
        NoisePanels

        % structs of info variables:
        Data
        Settings
    end

    methods (Access = public)
        % Refresh whatever tab is open:
        refreshScreen(app);
        % Force a full refresh:
        forceRefresh(app,~);
        % Refresh file edit times:
        refreshEditTimes(app);
        % Redo the whole spike sorting (e.g. we've removed some garbage)
        recalcClus(app,~);
        % Quickly break a minicluster in 2:
        breakCluster(app,id);
        % Try and recover from a frozen loading bar due to error:
        unhang(app);
        % Fix a wonky tree:
        pruneTree(app);
    end

    methods (Access = private)
        % Position the components correctly:
        positionComponents(app);
        % Build the merge tab contents:
        buildMergeTab(app);
        % Build the split tab contents:
        buildSplitTab(app);
        % Browse button pushed function
        BrowsePushed(app, ~);
        % Populate the file tree
        LoadDirectory(app, ~);
        % Cell selection callback: FileTable
        FileTableCellSelection(app, event);
        % Load the active file
        LoadFile(app);
        % Resize app:
        AppResize(app,~);
        % Handle key presses:
        AppKeyPress(app,event);
        % make n colors:
        cols = makeColors(~,n);  % This could be a static method...
        % Plot units function: (could be renamed mergeLoad to be in keeping
        % with other tabs
        plotUnits(app);
        % Compress waveforms into a single line method:
        [tt,wvs] = compressSpikes(~,t,spks); % This could be a static method...
        % Calculate waveform densities:
        [dens,y] = spikeHist(app,wvs);
        % Select units in the merge panel:
        UnitSelection(app,event);
        % Actually merge the selected clusters:
        mergeNow(app,~);
        % Actually split the cluster:
        splitNow(app,~);
        % Remove chosen outliers:
        cutNow(app,~);
        % Set the selected clusters labels:
        setLabel(app,which);
        % Actually delete clusters on press of garbage button:
        garbageCollector(app,~);
        % Remove currently chosen noise:
        cutNoise(app,~);
        % plot AC:
        plotAC(app,ax,ids);
        % plot FR:
        plotFR(app,ax,ids);
        % plot detection criterion: (depends on ultramegasort)
        plotDetectionCriterion(app,ax,ids);
        % Change whether plotting different colors or all same:
        colorCheckChg(app,~);
        % Change whether plotting to same scale or not:
        scaleCheckChg(app,~);
        % Change whether density plots are overlaid:
        densityCheckChg(app,~);
        % Write changes to the history file, so they can be repeated:
        pushHistory(app,method,varargin); % Deactivated at present...
        % Mark selected units as "good":
        markGood(app,~);
        % Mark selected units as "bad": (technically "unknown", just not
        % good)
        markBad(app,~);
        % Change split slider:
        splitSlide(app,event,val);
        % Change outlier slider:
        outlierSlide(app,event,val);
        % Change either noise slider:
        noiseSlide(app,~);
        % Change which units are selected in the PCA plot tab:
        PCASelection(app,~);
        % Tab change:
        tabChange(app,event);
        % Load the split tab:
        splitLoad(app,~);
        % Load the outlier tab:
        outlierLoad(app,~);
        % Load the details tab:
        deetLoad(app,~);
        % Load the PCA tab:
        pcaLoad(app,~);
        % Plot PCA in separate window:
        plotPCA(app,~);
        % Load the de-noise tab:
        noiseLoad(app,~);
    end

    % App initialization and construction
    methods (Access = private)
        % Create UIFigure and components
        function createComponents(app)
            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [round(rand(1,1)*100) round(rand(1,1)*100) app.Settings.Width app.Settings.Height];
            app.UIFigure.Name = 'Split & Merge Tool | Emerix';
            app.UIFigure.Resize = 'on'; % The figure is *mostly* capable of resizing, but it's not smooth, so I've turned it off. Set fig size when calling function.
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @AppResize, true);
            app.UIFigure.KeyPressFcn = createCallbackFcn(app, @AppKeyPress, true);

            if app.Settings.Fullscreen
                app.UIFigure.WindowState = 'fullscreen';
                ss = get(groot,'ScreenSize');
                app.Settings.Width = ss(3);
                app.Settings.Height = ss(4);
            end

            app.UIGrid = uigridlayout(app.UIFigure,[4 6]);
            app.UIGrid.ColumnSpacing = 0;
            app.UIGrid.RowSpacing = 0;
            app.UIGrid.Padding = [0 0 0 0];
            app.UIGrid.RowHeight = {5, 25, 5, '1x'};
            app.UIGrid.ColumnWidth = {5, 160, 5, 25, 5, '1x'};
            % BrowseButton
            app.BrowseButton = uibutton(app.UIGrid, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowsePushed, true);
            %app.BrowseButton.Position = [5 app.Settings.Height-30 app.Settings.TreeWidth-40 25];
            app.BrowseButton.Layout.Row = 2;
            app.BrowseButton.Layout.Column = 2;
            app.BrowseButton.Text = 'New directory...';
            app.BrowseButton.Icon = [app.Data.impath 'browse_small.png'];

            % SaveButton
            app.SaveButton = uibutton(app.UIGrid, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @saveSpikes, true);
            %app.SaveButton.Position = [app.Settings.TreeWidth-30 app.Settings.Height-30 25 25];
            app.SaveButton.Layout.Row = 2;
            app.SaveButton.Layout.Column = 4;
            app.SaveButton.Icon = [app.Data.impath 'save_small.png'];
            app.SaveButton.Text = '';
            app.SaveButton.Tooltip = 'Save (hold shift to save as)';

            % Create FileTable
            app.FileTable = uilistbox(app.UIGrid);
            %app.FileTable.ColumnName = {'Directory Contents'};
            %app.FileTable.RowName = {};
            %app.FileTable.CellSelectionCallback = createCallbackFcn(app, @FileTableCellSelection, true);
            app.FileTable.ValueChangedFcn = createCallbackFcn(app, @FileTableCellSelection, true);
            app.FileTable.Multiselect = 'off';
            %app.FileTable.Position = [1 1 app.Settings.TreeWidth app.Settings.Height-35];
            app.FileTable.Layout.Row = 4;
            app.FileTable.Layout.Column = [1 5];
            app.FileTable.Items = {};

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIGrid);
            %app.TabGroup.Position = [app.Settings.TreeWidth 0 app.Settings.Width-app.Settings.TreeWidth app.Settings.Height];
            app.TabGroup.Layout.Row = [1 4];
            app.TabGroup.Layout.Column = 6;
            app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @tabChange, true);

            % Create TabMerge
            app.TabMerge = uitab(app.TabGroup);
            app.TabMerge.Title = 'Inspect / Merge';
            app.TabMerge.Tag = 'merge';

            % Create TabSplit
            app.TabSplit = uitab(app.TabGroup);
            app.TabSplit.Title = 'Split';
            app.TabSplit.Tag = 'split';

            % Create TabOutliers
            app.TabOutliers = uitab(app.TabGroup);
            app.TabOutliers.Title = 'Outliers';
            app.TabOutliers.Tag = 'outliers';

            % Create TabDetails
            app.TabDetails = uitab(app.TabGroup);
            app.TabDetails.Title = 'Details';
            app.TabDetails.Tag = 'deets';

            % Create TabPCA
            app.TabPCA = uitab(app.TabGroup);
            app.TabPCA.Title = 'PCA';
            app.TabPCA.Tag = 'pca';

            % Create TabNoise
            app.TabNoise = uitab(app.TabGroup);
            app.TabNoise.Title = 'De-noise';
            app.TabNoise.Tag = 'noise';

            buildMergeTab(app);
            
            buildSplitTab(app);

            %% Outlier tab:
            app.OutlierPanels.HistPlot = uiaxes(app.TabOutliers);
            app.OutlierPanels.HistPlot.Position = [10 2*app.TabOutliers.Position(4)/3 2*app.TabOutliers.Position(3)/3 (app.TabOutliers.Position(4)/3)-5];
            disableDefaultInteractivity(app.OutlierPanels.HistPlot);

            app.OutlierPanels.OutlierSlider = uislider(app.TabOutliers);
            app.OutlierPanels.OutlierSlider.Position(1) = app.OutlierPanels.HistPlot.InnerPosition(1);
            app.OutlierPanels.OutlierSlider.Position(2) = (2*app.TabOutliers.Position(4)/3)-3;
            app.OutlierPanels.OutlierSlider.Position(3) = app.OutlierPanels.HistPlot.InnerPosition(3);
            app.OutlierPanels.OutlierSlider.ValueChangedFcn = createCallbackFcn(app, @outlierSlide, true);

            app.OutlierPanels.CurrentWaves = uiaxes(app.TabOutliers);
            app.OutlierPanels.CurrentWaves.Position = [10 (app.TabOutliers.Position(4)/3)-10 (app.TabOutliers.Position(3)/3)-40 (app.TabOutliers.Position(4)/3)-35];
            disableDefaultInteractivity(app.OutlierPanels.CurrentWaves);

            app.OutlierPanels.DropWaves = uiaxes(app.TabOutliers);
            app.OutlierPanels.DropWaves.Position = [10 10 (app.TabOutliers.Position(3)/3)-40 (app.TabOutliers.Position(4)/3)-35];
            disableDefaultInteractivity(app.OutlierPanels.DropWaves);

            app.OutlierPanels.PCA = uiaxes(app.TabOutliers);
            app.OutlierPanels.PCA.Position = [(app.TabOutliers.Position(3)/3)-10 35 (app.TabOutliers.Position(3)/3)+40 (2*app.TabOutliers.Position(4)/3)-95];
            disableDefaultInteractivity(app.OutlierPanels.PCA);

            app.OutlierPanels.Selector = uilistbox(app.TabOutliers);
            app.OutlierPanels.Selector.Position = [app.TabOutliers.Position(3)-170 app.TabOutliers.Position(4)-410 160 400];
            app.OutlierPanels.Selector.ValueChangedFcn = createCallbackFcn(app, @chooseUnitOutlier, true);

            app.OutlierPanels.CutButton = uibutton(app.TabOutliers, 'push');
            app.OutlierPanels.CutButton.Position = [app.TabOutliers.Position(3)-220 30 200 30];
            app.OutlierPanels.CutButton.Text = 'Remove outliers';
            app.OutlierPanels.CutButton.Icon = [app.Data.impath 'cut.png'];
            app.OutlierPanels.CutButton.ButtonPushedFcn = createCallbackFcn(app, @cutNow, true);

            %% Details tab:


            %% PCA tab:
            %{
            app.PCAPanels.PCAView = uiaxes(app.TabPCA);
            % Create PCASelected
            app.PCAPanels.PCASelected = uilistbox(app.TabPCA);
            app.PCAPanels.PCASelected.ValueChangedFcn = createCallbackFcn(app, @PCASelection, true);
            app.PCAPanels.PCASelected.Position = [app.TabPCA.Position(3)-170 app.TabPCA.Position(4)-220 160 200];
            app.PCAPanels.PCASelected.Multiselect = 'on';
            %}
            app.PCAPanels.PCBtn = uibutton(app.TabPCA, 'push');
            app.PCAPanels.PCBtn.Position = app.TabPCA.Position; % lols.
            app.PCAPanels.PCBtn.Text = {'Within-app PCA plot de-activated due to lagginess','Click anywhere to show PCA plot in a separate window'};
            app.PCAPanels.PCBtn.ButtonPushedFcn = createCallbackFcn(app, @plotPCA, true);

            %% Noise tab:
            app.NoisePanels.PowerSpec = uiaxes(app.TabNoise);
            app.NoisePanels.Waveforms = uiaxes(app.TabNoise);
            app.NoisePanels.PowerSlider = uislider(app.TabNoise);
            app.NoisePanels.FreqSlider(1) = uislider(app.TabNoise);
            app.NoisePanels.FreqSlider(2) = uislider(app.TabNoise);
            app.NoisePanels.CutNoise = uibutton(app.TabNoise, 'push');

            app.NoisePanels.PowerSpec.Visible = 'off';
            app.NoisePanels.Waveforms.Visible = 'off';
            app.NoisePanels.PowerSlider.Visible = 'off';
            app.NoisePanels.FreqSlider(1).Visible = 'off';
            app.NoisePanels.FreqSlider(2).Visible = 'off';
            app.NoisePanels.CutNoise.Visible = 'off';

            app.NoisePanels.PowerSlider.ValueChangedFcn = createCallbackFcn(app, @noiseSlide, true);
            app.NoisePanels.FreqSlider(1).ValueChangedFcn = createCallbackFcn(app, @noiseSlide, true);
            app.NoisePanels.FreqSlider(2).ValueChangedFcn = createCallbackFcn(app, @noiseSlide, true);
            app.NoisePanels.CutNoise.ButtonPushedFcn = createCallbackFcn(app, @cutNoise, true);

            disableDefaultInteractivity(app.NoisePanels.PowerSpec);
            disableDefaultInteractivity(app.NoisePanels.Waveforms);

        end

        % Save back to file, or to a new one if shift held
        function saveSpikes(app,~)
            modifiers = get(app.UIFigure,'currentModifier');
            if app.Settings.Debugging
                assignin('base','modifiers',modifiers)
            end
            spikes = app.Data.spikes;
            if any(strcmpi(modifiers,'shift'))
                % save as
                saveAsSpikes(app,[]);
            else
                % save
                msg = 'Saving these changes will overwrite previous changes';
                title = 'Confirm Save';
                selection = uiconfirm(app.UIFigure,msg,title,...
                   'Options',{'Overwrite','Save as new','Cancel'},...
                   'DefaultOption',1,'CancelOption',3);
                if strcmpi(selection,'overwrite')
                    svpth = [app.Data.FilePath filesep app.Data.activeFile];
                    save(svpth,'spikes');
                    disp(['Saved file at ' svpth ' at ' cell2mat(string(datetime))]);
                    app.Data.modified = zeros(1,length(app.Data.modified));
                    app.Data.Fresh = true;
                elseif strcmpi(selection,'save as new')
                    saveAsSpikes(app,[]);
                end
            end
            %refreshEditTimes(app); % update the file modification times
        end

        % Save as routine:
        function saveAsSpikes(app,~)
            spikes = app.Data.spikes;
            app.UIFigure.Visible = 'off';
            [file,pth] = uiputfile('*.mat','SplitMerge file',app.Data.activeFile);
            svpth = [pth file];
            if isequal(pth,0) || isequal(file,0)
                disp([9 'Cancelled, not saving.'])
            else
                save(svpth,'spikes');
                disp(['Saved file at ' svpth]);
                app.Data.modified = zeros(1,length(app.Data.modified));
                app.Data.Fresh = true;
            end
            %refreshEditTimes(app); % update the file modification times
            app.UIFigure.Visible = 'on';
        end
    end


    methods (Access = public)
        % Construct app
        function app = SplitMerge(varargin)
            app.Settings.Directory = '';
            app.Settings.Fullscreen = 0;
            app.Settings.Height = 900;
            app.Settings.Width = 1440;
            app.Settings.TreeWidth = 200;
            app.Settings.Colorful = true; % whether to plot different units in different colors
            app.Settings.ToScale = false; % whether to plot all unit waveforms to the same scale
            app.Settings.Density = false; % whether to plot the density histograms over the top of waveforms
            app.Settings.DensityBins = 50; % number of bins to use during density plots
            app.Settings.UpsampleRate = 1; % how much to upsample for FFT on spikes for noise detection
            app.Settings.nFFT = 8192;
            app.Settings.DateSort = false;
            app.Settings.SizeSort = false;
            app.Settings.Debugging = false;
            app.Settings.Epoch = []; % If empty, time plots fit to data, else xlim is set to this (a warning is given if spikes occur beyond epoch)
            app.Settings.ShowTime = false; % whether or not to show xticks on time plot

            allowable = fieldnames(app.Settings);
            if nargin > 0 && strcmpi(varargin{1},'help')
                % display allowable, then return
                disp([9 'Allowable input arguments:'])
                for a = 1:length(allowable)
                    disp([9 9 allowable{a}])
                end
                delete(app);
                if nargout == 0
                    clear app
                end
                return;
            end

            if mod(length(varargin),2) ~= 0
                error('Inputs must be in name, value pairs');
            end
            for v = 1:2:length(varargin)
                if find(ismember(allowable,varargin{v}))
                    app.Settings.(varargin{v}) = varargin{v+1};
                else
                    disp([9 'Not assigning ''' varargin{v} ''': not a property of SplitMerge class']);
                end
            end

            app.Data.impath = [fileparts(mfilename('fullpath')) filesep];
            app.Data.FirstLoad = true;
            app.Data.Fresh = true;
            app.Data.Selected = [];
            % set app.Data.modified to 1 to force re-plots when changing
            % tabs, or after a merge, etc. One flag for each tab.
            app.Data.modified = [0 0 0 0 0 0];
            app.Data.modifyList = [];

            if ~app.Settings.Debugging
                warning('off','MATLAB:callback:error');
            end

            % Create and configure components
            createComponents(app);
            %positionComponents(app); %TODO: check this is still required

            app.ScaleCheck.Value = app.Settings.ToScale;
            app.ColorCheck.Value = app.Settings.Colorful;
            app.DensityCheck.Value = app.Settings.Density;

            % Register the app with App Designer
            registerApp(app, app.UIFigure);

            if ~isempty(app.Settings.Directory) && ~strcmpi(app.Settings.Directory,'')
                app.Data.FilePath = app.Settings.Directory;
                pause(0.2); % let the figure load first
                LoadDirectory(app);
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)
            warning('on','MATLAB:callback:error'); % turn this back on
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
