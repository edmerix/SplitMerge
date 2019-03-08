% plot detection criterion: (depends on ultramegasort)
function plotDetectionCriterion(app,ax,ids)
    if nargin < 3 || isempty(ids)
        ids = app.Data.Selected;
    end
    cla(ax)
    [p,mu,stdev,n,x] = ss_undetected(app.Data.spikes,ids);
    % determine global extreme if there are other detection criterion plots on the current figure
    my_sign = sign(mu);
    global_ex = max(abs(x))*my_sign;
    % Now make an estimate of how many spikes are missing, given the Gaussian and the cutoff
    N = sum(n) / (1-p);
    if my_sign == -1
        a = linspace(global_ex,0,200);
    else
        a = linspace(0,global_ex,200);
    end
    b = normpdf(a,mu,stdev);
    b = (b/sum(b))*N*abs((x(2)-x(1))/(a(2)-a(1)));

    hh = bar(ax,x,n,1.0);
    set(hh,'EdgeColor',[0 0.2314 0.2745],'FaceColor',[0.0275 0.3412 0.3569]);
    set(ax,'XLim',sort([global_ex 0]));
    set(ax,'YLim',[0 max(n)]);
    line(ax,a,b,'Color',[0.5725 0.1333 0.0863],'LineWidth',2);

    % threshold line
    line(ax,[1 1]*my_sign, get(ax,'YLim'),'LineStyle','--','Color',[0 0 0],'LineWidth',2);

    set(ax,'XLim',sort([global_ex 0]));

    title(ax,['Estimated missing spikes: ' num2str(p*100,'%2.1f') '%']);

    xlabel(ax,'Detection metric')
    ylabel(ax,'No. of spikes')
end