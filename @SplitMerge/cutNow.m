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

    % My version uses column vectors, original UMS2k uses row vectors,
    % transpose if there's a discrepancy in this file between outliers and
    % main vectors:
    time_transposed = false;
    unwrapped_transposed = false;
    if iscolumn(app.Data.spikes.spiketimes) && isfield(app.Data.spikes.info,'outliers')...
            && isrow(app.Data.spikes.info.outliers.spiketimes)
        app.Data.spikes.spiketimes = app.Data.spikes.spiketimes';
        time_transposed = true;
    end
    if iscolumn(app.Data.spikes.unwrapped_times) && isrow(app.Data.spikes.info.outliers.unwrapped_times)
        app.Data.spikes.unwrapped_times = app.Data.spikes.unwrapped_times';
        unwrapped_transposed = true;
    end
    % dependent on remove_outliers from original UMS
    app.Data.spikes = remove_outliers(app.Data.spikes, drop);
    % Put them back if they were transposed:
    if time_transposed
        app.Data.spikes.spiketimes = app.Data.spikes.spiketimes';
    end
    if unwrapped_transposed
        app.Data.spikes.unwrapped_times = app.Data.spikes.unwrapped_times';
    end

    app.Data.modified = ones(1,length(app.Data.modified));
    app.Data.modifyList = [app.Data.modifyList app.Data.outlierID]; % why oh why doesn't matlab have .push()?
    app.OutlierPanels.CutButton.Enable = 'on';
    app.refreshScreen();
end
