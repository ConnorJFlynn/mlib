function y = sliding_polyfit(x,y,w)
%  y = sliding_polyfit(x,y,w)
% Computes a polyfit over a sliding window of width w.
% Polyfit is quadratic if more than 3 points are within window, else linear

for i = length(x):-1:1
    ii_ = abs(x - x(i))<= w;
    if sum(ii_)>3
      [P,~, mu] = polyfit(x(ii_),y(ii_), 2);
      y(i) = polyval(P,x(i),[],mu);
    elseif sum(ii_)>1
      [P,~, mu] = polyfit(x(ii_),y(ii_), 1);
      y(i) = polyval(P,x(i),[],mu);
    end
%     if mod(i,1000)==0
%         disp(i)
%     end
end

return
