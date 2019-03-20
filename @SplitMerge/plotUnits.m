function plotUnits(app)
    if app.Data.modified(1)
        %TODO: we now store which cluster IDs have been modified in 
        % app.Data.modifylist. We should only update those axes!
        app.Data.loader = uiprogressdlg(app.UIFigure,'Title','Please Wait',...
            'Message','Loading clusters');
        % Delete all previous spike panels
        ch = app.UnitsPanel.Children;
        for c = 1:length(ch)
            delete(ch);
            app.SpikePanels = [];
        end

        app.RecalcButton.Position = [app.TabMerge.Position(3)-450 app.TabMerge.Position(4)-30 145 24];
        app.AggCutoff.Position = app.RecalcButton.Position + [-120 0 -30 0];
        app.AggCutoff.Value = app.Data.spikes.params.agg_cutoff;
        app.ScaleCheck.Position = [15 app.TabMerge.Position(4)-30 100 24];
        app.ColorCheck.Position = [125 app.TabMerge.Position(4)-30 100 24];

        unq = unique(app.Data.spikes.assigns);
        plural = '';
        if length(unq) ~= 1, plural = 's'; end

        app.UnitsPanel.Title = [num2str(length(unq)) ' unit' plural ':'];
        app.UnitsPanel.Position = [5 5 app.TabMerge.Position(3)-310 app.TabMerge.Position(4)-40];

        app.ScaleCheck.Visible = 'on';
        app.ColorCheck.Visible = 'on';
        app.UnitsPanel.Visible = 'on';
        app.RecalcButton.Visible = 'on';
        app.AggCutoff.Visible = 'on';

        % populate all the spike panels here
        margin = 0;%0.01 * app.UnitsPanel.Position(3); % 1%
        w = (app.UnitsPanel.Position(3)/4) - margin - 5;
        start_y = app.UnitsPanel.Position(4) - w + (2*margin);

        app.UnitsPanel.Visible = 'off';
        app.MergePanel.Visible = 'off';
        cla(app.MergedWaves,'reset')
        cla(app.MergedMissing,'reset')
        cla(app.MergedAC,'reset')
        cla(app.MergedFR,'reset')
        app.SelectedUnits.Value = {};

        max_y = start_y - (floor((length(unq)-1)/4)* w) - 1; % need to offset so nothing becomes negative

        if max_y > 0, max_y = 0; end % don't move anything if nothing's dropped off the bottom

        app.SelectedUnits.Items = {'Loading...'};

        yl = NaN(2,length(unq)); % for scaling if app.Settings.ToScale == true
        for u = 1:length(unq)
            app.Data.loader.Message = ['Loading unit ' num2str(u) ' of ' num2str(length(unq))];
            
            xpos = mod(u-1,4);
            ypos = floor((u-1)/4);

            app.SpikePanels{u} = uiaxes(app.UnitsPanel);
            app.SpikePanels{u}.Position = [margin+(xpos*w) (start_y-(ypos*w))-max_y w w];
            
            t = (0:size(app.Data.spikes.waveforms,2)-1)/(app.Data.spikes.params.Fs/1e3);
            t = t - app.Data.spikes.params.cross_time;

            ids = app.Data.spikes.assigns == unq(u);
            waveforms = app.Data.spikes.waveforms(ids,:);
            [tt,wvs] = compressSpikes(app,t,waveforms);

            if app.Settings.Colorful
                line(app.SpikePanels{u},tt,wvs,'Color',app.Data.colors(u,:));
            else
                line(app.SpikePanels{u},tt,wvs);
            end

            rpv = sum(diff(app.Data.spikes.spiketimes(ids)) <= (app.Data.spikes.params.refractory_period * 0.001));
            plural = '';
            if rpv ~= 1, plural = 's'; end
            if rpv/length(app.Data.spikes.spiketimes(ids)) > 0.02
                rpvCol = 'red';
            else
                rpvCol = 'gray';
            end
            
            label = app.Data.spikes.labels(app.Data.spikes.labels(:,1) == unq(u),2);
            if label == 2
                labelCol = '0 0.6 0.2';
            else
                labelCol = '0 0 0';
            end
            app.SpikePanels{u}.Title.String = ['{\color[rgb]{' labelCol '}Unit ' num2str(unq(u)) '}: n = ' num2str(size(waveforms,1)) ' {\color{' rpvCol '}(' num2str(rpv) ' RPV' plural ')}'];

            disableDefaultInteractivity(app.SpikePanels{u});
            app.SpikePanels{u}.XGrid = 'on';
            app.SpikePanels{u}.YGrid = 'on';

            %app.SpikePanels{u}.ButtonDownFcn = createCallbackFcn(app, @UnitClick, true);

            %{
            app.SpikePanels{u}.XColor = 'none';
            yl = ylim(app.SpikePanels{u});
            text(app.SpikePanels{u},-0.6, yl(1), [num2str(yl(1)) 'µV']);
            text(app.SpikePanels{u},-0.6, yl(2), [num2str(yl(2)) 'µV']);
            %}
            xlim(app.SpikePanels{u},[t(1) t(end)]);

            yl(:,u) = ylim(app.SpikePanels{u});

            app.SelectedUnits.Items{u} = ['Unit ' num2str(unq(u))];
            
            drawnow('limitrate');
            
            app.Data.loader.Value = u/length(unq);
        end
        
        drawnow;

        app.UnitsPanel.Visible = 'on';

        % Only really need to do this on first load...
        % NOW THAT THIS IS A FREQUENTLY CALLED ROUTINE THIS SHOULD BE SPLIT
        % OUT INTO A SEPARATE FUNCTION?
        if app.Data.Fresh

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

            app.Data.Fresh = false;
        end

        app.MergePanel.Visible = 'on';

        if app.Settings.ToScale
            % link the axes, and apply the largest ylim
            % linkaxes(app.SpikePanels,'y'); linkaxes doesn't work with UIAxes objects in r2018b...
            for u = 1:length(unq)
                set(app.SpikePanels{u},'YLim',[min(yl(:)) max(yl(:))])
            end
        end
        
        app.Data.modified(1) = 0;
        app.Data.modifylist = [];
        
        close(app.Data.loader);
        app.Data.loader = [];
    else
        if app.Settings.Debugging
            disp([9 'Not re-plotting units as should be same file as last plot'])
        end
    end
end