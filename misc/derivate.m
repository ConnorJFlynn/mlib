function dfx = derivate(x,fx);
% dfx = derivate(x,fx);
%    [B,I,J] = UNIQUE(...) also returns index vectors I and J such
%    that B = A(I) and A = B(J)%
dfx = NaN(size(fx));

if all(size(x)==size(fx))
   dfx_ = diff(fx)./diff(x);
   mid_x = (x(1:(end-1))+x(2:end))./2;
   dfx = interp1(mid_x,dfx_,x,'linear','extrap');
elseif any(size(x)==1)&&~any(size(fx)==1)&&(sum(size(x)==size(fx))==1)
   if find(size(x)==size(fx))==1
      dfx_ = diff(fx)./(diff(x)*ones([1,size(fx,2)]));
      mid_x = (x(1:(end-1))+x(2:end))./2;
      dfx = interp1(mid_x,dfx_,x,'linear','extrap');
   else
      dfx_ = diff(fx,1,2)./(ones([size(fx,1),1])*diff(x,1,2));
      mid_x = (x(1:(end-1))+x(2:end))./2;
      dfx = interp1(mid_x',dfx_',x','linear','extrap')';
   end
end

