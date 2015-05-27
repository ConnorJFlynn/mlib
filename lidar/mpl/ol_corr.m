function [corr] = ol_corr(range, signal);
%usual syntax: [corr] = ol_corr(range, mean(signal_r2(:,select)')');
done = 0;
while ~done,
   hold off
   plot(range, real(log(signal)),'+g', range, real(log(signal)), 'c');
   zoom on;
   disp('Overlap correction factors will be generated down to the lowest value of range displayed.');
   disp('Zoom into the desired portion of the graph and hit enter when ready.');
   pause;
   zoom off;
   hold on;
   RangeLim = get(gca, 'XLim');
   SignalLim = get(gca,'YLim');
   DisplayRange = find((range>=RangeLim(1)) & (range<=RangeLim(2)));
   disp('Select the range of values to use in the line fit by clicking the beginning and ending points...')
   points = zeros(2);
   points = ginput(2);
   fitrange = find((range>=min(points(:,1))) & (range<=max(points(:,1))));
   if length(fitrange) == 0
      disp('No points were within the two clicks.  Try again?');
   else
      coef = polyfit(range(fitrange), real(log(signal(fitrange))),1);
      testfit = polyval(coef, range([DisplayRange]));
%      testfit = coef(1)*range([DisplayRange]) + coef(2);
      plot(range(DisplayRange), testfit,'r');
      okay = input('Is this okay?  Is so, hit a "Y".  Otherwise, we start over..   .','s');
      okay = upper(okay);
      if okay == 'Y' 
         done = 1;
      end;
   end;
end;
%subrange=[min(DisplayRange):min(fitrange)+2 ];
subrange=[min(DisplayRange):max(fitrange) ];
corr = zeros(length(subrange),2);
corr(:,1) =[range(subrange)];
corr(:,2) = testfit(subrange) - real(log(signal(subrange)));
too_big = find((corr(:,2)>=10));
corr(too_big,2) = zeros(size(corr(too_big,2)));
corr(:,2) = exp(corr(:,2));

[fname, pname] = putfile('overlap.dat','overlap');
if pname~=0
 % eval(['save ', pname, fname, ' corr -ascii'])
  save([pname, fname], 'corr', '-ASCII')
end
