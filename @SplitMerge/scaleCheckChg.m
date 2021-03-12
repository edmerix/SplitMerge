function scaleCheckChg(app,~)
    val = app.ScaleCheck.Value;
    if val ~= app.Settings.ToScale
        app.Settings.ToScale = val;
        unq = unique(app.Data.spikes.assigns);
        big_padded = [min(app.Data.spikes.waveforms(:)) max(app.Data.spikes.waveforms(:))];
        % add 5% either side:
        big_padded = big_padded + ([-1 1]*(diff(big_padded)/20));
        
        for u = 1:length(unq)
            if ~isempty(app.SpikePanels{unq(u)})
                if app.Settings.ToScale
                    ylim(app.SpikePanels{unq(u)},big_padded);
                else
                    these_waves = app.Data.spikes.waveforms(app.Data.spikes.assigns == unq(u),:);
                    small_padded = [min(these_waves(:)) max(these_waves(:))];
                    % add 5% either side:
                    small_padded = small_padded + ([-1 1]*(diff(small_padded)/20));
                    ylim(app.SpikePanels{unq(u)},small_padded);
                end
            end
        end
    end
end