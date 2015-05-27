function [hbbCol, abbCol] = annCsvReader(inputFile )
    delimiter = ',';
    fid = fopen(inputFile,'r');   %# Open the file
    lineArray = cell(500,1);    %# Preallocate a cell array (ideally slightly
                                %#   larger than is needed)
    lineIndex = 1;              %# Index of cell to place the next line in
    nextLine = fgetl(fid);      %# Skip the 2 line from the file
    nextLine = fgetl(fid);      %# Read the first data line from the file
    while ~isequal(nextLine,-1)             %# Loop while not at the end of the file
        lineArray{lineIndex} = nextLine;    %# Add the line to the cell array
        lineIndex = lineIndex+1;            %# Increment the line index
        nextLine = fgetl(fid);              %# Read the next line from the file
    end
    fclose(fid);                 %# Close the file
    
    lineArray = lineArray(1:lineIndex-1);  %# Remove empty cells, if needed
    
    for iLine = 1:lineIndex-1              %# Loop over lines
        lineData = textscan(lineArray{iLine},'%s',...  %# Read strings
                    'Delimiter',delimiter);
        lineData = lineData{1};              %# Remove cell encapsulation
        if strcmp(lineArray{iLine}(end),delimiter)  %# Account for when the line
            lineData{end+1} = '';                     %#   ends with a delimiter
        end
        lineArray(iLine,1:numel(lineData)) = lineData;  %# Overwrite line data
    end
    
    hbbCol = str2double(strrep(strrep(lineArray(2:end, find(ismember(lineArray(1, :),'Hot BB Mean'))), '"', ''), ' ', ''));
    abbCol = str2double(strrep(strrep(lineArray(2:end, find(ismember(lineArray(1, :),'Cold BB Mean'))), '"', ''), ' ', ''));
end

