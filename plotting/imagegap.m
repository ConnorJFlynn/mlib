function fig = imagegap(X,Y,A,x_grid)
% fig = imagegap(X,Y,A,x_grid)
% generates image on regular grid inserting missing if necessary
if exist('x_grid','var')
    [B,x_grid] = fill_img(A, X,x_grid);
else
    [B,x_grid] = fill_img(A, X);
end

fig = gcf; 
imagesc(x_grid,Y,B); axis('xy')

