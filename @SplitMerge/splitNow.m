function splitNow(app,~)
    app.CommitSplit.Enable = 'off';
    id = app.Data.splitID;
    subClus = app.Data.splitSubclus;
    subClus(subClus == id) = []; % don't need to split from itself
    
    % My hardcoded new version
    assigns = app.Data.spikes.info.kmeans.assigns;
    
    agg = app.Data.spikes.info.tree;
    
    lowval = floor(app.SplitChaps.SplitSlider.Value);
    
    changes = agg(1:lowval,:);
    for c = 1:size(changes,1)
        assigns(assigns == changes(c,2)) = changes(c,1);
    end
    
    for s = 1:length(subClus)
        if app.Settings.Debugging
            disp([9 'Splitting ' num2str(subClus(s)) ' out of ' num2str(id)])
        end
        inds = assigns == subClus(s);
        %waveforms = app.Data.spikes.waveforms(inds,:);
        % check all of the previous assigns(inds) are equal to the original
        % id.
        
        app.Data.spikes.assigns(inds) = subClus(s);
        % add this ID back to labels:
        app.Data.spikes.labels = [app.Data.spikes.labels; subClus(s) 1];
        % remove this merge from the "tree":
        treeInd = app.Data.spikes.info.tree(:,1) == id & app.Data.spikes.info.tree(:,2) == subClus(s);
        app.Data.spikes.info.tree(treeInd,:) = [];
    end
    [~,ord] = sort(app.Data.spikes.labels(:,1));
    app.Data.spikes.labels = app.Data.spikes.labels(ord,:); % reorder the labels
    
    %original function called by the original splitmerge_tool:
    %app.Data.spikes = split_cluster(app.Data.spikes,subClus);
    % Nope, I have no idea how that function works. Sticking to my version,
    % but if stuff breaks, it might be that I haven't finished all the
    % necessary updates when splitting...
    
    app.Data.colors = makeColors(app,length(unique(app.Data.spikes.assigns)));
    
    app.Data.modified = ones(1,length(app.Data.modified)); % one flag for each tab
    app.CommitSplit.Enable = 'on';
    
    refreshScreen(app);
end