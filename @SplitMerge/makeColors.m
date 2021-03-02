function cols = makeColors(~,n)
    %if exist('hex2col','file')
    % hard-coded palette:
    palette = [
        0.9020    0.0980    0.2941
        0.2353    0.7059    0.2941
        1.0000    0.8824    0.0980
        0.2627    0.3882    0.8471
        0.9608    0.5098    0.1922
        0.5686    0.1176    0.7059
        0.2588    0.8314    0.9569
        0.9412    0.1961    0.9020
        0.7490    0.9373    0.2706
        0.9804    0.7451    0.7451
        0.2745    0.6000    0.5647
        0.9020    0.7451    1.0000
        0.6039    0.3882    0.1412
        0.3725    0.4824    0.6588
        0.5020         0         0
        0.6667    1.0000    0.7647
        0.5020    0.5020         0
        0.3725    0.6588    0.4392
             0         0    0.4588
        0.6627    0.6627    0.6627
             0         0         0
    ];

    c = 0;
    cols = NaN(n,3);
    for u = 1:n
        c = c + 1;
        if c > size(palette,1) % wrap around if > 21 clusters
            c = 1;
        end
        cols(u,:) = palette(c,:);
    end
    %{
    else
        if exist('distinguishable_colors','file')
            cols = distinguishable_colors(n);
        else
            cols = lines(n);
        end
    end
    %}
end
