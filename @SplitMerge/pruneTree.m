function pruneTree(app)
% Look for duplicate entries in the merge tree, and prune merges that were
% logged after that cluster had already merged with another.
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
end