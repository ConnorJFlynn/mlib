function [mfr, aero, eps] = fkb_aod_screen(fkb_dir);
%[mfr, aero, eps] = fkb_aod_screen(fkb_dir);
%%
if ~exist('fkb_dir','var')
   fkb_dir = getdir;
end;
fkb_file = dir([fkb_dir, '*.nc']);
%%
tmp = ancload([fkb_dir, fkb_file(1).name]);
%%

figure(1); ax = []; 
ax(1) = subplot(2,1,1);
semilogy(serial2doy(tmp.time), [tmp.vars.total_optical_depth_filter2.data;tmp.vars.total_optical_depth_filter5.data],'.-')
ax(2) = subplot(2,1,2)
plot(serial2doy(tmp.time), [tmp.vars.elevation_angle.data;tmp.vars.azimuth_angle.data],'.-')
legend('elev','airmass')
linkaxes(ax,'x')
% xlim(xl)
%%
mfr.time = tmp.time;
mfr.dims = tmp.dims;
mfr.atts = tmp.atts;
mfr.recdim = tmp.recdim;
mfr.vars.base_time = tmp.vars.base_time;
mfr.vars.time_offset = tmp.vars.time_offset;
mfr.vars.total_optical_depth_filter2 = tmp.vars.total_optical_depth_filter2;
mfr.vars.total_optical_depth_filter5 = tmp.vars.total_optical_depth_filter5;
mfr.vars.elevation_angle = tmp.vars.elevation_angle
mfr.vars.azimuth_angle = tmp.vars.azimuth_angle;

%%
Ios.time = tmp.time(1);
Ios.dims.time = tmp.dims.time;
Ios.dims.time.length = length(fkb_file);
Ios.recdim = tmp.recdim;
Ios.recdim.length = length(fkb_file);
Ios.vars.Io_filter1 = tmp.vars.Io_filter1;
Ios.vars.Io_filter1.dims = tmp.vars.aerosol_optical_depth_filter1.dims;
Ios.vars.Io_filter2 = tmp.vars.Io_filter2;
Ios.vars.Io_filter2.dims = tmp.vars.aerosol_optical_depth_filter2.dims;
Ios.vars.Io_filter3 = tmp.vars.Io_filter3;
Ios.vars.Io_filter3.dims = tmp.vars.aerosol_optical_depth_filter3.dims;
Ios.vars.Io_filter4 = tmp.vars.Io_filter4;
Ios.vars.Io_filter4.dims = tmp.vars.aerosol_optical_depth_filter4.dims;
Ios.vars.Io_filter5 = tmp.vars.Io_filter5;
Ios.vars.Io_filter5.dims = tmp.vars.aerosol_optical_depth_filter5.dims;
Ios.vars.Rayleigh_optical_depth_filter1 = tmp.vars.Rayleigh_optical_depth_filter1;
Ios.vars.Rayleigh_optical_depth_filter2 = tmp.vars.Rayleigh_optical_depth_filter2;
Ios.vars.Rayleigh_optical_depth_filter5 = tmp.vars.Rayleigh_optical_depth_filter5;

for f = 2:length(fkb_file);
tmp = ancload([fkb_dir, fkb_file(f).name]);
   disp(['File ',num2str(f), ' of ', num2str(length(fkb_file))]);
mfr2.time = tmp.time;
mfr2.dims = tmp.dims;
mfr2.atts = tmp.atts;
mfr2.recdim = tmp.recdim;
mfr2.vars.base_time = tmp.vars.base_time;
mfr2.vars.time_offset = tmp.vars.time_offset;
mfr2.vars.total_optical_depth_filter2 = tmp.vars.total_optical_depth_filter2;
mfr2.vars.total_optical_depth_filter5 = tmp.vars.total_optical_depth_filter5;
mfr2.vars.elevation_angle = tmp.vars.elevation_angle
mfr2.vars.azimuth_angle = tmp.vars.azimuth_angle;

mfr = anccat(mfr, mfr2);
Ios.time(f) = tmp.time(1);
Ios.vars.Io_filter1.data(f) = tmp.vars.Io_filter1.data;
Ios.vars.Io_filter2.data(f) = tmp.vars.Io_filter2.data;
Ios.vars.Io_filter3.data(f) = tmp.vars.Io_filter3.data;
Ios.vars.Io_filter4.data(f) = tmp.vars.Io_filter4.data;
Ios.vars.Io_filter5.data(f) = tmp.vars.Io_filter5.data;
end
%%
fkb_out = [fkb_dir,'fkb_new_tau.nc'];
%
mfr.fname = fkb_out;
mfr.clobber = true;
% 
%%
save([fkb_out,'_.mat'],'mfr')
save([fkb_dir,'new_Ios.mat'],'Ios');
%% 
% ancsave(mfr)
% %%
% mfr = loadinto([fkb_out,'_.mat']);
%  Ios = loadinto([fkb_dir,'..',filesep,'new_Ios.mat']);
% %%
% mfr = ancload(fkb_out);
%%
good = mfr.vars.total_optical_depth_filter5.data>0 & mfr.vars.total_optical_depth_filter5.data<1 & ...
   ~((mfr.vars.elevation_angle.data<14)|((mfr.vars.elevation_angle.data<17)&(mfr.vars.azimuth_angle.data>260)));
ii = 0;
v = [ 118.8723  123.9871    0.0259    1.3858];

%%
for x = 1:6
ii = ii+1;
[good(good)] = hmadf_span(mfr.vars.total_optical_depth_filter5.data(good), 15, 2);
sum_good(ii) = sum(good);
disp(num2str(sum(good)));
semilogy(serial2doy(mfr.time),  mfr.vars.total_optical_depth_filter5.data,'r.',serial2doy(mfr.time(good)),  mfr.vars.total_optical_depth_filter5.data(good),'b.'); 
title(['Iterations = ',num2str(ii),'  good = ',num2str(sum(good))])
axis(v)
pause(.125)
end

for d = floor(mfr.time(end)):-1:floor(mfr.time(1))
   disp(['Day ',num2str(d-floor(mfr.time(1)))])
   day = (mfr.time>=d)&(mfr.time<(d+1))&(mfr.vars.total_optical_depth_filter5.data>0)...
      &isfinite(mfr.vars.total_optical_depth_filter5.data);
   if sum(day)>0
   good(day) =post_screen(serial2doy(mfr.time(day)), mfr.vars.total_optical_depth_filter2.data(day), good(day),15,2);
   end
end
semilogy(serial2doy(mfr.time),  mfr.vars.total_optical_depth_filter5.data,'r.',serial2doy(mfr.time(good)),  mfr.vars.total_optical_depth_filter5.data(good),'b.'); 
title(['Iterations = ',num2str(ii),'  good = ',num2str(sum(good))])
axis(v)
pause(.125)
post_good = good;
%%
%repeat about 15 times to cull non-physical high values.
%%
figure; semilogy(serial2doy(mfr.time),  mfr.vars.total_optical_depth_filter5.data,'r.',serial2doy(mfr.time(good)),  mfr.vars.total_optical_depth_filter5.data(good),'b.'); title(['good = ',num2str(sum(good))])
figure; semilogy(serial2doy(mfr.time),  mfr.vars.total_optical_depth_filter2.data,'r.',serial2doy(mfr.time(good)),  mfr.vars.total_optical_depth_filter2.data(good),'g.'); title(['good = ',num2str(sum(good))])

%%
% post_good = false(size(mfr.time));
% for d = floor(mfr.time(end)):-1:floor(mfr.time(1))
%    disp(['Day ',num2str(d-floor(mfr.time(1)))])
%    day = (mfr.time>=d)&(mfr.time<(d+1))&(mfr.vars.total_optical_depth_filter5.data>0)...
%       &isfinite(mfr.vars.total_optical_depth_filter5.data);
%    if sum(day)>0
%    [good(day)] =post_screen(serial2doy(mfr.time(day)), mfr.vars.total_optical_depth_filter2.data(day), good(day),15,4);
%    end
% end
% post_good = good;
% post_good_ii = find(post_good);
% 
% semilogy(serial2doy(mfr.time),  mfr.vars.total_optical_depth_filter5.data,'r.',serial2doy(mfr.time(post_good)),  mfr.vars.total_optical_depth_filter5.data(post_good),'b.'); title(['post\_good = ',num2str(sum(post_good))])
% axis(v)
% %figure; semilogy(serial2doy(mfr.time),  mfr.vars.total_optical_depth_filter2.data,'r.',serial2doy(mfr.time(post_good)),  mfr.vars.total_optical_depth_filter2.data(post_good),'g.'); title(['post\_good = ',num2str(sum(post_good))])

%%
good = post_good;
%%
aero = false(size(mfr.time)); eps = ones(size(mfr.time));
[aero(good), eps(good), aero_eps, mad, abs_dev] = aod_screen(serial2doy(mfr.time(good)), mfr.vars.total_optical_depth_filter5.data(good),0, 1,15, 3, 1e-2,20,20,.02);
figure; plot(serial2doy(mfr.time(good)), mfr.vars.total_optical_depth_filter5.data(good),'b.',serial2doy(mfr.time(aero)), mfr.vars.total_optical_depth_filter5.data(aero),'g.'); title(['good = ',num2str(sum(eps<1e-2))]);
aero_ii =find(aero);
axis(v)
%%
mfr.vars.variability_flag.data = eps;
mfr.vars.aero = aero;
fkb_screened = [fkb_dir,'fkb_new_tau_screened'];
save([fkb_screened,'.mat'],'mfr')
%%
fkb_screened = ancload(['F:\case_studies\fkb\fkbmfrsraod1flynnM1.c0\screened\all_screened\fkbmfrsraod1michM1.c1.20070421.055540.nc']);
%%
anet2 = read_cimel_aod;
%%
[ainb2, bina2] = nearest(fkb_screened.time, anet2.time);
%%
figure; plot(serial2doy(fkb_screened.time), fkb_screened.vars.aerosol_optical_depth_filter2.data, 'g.',...
serial2doy(anet1.time), anet1.AOT_500,'r.');
%%
clear ax
pos2 = mfr.vars.total_optical_depth_filter2.data>0 & mfr.vars.total_optical_depth_filter2.data<.5;
figure; ax(1)= subplot(2,1,1); 
plot(serial2doy(mfr.time(pos2)), mfr.vars.total_optical_depth_filter2.data(pos2), 'b.',...
   serial2doy(fkb_screened.time), fkb_screened.vars.aerosol_optical_depth_filter2.data, 'g.',...
serial2doy(fkb_screened.time(ainb2)), fkb_screened.vars.aerosol_optical_depth_filter2.data(ainb2), 'k.',...
serial2doy(anet2.time(bina2)), anet2.AOT_500(bina2),'r.');
title('500 nm')
legend('mfrsr TOD unscreened','mfrsr','Aeronet')
ax(2) =subplot(2,1,2); plot(serial2doy(Ios.time), Ios.vars.Io_filter2.data,'-rx');
title('MFRSR Io values')
% linkaxes(ax,'x')
%
%%
figure; scatter(fkb_screened.vars.aerosol_optical_depth_filter2.data(ainb2), anet2.AOT_500(bina2),16,anet2.time(bina2),'filled');
axis('square')
hold('on');
xl = xlim;
plot(xl,xl,'r');
hold('off')
xlabel('mfrsr');ylabel('Aeronet');
title('500 nm comparison')
xlim(ylim)


%
%%
pos5 = mfr.vars.total_optical_depth_filter5.data>0 & mfr.vars.total_optical_depth_filter5.data<.5;
figure; ax(3)= subplot(2,1,1); 
plot(serial2doy(mfr.time(pos5)), mfr.vars.total_optical_depth_filter5.data(pos5), 'b.',...
   serial2doy(fkb_screened.time), fkb_screened.vars.aerosol_optical_depth_filter5.data, 'g.',...
serial2doy(fkb_screened.time(ainb2)), fkb_screened.vars.aerosol_optical_depth_filter5.data(ainb2), 'k.',...
serial2doy(anet2.time(bina2)), anet2.AOT_870(bina2),'r.');
title('870 nm')
legend('mfrsr TOD unscreened','mfrsr','Aeronet')
ax(4) =subplot(2,1,2); plot(serial2doy(Ios.time), Ios.vars.Io_filter5.data,'-rx');
title('MFRSR Io values')
linkaxes(ax,'x')
%
%%
figure; scatter(fkb_screened.vars.aerosol_optical_depth_filter5.data(ainb2), anet2.AOT_870(bina2),16,anet2.time(bina2),'filled');
axis('square')
hold('on');
xl = xlim;
plot(xl,xl,'r');
hold('off')
xlabel('mfrsr');ylabel('Aeronet');
title('870 nm comparison')
xlim(ylim)

%%
%Now read each original file, match up with times in year-long file, and
%filter our values flagged as bad, then re-save
for f = 1:length(fkb_file);
   tmp = ancload([fkb_dir, fkb_file(f).name]);
   disp(['File ',num2str(f), ' of ', num2str(length(fkb_file))]);
   these = (mfr.time>=tmp.time(1))&(mfr.time<=tmp.time(end));
   tmp.vars.variability_flag.data = single(eps(these));
   keep = aero(these);
   [tmp_keep, tmp_dump] = ancsift(tmp, tmp.dims.time, keep);
   tmp_keep.fname = [tmp_keep.fname,'_.nc'];
   tmp_keep.quiet = true;
   tmp_keep.clobber = true;
   if length(tmp_keep.time>0)
      ancsave(tmp_keep);
   end   
end
%%
