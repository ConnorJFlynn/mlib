function [Vo,tau,Vo_, tau_, good] = dbl_lang(airmass,V,stdev_mult,Ntimes,steps,show, title_2)
% [Vo,tau,Vo_, tau_, good] = dbl_lang(airmass,V,stdev_mult,Ntimes,steps,show, title_2);
% Sequential application of standard and unweighted langley with outlier rejection via Schmid maxabs
% Usable for refined Langley by multiplying V by exp(tau_g.*m)
% Usable for tau-langley by multiplying airmass by tau
% required: airmass, V
% optional: stdev_mult, default=2.5.  Larger value is less stringent
% optional: steps, default=1, number of outliers to remove per iteration.
% optional: Ntimes, default = 10, minimum number of distinct times for a valid Langley
% Larger is faster but less robust
% show = 0, don't show any plots
% show = 1, show only last plot
% show = 2, show all plots, i.e. "really" show.
% output: Vo, tau TOA and tau from Langley
% output: Vo_, tau_: TOA and tau from unweighted Langley
%
% Need a graceful exit for failure
% 2022-10-14, CJF: handled several failure modes relating to Vo, dev, val not being
% assigned unless there were enough good values, and also caught instances of there
% being no good values and so those related fields being missing.
% 2022-10-15, CJF: Eliminate the unweighted plot, it adds no value.  

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
if ~isavar('steps')||isempty(steps)
   steps=1;
end
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
Vo = NaN; tau = NaN; Vo_=NaN; tau_=NaN; 
dev = NaN(size(airmass)); sdev = NaN; mad = NaN;
dev_ = NaN(size(airmass)); sdev_ = NaN; mad_ = NaN;
val = NaN; val_ = NaN; P = NaN; P_ = NaN;
while ~done
   goods = sum(good);
   if goods>Ntimes
      [P] = polyfit(airmass(good)',logV(good)',1);
      dev(good) =  (logV(good) - polyval(P, airmass(good)));
      sdev = std(dev(good));
      tau = -P(1);
      Vo = exp(polyval(P,0));
      mad = max(abs(dev(good)));

      [P_] = polyfit(1./airmass(good), real(logV(good))./airmass(good), 1);
      dev_(good) =  (real(logV(good))./airmass(good) - polyval(P_, 1./airmass(good)));
      sdev_ = std(dev_(good));
      Vo_ = exp(P_(1));
      y_int = polyval(P_, 0);
      tau_ = -y_int;
      mad_ = max(abs(dev_(good)));
   end
   time_test = Ntimes > sum(good); 
   time_test = ~isempty(time_test)&&time_test;
   val = max(abs(dev(good)))/sdev;
   test = ~isempty(val)&&(val<stdev_mult)||(sdev<1e-12); 
   test = ~isempty(test)&&test;
   val_ = max(abs(dev_(good)))/sdev_;
   test_ = ~isempty(val_)&&(val_<stdev_mult)||(sdev_<1e-12);
   test_ = ~isempty(test_)&&test_;

   done = (test && test_)||time_test;
   if show==2 % show ALL plots
      scatter(ax(1),airmass(good), V(good), 25,abs(dev(good))/sdev);colorbar;
      logy(ax(1));
      %    semilogy(airmass(good), V(good),'.');
      title_str = ['goods=',num2str(goods),...
         ' std=',sprintf('%0.3g',sdev),...
         ' val=',sprintf('%0.3g',val),...
         ' Vo=',sprintf('%0.3g',Vo),...
         ' tau=',sprintf('%0.3g',tau)];
      if isavar('title_2') title_str = {title_2;title_str}; end
      title(ax(1),title_str);
      % semilogy(airmass(good), V(good), 'g.',airmass(~good), V(~good), 'rx', airmass, exp(polyval(P, airmass)),'b');
      hold(ax(1),'on');
      plot(ax(1), airmass(good), exp(polyval(P, airmass(good))),'r');
      hold(ax(1),'off');
      

%       scatter(ax(2),1./airmass(good), real(logV(good))./airmass(good), 36,abs(dev_(good))./sdev_);colorbar;
%       %    plot(1./airmass(good), real(logV(good))./airmass(good),'.');
%       
%       title(ax(2),['goods=',num2str(goods),...
%          ' std=',sprintf('%0.3g',sdev_),...
%          ' val=',sprintf('%0.3g',val_),...
%          ' Vo=',sprintf('%0.3g',Vo_),...
%          ' tau=',sprintf('%0.3g',tau_)]);
%       hold(ax(2),'on');
%       plot(ax(2), 1./airmass(good), polyval(P_, 1./airmass(good)),'r');
%       hold(ax(2),'off');
       set(ax(1),'position',pos_1,'outerposition',outer_1);
%       set(ax(2),'position',pos_2,'outerposition',outer_2);
       pause(.1);
   end
   if ~done
      for s = 1:steps
         good(good) = abs(dev(good))<mad;
         goods = sum(good);
         mad_ = max(abs(dev_(good)));
         good(good) = abs(dev_(good))<mad_;
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
      ' Vo=',sprintf('%0.3g',Vo), ' tau=',sprintf('%0.3g',tau)];
   if isavar('title_2') title_str = {title_2;title_str}; end
   title(title_str);
   % semilogy(airmass(good), V(good), 'g.',airmass(~good), V(~good), 'rx', airmass, exp(polyval(P, airmass)),'b');
   hold('on');
   plot( airmass(good), exp(polyval(P, airmass(good))),'r')
   hold('off');
   
%    ax(2) = subplot(2,1,2);
%    if ~any(isnan(dev_))&&~isnan(sdev_)
%       scatter(1./airmass(good), real(logV(good))./airmass(good), 36,abs(dev_(good))./sdev_);colorbar;
%    else
%       plot(1./airmass(good), real(logV(good))./airmass(good), 'o');colorbar;
%    end
%    %    plot(1./airmass(good), real(logV(good))./airmass(good),'.');
%    
%    title(['goods=',num2str(goods),...
%       ' std=',sprintf('%0.3g',sdev_),...
%       ' val=',sprintf('%0.3g',val_),...
%       ' Vo=',sprintf('%0.3g',Vo_),...
%       ' tau=',sprintf('%0.3g',tau_)]);
%    hold('on');
%    plot( 1./airmass(good), polyval(P_, 1./airmass(good)),'r');
%    hold('off');
   pause(.1);
end
return
