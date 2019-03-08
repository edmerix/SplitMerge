function breakCluster(app,id)
    if nargin < 2 || isempty(id)
        disp([9 'Need a cluster ID to break into 2 clusters']);
    else
        if isfield(app.Data,'spikes')
            % Uses default UMS2000 break_minicluster function: Actually
            % don't. TODO: update this so that breaking cluster doesn't use
            % spikes.info.kmeans.assigns but spikes.assigns instead
            app.Data.spikes = break_minicluster(app.Data.spikes,id);
            app.Data.modified = ones(1,length(app.Data.modified));
            app.refreshScreen();
        else
            if app.Settings.Debugging
                disp([9 'Yet to load a file, not plotting'])
            end
        end
    end
end