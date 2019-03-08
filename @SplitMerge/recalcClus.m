% Redo the whole spike sorting (because we've removed some garbage
% for example)
function recalcClus(app,~)
    msg = 'Recalculating clusters will overwrite everything';
    if ~isempty(find(app.Data.spikes.labels(:,2) == 2, 1))
        msg = {msg; '(including clusters currently marked as good)'};
    end
    title = 'Confirm recalculation';
    selection = uiconfirm(app.UIFigure,msg,title,...
       'Options',{'Recalculate','Cancel'},...
       'DefaultOption',2,'CancelOption',2);
    if strcmpi(selection,'recalculate')
        app.UIFigure.Visible = 'off';
        app.Data.spikes.params.agg_cutoff = app.AggCutoff.Value;
        disp([9 'Recalculating clusters with aggregation cutoff of ' num2str(app.Data.spikes.params.agg_cutoff) '...'])
        app.Data.spikes = ss_kmeans(app.Data.spikes);
        app.Data.spikes = ss_energy(app.Data.spikes);
        app.Data.spikes = ss_aggregate(app.Data.spikes);
        pushHistory(app,'n');

        app.UIFigure.Visible = 'on';

        app.Data.modified = ones(1,length(app.Data.modified));

        refreshScreen(app);
    end
end