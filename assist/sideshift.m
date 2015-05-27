function [y] = sideshift(x,y,shift_zpd);
% Usage: [y] = sideshift(x,y,shift_zpd)
% Similar to fftshift except:
% 1. Centers the supplied igm.y by shifting by shift_zpd
% The intent is to leave the ZPD peak located at the first indice in the
% second half of the ifg.  For example, for an ifg of length 8, you want 
% [ a a a a Z b b b].
% Then when acted on by fftshift the vector will be [Z b b b a a a a] 

dim_n = find(size(y)==length(x));
xi = zeros(size(x));
xi(:) = [1:length(x)];
xy = ones(size(y,find(size(y)~=length(x))),1)*xi;
xy = mod(xy-1+shift_zpd*ones(size(xi)),length(x))+1;
for yy = 1:size(y,find(size(y)~=length(x)))
    y(yy,:) = y(yy,xy(yy,:));
end
% shift_ind = zeros(size(size(y)));
% shift_ind(dim_n) = -1.*shift_zpd;
% y = circshift(y,-1.*shift_zpd);
% if dim_n==1
%    if shift_zpd>0
%       y = flipud(y);
%    end
%    inds = [1:abs(shift_zpd)];
%    y(inds,:)=y(inds+abs(shift_zpd),:);
%    if shift_zpd>0
%       y = flipud(y);
%    end
% else
%    if shift_zpd>0
%       y = fliplr(y);
%    end
%    inds = [1:abs(shift_zpd)];
%    y(:,inds)=y(:,inds+abs(shift_zpd));
%    if shift_zpd>0
%       y = fliplr(y);
%    end
% end


return
