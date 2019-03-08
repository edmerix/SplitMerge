function PCASelection(app,~)
%{
    selected = app.PCAPanels.PCASelected.Value;
    ids = zeros(1,length(selected));
    unq = unique(app.Data.spikes.assigns);
    for s = 1:length(selected)
        ids(s) = str2double(strrep(selected{s},'Unit ',''));
    end
    hidden = setdiff(unq,ids);
    
    if app.Settings.Debugging
        disp([9 'Hiding units ' num2str(hidden) ' from PCA plot'])
        disp([9 'Showing units ' num2str(ids) ' on PCA plot'])
    end
    drawnow('limitrate');
    set(app.PCAPanels.plots(ismember(unq,ids)),'Visible','on');
    set(app.PCAPanels.plots(ismember(unq,hidden)),'Visible','off');
    drawnow; % the above changes seem to be buggy, and freeze the app.
%}
disp([9 'Deactivated PCA panel because of huge performance hit'])
end