function cols = makeColors(~,n)
    if exist('hex2col','file')
        % hard-coded palette:
        col_str = '#e6194B,#3cb44b,#ffe119,#4363d8,#f58231,#911eb4,#42d4f4,#f032e6,#bfef45,#fabebe,#469990,#e6beff,#9A6324,#5f7ba8,#800000,#aaffc3,#808000,#5fa870,#000075,#a9a9a9,#000000';
        col_str = strsplit(col_str,',');
        c = 0;
        cols = NaN(n,3);
        for u = 1:n
            c = c + 1;
            if c > length(col_str) % wrap around if > 19 clusters
                c = 1;
            end
            cols(u,:) = hex2col(col_str{c});
        end
    else
        if exist('distinguishable_colors','file')
            cols = distinguishable_colors(n);
        else
            cols = lines(n);
        end
    end
end