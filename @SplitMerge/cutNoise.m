function cutNoise(app,~)
    app.NoisePanels.CutNoise.Enable = 'off';
    
    x = [app.NoisePanels.FreqSlider.Value];    
    x = sort(x);
    
    y = app.NoisePanels.PowerSlider.Value;
    
    subset = app.NoisePanels.wv_amps(:,app.NoisePanels.frqs > x(1) & app.NoisePanels.frqs < x(2));
    
    [badinds,~] = ind2sub(size(subset),find(subset > y));
    badinds = unique(badinds);
    
    %% TODO: REPLACE THIS SECTION WITH:
    % app.Data.spikes = ss_move_subset(app.Data.spikes,badinds,'garbage');
    % (but check it's performing correctly first...)
    newtrash.waveforms = app.Data.spikes.waveforms(badinds,:);
    newtrash.spiketimes = app.Data.spikes.spiketimes(badinds);
    newtrash.trials = app.Data.spikes.trials(badinds);
    newtrash.unwrapped_times = app.Data.spikes.unwrapped_times(badinds);
    newtrash.assigns = app.Data.spikes.assigns(badinds);
    if isfield(app.Data.spikes,'garbage')
        old = app.Data.spikes.garbage;
        garbage.waveforms = [old.waveforms; newtrash.waveforms];
        garbage.spiketimes = [old.spiketimes; newtrash.spiketimes];
        garbage.trials = [old.trials newtrash.trials];
        garbage.unwrapped_times = [old.unwrapped_times; newtrash.unwrapped_times];
        garbage.assigns = [old.assigns newtrash.assigns];
        clear old
    else
        garbage = newtrash;
    end
    app.Data.spikes.garbage = garbage;
    clear newtrash garbage

    app.Data.spikes.waveforms(badinds,:) = [];
    app.Data.spikes.spiketimes(badinds) = [];
    app.Data.spikes.trials(badinds) = [];
    app.Data.spikes.unwrapped_times(badinds) = [];
    app.Data.spikes.assigns(badinds) = [];
    app.Data.spikes.labels(app.Data.spikes.labels(:,2) == 4,:) = [];
    app.Data.spikes.info.pca.u(badinds,:) = [];
    app.Data.spikes.info.kmeans.assigns(badinds) = [];
    
    app.NoisePanels.frqs = [];
    app.NoisePanels.wv_amps = [];
    %%
    recalcClus(app,[]);
    
    app.NoisePanels.CutNoise.Enable = 'on';
end