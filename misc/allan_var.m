function avar = allan_var(y)
% primitive Allan variance

m = 0;
while m<length(y)./10 & length(y)>10;
   if isavar('avar')
      clear avar;
   end
   N = min([120,floor(length(y)./10)]);
   for n = 2:N
      y_bar = downsample(y,n);
      dy_bar = diff(y_bar);
      dy_bar_squared = dy_bar.^2;
      avar.n(n-1) = n;
      avar.avar(n-1) = sum(dy_bar_squared)./(2*(length(y_bar)-1));
   end
   avar.ava5 = smooth(avar.avar)'; [~,m] = sort(avar.ava5);m = m(1);
   % [~, lows] = sort(avar.avar(low_ii)); low_ii = low_ii(lows(1:end./2)); low_ii = sort(low_ii);
   % % low_ii = sort(low_ii); low_ii = low_ii(1:floor(0.5.*end));
   % [P,S] = polyfit(avar.n(low_ii), log(avar.avar(low_ii)),2);
   % m = floor(roots(polyder(P)));
   % figure(25); plot(avar.n, log(avar.avar),'k-x',avar.n(low_ii), polyval(P,avar.n(low_ii)),'-',m,polyval(P,avar.n(m)),'o');
   figure(25); plot(avar.n, log(avar.avar),'k-x',avar.n, log(avar.ava5),'-',m,log(avar.ava5(m)),'o');

   title(['time span: ',num2str(length(y)), ' averaging:',num2str(m)]);
   y = y(1:floor(0.8*end));

end
avar.m = m;


return