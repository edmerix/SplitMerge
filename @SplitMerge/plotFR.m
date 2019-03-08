% plot FR:
function plotFR(app,ax,ids)
    if nargin < 3 || isempty(ids)
        ids = ismember(app.Data.spikes.assigns, app.Data.Selected);
    end
    % lifted from plot_stability.m (ultramegasort)
    % Firing rate: (left y-axis)
    yyaxis(ax,'left');
    cla(ax)
    %inds = ismember(app.Data.spikes.assigns,ids);
    spiketimes = sort(app.Data.spikes.spiketimes(ids));
    tlims = [min(app.Data.spikes.spiketimes) max(app.Data.spikes.spiketimes)];% [0 sum(spikes.info.detect.dur)];  
    num_bins  = round( diff(tlims) /  app.Data.spikes.params.display.stability_bin_size);
    edges = linspace(tlims(1),tlims(2),num_bins+1);
    n = histc(spiketimes,edges);  
    n(end) = [];    
    vals = n/mean(diff(edges));

    hold(ax,'on')
    bar(ax, edges(1:end-1) ,vals,1.0);
    shading(ax,'flat');
    hold(ax,'off')
    set(ax, 'XLim', tlims)%,'YLim',[0 2*max(get(ax,'YLim'))])
    %{
    yticks = get(ax,'YTick');
    set(ax,'YTick',yticks( yticks<=max(yticks)/2))
    %}
    %xlabel(ax,'Time (s)')
    set(ax,'XTick',[]);
    ylabel(ax,'Firing rate (Hz)')

    % Stability: (right y-axis)
    yyaxis(ax,'right');
    cla(ax)
    memberwaves = app.Data.spikes.waveforms(ids,:);
    amp = range(memberwaves');

    if isequal(app.Data.spikes.params.display.max_scatter, 'all')
        ind = 1:length(amp);
    else
        choice = randperm(length(amp));
        max_pos = min(length(amp), app.Data.spikes.params.display.max_scatter);
        ind = choice(1:max_pos);
    end
    l = scatter(ax,spiketimes(ind),amp(ind));
    set(l,'Marker','.','MarkerEdgeColor',[.3 .5 .3],'MarkerEdgeAlpha',0.4,'MarkerFaceAlpha',0.5)
    set(ax,'Xlim',tlims)
    set(ax,'YLim',[0 max(amp)])
    xlabel(ax,'Time (s)')
    ylabel(ax,'Amplitude (\muV)')
    ax.YAxis(2).Color = [0.3 0.5 0.3];

    % Attempting to stop a weird bug wherein after doing yyaxis on this set of axes, suddenly
    % clicking on a waveform in the spike panels causes a warning about no appropriate method
    % for UIAxes with processFigureHitObject. Which we already knew, which is why we didn't
    % set up clicking on spike panels to begin with...
    % yyaxis(ax,'left');
    % Nope, still the same issue. What on earth...
end