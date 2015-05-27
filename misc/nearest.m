function [Aind, Bind] = nearest(A,B,nearby);
% [Aind, Bind] = nearest(A,B,nearby);
% Returns the unique set of one-to-one paired indices having least
% separation. That is, the points identified by Aind and Bind represent
% matched pairs from A and B which are closest to one another.

% Idea is to use interp1('nearest','extrap') to first identify nearest points.  
% This may yield repeats, so follow it with unique and then another interp1
% pass with A and B swapped.
if (find(size(A)==1,1))~=(find(size(B)==1,1))
   B = B';
end
if ~exist('nearby','var')
   nearby = abs(2*max([mean(diff(A)), mean(diff(B))]));
end
if length(A)>=length(B)
   [longer,l_ind] = sort(A);
   [shorter, s_ind] = sort(B);
else
   [longer,l_ind] = sort(B);
   [shorter, s_ind] = sort(A);
end

[short_in_long] = interp1(longer(end:-1:1), (length(longer):-1:1),shorter,'nearest','extrap');
short_in_long = unique(short_in_long);
long_in_short = interp1(shorter(end:-1:1), (length(shorter):-1:1),longer(short_in_long),'nearest','extrap');
long_in_short = unique(long_in_short);
while length(long_in_short)~=length(short_in_long)
   if length(long_in_short)~=length(short_in_long)
      [short_in_long] = interp1(longer, (1:length(longer)),shorter(long_in_short),'nearest','extrap');
      short_in_long = unique(short_in_long);
   end
   if length(long_in_short)~=length(short_in_long)
      [long_in_short] = interp1(shorter, (1:length(shorter)),longer(short_in_long),'nearest','extrap');
      long_in_short = unique(long_in_short);
   end
end
if isempty(long_in_short)
   disp('Pathological evenly spaced points?')
end
if length(A)>=length(B)
   Aind = l_ind(short_in_long);
   Bind = s_ind(long_in_short);
 else
   Bind = l_ind(short_in_long);
   Aind = s_ind(long_in_short);
end

too_far = abs(A(Aind)-B(Bind))>nearby;
Aind(too_far) = [];
Bind(too_far) = [];