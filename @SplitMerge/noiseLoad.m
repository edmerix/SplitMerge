function noiseLoad(app,~)
    if app.Data.modified(6)
        app.Data.loader = uiprogressdlg(app.UIFigure,'Title','Loading data',...
            'Indeterminate','on');
        
        cla(app.NoisePanels.PowerSpec);
        cla(app.NoisePanels.Waveforms);
        
        app.NoisePanels.PowerSpec.Position = [5 2*app.TabNoise.Position(4)/5 (app.TabNoise.Position(3)/2)-20 3*(app.TabNoise.Position(4)/5)-5];
        app.NoisePanels.Waveforms.Position = [(app.TabNoise.Position(3)/2)+40 (2*app.TabNoise.Position(4)/5) (app.TabNoise.Position(3)/2)-50 3*(app.TabNoise.Position(4)/5)-20];
        
        app.NoisePanels.PowerSpec.XTickLabel = {};
        app.NoisePanels.PowerSpec.XColor = 'k';
        app.NoisePanels.PowerSpec.XGrid = 'on';
        app.NoisePanels.PowerSpec.YTickLabel = {};
        app.NoisePanels.PowerSpec.YColor = 'k';
        app.NoisePanels.PowerSpec.YGrid = 'on';
        app.NoisePanels.PowerSpec.TickDir = 'out';
        app.NoisePanels.PowerSpec.TickLength = [0.001 0.001];
        app.NoisePanels.PowerSpec.YLabel.String = 'Power';
        app.NoisePanels.PowerSpec.Title.String = 'Spike power vs frequency (Hz)';
        
        app.NoisePanels.FreqSlider(1).Position(1) = app.NoisePanels.PowerSpec.InnerPosition(1);
        app.NoisePanels.FreqSlider(1).Position(2) = app.NoisePanels.PowerSpec.Position(2)-5;
        app.NoisePanels.FreqSlider(1).Position(3) = app.NoisePanels.PowerSpec.InnerPosition(3);
        
        app.NoisePanels.FreqSlider(1).MajorTicks = [];
        app.NoisePanels.FreqSlider(1).MinorTicks = [];
        
        app.NoisePanels.FreqSlider(2).Position(1) = app.NoisePanels.PowerSpec.InnerPosition(1);
        app.NoisePanels.FreqSlider(2).Position(2) = app.NoisePanels.FreqSlider(1).Position(2)-10;
        app.NoisePanels.FreqSlider(2).Position(3) = app.NoisePanels.PowerSpec.InnerPosition(3);
        
        app.NoisePanels.PowerSlider.Orientation = 'vertical';
        app.NoisePanels.PowerSlider.Position(1) = app.NoisePanels.PowerSpec.Position(1)+app.NoisePanels.PowerSpec.Position(3);
        app.NoisePanels.PowerSlider.Position(2) = app.NoisePanels.PowerSpec.InnerPosition(2);
        app.NoisePanels.PowerSlider.Position(4) = app.NoisePanels.PowerSpec.InnerPosition(4);
        
        Fs = app.Data.spikes.params.Fs;
        uprate = app.Settings.UpsampleRate;
        full_wvs = app.Data.spikes.waveforms;
        nfft = app.Settings.nFFT;
        halfn = floor(nfft / 2)+1;
        deltaf = 1 / ( nfft / (Fs*uprate));
        app.NoisePanels.frqs = (0:(halfn-1)) * deltaf;
        
        app.NoisePanels.wv_amps = NaN(size(full_wvs,1),length(app.NoisePanels.frqs));
        for n = 1:size(full_wvs,1)
            up_wv = interp(full_wvs(n,:),uprate);
            z = fft(up_wv, nfft);
            amp(1) = abs(z(1)) ./ (nfft);
            amp(2:(halfn-1)) = abs(z(2:(halfn-1))) ./ (nfft / 2); 
            amp(halfn) = abs(z(halfn)) ./ (nfft);
            app.NoisePanels.wv_amps(n,:) = amp;
        end
        
        [ff,wv_amp_compress] = compressSpikes(app,app.NoisePanels.frqs,app.NoisePanels.wv_amps);
        
        plot(app.NoisePanels.PowerSpec,ff,wv_amp_compress,'color',[0.2000 0.4196 0.5294]);
        app.NoisePanels.PowerSpec.XLim = [0 Fs/5];
        app.NoisePanels.PowerSpec.YLim = [0 ceil(max(app.NoisePanels.wv_amps(:)))];
        
        app.NoisePanels.PowerSlider.Limits = app.NoisePanels.PowerSpec.YLim;
        app.NoisePanels.PowerSlider.Value = app.NoisePanels.PowerSpec.YLim(2);
        
        app.NoisePanels.FreqSlider(1).Limits = app.NoisePanels.PowerSpec.XLim;
        app.NoisePanels.FreqSlider(2).Limits = app.NoisePanels.PowerSpec.XLim;
        app.NoisePanels.FreqSlider(1).Value = app.NoisePanels.PowerSpec.XLim(1);
        app.NoisePanels.FreqSlider(2).Value = app.NoisePanels.PowerSpec.XLim(2);
        app.NoisePanels.FreqSlider(2).MajorTicks = app.NoisePanels.PowerSpec.XTick;
        
        app.NoisePanels.ThreshLine = line(app.NoisePanels.PowerSpec,...
            [app.NoisePanels.FreqSlider(1).Value app.NoisePanels.FreqSlider(2).Value],...
            [app.NoisePanels.PowerSlider.Value app.NoisePanels.PowerSlider.Value],...
            'Color',[0.9725 0.1333 0.0863],'linewidth',2);
        
        app.NoisePanels.ThreshRect = rectangle(app.NoisePanels.PowerSpec,'Position',[0 0 1 1]);
        app.NoisePanels.ThreshRect.FaceColor = [0.9725 0.1333 0.0863 0.2];
        app.NoisePanels.ThreshRect.EdgeColor = [0.9725 0.1333 0.0863 0.2];
        
        t = (0:size(app.Data.spikes.waveforms,2)-1)/(app.Data.spikes.params.Fs/1e3);
        t = t - app.Data.spikes.params.cross_time;
        [tt,wvs] = compressSpikes(app,t,full_wvs);
        
        plot(app.NoisePanels.Waveforms,tt,wvs','color',[0.3 0.3 0.3])
        app.NoisePanels.Waveforms.XGrid = 'on';
        app.NoisePanels.Waveforms.YGrid = 'on';
        app.NoisePanels.Waveforms.XLim = [min(tt) max(tt)];
        app.NoisePanels.Waveforms.TickDir = 'out';
        app.NoisePanels.Waveforms.TickLength = [0.005 0.005];
        app.NoisePanels.Waveforms.XLabel.String = 'Time (ms)';
        app.NoisePanels.Waveforms.YLabel.String = 'Voltage (\muV)';
        
        app.NoisePanels.CutNoise.Position(1) = app.TabNoise.Position(3)-280;
        app.NoisePanels.CutNoise.Position(2) = 30;
        app.NoisePanels.CutNoise.Position(3) = 250;
        app.NoisePanels.CutNoise.Position(4) = 30;
        app.NoisePanels.CutNoise.Text = 'Remove noise and re-calculate clusters';
        
        app.NoisePanels.PowerSpec.Visible = 'on';
        app.NoisePanels.Waveforms.Visible = 'on';
        app.NoisePanels.PowerSlider.Visible = 'on';
        app.NoisePanels.FreqSlider(1).Visible = 'on';
        app.NoisePanels.FreqSlider(2).Visible = 'on';
        app.NoisePanels.CutNoise.Visible = 'on';
        
        app.Data.modified(6) = 0;
        close(app.Data.loader);
        app.Data.loader = [];
    else
        if app.Settings.Debugging
            disp([9 'Not re-plotting de-noise panel as should be same as last plot'])
        end
    end
end