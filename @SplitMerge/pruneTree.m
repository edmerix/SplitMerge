function pruneTree(app)
% Look for duplicate entries in the merge tree, and prune merges that were
% logged after that cluster had already merged with another.
% Also removes leftover/redundant labels
    treeClone = app.Data.spikes.info.tree;
    shoots = unique(treeClone(:,2));
    for s = 1:length(shoots)
        graftedShoots = find(treeClone(:,2) == shoots(s));
        if length(graftedShoots) > 1
            treeClone(graftedShoots(2:end),:) = [];
        end
    end
    % TODO: a sanity check on treeClone before applying it below:
    app.Data.spikes.info.tree = treeClone;
    % Remove leftover labels:
    app.Data.spikes.labels(~ismember(app.Data.spikes.labels(:,1),unique(app.Data.spikes.assigns)),:) = [];
    % Remove duplicates (keeping highest label value):
    [~,u] = unique(app.Data.spikes.labels(:,1));
    duplicates = setdiff(1:size(app.Data.spikes.labels,1),u);
    % could just remove these duplicates (especially as later indices, as
    % returned by the above, are more likely to be the higher values), but
    % let's loop through just in case they're mis-ordered:
    for d = 1:length(duplicates)
        inds = find(app.Data.spikes.labels(:,1) == app.Data.spikes.labels(duplicates(d),1));
        vals = app.Data.spikes.labels(inds,2);
        [~,keeping] = max(vals);
        dropping = inds(setdiff(1:length(inds),keeping));
        app.Data.spikes.labels(dropping,:) = [];
    end
end