function pcaLoad(app,~)
%{
    if app.Data.modified(5)
        app.PCAPanels.PCASelected.Items = {'Loading...'};
        cla(app.PCAPanels.PCAView);
        app.PCAPanels.PCAView.Position = [20 20 app.TabPCA.Position(3)-200 app.TabPCA.Position(4)-40];
        app.PCAPanels.PCASelected.Position = [app.TabPCA.Position(3)-170 app.TabPCA.Position(4)-220 160 200];
        hold(app.PCAPanels.PCAView,'on');
        
        pc = app.Data.spikes.info.pca.u;
        unq = unique(app.Data.spikes.assigns);
        
        app.PCAPanels.plots = NaN(1,length(unq));
        
        if app.Settings.Debugging
            disp([9 '3D PCA plot is turned off due to lag and general bugginess in UIFigure'])
        end
        
        for u = 1:length(unq)
            app.PCAPanels.PCASelected.Items{u} = ['Unit ' num2str(unq(u))];
            
            inds = app.Data.spikes.assigns == unq(u);
            %{
            app.PCAPanels.plots(u) = plot3(app.PCAPanels.PCAView,...
                pc(inds,1),pc(inds,2),pc(inds,3),...
                '.','color',app.Data.colors(u,:),'markersize',14);
            %}
            app.PCAPanels.plots(u) = plot(app.PCAPanels.PCAView,...
                pc(inds,1),pc(inds,2),...
                '.','color',app.Data.colors(u,:),'markersize',14);
            drawnow('limitrate');
        end
        % start with all selected (because that's how it's plotted):
        app.PCAPanels.PCASelected.Value = app.PCAPanels.PCASelected.Items;

        app.PCAPanels.PCAView.TickDir = 'out';
        app.PCAPanels.PCAView.TickLength = [0.002 0.002];

        app.PCAPanels.PCAView.XLabel.String = 'PC 1';
        app.PCAPanels.PCAView.YLabel.String = 'PC 2';
        app.PCAPanels.PCAView.ZLabel.String = 'PC 3';
        
        disableDefaultInteractivity(app.PCAPanels.PCAView);
        %rotate3d(app.PCAPanels.PCAView,'on');
        grid(app.PCAPanels.PCAView,'on');
        hold(app.PCAPanels.PCAView,'off');
        
        drawnow;
        
        app.Data.modified(5) = 0;
    else
        if app.Settings.Debugging
            disp([9 'Not re-plotting PCA as should be same as last plot'])
        end
    end
%}
end