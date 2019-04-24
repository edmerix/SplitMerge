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
        FileTable       matlab.ui.control.Table
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
        GoodButton      matlab.ui.control.Button
        AggCutoff       matlab.ui.control.Spinner
        RecalcButton    matlab.ui.control.Button
        ColorCheck      matlab.ui.control.CheckBox
        ScaleCheck      matlab.ui.control.CheckBox
        SaveButton      matlab.ui.control.Button
        CommitSplit     matlab.ui.control.Button
        
        % groups of UI items:
        SplitChaps
        SpikePanels
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
        % Refresh file edit times:
        refreshEditTimes(app);
        % Redo the whole spike sorting (e.g. we've removed some garbage)
        recalcClus(app,~);
        % Quickly break a minicluster in 2:
        breakCluster(app,id);
        % Try and recover from a frozen loading bar due to error:
        unhang(app);
    end
    
    methods (Access = private)
        % Browse button pushed function
        BrowsePushed(app, ~);
        % Populate the file tree
        LoadDirectory(app, ~);
        % Cell selection callback: FileTable
        FileTableCellSelection(app, event);
        % Load the active file
        LoadFile(app);
        % Resize app: (not currently being called at all because resize is turned off)
        AppResize(app,~);
        % make n colors:
        cols = makeColors(~,n);  % This could be a static method...
        % Plot units function: (could be renamed mergeLoad to be in keeping
        % with other tabs
        plotUnits(app);
        % Compress waveforms into a single line method:
        [tt,wvs] = compressSpikes(~,t,spks); % This could be a static method...
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
        % Write changes to the history file, so they can be repeated:
        pushHistory(app,method,varargin); % Deactivated at present...
        % Mark selected units as "good":
        markGood(app,~);
        % Change split slider:
        splitSlide(app,event);
        % Change outlier slider:
        outlierSlide(app,event);
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
            app.UIFigure.Resize = 'off'; % The figure is *mostly* capable of resizing, but it's not smooth, so I've turned it off. Set fig size when calling function.
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @AppResize, true);
            
            if app.Settings.Fullscreen
                app.UIFigure.WindowState = 'fullscreen';
                ss = get(groot,'ScreenSize');
                app.Settings.Width = ss(3);
                app.Settings.Height = ss(4);
            end
            
            % BrowseButton
            app.BrowseButton = uibutton(app.UIFigure, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowsePushed, true);
            app.BrowseButton.Position = [5 app.Settings.Height-30 160 25];
            app.BrowseButton.Text = 'New directory...';
            app.BrowseButton.Icon = [app.Data.impath 'browse.png'];
            
            % SaveButton
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @saveSpikes, true);
            app.SaveButton.Position = [170 app.Settings.Height-30 25 25];
            app.SaveButton.Icon = [app.Data.impath 'save.png'];
            app.SaveButton.Text = '';
            app.SaveButton.Tooltip = 'Save (hold shift to save as)';
            
            % Create FileTable
            app.FileTable = uitable(app.UIFigure);
            app.FileTable.ColumnName = {'Directory Contents'};
            app.FileTable.RowName = {};
            app.FileTable.CellSelectionCallback = createCallbackFcn(app, @FileTableCellSelection, true);
            app.FileTable.Position = [1 1 app.Settings.TreeWidth app.Settings.Height-35];
            
            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [app.Settings.TreeWidth 0 app.Settings.Width-app.Settings.TreeWidth app.Settings.Height];
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

            %% Inspect/merge panel:
            % Create MergePanel
            app.MergePanel = uipanel(app.TabMerge);
            app.MergePanel.Title = 'Selected cluster(s)';
            app.MergePanel.Position = [app.TabMerge.Position(3)-300 0 300 app.TabMerge.Position(4)-25];
            app.MergePanel.Visible = 'off';
            
            % Create UnitsPanel
            app.UnitsPanel = uipanel(app.TabMerge);
            app.UnitsPanel.Title = 'Units';
            app.UnitsPanel.Visible = 'off';
            app.UnitsPanel.Scrollable = 'on';
            
            % Create agg_cutoff value
            app.AggCutoff = uispinner(app.TabMerge);
            app.AggCutoff.ValueDisplayFormat = 'AggCutoff: %.2f';
            app.AggCutoff.Visible = 'off';
            app.AggCutoff.Step = 0.01;
            
            % Create RecalcButton
            app.RecalcButton = uibutton(app.TabMerge,'push');
            app.RecalcButton.Text = 'Recalculate clusters';
            app.RecalcButton.Visible = 'off';
            app.RecalcButton.ButtonPushedFcn = createCallbackFcn(app, @recalcClus, true);
            
            % Create scale/colorful checkboxes
            app.ScaleCheck = uicheckbox(app.TabMerge);
            app.ScaleCheck.Text = 'Maintain scale';
            app.ScaleCheck.Visible = 'off';
            app.ScaleCheck.ValueChangedFcn = createCallbackFcn(app, @scaleCheckChg, true);
            
            app.ColorCheck = uicheckbox(app.TabMerge);
            app.ColorCheck.Text = 'Colorful plots';
            app.ColorCheck.Visible = 'off';
            app.ColorCheck.ValueChangedFcn = createCallbackFcn(app, @colorCheckChg, true);
            
            % Create SelectedUnits
            app.SelectedUnits = uilistbox(app.MergePanel);
            app.SelectedUnits.ValueChangedFcn = createCallbackFcn(app, @UnitSelection, true);
            app.SelectedUnits.Position = [0.75*app.MergePanel.Position(3) app.MergePanel.Position(4)-220 0.24*app.MergePanel.Position(3) 200];
            app.SelectedUnits.Multiselect = 'on';
            
            % Create MergedWaves
            app.MergedWaves = uiaxes(app.MergePanel);
            disableDefaultInteractivity(app.MergedWaves);
            % Create MergedMissing
            app.MergedMissing = uiaxes(app.MergePanel);
            disableDefaultInteractivity(app.MergedMissing);
            % Create MergedAC
            app.MergedAC = uiaxes(app.MergePanel);
            disableDefaultInteractivity(app.MergedAC);
            % Create MergedFR
            app.MergedFR = uiaxes(app.MergePanel);
            disableDefaultInteractivity(app.MergedFR);
            
            % Create Buttons in merge panel
            app.MergeButton = uibutton(app.MergePanel, 'push');
            app.MergeButton.ButtonPushedFcn = createCallbackFcn(app, @mergeNow, true);
            app.GarbageButton = uibutton(app.MergePanel, 'push');
            app.GarbageButton.ButtonPushedFcn = createCallbackFcn(app, @garbageCollector, true);
            app.GoodButton = uibutton(app.MergePanel, 'push');
            app.GoodButton.ButtonPushedFcn = createCallbackFcn(app, @markGood, true);
            
            %% Split panel:
            app.SplitChaps.SplitTree = uiaxes(app.TabSplit);
            app.SplitChaps.SplitTree.Position = [1 app.TabSplit.Position(4)/2 2*(app.TabSplit.Position(3)/5) (app.TabSplit.Position(4)/2)-10];
            
            app.SplitChaps.SplitSlider = uislider(app.TabSplit);
            app.SplitChaps.SplitSlider.Orientation = 'vertical';
            app.SplitChaps.SplitSlider.Position(1) = app.SplitChaps.SplitTree.InnerPosition(1)+app.SplitChaps.SplitTree.InnerPosition(3);
            app.SplitChaps.SplitSlider.Position(2) = app.SplitChaps.SplitTree.InnerPosition(2);
            app.SplitChaps.SplitSlider.Position(4) =  app.SplitChaps.SplitTree.InnerPosition(4);

            app.SplitChaps.SplitSlider.ValueChangedFcn = createCallbackFcn(app, @splitSlide, true);
            % Might do ValueChangingFcn for the above just for dragging the
            % green line. Only apply changes on ChangedFcn not ChangingFcn.
            disableDefaultInteractivity(app.SplitChaps.SplitTree);
            
            app.SplitChaps.SplitWaves = uipanel(app.TabSplit);
            app.SplitChaps.SplitWaves.Title = 'Clusters with cutoff at step -';
            app.SplitChaps.SplitWaves.Position = [2*(app.TabSplit.Position(3)/5)+50 4 3*(app.TabSplit.Position(3)/5)-50 app.TabSplit.Position(4)-6];
            app.SplitChaps.SplitWaves.Visible = 'on';
            app.SplitChaps.SplitWaves.Scrollable = 'on';
            
            app.SplitChaps.CurrentWaves = uiaxes(app.TabSplit);
            app.SplitChaps.CurrentWaves.Position = [15 40 (2*app.TabSplit.Position(3)/5)-20 (app.TabSplit.Position(4)/2)-60];
            disableDefaultInteractivity(app.SplitChaps.CurrentWaves);
            
            app.SplitChaps.UnitSelection = uidropdown(app.TabSplit);
            app.SplitChaps.UnitSelection.Position = [20 8 150 30];
            app.SplitChaps.UnitSelection.ValueChangedFcn = createCallbackFcn(app, @chooseUnitSplit, true);
            
            app.CommitSplit = uibutton(app.TabSplit, 'push');
            app.CommitSplit.Position = [(2*app.TabSplit.Position(3)/5)-170 8 190 30];
            app.CommitSplit.Text = 'Split cluster';
            app.CommitSplit.FontWeight = 'bold';
            %app.CommitSplit.FontColor = [0.4 0 0];
            app.CommitSplit.Icon = [app.Data.impath 'split.png'];
            app.CommitSplit.ButtonPushedFcn = createCallbackFcn(app, @splitNow, true);
            
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
                elseif strcmpi(selection,'save as new')
                    saveAsSpikes(app,[]);
                end
            end
            refreshEditTimes(app); % update the file modification times
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
            end
            refreshEditTimes(app); % update the file modification times
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
            app.Settings.UpsampleRate = 4; % how much to upsample for FFT on spikes for noise detection
            app.Settings.nFFT = 8192;
            app.Settings.DateSort = false;
            app.Settings.SizeSort = false;
            app.Settings.Debugging = false;
            
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
            app.Data.Fresh = true;
            app.Data.Selected = [];
            % set app.Data.modified to 1 to force re-plots when changing
            % tabs, or after a merge, etc. One flag for each tab.
            app.Data.modified = [0 0 0 0 0 0];
            app.Data.modifylist = [];
            
            if ~app.Settings.Debugging
                warning('off','MATLAB:callback:error');
            end
            
            % Create and configure components
            createComponents(app);
            
            app.ScaleCheck.Value = app.Settings.ToScale;
            app.ColorCheck.Value = app.Settings.Colorful;

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