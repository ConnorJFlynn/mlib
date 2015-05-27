load('C:\case_studies\tnmpl\day_mat\tnmplzen.2006_09_16.dat.mat')
%%
zen_0 = mplz_day.hk.zenith <20;
zen_45 = mplz_day.hk.zenith >20 &  mplz_day.hk.zenith <50;
zen_75 = mplz_day.hk.zenith >72 &  mplz_day.hk.zenith <78;
zen_85 = mplz_day.hk.zenith >84.5 &  mplz_day.hk.zenith <85.5;
zen_90  =  mplz_day.hk.zenith >89 & mplz_day.hk.zenith <91;
zen_90p  =  mplz_day.hk.zenith >91;
dark = mplz_day.hk.bg < 2e-2;

%% This section used to determine which profiles (at various angles) are
%% unblocked and so useful for fitting.
figure; semilogy(mplz_day.range,(mplz_day.prof(:,dark&zen_45)),'c-'); 
%%
sub_r = mplz_day.range>12 & mplz_day.range<15;
sky = 10.^mean(real(log10(mplz_day.prof(sub_r,:))),1)>=1 ;
figure; semilogy(mplz_day.range,(mplz_day.prof(:,dark&zen_45))./((mplz_day.range.^2)*ones([1,length(find(dark&zen_45))])),'c-',...
mplz_day.range,(mplz_day.prof(:,dark&zen_45&sky))./((mplz_day.range.^2)*ones([1,length(find(dark&zen_45&sky))])),'k-'); 
%%
% Initial idea is to apply existing overlap "tnmpl_col_ol2" derived from
% vertical profile on Sept 16.  
% Then compare the resulting profiles to a slant attenprof, forming the
% ratio and fitting the result below some near range.
% Not sure yet how we'll get horizontal but maybe just from the slope of
% the log-scale plot?  I think this is independent of the profile units.

% if sum(sky&zen_0&dark)>10

molec = std_ray_atten(mplz_day.range);
[T,P] = std_atm(mplz_day.range.* cos(75.*pi/180));
%Then, with the TP profs, call ray_a_b(T,P) for Rayleigh alpha and beta.
[alpha_R, beta_R] = ray_a_b(T,P);
height = mplz_day.range .* cos(75.*pi/180);
prof_prime = slant_attenprof(height, alpha_R, beta_R, mplz_day.range , cos(75.*pi/180));
pbl = .5e-3 .* exp(-mplz_day.range./2.5);
pin_val = 10.^(mean(real(log10(molec(sub_r)+pbl(sub_r))))-mean(real(log10(mean(mplz_day.prof(sub_r,sky&zen_0&dark),2)))));
pin_val2 = 10.^(mean(real(log10(prof_prime(sub_r)+pbl(sub_r))))-mean(real(log10(mean(mplz_day.prof(sub_r,sky&zen_75&dark),2)))));
%%
figure; lines = semilogy(mplz_day.range, mplz_day.prof(:,sky&zen_0&dark),'-'); lines = recolor(lines,serial2doy(mplz_day.time(sky&dark&zen_0)));
%%
figure; semilogy(mplz_day.range, molec+pbl,'.r-',mplz_day.range, pin_val .* mean(mplz_day.prof(:,sky&zen_0&dark),2),'b-'); 
title([datestr(mplz_day.time(1),'mmm dd, yyyy'),'  ',datestr(mplz_day.time(1),'yyyy/mm/dd')],'interp','none')
%%
figure; semilogy(mplz_day.range, prof_prime+pbl,'.r-',mplz_day.range, pin_val2 .* mean(mplz_day.prof(:,sky&zen_75&dark),2),'b-'); 
title(['slant path: ',datestr(mplz_day.time(1),'mmm dd, yyyy'),'  ',datestr(mplz_day.time(1),'yyyy/mm/dd')],'interp','none')
%%

figure; semilogy(mplz_day.range, (molec+pbl) ./ (pin_val .* mean(mplz_day.prof(:,sky&zen_0&dark),2)),'k-'); 
title([datestr(mplz_day.time(1),'mmm dd, yyyy'),'  ',datestr(mplz_day.time(1),'yyyy/mm/dd')],'interp','none')

figure; semilogy(mplz_day.range, mean(mplz_day.prof(:,sky&zen_0&dark),2)./(mplz_day.range.^2),'g-'); 
title([datestr(mplz_day.time(1),'mmm dd, yyyy'),'  ',datestr(mplz_day.time(1),'yyyy/mm/dd')],'interp','none')
%%

figure; semilogy(mplz_day.range, molec,'.r-',mplz_day.range, pin_val .* mean(mplz_day.prof(:,sky&zen_0&dark),2).*(tnmpl_col_ol2(mplz_day.range).^1),'b-'); 
title([datestr(mplz_day.time(1),'mmm dd, yyyy'),'  ',datestr(mplz_day.time(1),'yyyy/mm/dd')],'interp','none')
%%
figure; semilogy(mplz_day.range, prof_prime+pbl,'.r-',mplz_day.range, pin_val2 .* mean(mplz_day.prof(:,sky&zen_75&dark),2).*(tnmpl_col_ol2(mplz_day.range).^1),'b-'); 
title([datestr(mplz_day.time(1),'mmm dd, yyyy'),'  ',datestr(mplz_day.time(1),'yyyy/mm/dd')],'interp','none')
%%
xlim([0,20]);
ylim(yl);
xlabel('range [km]')
ylabel('attn. backscatter')
%%
% else
%    disp(['Not enough valid points for ',datestr(mplz_day.time(1),'mmm dd, yyyy')])
% end
%
