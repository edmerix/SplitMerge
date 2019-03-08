function outlierLoad(app,~)
    if app.Data.modified(3)
        app.OutlierPanels.HistPlot.Position = [20 2*app.TabOutliers.Position(4)/3 2*app.TabOutliers.Position(3)/3 (app.TabOutliers.Position(4)/3)-5];
        app.OutlierPanels.HistPlot.YTickLabel = [];
        app.OutlierPanels.HistPlot.XTickLabel = [];
        app.OutlierPanels.OutlierSlider.Position(1) = app.OutlierPanels.HistPlot.InnerPosition(1);
        app.OutlierPanels.OutlierSlider.Position(2) = (2*app.TabOutliers.Position(4)/3)-3;
        app.OutlierPanels.OutlierSlider.Position(3) = app.OutlierPanels.HistPlot.InnerPosition(3);
        app.OutlierPanels.CurrentWaves.Position = [20 (app.TabOutliers.Position(4)/3)-10 (app.TabOutliers.Position(3)/3)-40 (app.TabOutliers.Position(4)/3)-35];
        app.OutlierPanels.DropWaves.Position = [20 10 (app.TabOutliers.Position(3)/3)-40 (app.TabOutliers.Position(4)/3)-35];
        app.OutlierPanels.PCA.Position = [(app.TabOutliers.Position(3)/3)-10 35 (app.TabOutliers.Position(3)/3)+40 (2*app.TabOutliers.Position(4)/3)-95];
        app.OutlierPanels.Selector.Position = [app.TabOutliers.Position(3)-170 app.TabOutliers.Position(4)-410 160 400];
        app.OutlierPanels.CutButton.Position = [app.TabOutliers.Position(3)-220 30 200 30];
        
        cla(app.OutlierPanels.HistPlot);
        
        unq = unique(app.Data.spikes.assigns);
        
        if isempty(app.Data.outlierID) || app.Data.outlierID == 0 || ~ismember(app.Data.outlierID,unq)
            app.Data.outlierID = unq(1);
        end
        
        inds = app.Data.spikes.assigns == app.Data.outlierID;
        wvs = app.Data.spikes.waveforms(inds,:);
        spiketimes = app.Data.spikes.spiketimes(inds);
        
        app.OutlierPanels.Selector.Items = {'Loading...'};
        % Populate Selector.Items here, and select the correct one!
        for u = 1:length(unq)
            app.OutlierPanels.Selector.Items{u} = ['Unit ' num2str(unq(u))];
        end
        app.OutlierPanels.Selector.Value = ['Unit ' num2str(app.Data.outlierID)];
        
        meanWv = mean(wvs);
        [z,dof] = get_zvalues(wvs,cov(wvs));
        [hz,x1] = hist(z,100);
        if x1(end)-x1(1) < 2
            title(app.OutlierPanels.HistPlot,'Not enough spikes for histogram');
        else
            hold(app.OutlierPanels.HistPlot,'on');

            bar(app.OutlierPanels.HistPlot,x1,hz,1,...
                'EdgeColor',[0 0.2314 0.2745],'FaceColor',[0.0275 0.3412 0.3569]);
            y = chi2pdf(x1,dof);
            y = y * length(z) * (x1(2)-x1(1));
            line(app.OutlierPanels.HistPlot,x1,y,...
                'Color',[0.5725 0.1333 0.0863],'LineWidth',2)

            which = find(diff(spiketimes) < app.Data.spikes.params.refractory_period/1000);
            which = unique([which which+1]);
            plot(app.OutlierPanels.HistPlot,...
                z(which), mean(app.OutlierPanels.HistPlot.YLim)*ones(size(z(which))),...
                'kx','markersize',10);
            
            hold(app.OutlierPanels.HistPlot,'off');
            title(app.OutlierPanels.HistPlot,['Unit ' num2str(app.Data.outlierID)]);
        end
        
        maxZ = app.OutlierPanels.HistPlot.XLim(2);
        
        app.OutlierPanels.SplitLine = line(app.OutlierPanels.HistPlot,...
            [maxZ maxZ],app.OutlierPanels.HistPlot.YLim,'color','r',...
            'linewidth',2,'linestyle','--');
        
        app.OutlierPanels.OutlierSlider.Limits = app.OutlierPanels.HistPlot.XLim;
        app.OutlierPanels.OutlierSlider.MajorTicks = app.OutlierPanels.HistPlot.XTick;
        app.OutlierPanels.OutlierSlider.MinorTicks = [];
        app.OutlierPanels.OutlierSlider.Value = maxZ;
        app.OutlierPanels.HistPlot.TickLength = [0 0];
        
        t = (0:size(app.Data.spikes.waveforms,2)-1)/(app.Data.spikes.params.Fs/1e3);
        t = t - app.Data.spikes.params.cross_time;
        [tt,wvs] = compressSpikes(app,t,wvs);
        plot(app.OutlierPanels.CurrentWaves,tt,wvs)
        app.OutlierPanels.CurrentWaves.XLim = [t(1) t(end)];
        plot(app.OutlierPanels.DropWaves,t,meanWv,'color','k','linewidth',2)
        app.OutlierPanels.DropWaves.XLim = [t(1) t(end)];

        pc = app.Data.spikes.info.pca.u(inds,1:3);
        plot(app.OutlierPanels.PCA,pc(:,1),pc(:,2),'k.','markersize',11)
        
        grid(app.OutlierPanels.HistPlot,'on');
        grid(app.OutlierPanels.CurrentWaves,'on');
        grid(app.OutlierPanels.DropWaves,'on');
        grid(app.OutlierPanels.PCA,'on');
        
        title(app.OutlierPanels.PCA,[num2str(length(z)) ' spikes'])
        app.Data.modified(3) = 0;
    else
        if app.Settings.Debugging
            disp([9 'Not refreshing outlier panel - should be identical to last load'])
        end
    end
end