% Write changes to the history file, so they can be repeated even
% if we don't save back to the file:
function pushHistory(app,method,varargin)
    % Currently deactivated, will finish implementation when rest
    % of the methods are written.
    %{
    strOut = cell(1,length(varargin));
    for v = 1:length(varargin)
        strOut{v} = strjoin(arrayfun(@(x) num2str(x),varargin{v},'UniformOutput',false),',');
    end
    fl = [app.Data.FilePath filesep '.SplitMerge' filesep strrep(app.Data.activeFile,'.mat','.emrx')];
    fID = fopen(fl,'a');
    str = [method '_' strjoin(strOut,'_')];
    fprintf(fID,[str '\n']);
    fclose(fID);
    %}
end