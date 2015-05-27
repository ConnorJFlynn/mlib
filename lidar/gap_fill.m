function [grid, ind] = gap_fill(in, grid, missing);
%ind = gap_fill(in, grid, missing);
% Returns ind of length grid with the indices of in corresponding to the
% indices of the supplied grid with gaps filled with missing or NaN.

if ~exist('missing', 'var')
    missing = NaN;
end
if ~exist('grid', 'var')
    grid_min = min(in);
    grid_max = max(in);
    in_diff = diff(in);
    pos_diff = find(in_diff>0);
    grid_step = min(in_diff(pos_diff));
    grid = [grid_min:grid_step:grid_max];
else
    grid_step = grid(2)-grid(1);
end
ind = NaN(size(grid));
g = 1; i = 1;
%We will assign grid elements if there is an in element greater than or
%equal to grid(n), but less than grid(n-1)
while n <= length(in)
    
%Let's not assume that in and grid are perfectly properly matched. 
% The output must correspond to the grid, not to in


for in = 1:length(in)