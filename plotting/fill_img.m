function [B,x_grid] = fill_img(A, x,x_grid); 
% [B,x_grid] = fill_img(A, x,x_grid); 
% Returns the regular gridded matrix B composed of the rows of A
% with x nearest to x_grid. Row of B without corresponding A are NaN.
% If x_grid is not supplied, the grid runs from [min(x):interval:max(x)]
if size(x,1)==size(A,2) 
   x = x';
end
if ~exist('x_grid','var')
   interval = intervals(x);
   x_grid = [min(x):interval(1):max(x)];
end
if (length(x)==2)&(length(x_grid)==2)
   x = linspace(x_grid(1), x_grid(2), size(A,1));
   x_grid = x;
end
ind = round(interp1(x_grid,[1:length(x_grid)],x,'nearest'));
% ind = round(interp1(x_grid,[1:length(x_grid)],x,'nearest', 'extrap')); %
% This might have fixed the NaN problem
ind(isNaN(ind)) = [];
[ind, uini, iinu] = unique(ind);
ind(1)= max(1,ind(1)); ind(end) = min(length(x_grid),ind(end));

% [ind, bina] = nearest(x, x_grid);
% for i = length(x):-1:1;
%     [tmp, ind(i)] = min(abs(x(i)-x_grid));
% end
if ndims(A)==2
   [row,col] = size(A);
   B = NaN([row,length(x_grid)]);
   B(:,ind) = A(:,uini);
   %find mini-gaps one bin wide and fill with previous profile
   gap_size = [1,diff(ind)]-1;
   minigaps = find(gap_size==1);
   B(:,(ind(minigaps)-1)) = B(:,(ind(minigaps)-2));
elseif ndims(A)==3
   [row,col,colr] = size(A);
   B = NaN([row,length(x_grid),colr]);
   % Br = NaN([row,length(x_grid)]);
   % Bg = NaN([row,length(x_grid)]);
   % Bb = NaN([row,length(x_grid)]);
   B(:,ind,1) = A(:,uini,1);
   B(:,ind,2) = A(:,uini,2);
   B(:,ind,3) = A(:,uini,3);
   % Bg(:,ind,2) = A(:,:,2);
   % Bb(:,ind,3) = A(:,:,3);
   %find mini-gaps one bin wide and fill with previous profile
   gap_size = [1,diff(ind)]-1;
   minigaps = find(gap_size==1);
   B(:,(ind(minigaps)-1),1) = B(:,(ind(minigaps)-2),1);
   B(:,(ind(minigaps)-1),2) = B(:,(ind(minigaps)-2),2);
   B(:,(ind(minigaps)-1),3) = B(:,(ind(minigaps)-2),3);
end
