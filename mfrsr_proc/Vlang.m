function [Vo, good] = Vlang(airmass,V,stdev_mult,Ntimes,kicks,show, title_2)
% [Vo, good] = Vlang(airmass,V,stdev_mult,Ntimes,kicks,show, title_2);
% Iterative regression of "Vo" vs airmass with outlier rejection via Schmid maxabs
% required: airmass, V
% optional: stdev_mult, default=2.5.  Larger value is less stringent
% optional: kicks, default=1, number of outliers to remove per iteration.
% optional: Ntimes, default = 10, minimum number of distinct times for a valid Langley
% Larger is faster but less robust
% show = 0, don't show any plots
% show = 1, show only last plot
% show = 2, show all plots, i.e. "really" show.
% output: Vo, good
% 2023-02-27, CJF: Created to pin SASHe to TOD from external sources. 

% To do: Make the exit tests less complicated
% Consider how to discard airmass outliers. Edge values that dominate the slope
% Perhaps a distance test comparing distance from each point to the mean.
% Sort this distance and discard the most distant points if they are too sparse
% compared to the mean distance.  This would be done _before_ computing the fits and
% discarding statistical outlier from the fit
% And on exist set Vo to NaN if Vo or tau are <=0. 

good = true(size(airmass));
% good_ = good;
goods = sum(good);
if ~isavar('stdev_mult')||isempty(stdev_mult)
   stdev_mult=2.5;
end
if ~isavar('kicks')||isempty(kicks)
   kicks=1;
end
kicks = max([kicks, 1]);
if ~isavar('Ntimes')||isempty(Ntimes)
   Ntimes=10;
end
if ~isavar('show')||(show<1)
   show = 0;
end
if ~isavar('title_2')
   title_2 = [];
end
done = length(airmass)<Ntimes;
logV = real(log(V)); 
if show>0
   fig = figure(1004);
   ax(1) = subplot(1,1,1);title('temp');
%    ax(2) = subplot(2,1,2);title('temp');
   outer_1 = get(ax(1),'OuterPosition');
   pos_1 = get(ax(1),'Position');
%    outer_2 = get(ax(2),'OuterPosition');
%    pos_2 = get(ax(2),'Position');
%    fig_pos = [22   357   560   420];
%    set(fig,'position',fig_pos);
end
Vo = NaN; 
dev = NaN(size(airmass)); sdev = NaN; mad = NaN;
val = NaN; P = NaN; 
while ~done
   goods = sum(good);
   if goods>Ntimes
      [P] = polyfit(airmass(good)',logV(good)',1);
      dev(good) =  (logV(good) - polyval(P, airmass(good)));
      sdev = std(dev(good));
      Vo = exp(polyval(P,0));
      mad = max(abs(dev(good)));
   end
   time_test = Ntimes > sum(good); 
   time_test = ~isempty(time_test)&&time_test;
   val = max(abs(dev(good)))/sdev;
   test = ~isempty(val)&&(val<stdev_mult)||(sdev<1e-12); 
   test = ~isempty(test)&&test;

   done = test ||time_test;
   if show==2 % show ALL plots
      scatter(ax(1),airmass(good), V(good), 25,abs(dev(good))/sdev);colorbar;
      logy(ax(1));
      %    semilogy(airmass(good), V(good),'.');
      title_str = ['goods=',num2str(goods),...
         ' std=',sprintf('%0.3g',sdev),...
         ' val=',sprintf('%0.3g',val),...
         ' Vo=',sprintf('%0.3g',Vo)];
      if isavar('title_2') title_str = {title_2;title_str}; end
      title(ax(1),title_str);
      % semilogy(airmass(good), V(good), 'g.',airmass(~good), V(~good), 'rx', airmass, exp(polyval(P, airmass)),'b');
      hold(ax(1),'on');
      plot(ax(1), airmass(good), exp(polyval(P, airmass(good))),'r');
      hold(ax(1),'off');
      
       set(ax(1),'position',pos_1,'outerposition',outer_1);
%       set(ax(2),'position',pos_2,'outerposition',outer_2);
%        pause(.1);
   end
   if ~done
      for s = 1:kicks
         good(good) = abs(dev(good))<mad;
%          good(good) = (dev(good))<mad;
         goods = sum(good);
         mad = max(abs(dev(good)));
      end
   end
end
if show>0
%    ax(1) = subplot(2,1,1);
   if ~any(isnan(dev))&&~isnan(sdev)
      scatter(airmass(good), V(good), 25,abs(dev(good))/sdev);colorbar;
   else
      plot(airmass(good), V(good), 'o');
   end
   logy;
   %    semilogy(airmass(good), V(good),'.');
   title_str = ['goods=',num2str(goods),' std=',sprintf('%0.3g',sdev),' val=',sprintf('%0.3g',val),...
      ' Vo=',sprintf('%0.3g',Vo)];
   if isavar('title_2') title_str = {title_2;title_str}; end
   title(title_str);
   % semilogy(airmass(good), V(good), 'g.',airmass(~good), V(~good), 'rx', airmass, exp(polyval(P, airmass)),'b');
   hold('on');
   plot( airmass(good), exp(polyval(P, airmass(good))),'r')
   hold('off');
   
%    menu('OK','OK')
end
return
