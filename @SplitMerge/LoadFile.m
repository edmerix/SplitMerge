% Load the active file
function LoadFile(app)
    temp = load([app.Data.FilePath filesep app.Data.activeFile],'spikes');
    app.Data.spikes = temp.spikes;
    app.Data.modified = ones(1,length(app.Data.modified));
    app.Data.splitID = 0;
    app.Data.outlierID = 0;
    app.Data.clusterSubassigns = [];
    app.Data.splitSubclus = [];
    app.Data.Selected = [];
    
    clear temp
    
    % Set colors:
    unq = unique(app.Data.spikes.assigns);
    
    app.Data.colors = makeColors(app,length(unq));

    % This enables us to only plot the current tab when loading a file,
    % which speeds up the ability to go through each file while only
    % looking at one panel for each, without having to plot all clusters on
    % each load, etc. (The subfunctions keep track of if the file has
    % changed and so re-plot if necessary)
    refreshScreen(app);
end