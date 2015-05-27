function [CoaddedData] = CoaddData(Data);
% Returns forward and reverse in two seperate structures
% Data is the structure with forward and reverse data sets
if isfield(Data,'Header')
  CoaddedData.Header = Data.Header;
end
CoaddedData.x = Data.x;
CoaddedData.y =mean(Data.y, 1);
% CoaddedData.y = sum(Data.y, 1);
% CoaddedData.y = CoaddedData.y / size(Data.y, 1);
% z = mean(Data.y, 1);