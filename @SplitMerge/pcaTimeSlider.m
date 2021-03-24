function pcaTimeSlider(app,~)

spikes = app.Data.spikes;

hfig = figure('position',[100 100 695 690]);

h_ax = axes('position',[0.1 0.2 0.8 0.75]);
h_plot = plot3(h_ax,spikes.info.pca.u(:,1),spikes.info.pca.u(:,2),spikes.info.pca.u(:,3),'.');
xlabel('PC 1')
ylabel('PC 2')
rotate3d(h_ax,'on')

t_slide = double([min(spikes.spiketimes) max(spikes.spiketimes)]);

t_space = 60*(round((diff(t_slide)/20)/60));

jRangeSlider = com.jidesoft.swing.RangeSlider(t_slide(1),t_slide(2),t_slide(1),t_slide(2));
jRangeSlider = javacomponent(jRangeSlider, [0,0,695,40], hfig);

set(jRangeSlider, 'MajorTickSpacing',t_space*2, 'MinorTickSpacing',t_space,...
    'PaintTicks',true, 'PaintLabels',true, 'Background',java.awt.Color.white,...
    'StateChangedCallback',@(hObject,event)pca_replot(hObject,event,jRangeSlider,spikes,h_plot));

end

function pca_replot(~,~,s_p,spikes,h_plot)
timing = [s_p.LowValue s_p.HighValue];

subset = find(spikes.spiketimes > timing(1) & spikes.spiketimes <= timing(2));
set(h_plot,'XData',spikes.info.pca.u(subset,1),'YData',spikes.info.pca.u(subset,2),'ZData',spikes.info.pca.u(subset,3));

end