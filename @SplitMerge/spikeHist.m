function [dens,y] = spikeHist(app,wvs)

n = app.Settings.DensityBins;

min_these = min(wvs(:));
max_these = max(wvs(:));

big_padded = [min(app.Data.spikes.waveforms(:)) max(app.Data.spikes.waveforms(:))];
% add 5% either side:
big_padded = big_padded + ([-1 1]*(diff(big_padded)/20));
min_all = big_padded(1);
max_all = big_padded(2);

% scale it so the requested number of bins spans just that unit's data
% range, not the largest unit's (but still running over the full range for
% the plot)
scaled_n = ceil(n / (max_these - min_these)) * (max_all - min_all);

wvs = wvs - min_all;
wvs = wvs./(max_all-min_all);
wvs = wvs.*scaled_n;

wvs = round(wvs);
y = linspace(min_all,max_all,scaled_n);
dens = hist(wvs,1:scaled_n);