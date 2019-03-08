% Populate the file tree
function LoadDirectory(app, ~)
    if app.Settings.Debugging
        disp(['Setting SplitMerge path to ' app.Data.FilePath]);
    end
    % Populate file "tree" here (used to be a tree, but now has to be a table...)
    a = dir([app.Data.FilePath filesep '*.mat']);
    if app.Settings.SizeSort == true % size sort takes priority over date sort
        [~,idx] = sort([a.bytes],'descend');
        a = a(idx);
    elseif app.Settings.DateSort == true
        [~,idx] = sort([a.datenum],'descend');
        a = a(idx);
    end
    b = {a(:).name; a(:).date}';

    app.FileTable.Data = b;
    app.FileTable.ColumnName = {app.Data.FilePath,'Last edit time'};
    %app.FileTable.Tooltip = {'Current directory:',app.Data.FilePath};
    app.FileTable.ColumnWidth = {'auto',150};
    app.FileTable.FontSize = 12;

    if ~exist([app.Data.FilePath filesep '.SplitMerge'],'dir')
        mkdir([app.Data.FilePath filesep '.SplitMerge'])
    end
end