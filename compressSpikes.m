% Compress spike matrix into continuous line separated by NaNs to
% speed up plotting (means can't be multi-colored, but the speed
% benefit is well worth it. e.g. a matrix of 18,146 spikes from one
% Utah array channel goes from 6.3611 seconds to 0.014457 seconds)
function [tt,wvs] = compressSpikes(~,t,spks)
    if iscolumn(t)
        t = t';
    end
    n = size(spks,2) + 1;

    wvs = spks';
    wvs(n,:) = NaN;
    wvs = wvs(:);

    tt = repmat(t',1,size(spks,1));
    tt(n,:) = NaN;
    tt = tt(:);
end