function [good, Vo,tau,Vo_, tau_,settings, final_stats] = multi_lang(in_data,tests,show);
% [good, Vo,tau,Vo_, tau_,settings, final_stats] = multi_lang(in_data,tests,show);
% Sequential application of standard and unweighted langley with Thompson
% iterative outlier rejection via Schmid until all test conditions are met
% Attempts to bracket physically reasonable Vo to avoid sub-Rayleigh and
% ginourmous tau.
% in_data.time, required
% in_data.V, required
% in_data.airmass, required
% in_data.lambda_nm, required
% in_data.Vo (missing may be empty, <= 0, inf, or NaN)
% tests.stdev_mult (default 2.5, lower is more stringent)
% tests.steps (number of outliers to discard, default is 5, larger is
% faster but less robust
% tests.Ntimes (minimum number of records to accept as valid Langley)
% tests.tau_max ()
% tests.prescreen struct
%  prescreen.on = true (false) (may someday support setting any of the aod screen
% parameters with this struct)
% show = 0, don't show any plots
% show = 1, show only final plot
% show = 2, show plot of running results
% Added min and max test for Io and tau
% output: good (boolean of in_data length) is the main output
% output: Vo, tau TOA and tau from Langley
% output: Vo_, tau_: TOA and tau from unweighted Langley
%
% show (0 = no plots, 1 = final plot only, 2 = running plots of progress)
if ~isfield(in_data,'Vo')||isempty(in_data.Vo)||(in_data.Vo<=0)||isinf(in_data.Vo)
   Vo = [];
else
   Vo = in_data.Vo;
end
if ~exist('tests','var')||isempty(tests)
   tests.stdev_mult=3.5;
   tests.steps = 10;
   tests.Ntimes = 50;
   tests.tau_max = 1;
   tests.prescreen.on = false;
   tests.std_max = 3e-3;
   tests.min_am_span = 1;
end
if isfield(tests,'std_max')
   std_max = tests.std_max;
else
   std_max = 3e-3;
end
if isfield(tests,'min_am_span')
   min_am_span = tests.min_am_span;
else
   min_am_span = 1;
end
if isfield(tests,'max_tau')
   tau_max = tests.tau_max;
else
   tau_max = 1;
end
settings = tests;
% settigns.stdev_mult=tests.stdev_mult;
% settigns.steps = steps;
% settigns.Ntimes = Ntimes;
settings.tau_max = tau_max;
% settigns.prescreen =prescreen;
settings.std_max = std_max;
settings.min_am_span = min_am_span;

if isfield(tests,'prescreen')
   prescreen = tests.prescreen;
end
if ~exist('prescreen','var')||~isfield(prescreen,'on')
   prescreen.on = false;
end;
if ~exist('show','var')||(show<1)
   show = 0;
end
if show>0
   if prescreen.on
      fig1 = figure(1001);
      set(fig1,'position',[121   349   560   420]);
   end
%    fig2 = figure(1005);
%    set(fig2,'position',[733   351   560   420]);
end
Vos = NaN(size(in_data.time));
TOD = NaN(size(in_data.time));
aero = false(size(in_data.time));

% good_ii = find(good);

tau_ray = tau_std_ray_atm(in_data.lambda_nm/1000);
atm = 1; 
if isfield(in_data,'press_hPa')&&in_data.press_hPa>10
    atm = (in_data.press_hPa./1013);
end
if (atm >.01 & atm<1 )|(atm>1&atm<1.1)
    tau_ray = tau_ray .*atm;
end
    tr_ray = exp(-tau_ray.*in_data.airmass);
   

% Divide by Rayleigh transmittances to obtain "refined" Langley
%     in_data.V = in_data.V./tr_ray; 

good = isfinite(in_data.V)&(in_data.V>0)&(~isNaN(in_data.V))&in_data.airmass>=1;
if isfield(in_data,'good')&&all(size(good)==size(in_data.good))
    good = good&in_data.good;
end
Vos(good) = exp(tau_ray.*in_data.airmass(good)).*in_data.V(good);% Legacy from non-refined
% Vos(good) = in_data.V(good);
% figure; plot(airmass(good), Vos(good), '.')
Vo_ray = max([Vo,Vos(good)]);
% Preliminary TOD assuming Vo_ray is true, used only for prescreen
TOD(good)= log(Vo_ray./in_data.V(good))./in_data.airmass(good); 
% Vos(good) = exp(tau_max.*in_data.airmass(good)).*in_data.V(good);
% Vo_max = min(Vos(good));

if prescreen.on
   %Now we have a trial total optical depth TOD, so gently screen with aod_screen.
   prescreen.max_tau = 2; prescreen.pre_window = 5; prescreen.mads_thresh = .5; ;
   prescreen.eps_thresh = 1e-1; prescreen.eps_window = 5; prescreen.post_window = 15;
   prescreen.base_tau = tau_ray./2;
   [aero(good), eps, aero_eps, mad, abs_dev] = ...
      aod_screen(in_data.time(good), TOD(good),tau_ray, prescreen.max_tau,prescreen.pre_window, ...
      prescreen.mads_thresh, prescreen.eps_thresh, prescreen.eps_window, prescreen.post_window, ...
      prescreen.base_tau);
   if show>0
      figure(1001); ax(1)=subplot(2,1,1); plot(in_data.time-in_data.time(1), TOD, 'k.',...
         in_data.time(good)-in_data.time(1), TOD(good),'r.',in_data.time(aero)-in_data.time(1), TOD(aero),'g.');
      xlabel('time (days)');
      ylabel('tau');
      title(['Retained ', num2str(sum(aero)),' of ',num2str(length(aero)), ' values.'])
      ax(2)=subplot(2,1,2); plot(in_data.airmass, TOD, 'k.', in_data.airmass(good), TOD(good), 'r.', in_data.airmass(aero), TOD(aero), 'g.');
      xlabel('airmass')
      ylabel('tau');
      linkaxes(ax,'y');zoom('on');
      fig2 = figure(1005);
      set(fig2,'position',[733   351   560   420]);
      figure(fig2);
   end
   % Now conduct double-langley part
   good = aero;
end
% good(aero) = true;
% good_ = good;
goods = sum(good);
done = false;
logV = real(log(in_data.V));
if sum(good)>=tests.Ntimes
      only_am_test = 0;
      only_std_test = 0;
      only_std_test_uw = 0;
      only_val_test = 0;
      only_val_test_uw = 0;
      only_tau_test = 0;
      only_tau_test_uw = 0;
      only_Vo_test = 0;
      only_Vo_test_uw = 0;
      only_val_tests = 0;
      only_tau_tests = 0;
      only_Vo_tests = 0;
   only_std_tests = 0;
   while ~done
      %       tau_ray = tau_std_ray_atm(in_data.lambda_nm/1000);
      % Vos(good) = exp(tau_ray.*in_data.airmass(good)).*in_data.V(good);
      % figure; plot(airmass(good), Vos(good), '.')
      % Vo_ray = max([Vo,Vos(good)]);
      % TOD(good)= log(Vo_ray./in_data.V(good))./in_data.airmass(good);
%       Vos(good) = exp(tau_max.*in_data.airmass(good)).*in_data.V(good);
%       Vo_max = min(Vos(good));
      goods = sum(good);
      [P] = polyfit(in_data.airmass(good)',logV(good)',1);
      dev(good) =  (polyval(P, in_data.airmass(good))-logV(good));
      sdev = std(dev(good));
      tau = -P(1);
      Vo = exp(polyval(P,0));
      mad = max(abs(dev(good)));
%       mad = max((dev(good)));
      
      %    SS_tot = sum((logV(good)-mean(logV(good)).^2));
      %    SS_err = sum((logV(good)-polyval(P,airmass(good))).^2);
      %    R2 = 1 - SS_err./SS_tot;
      
      [P_] = polyfit(1./in_data.airmass(good), real(logV(good))./in_data.airmass(good), 1);
      dev_(good) =  (polyval(P_, 1./in_data.airmass(good))-real(logV(good))./in_data.airmass(good));
      sdev_ = std(dev_(good));
      Vo_ = exp(P_(1));
      y_int = polyval(P_, 0);
      tau_ = -y_int;
      mad_ = max(abs(dev_(good)));
%       mad_ = max((dev_(good)));      
      %    SS_tot_uw = sum((real(logV(good))./airmass(good)-mean(real(logV(good))./airmass(good)).^2));
      %    SS_err_uw = sum((real(logV(good))./airmass(good)-polyval(P_,1./airmass(good))).^2);
      %    R2_uw = 1 - SS_err_uw./SS_tot_uw;
      
      N_test = tests.Ntimes > sum(good);
      am_span = max(in_data.airmass(good))-min(in_data.airmass(good));
      am_test = am_span>min_am_span;
      std_test = sdev<std_max;
      std_test_uw = sdev_<std_max;
      val = max(abs(dev(good)))/sdev;
      val_test = val<tests.stdev_mult;
      val_ = max(abs(dev_(good)))/sdev_;
      val_test_uw = val_<tests.stdev_mult;
      tau_test = ((tau>.5*tau_ray)||((tau+0.03)>tau_ray))&&(tau<tau_max);
      tau_test_uw = ((tau_>.5*tau_ray)||((tau_+0.03)>tau_ray))&&(tau_<tau_max);
%       tau_test_uw = ((tau_+.01)>tau_ray)&&(tau_<tau_max);
      Vo_test = (Vo > 0.95.*Vo_ray);%&&(Vo < Vo_max);
      Vo_test_uw = (Vo_ > 0.95.*Vo_ray);%&&(Vo_ < Vo_max);
       if show==2
         ax(1) = subplot(3,1,1);
         scatter(in_data.airmass(good), in_data.V(good), 5,abs(dev(good))/sdev);colorbar;
         logy;
         %    semilogy(airmass(good), V(good),'.');
         title(['goods=',num2str(goods),...
            ' val=',sprintf('%0.4g',val),...
            ' Vo=',sprintf('%0.4g',Vo),...
            ' tau=',sprintf('%0.4g',tau)]);
         % semilogy(airmass(good), V(good), 'g.',airmass(~good), V(~good), 'rx', airmass, exp(polyval(P, airmass)),'b');
         hold('on');
         plot( in_data.airmass(good), exp(polyval(P, in_data.airmass(good))),'r')
         hold('off');
         
         ax(2) = subplot(3,1,2);
         scatter(1./in_data.airmass(good), real(logV(good))./in_data.airmass(good), 6,abs(dev_(good))./sdev_);colorbar;
         %    plot(1./airmass(good), real(logV(good))./airmass(good),'.');
         
         title(['goods=',num2str(goods),...
            ' val=',sprintf('%0.4g',val_),...
            ' Vo=',sprintf('%0.4g',Vo_),...
            ' tau=',sprintf('%0.4g',tau_)]);
         hold('on');
         plot( 1./in_data.airmass(good), polyval(P_, 1./in_data.airmass(good)),'r');
         hold('off');
         subplot(3,1,3); 
         plot([1,1],[0,double(std_test)],'-o',[2,2],[0,double(std_test_uw)],'-o',...
             [3,3],[0,double(val_test)],'-o',[4,4],[0,double(val_test_uw)],'-o', ...
             [5,5],[0,double(val_test)],'-o',[6,6],[0,double(tau_test_uw)],'-o', ...
             [7,7],[0,double(Vo_test)],'-x',[8,8],[0,double(Vo_test_uw)],'-x', ...
             [9,9],[0,double(am_test)],'-x'); legend('std','std uw','val','val uw','tau','tau uw','Vo','Vo uw','am','location','eastoutside')
         pause(.1);
      end
      % Identify which tests dominate:
      only_std_test = only_std_test + single((am_test && std_test_uw && val_test_uw && tau_test &&tau_test_uw && Vo_test && Vo_test_uw)&&~std_test);
      only_std_test_uw = only_std_test_uw + single((am_test && std_test && val_test_uw && tau_test &&tau_test_uw && Vo_test && Vo_test_uw)&&~std_test_uw);
      only_val_test = only_val_test + single((am_test && std_test && std_test_uw && val_test_uw && tau_test &&tau_test_uw && Vo_test && Vo_test_uw)&&~val_test);
      only_val_test_uw = only_val_test_uw + single((am_test && std_test && std_test_uw && val_test && tau_test &&tau_test_uw && Vo_test && Vo_test_uw)&& ~val_test_uw);
      only_tau_test = only_tau_test + single((am_test && std_test && std_test_uw && val_test && val_test_uw &&tau_test_uw && Vo_test && Vo_test_uw)&& ~tau_test );
      only_tau_test_uw = only_tau_test_uw + single((am_test && std_test && std_test_uw && val_test && val_test_uw && tau_test && Vo_test && Vo_test_uw) &&~tau_test_uw);
      only_Vo_test = only_Vo_test + single((am_test && std_test && std_test_uw && val_test && val_test_uw && tau_test &&tau_test_uw && Vo_test_uw)&& ~Vo_test );
      only_Vo_test_uw = only_Vo_test_uw + single((am_test && std_test && std_test_uw && val_test && val_test_uw && tau_test &&tau_test_uw && Vo_test)&& ~Vo_test_uw);
      only_am_test = only_am_test + single((std_test && std_test_uw && val_test && val_test_uw && tau_test &&tau_test_uw && Vo_test&& Vo_test_uw)&& ~am_test);

      only_std_tests = only_std_tests + single((val_test && val_test_uw &&tau_test &&tau_test_uw && Vo_test && Vo_test_uw)&&(~std_test||~std_test_uw));
      only_val_tests = only_val_tests + single((std_test&& std_test_uw && tau_test &&tau_test_uw && Vo_test && Vo_test_uw)&&(~val_test||~val_test_uw));
      only_tau_tests = only_tau_tests + single((std_test&& std_test_uw &&val_test && val_test_uw && Vo_test && Vo_test_uw)&& (~tau_test||~tau_test_uw));
      only_Vo_tests = only_Vo_tests + single((std_test&& std_test_uw && val_test && val_test_uw && tau_test &&tau_test_uw)&& (~Vo_test|| ~Vo_test_uw)) ;
      
      done = (am_test && std_test && std_test_uw &&val_test && val_test_uw && tau_test &&tau_test_uw && Vo_test && Vo_test_uw)||N_test;

      if ~done
         for s = 1:tests.steps
            good(good) = abs(dev(good))<mad;
            goods = sum(good);
            mad_ = max(abs(dev_(good)));
            good(good) = abs(dev_(good))<mad_;
            goods = sum(good);
            mad = max(abs(dev(good)));
         end
      end
   end
   
   final_stats.Ngood = sum(good);
   final_stats.am_span = am_span;
   final_status.sdev = sdev;
   final_status.sdev_uw = sdev_;
   final_status.mad = max(abs(dev(good)));
   final_status.mad_sdev_ratio = val;
   final_status.mad_uw = max(abs(dev_(good)));
   final_status.mad_sdev_ratio_uw = val_;
   final_status.Vo_agreement = (Vo-Vo_)./min([Vo,Vo_]);
   
   if (show>0)&&(~N_test)
      fig2 = figure(1005);
      set(fig2,'position',[733   351   560   420]);
      figure(fig2);
      ax(1) = subplot(2,1,1);
      scatter(in_data.airmass(good), in_data.V(good), 5,abs(dev(good))/sdev);colorbar;
      logy;
      %    semilogy(airmass(good), V(good),'.');
      title(['goods=',num2str(goods),...
         ' std=',sprintf('%0.3g',sdev),...
         ' val=',sprintf('%0.3g',val),...
         ' Vo=',sprintf('%0.3g',Vo),...
         ' tau=',sprintf('%0.3g',tau)]);
      % semilogy(airmass(good), V(good), 'g.',airmass(~good), V(~good), 'rx', airmass, exp(polyval(P, airmass)),'b');
      hold('on');
      plot( in_data.airmass(good), exp(polyval(P, in_data.airmass(good))),'r')
      hold('off');
      
      ax(2) = subplot(2,1,2);
      scatter(1./in_data.airmass(good), real(logV(good))./in_data.airmass(good), 6,abs(dev_(good))./sdev_);colorbar;
      %    plot(1./airmass(good), real(logV(good))./airmass(good),'.');
      
      title(['goods=',num2str(goods),...
         ' std=',sprintf('%0.3g',sdev_),...
         ' val=',sprintf('%0.3g',val_),...
         ' Vo=',sprintf('%0.3g',Vo_),...
         ' tau=',sprintf('%0.3g',tau_)]);
      hold('on');
      plot( 1./in_data.airmass(good), polyval(P_, 1./in_data.airmass(good)),'r');
      hold('off');
      pause(.1);
   end
   Ngood = sum(good);
else
   Vo = NaN;
   tau = NaN;
   Vo_ = NaN;
   tau_ = NaN;
   Ngood= 0;
   good = false(size(in_data.time));
   if (show>0)&&exist('fig2','var')
      close(fig2);
   end
   final_stats = [];
end
   
return
