% Keypress handler:
function AppKeyPress(app,event)
    % Keys that function the same regardless of active tab:
    switch event.Key
        case 's'
            app.saveSpikes();
            return;
        otherwise
            %
    end
    
    % Ctrl+ keys change tab, and are always the same regardless of active
    % tab:
    if any(strcmpi(event.Modifier,'control'))
        switch event.Key
            case {'i','m','1'} % inspect/merge
                app.TabGroup.SelectedTab = app.TabMerge;
                app.refreshScreen();
            case {'t','2'} % spliT (s is taken for save)
                app.TabGroup.SelectedTab = app.TabSplit;
                app.refreshScreen();
            case {'o','3'}
                app.TabGroup.SelectedTab = app.TabOutliers;
                app.refreshScreen();
            case {'d','4'}
                app.TabGroup.SelectedTab = app.TabDetails;
                app.refreshScreen();
            case {'p','5'}
                app.TabGroup.SelectedTab = app.TabPCA;
                app.refreshScreen();
            case {'n','6'}
                app.TabGroup.SelectedTab = app.TabNoise;
                app.refreshScreen();
            case 'r'
                app.refreshScreen();
            case 'escape'
                app.unhang();
            otherwise
                %
        end
    else
        % Keys that have specific functions in specific tabs:
        switch app.TabGroup.SelectedTab.Tag
            case 'merge'
                switch event.Key
                    case 'g' % Mark as good
                        app.markGood();
                    case 'b' % Mark as bad (unknown technically)
                        app.markBad();
                    case 'c' % Show compare pair plot (shift+c uses mean ± 2SD)
                        app.comparePairs(any(strcmpi(event.Modifier,'shift')));
                    case 'p' % Plot PCA:
                        app.plotPCA();
                    case 'm' % Merge the selected:
                        app.MergeNow();
                    case 't' % move to trash:
                        app.garbageCollector();
                    otherwise
                        %
                end
            case 'split'
                switch event.Key
                    case 'x' % commit the split
                        app.splitNow();
                    case 'downarrow' % move the threshold down 1 value, or 5% of range if shift
                        lims = app.SplitChaps.SplitSlider.Limits;
                        oldVal = app.SplitChaps.SplitSlider.Value;
                        if any(strcmpi(event.Modifier,'shift'))
                            newVal = max(oldVal-(diff(lims)/20), min(lims));
                        else
                            newVal = max(oldVal-1, min(lims));
                        end
                        app.SplitChaps.SplitSlider.Value = newVal;
                        app.splitSlide([],newVal);
                    case 'uparrow' % move the threshold up 1 value, or 5% of range if shift
                        lims = app.SplitChaps.SplitSlider.Limits;
                        oldVal = app.SplitChaps.SplitSlider.Value;
                        if any(strcmpi(event.Modifier,'shift'))
                            newVal = min(oldVal+(diff(lims)/20), max(lims));
                        else
                            newVal = min(oldVal+1, max(lims));
                        end
                        app.SplitChaps.SplitSlider.Value = newVal;
                        app.splitSlide([],newVal);
                    otherwise
                        %
                end
            case 'outliers'
                switch event.Key
                    case 'c' % cut the marked ones
                        app.cutNow();
                    case 'leftarrow' % move the slider to the left by 1 value, or 5% of range if shift
                        lims = app.OutlierPanels.OutlierSlider.Limits;
                        oldVal = app.OutlierPanels.OutlierSlider.Value;
                        if any(strcmpi(event.Modifier,'shift'))
                            newVal = max(oldVal-(diff(lims)/20), min(lims));
                        else
                            newVal = max(oldVal-1, min(lims));
                        end
                        app.OutlierPanels.OutlierSlider.Value = newVal;
                        app.outlierSlide([],newVal);
                    case 'rightarrow' % move the slider to the right by 1 value, or 5% of range if shift
                        lims = app.OutlierPanels.OutlierSlider.Limits;
                        oldVal = app.OutlierPanels.OutlierSlider.Value;
                        if any(strcmpi(event.Modifier,'shift'))
                            newVal = min(oldVal+(diff(lims)/20), max(lims));
                        else
                            newVal = min(oldVal+1, max(lims));
                        end
                        app.OutlierPanels.OutlierSlider.Value = newVal;
                        app.outlierSlide([],newVal);
                    otherwise
                        %disp(event)
                end
            otherwise
                %
        end
    end
end