function splitLoad(app, ~)
    if app.Data.modified(2)
        app.Data.loader = uiprogressdlg(app.UIFigure,'Title','Loading data',...
            'Indeterminate','on');
        cla(app.SplitChaps.SplitTree);
        cla(app.SplitChaps.CurrentWaves);
        ch = app.SplitChaps.SplitWaves.Children;
        delete(ch);
        
        app.SplitChaps.SplitTree.Position = [1 app.TabSplit.Position(4)/2 2*(app.TabSplit.Position(3)/5) (app.TabSplit.Position(4)/2)-10];
        app.SplitChaps.SplitTree.XTick = [];
        app.SplitChaps.SplitTree.YTick = [];
        
        app.SplitChaps.SplitSlider.Position(1) = app.SplitChaps.SplitTree.InnerPosition(1)+app.SplitChaps.SplitTree.InnerPosition(3);
        app.SplitChaps.SplitSlider.Position(2) = app.SplitChaps.SplitTree.InnerPosition(2);
        app.SplitChaps.SplitSlider.Position(4) =  app.SplitChaps.SplitTree.InnerPosition(4);
        
        app.SplitChaps.SplitWaves.Position = [2*(app.TabSplit.Position(3)/5)+50 4 3*(app.TabSplit.Position(3)/5)-50 app.TabSplit.Position(4)-6];
        
        app.SplitChaps.CurrentWaves.Position = [15 40 (2*app.TabSplit.Position(3)/5)-20 (app.TabSplit.Position(4)/2)-60];
        
        app.CommitSplit.Position = [(2*app.TabSplit.Position(3)/5)-170 8 190 30];
        
        assigns = app.Data.spikes.info.kmeans.assigns;
        agg_block = app.Data.spikes.info.tree;
        if isempty(agg_block)
            title(app.SplitChaps.CurrentWaves,'No clusters have been merged in this file');
            if app.Settings.Debugging
                disp('Not plotting tree: no clusters have been merged in this file');
            end
        else
            colors = makeColors(app,max(app.Data.spikes.info.tree(:)));
            
            unq = unique(app.Data.spikes.assigns);
            app.SplitChaps.UnitSelection.Items = {'Loading...'};
            for u = 1:length(unq)
                app.SplitChaps.UnitSelection.Items{u} = ['Unit ' num2str(unq(u))];
            end
            
            % default to first cluster when loading:
            if app.Data.splitID == 0 || ~ismember(app.Data.splitID,unq)
                app.Data.splitID = unq(1);
            end
            
            %app.SplitChaps.UnitSelection.Value = find(unq == app.Data.splitID);
            app.SplitChaps.UnitSelection.Value = ['Unit ' num2str(app.Data.splitID)];
            
            %{
                On selection of a new cluster ID from the dropdown menu we
                set app.Data.splitID to that cluster's ID and then set 
                app.Data.modified(2) to 1, then call splitLoad(app,[]); again.
            %}
            
            t = (0:size(app.Data.spikes.waveforms,2)-1)/(app.Data.spikes.params.Fs/1e3);
            t = t - app.Data.spikes.params.cross_time;
            wvs = app.Data.spikes.waveforms(app.Data.spikes.assigns == app.Data.splitID,:);
            
            [tt,wvs] = compressSpikes(app,t,wvs);
            plot(app.SplitChaps.CurrentWaves,tt,wvs);
            title(app.SplitChaps.CurrentWaves,['Current waves for unit ' num2str(app.Data.splitID)])
            app.SplitChaps.CurrentWaves.XGrid = 'on';
            app.SplitChaps.CurrentWaves.YGrid = 'on';
            app.SplitChaps.CurrentWaves.XLim = [t(1) t(end)];
            app.SplitChaps.CurrentWaves.XLabel.String = 'Time (ms)';
            app.SplitChaps.CurrentWaves.YLabel.String = 'Voltage (\muV)';
            app.SplitChaps.CurrentWaves.TickDir = 'out';
            app.Data.clusterSubassigns = [];
            
            tree = make_tree(app, assigns, app.Data.splitID, agg_block);
            
            app.Data.clusterSubassigns = unique(app.Data.clusterSubassigns);
            
            maxStep = ceil(tree.order);
            if maxStep < 1, maxStep = 1; end
            
            [~, tree] = draw_tree(app.SplitChaps.SplitTree, tree, 1, colors);
            
            %app.Data.tree = tree;
            
            app.SplitChaps.SplitTree.YLim = [0 maxStep];
            app.SplitChaps.SplitTree.XLim = [0.5 tree.num_nodes+0.5];
            app.SplitChaps.SplitTree.XColor = 'w';
            app.SplitChaps.SplitTree.YColor = 'w';
            
            app.SplitChaps.SplitSlider.Limits = [0 maxStep];
            app.SplitChaps.SplitSlider.MinorTicks = [];
            app.SplitChaps.SplitSlider.MajorTicks = 0:maxStep;
            app.SplitChaps.SplitSlider.Value = maxStep;
            
            hold(app.SplitChaps.SplitTree,'on');
            app.SplitChaps.SplitLine = line(app.SplitChaps.SplitTree,...
                app.SplitChaps.SplitTree.XLim,[maxStep maxStep],'color','r',...
                'linewidth',2,'linestyle','--');
            hold(app.SplitChaps.SplitTree,'off');
        end
        
        app.Data.modified(2) = 0;
        close(app.Data.loader);
        app.Data.loader = [];
        
    else
        if app.Settings.Debugging
            disp([9 'Not re-plotting split panel as should be same file as last plot'])
        end
    end
end

% recursively generate a tree structure from spikes.info.tree
% (courtesy of plot_cluster_tree.m from UMS)
function [tree, val] = make_tree(app, assigns, clust, agg_block)
    row = find(agg_block(:,1) == clust, 1,'last');
    tree.local_id = clust;
    
    if ~isempty(row) % current node has children
        from = agg_block(row,2); 
        agg_block(row:end,:) = [];
        % recursively generate children
        [tree.left, left_val] = make_tree(app, assigns, clust, agg_block);
        [tree.right, right_val] = make_tree(app, assigns, from, agg_block);
        tree.num_members = tree.left.num_members + tree.right.num_members;
        tree.num_nodes = tree.left.num_nodes + tree.right.num_nodes;
        tree.order = row;
        % we want the lower numbered clusterID to always be the left child
        val = min(left_val, right_val);
        if right_val < left_val
            temp = tree.right;
            tree.right = tree.left;
            tree.left = temp;
        end     
    else % reached a leaf, no children
        tree.left = [];
        tree.right = [];
        tree.num_members = sum(assigns == clust);
        tree.num_nodes = 1;
        tree.order = 0;
        val = clust;
    end
    app.Data.clusterSubassigns = [app.Data.clusterSubassigns val];
end

% recursively draw the aggregation tree
% (courtesy of plot_cluster_tree.m from UMS)
function [x,tree] = draw_tree(ax, tree, first_time, colors)
    persistent pos; % I do not like this. Let's change it later.
    
    if first_time, pos = 1; end
      
    if ~isempty(tree.left) % draw lines connecting to children
        [x1, tree.left] = draw_tree(ax, tree.left, 0, colors);
        [x2, tree.right] = draw_tree(ax, tree.right, 0, colors);
        x = (x1 + x2) / 2;
        y = tree.order;
        
        % draw lines
        line(ax, [x1 x2], [y, y],'LineWidth',2,'Color',[0 0 0])
        line(ax, [x1 x1], [tree.left.order, y],'LineWidth',2,'Color',[0 0 0]);
        line(ax, [x2 x2], [tree.right.order, y],'LineWidth',2,'Color',[0 0 0]);
    else % draw a labeled dot if we are at a leaf node 
        x = pos;
        pos = pos + 1;
        hold(ax,'on')
        s = scatter(ax, x, tree.order);
        hold(ax,'off')
        tree.dot = s;
        t = text(ax, x + .1, tree.order, num2str(tree.local_id));
        set(t,'VerticalAlignment','bottom');
    end
    hold(ax,'on')
    s = scatter(ax, x, tree.order);
    hold(ax,'off')
    tree.dot = s;
    set(s, 'MarkerFaceColor', colors(tree.local_id,:),...
        'MarkerEdgeColor', colors(tree.local_id,:),...
        'SizeData', 60, 'LineWidth', 2);
end