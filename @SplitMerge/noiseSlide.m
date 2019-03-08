function noiseSlide(app,~)
    %{
    app.Data.loader = uiprogressdlg(app.UIFigure,'Title','Updating...',...
            'Indeterminate','on');
    %}
    app.NoisePanels.PowerSpec.Visible = 'off';
    app.NoisePanels.Waveforms.Visible = 'off';
    cla(app.NoisePanels.Waveforms);
    
    x = [app.NoisePanels.FreqSlider.Value];    
    x = sort(x);
    
    y = app.NoisePanels.PowerSlider.Value;
    set(app.NoisePanels.ThreshLine,'XData',x,'YData',[y y]);
    app.NoisePanels.ThreshRect.Position = [x(1) y diff(x) app.NoisePanels.PowerSpec.YLim(2)-y];
    
    subset = app.NoisePanels.wv_amps(:,app.NoisePanels.frqs > x(1) & app.NoisePanels.frqs < x(2));
    
    
    [drop,~] = ind2sub(size(subset),find(subset > y));
    drop = unique(drop);
    keeping = setdiff(1:size(app.Data.spikes.waveforms,1),drop);
    
    t = (0:size(app.Data.spikes.waveforms,2)-1)/(app.Data.spikes.params.Fs/1e3);
    t = t - app.Data.spikes.params.cross_time;
    [tt,good_wvs] = compressSpikes(app,t,app.Data.spikes.waveforms(keeping,:));
    plot(app.NoisePanels.Waveforms,tt,good_wvs','color',[0.3 0.3 0.3]);
    [tt,bad_wvs] = compressSpikes(app,t,app.Data.spikes.waveforms(drop,:));
    hold(app.NoisePanels.Waveforms,'on');
    plot(app.NoisePanels.Waveforms,tt,bad_wvs','color',[0.9 0.05 0.1]);
    hold(app.NoisePanels.Waveforms,'off');
    app.NoisePanels.PowerSpec.Visible = 'on';
    app.NoisePanels.Waveforms.Visible = 'on';
    %{
    close(app.Data.loader);
    app.Data.loader = [];
    %}
end