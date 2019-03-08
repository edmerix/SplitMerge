function plotPCA(app,~)
    pc = app.Data.spikes.info.pca.u;
    unq = unique(app.Data.spikes.assigns);
    hfig = figure('Position',[100 100 800 700]);
    ax = axes('Position',[0.05 0.05 0.9 0.9]);
    hold(ax,'on');
    group = zeros(1,length(unq));
    unit = compose('Unit %d',unq);
    for u = 1:length(unq)
        subset = find(app.Data.spikes.assigns == unq(u));
        group(u) = plot3(ax,pc(subset,1),...
            pc(subset,2),...
            pc(subset,3),'.','color',app.Data.colors(u,:),'MarkerSize',14);
    end
    ax.XLabel.String = 'PC 1';
    ax.YLabel.String = 'PC 2';
    ax.ZLabel.String = 'PC 3';
    ax.XGrid = 'on';
    ax.YGrid = 'on';
    ax.ZGrid = 'on';
    rotate3d(ax,'on')
    legend(ax,group,unit,'Location','NorthEastOutside');

    dcm_obj = datacursormode(hfig);
    set(dcm_obj,'UpdateFcn',@myupdatefcn)    
end

function txt = myupdatefcn(~,event_obj)
    % Customizes text of data tips
    all_u = get(gca,'Children');
    for a = 1:length(all_u)
        set(all_u(a),'Markersize',12);
    end
    target = get(event_obj,'Target');
    unit = get(target,'DisplayName');
    set(target,'MarkerSize',24);
    txt = {unit};
end