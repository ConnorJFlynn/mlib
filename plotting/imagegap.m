function [img,x_grid] = imagegap(X,Y,A,x_grid)
% fig = imagegap(X,Y,A,x_grid)
% generates image on regular grid inserting missing if necessary
if ~isempty(who('x_grid'))
    [B,x_grid] = fill_img(A, X,x_grid);
else
    [B,x_grid] = fill_img(A, X);
end

img = imagesc(x_grid,Y,B); axis('xy')


