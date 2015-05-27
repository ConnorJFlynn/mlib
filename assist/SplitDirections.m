function [Forward, Reverse] = SplitDirections(Data);
% Returns forward and reverse in two seperate structures
% Data is the structure with forward and reverse data sets

Forward.Header = Data.Header;
Reverse.Header = Data.Header;

Forward.x = Data.x;
Reverse.x = Data.x;

ll = 1:2:size(Data.y, 1);
Forward.y = Data.y(ll, :);

ll = 2:2:size(Data.y, 1);
Reverse.y = Data.y(ll, :);
