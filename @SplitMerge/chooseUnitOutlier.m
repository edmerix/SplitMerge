function chooseUnitOutlier(app,event)
    val = event.Value;
    app.Data.outlierID = str2double(strrep(val,'Unit ',''));
    if app.Settings.Debugging
        disp([9 'Changing outlier panel to unit ' num2str(app.Data.outlierID)])
    end
    app.Data.modified(3) = 1;
    refreshScreen(app);
end