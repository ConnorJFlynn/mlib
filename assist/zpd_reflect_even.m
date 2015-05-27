function [y_] = zpd_reflect_even(x,y,shift_zpd);
% Usage: [y] = zpd_reflect_even(x,y,shift_zpd)
% Similar to fftshift except:
% 1. Centers the supplied igm.y by reflecting across the identified zpd
% 2. Truncates to leave zpd at length/2 + 1 position
% 3. Swap the centered igm about the center
% Generates a igram of even length
y_ = y;
shift_dim = find(size(y)==length(x)) -1;
if shift_zpd~=0 
   y_ = shiftdim(y,shift_dim);
   center = length(x)./2 + 1;
   zpd = center - shift_zpd;
   rhs = y_(zpd+1:end,:);
   lhs = y_(1:zpd-1,:);
   lim = min([size(lhs,1),size(rhs,1)]);
   if shift_zpd>0 %right hand side is longer
     y_ = [flipud(rhs);y_(zpd,:);rhs];
     ycenter = (size(y_,1)-1)./2  + 1;
     y_(ycenter-lim:ycenter-1,:) = lhs;
   else %left hand side is longer
      y_ = [lhs;y_(zpd,:);flipud(lhs)];
      ycenter = (size(y_,1)-1)./2 + 1;
      y_(ycenter+1:ycenter+lim,:) = rhs;
   end
   cut = ycenter - center;
   y_ = y_(1+cut:end-cut-1,:);
   y_ = shiftdim(y_,ndims(y_)-shift_dim);
end
y_ = fftshift(y_,shift_dim+1);
return
