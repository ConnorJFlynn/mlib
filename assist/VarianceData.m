function [VariancedData] = VarianceData(Data);
% Returns forward and reverse in two seperate structures
% Data is the structure with forward and reverse data sets
if isfield(Data,'Header')
VariancedData.Header = Data.Header;
end
VariancedData.x = Data.x;
VariancedData.y = var(Data.y,0, 1);

