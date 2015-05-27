% shadow find

%%
clear
plots_ppt;
find_zen_path =  ['C:\case_studies\ARRA\SAS\testing_and_characterization\find_zenith'];
find_zen_path =  ['C:\case_studies\ARRA\SAS\testing_and_characterization\find_zenith\2010_8_19\'];
find_zen_path =  ['C:\case_studies\ARRA\SAS\testing_and_characterization\find_zenith\2010_8_20\'];
[this,fname] = loadinto(find_zen_path);
%%
band.fname = fname;
band.deg = mod(this(:,1)+0,360);
[band.deg,inds]  = sort(band.deg);
band.cts = this(:,2);
band.cts = band.cts(inds);
wind = 15;
band.filt_deg = filter(ones(1,wind)/wind,1,band.deg);
band.filt_cts = filter(ones(1,wind)/wind,1,band.cts);
tmp = band.filt_cts-min(band.filt_cts);
band.filt_norm = tmp./max(tmp);
band.df_dd = diff(band.filt_norm)./diff(band.filt_deg);
band.deg_dd = band.filt_deg(2:end) +(band.filt_deg(2)-band.filt_deg(1))./2;

% figure; plot(band.filt_deg, band.filt_norm,'r-')

%%
s = wind;
while band.filt_norm(s)>.75
   s = s+1;
end
%%
ss = s;
while band.filt_deg(ss) > (band.filt_deg(s)-5)
   ss = ss-1;
end
%%
while band.filt_norm(s)<=.75
   s = s+1;
end
%%
t = s;
while band.filt_deg(t) < (band.filt_deg(s)+5)
   t = t+1;
end
shade_1 = [ss:t];
%%
s = t;
while band.filt_norm(s)>.75
   s = s+1;
end
%%
ss = s;
while band.filt_deg(ss) > (band.filt_deg(s)-5)
   ss = ss-1;
end
%%
while band.filt_norm(s)<=.75
   s = s+1;
end
%%
t = s;
while band.filt_deg(t) < (band.filt_deg(s)+5)
   t = t+1;
end
%%
shade_2 = [ss:t];
%%


% Find edge of shade 1


[shade_1_falling, shade_1_falling_i] = min(band.df_dd(shade_1));
[shade_1_rising, shade_1_rising_i] = max(band.df_dd(shade_1));
shade_1_middle = mean(band.deg_dd(shade_1([shade_1_falling_i,shade_1_rising_i])));
%%
[shade_2_falling, shade_2_falling_i] = min(band.df_dd(shade_2));
[shade_2_rising, shade_2_rising_i] = max(band.df_dd(shade_2));
shade_2_middle = mean(band.deg_dd(shade_2([shade_2_falling_i,shade_2_rising_i])));

shade_2_minus_shade_1 = shade_2_middle - shade_1_middle

%%
% This time define shade edges according to a quadratic fit to the inner
% half of the derivative.
peak_deriv = max(abs(band.df_dd(shade_1)));
neg_bell =  band.df_dd(shade_1)<(-0.5.*peak_deriv);
shade_1_neg_P = polyfit(band.deg_dd(shade_1(neg_bell)),band.df_dd(shade_1(neg_bell)),2);
shade_1_neg_P_prime = [2.*shade_1_neg_P(1), shade_1_neg_P(2)];
shade_1_left_mid = -shade_1_neg_P_prime(2)./shade_1_neg_P_prime(1);
pos_bell =  band.df_dd(shade_1)>(0.5.*peak_deriv);
shade_1_pos_P = polyfit(band.deg_dd(shade_1(pos_bell)),band.df_dd(shade_1(pos_bell)),2);
shade_1_pos_P_prime = [2.*shade_1_pos_P(1), shade_1_pos_P(2)];
shade_1_right_mid = -shade_1_pos_P_prime(2)./shade_1_pos_P_prime(1);
shade_1_center = (shade_1_right_mid + shade_1_left_mid)./2;

% Now for the second shadow
peak_deriv = max(abs(band.df_dd(shade_2)));
neg_bell =  band.df_dd(shade_2)<(-0.5.*peak_deriv);
shade_2_neg_P = polyfit(band.deg_dd(shade_2(neg_bell)),band.df_dd(shade_2(neg_bell)),2);
shade_2_neg_P_prime = [2.*shade_2_neg_P(1), shade_2_neg_P(2)];
shade_2_left_mid = -shade_2_neg_P_prime(2)./shade_2_neg_P_prime(1);
pos_bell =  band.df_dd(shade_2)>(0.5.*peak_deriv);
shade_2_pos_P = polyfit(band.deg_dd(shade_2(pos_bell)),band.df_dd(shade_2(pos_bell)),2);
shade_2_pos_P_prime = [2.*shade_2_pos_P(1), shade_2_pos_P(2)];
shade_2_right_mid = -shade_2_pos_P_prime(2)./shade_2_pos_P_prime(1);
shade_2_center = (shade_2_right_mid + shade_2_left_mid)./2;

shade_2_center_minus_shade_1_center = shade_2_center - shade_1_center;
%%
figure; s(1) = subplot(2,1,1); plot(band.filt_deg ,band.filt_norm,'.-',...
   band.filt_deg(shade_1), band.filt_norm(shade_1),'x',...
   band.filt_deg(shade_2), band.filt_norm(shade_2),'x',...
   [shade_1_middle,shade_1_middle],[-.2,1.2],'k:',...
   [shade_2_middle,shade_2_middle],[-.2,1.2],'k:',...
   [shade_1_center,shade_1_center],[-.2,1.2],'r--',...
   [shade_2_center,shade_2_center],[-.2,1.2],'r--');
[pn,fnm,ext] = fileparts(fname);
title(fnm);
grid('on');
s(2) = subplot(2,1,2); plot(band.deg_dd(shade_1), band.df_dd(shade_1),'-o',...
  band.deg_dd(shade_2), band.df_dd(shade_2),'-o');
yl = ylim;
ylim(1.5*yl);
tl = title({['shade_1_mid:',sprintf('%2.3f',(shade_1_middle)),'  shade_2_mid:',sprintf('%2.3f',(shade_2_middle))];...
   ['shade_1_cen:',sprintf('%2.3f',(shade_1_center)),'  shade_2_cen:',sprintf('%2.3f',(shade_2_center))];...
   ['sep_1:',sprintf('%2.3f',(shade_2_minus_shade_1)),'  sep_2:',sprintf('%2.3f',(shade_2_center_minus_shade_1_center))]});
set(tl,'interp','none')
grid('on')
linkaxes(s,'x');
%%
x = [-5,0,5]; y = [175.948, 185.415, 195.090];
X_zen_1 = (180-y(1))*(x(2)-x(1))/(y(2)-y(1)) +x(1)
X_zen_3 = (180-y(3))*(x(2)-x(3))/(y(2)-y(3)) +x(3)
