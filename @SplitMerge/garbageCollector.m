% Actually delete clusters on press of garbage button
% It also saves the deleted clusters into a trash_{filename} file in
% .SplitMerge directory at same root as original file.
% UPDATE - it doesn't save into trash_{filename} at the moment, instead
% saving the removed data into a subfield: spikes.garbage
function garbageCollector(app,~)
    app.MergeButton.Enable = 'off';
    app.GarbageButton.Enable = 'off';

    bad = app.Data.Selected;
    badinds = ismember(app.Data.spikes.assigns, bad);

    disp([9 'Removing clusters ' strjoin(arrayfun(@(x) num2str(x),bad,'UniformOutput',false),', ')])
    
    %% VERSION THAT STORES IN HIDDEN FILE:
    %{
    % write them to a file to store as garbage in .SplitMerge
    newtrash.waveforms = app.Data.spikes.waveforms(badinds,:);
    newtrash.spiketimes = app.Data.spikes.spiketimes(badinds);
    newtrash.trials = app.Data.spikes.trials(badinds);
    newtrash.unwrapped_times = app.Data.spikes.unwrapped_times(badinds);
    newtrash.assigns = app.Data.spikes.assigns(badinds);
    
    trashFile = [app.Data.FilePath filesep '.SplitMerge' filesep 'trash_' app.Data.activeFile];
    
    if exist(trashFile,'file')
        old = load(trashFile,'garbage');
        garbage.waveforms = [old.garbage.waveforms; newtrash.waveforms];
        garbage.spiketimes = [old.garbage.spiketimes; newtrash.spiketimes];
        garbage.trials = [old.garbage.trials newtrash.trials];
        garbage.unwrapped_times = [old.garbage.unwrapped_times; newtrash.unwrapped_times];
        garbage.assigns = [old.garbage.assigns newtrash.assigns];
        clear old
        %TODO:
        % Need to go through and remove duplicates (i.e. ones occuring at
        % the same time with the same assign) otherwise we could really
        % bloat this by deleting waveforms multiple times without saving in
        % between.
    else
        garbage = newtrash;
    end
    save(trashFile,'garbage');
    clear newtrash garbage
    %}

    %% VERSION THAT STORES WITHIN FILE:
    %% TODO: REPLACE THIS SECTION WITH:
    % app.Data.spikes = ss_move_subset(app.Data.spikes,badinds,'garbage');
    % (but check it's performing correctly first...)
    newtrash.waveforms = app.Data.spikes.waveforms(badinds,:);
    newtrash.spiketimes = app.Data.spikes.spiketimes(badinds);
    newtrash.trials = app.Data.spikes.trials(badinds);
    newtrash.unwrapped_times = app.Data.spikes.unwrapped_times(badinds);
    newtrash.assigns = app.Data.spikes.assigns(badinds);
    if isfield(app.Data.spikes,'garbage')
        old = app.Data.spikes.garbage;
        garbage.waveforms = [old.waveforms; newtrash.waveforms];
        garbage.spiketimes = [old.spiketimes; newtrash.spiketimes];
        garbage.trials = [old.trials newtrash.trials];
        garbage.unwrapped_times = [old.unwrapped_times; newtrash.unwrapped_times];
        garbage.assigns = [old.assigns newtrash.assigns];
        clear old
    else
        garbage = newtrash;
    end
    app.Data.spikes.garbage = garbage;
    clear newtrash garbage

    app.Data.spikes.waveforms(badinds,:) = [];
    app.Data.spikes.spiketimes(badinds) = [];
    app.Data.spikes.trials(badinds) = [];
    app.Data.spikes.unwrapped_times(badinds) = [];
    app.Data.spikes.assigns(badinds) = [];
    app.Data.spikes.labels(app.Data.spikes.labels(:,2) == 4,:) = [];
    app.Data.spikes.info.pca.u(badinds,:) = [];
    app.Data.spikes.info.kmeans.assigns(badinds) = [];
    % hopefully that's all of them...
    %%
    app.MergeButton.Enable = 'on';
    app.GarbageButton.Enable = 'on';

    pushHistory(app,'t',bad);
    
    app.Data.modified = ones(1,length(app.Data.modified));
    plotUnits(app); % Same as for mergeNow function.
end