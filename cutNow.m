function cutNow(app,~)
    app.OutlierPanels.CutButton.Enable = 'off';
    
    val = app.OutlierPanels.OutlierSlider.Value;
    inds = find(app.Data.spikes.assigns == app.Data.outlierID);
    wvs = app.Data.spikes.waveforms(inds,:);
    [z,~] = get_zvalues(wvs,cov(wvs));
    
    drop = zeros(1,length(app.Data.spikes.assigns));
    drop(inds(z > val)) = 1;
    
    if app.Settings.Debugging
        id = app.Data.outlierID;
        disp([9 'Removing ' num2str(length(find(z > val))) ' of ' num2str(length(z)) ' spikes from unit ' num2str(id)]);
    end
    
    % dependent on remove_outliers from original UMS
    app.Data.spikes = remove_outliers(app.Data.spikes, drop);
    
    app.Data.modified = ones(1,length(app.Data.modified));
    app.Data.modifylist = [app.Data.modifylist app.Data.outlierID]; % why oh why doesn't matlab have .push()?
    app.OutlierPanels.CutButton.Enable = 'on';
    refreshScreen(app);
end