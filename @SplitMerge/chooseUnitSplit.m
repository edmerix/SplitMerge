function chooseUnitSplit(app,event)
    %{
        On selection of a new cluster ID from the dropdown menu we will
        set app.Data.splitID to that cluster's ID and then set 
        app.Data.modified(2) to 1, then call splitLoad(app,[]); again.
    %}
    %assignin('base','event',event);
    val = event.Value;
    app.Data.splitID = str2double(strrep(val,'Unit ',''));
    if app.Settings.Debugging
        disp([9 'Changing split panel to unit ' num2str(app.Data.splitID)])
    end
    app.Data.modified(2) = 1;
    refreshScreen(app);
end