function outlierSlide(app,event)
    val = event.Value;

    set(app.OutlierPanels.SplitLine,'XData',[val val]);
    
    cla(app.OutlierPanels.DropWaves);
    cla(app.OutlierPanels.PCA);
    
    inds = app.Data.spikes.assigns == app.Data.outlierID;
    wvs = app.Data.spikes.waveforms(inds,:);
    [z,~] = get_zvalues(wvs,cov(wvs));
    meanWv = mean(wvs);
    
    t = (0:size(app.Data.spikes.waveforms,2)-1)/(app.Data.spikes.params.Fs/1e3);
    t = t - app.Data.spikes.params.cross_time;
    [tt,wvs] = compressSpikes(app,t,wvs(z > val,:));
    
    plot(app.OutlierPanels.DropWaves,t,meanWv,'color','k','linewidth',2)
    hold(app.OutlierPanels.DropWaves,'on');
    plot(app.OutlierPanels.DropWaves,tt,wvs,'r');
    hold(app.OutlierPanels.DropWaves,'off');
    
    pc = app.Data.spikes.info.pca.u(inds,1:3);
    
    plot(app.OutlierPanels.PCA,pc(:,1),pc(:,2),'k.','markersize',11);
    hold(app.OutlierPanels.PCA,'on');
    plot(app.OutlierPanels.PCA,pc(z > val,1),pc(z > val,2),'r.','markersize',12);
    hold(app.OutlierPanels.PCA,'off');
    
    app.OutlierPanels.DropWaves.XLim = [t(1) t(end)];

    title(app.OutlierPanels.PCA,[num2str(length(find(z > val))) ' out of ' num2str(length(z)) ' spikes'])
end