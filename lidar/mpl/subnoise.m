function X = subnoise(Y,bot,top);
% This function accepts a vector lidar profile and returns
% the vector with noise reduced by splitting the profile into
% positive and negative halves, reducing each halve by the mean
% deviation and recombining.

X = Y;
  noise_top = .98;
  noise_bot = .85;
if nargin == 3
  noise_bot = bot;
  noise_top = top;
end;
top = ceil(noise_top*length(X));
bot = fix(noise_bot*length(X));
under = find(X<mean(X(bot:top)));
over = find(X>mean(X(bot:top)));
X(under)= X(under) - mean(X(under(find(under>bot&under<top))));
X(over)= X(over) - mean(X(over(find(over>bot&over<top))));
