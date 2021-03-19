function plotUnits(app)
    if app.Data.modified(1) || app.Data.doFirstPlot(1)
        % we now store which cluster IDs have been modified in
        % app.Data.modifyList. So we only update those axes
        app.Data.loader = uiprogressdlg(app.UIFigure,'Title','Please Wait',...
            'Message','Loading clusters');
        %{
        app.RefreshButton.Position = [app.TabMerge.Position(3)-405 app.TabMerge.Position(4)-30 100 24];
        app.RecalcButton.Position = app.RefreshButton.Position + [-150 0 45 0];
        app.AggCutoff.Position = app.RecalcButton.Position + [-120 0 -30 0];
        app.ScaleCheck.Position = [15 app.TabMerge.Position(4)-30 100 24];
        app.ColorCheck.Position = [125 app.TabMerge.Position(4)-30 100 24];
        app.DensityCheck.Position = [230 app.TabMerge.Position(4)-30 120 24];
        %}
        app.AggCutoff.Value = app.Data.spikes.params.agg_cutoff;
        unq = unique(app.Data.spikes.assigns);
        plural = '';
        if length(unq) ~= 1, plural = 's'; end

        app.UnitsPanel.Title = [num2str(length(unq)) ' unit' plural ':'];
        %app.UnitsPanel.Position = [5 5 app.TabMerge.Position(3)-310 app.TabMerge.Position(4)-40];

        app.ScaleCheck.Visible = 'on';
        app.ColorCheck.Visible = 'on';
        app.DensityCheck.Visible = 'on';
        app.UnitsPanel.Visible = 'on';
        app.RefreshButton.Visible = 'on';
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
        
        if app.Data.doFirstPlot(1)
            ch = app.UnitsPanel.Children;
            for c = 1:length(ch)
                delete(ch);
                app.SpikePanels = [];
            end
            for s = 1:length(app.SpikePanels)
                app.SpikePanels{s} = [];
            end
        end
        
        temp = cellfun(@isempty,app.SpikePanels);
        currentlyPlotted = find(~temp);
        clear temp
        toDrop = setdiff(currentlyPlotted,unq); % remove panels that aren't in there
        for t = 1:length(toDrop)
            delete(app.SpikePanels{toDrop(t)});
            app.SpikePanels{toDrop(t)} = [];
        end

        big_padded = [min(app.Data.spikes.waveforms(:)) max(app.Data.spikes.waveforms(:))];
        % add 5% either side:
        big_padded = big_padded + ([-1 1]*(diff(big_padded)/20));
        for u = 1:length(unq)
            % if it doesn't have an axes plotted for it:
            if length(app.SpikePanels) < unq(u) || isempty(app.SpikePanels{unq(u)})
                app.SpikePanels{unq(u)} = uiaxes(app.UnitsPanel);
                % a bit redundant, but may allow for compressing cell array later:
                % (can't at present if a new unit appears with a lower UID than an old one)
                app.SpikePanels{unq(u)}.UserData.UID = unq(u);
                app.Data.modifyList = [app.Data.modifyList unq(u)];
            end

            app.Data.loader.Message = ['Loading unit ' num2str(u) ' of ' num2str(length(unq))];

            xpos = mod(u-1,4);
            ypos = floor((u-1)/4);
            app.SpikePanels{unq(u)}.Position = [margin+(xpos*w) (start_y-(ypos*w))-max_y w w];
            if any(ismember(app.Data.modifyList,unq(u)))
                cla(app.SpikePanels{unq(u)});
                t = (0:size(app.Data.spikes.waveforms,2)-1)/(app.Data.spikes.params.Fs/1e3);
                t = t - app.Data.spikes.params.cross_time;

                ids = app.Data.spikes.assigns == unq(u);
                waveforms = app.Data.spikes.waveforms(ids,:);
                [tt,wvs] = compressSpikes(app,t,waveforms);

                if app.Settings.Colorful
                    line(app.SpikePanels{unq(u)},tt,wvs,'Color',app.Data.colors(u,:));
                else
                    line(app.SpikePanels{unq(u)},tt,wvs);
                end
                
                if app.Settings.Density
                    pre_y = ylim(app.SpikePanels{unq(u)});
                    [dens,y] = app.spikeHist(waveforms);
                    hold(app.SpikePanels{unq(u)},'on');
                    imagesc(app.SpikePanels{unq(u)},t,y,dens)
                    alpha(app.SpikePanels{unq(u)},0.7);
                    colormap(app.SpikePanels{unq(u)},'hot');
                    ylim(app.SpikePanels{unq(u)},pre_y)
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
                app.SpikePanels{unq(u)}.Title.String = ['{\color[rgb]{' labelCol '}Unit ' num2str(unq(u)) '}: n = ' num2str(size(waveforms,1)) ' {\color{' rpvCol '}(' num2str(rpv) ' RPV' plural ')}'];

                disableDefaultInteractivity(app.SpikePanels{unq(u)});
                app.SpikePanels{unq(u)}.XGrid = 'on';
                app.SpikePanels{unq(u)}.YGrid = 'on';
                if isprop(app.SpikePanels{unq(u)},'Toolbar')
                    app.SpikePanels{unq(u)}.Toolbar.Visible = 'off';
                end

                xlim(app.SpikePanels{unq(u)},[t(1) t(end)]);
            end
            % TODO: need to have a handle to the line for each panel, and update its color if needed here

            app.SelectedUnits.Items{u} = ['Unit ' num2str(unq(u))];

            drawnow('limitrate');

            app.Data.loader.Value = u/length(unq);
            
            if app.Settings.ToScale
                ylim(app.SpikePanels{unq(u)},big_padded);
            else
                these_waves = app.Data.spikes.waveforms(app.Data.spikes.assigns == unq(u),:);
                small_padded = [min(these_waves(:)) max(these_waves(:))];
                % add 5% either side:
                small_padded = small_padded + ([-1 1]*(diff(small_padded)/20));
                ylim(app.SpikePanels{unq(u)},small_padded);
            end
        end

        drawnow;

        app.UnitsPanel.Visible = 'on';
        app.MergePanel.Visible = 'on';

        %{
        % This is a bit slow, so I've temporarily disabled it ? colors can
        be manually updated by toggling "Show colors" off and on again.
        
        % The color's will have become out of sync beyond the lowest
        % modified unit, so update all plots with unit IDs above that one:
        lowest = min(app.Data.modifyList);
        if ~isempty(lowest)
            updateFrom = find(unq == lowest);
            if app.Settings.Colorful
                for u = updateFrom:length(unq)
                    app.SpikePanels{unq(u)}.Children(1).Color = app.Data.colors(u,:);
                end
            else
                for u = updateFrom:length(unq)
                    app.SpikePanels{unq(u)}.Children(1).Color = [0 0.4470 0.7410];
                end
            end
        end
        %}
        app.Data.modified(1) = 0;
        app.Data.doFirstPlot(1) = 0;
        app.Data.modifyList = [];

        close(app.Data.loader);
        app.Data.loader = [];
    else
        if app.Settings.Debugging
            disp([9 'Not re-plotting units as should be same file as last plot'])
        end
    end
end
