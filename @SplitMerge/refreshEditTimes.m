function refreshEditTimes(app,~)
    fl = dir([app.Data.FilePath filesep app.Data.activeFile]);
    if length(fl) ~= 1 && app.Settings.Debugging
        disp(['Found ' num2str(length(fl)) ' files that match current filename somehow'])
        disp('Not updating file modification times');
    else
        mod = fl(1).date;
        ind = strcmp(app.FileTable.Data(:,1),app.Data.activeFile);
        app.FileTable.Data{ind,2} = mod;
    end
end