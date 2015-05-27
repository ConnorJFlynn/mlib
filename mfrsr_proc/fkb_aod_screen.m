function [mfr, aero, eps] = fkb_aod_screen(fkb_dir);
%[mfr, aero, eps] = fkb_aod_screen(fkb_dir);
%%
if ~exist('fkb_dir','var')
   fkb_dir = getdir;
end;
fkb_file = dir([fkb_dir, '*.cdf']);
%%
tmp = ancload([fkb_dir, fkb_file(1).name]);
%%
mfr.time = tmp.time;
mfr.dims = tmp.dims;
mfr.atts = tmp.atts;
mfr.recdim = tmp.recdim;
mfr.vars.base_time = tmp.vars.base_time;
mfr.vars.time_offset = tmp.vars.time_offset;
mfr.vars.total_optical_depth_filter1 = tmp.vars.total_optical_depth_filter1;
mfr.vars.total_optical_depth_filter2 = tmp.vars.total_optical_depth_filter2;
mfr.vars.total_optical_depth_filter5 = tmp.vars.total_optical_depth_filter5;

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
mfr2.vars.total_optical_depth_filter1 = tmp.vars.total_optical_depth_filter1;
mfr2.vars.total_optical_depth_filter2 = tmp.vars.total_optical_depth_filter2;
mfr2.vars.total_optical_depth_filter5 = tmp.vars.total_optical_depth_filter5;
mfr = anccat(mfr, mfr2);
Ios.time(f) = tmp.time(1);
Ios.vars.Io_filter1.data(f) = tmp.vars.Io_filter1.data;
Ios.vars.Io_filter2.data(f) = tmp.vars.Io_filter2.data;
Ios.vars.Io_filter3.data(f) = tmp.vars.Io_filter3.data;
Ios.vars.Io_filter4.data(f) = tmp.vars.Io_filter4.data;
Ios.vars.Io_filter5.data(f) = tmp.vars.Io_filter5.data;
end
%%
fkb_out = [fkb_dir, '..',filesep,'fkb_tau.nc'];
%%
mfr.fname = fkb_out;
mfr.clobber = true;
% 
%%
save([fkb_out,'_.mat'],'mfr')
save([fkb_dir,'..',filesep,'Ios.mat'],'Ios');
%% 
ancsave(mfr)
%%
mfr = loadinto([fkb_out,'.mat']);
Ios = loadinto([fkb_dir,'..',filesep,'Ios.mat']);
%%
mfr = ancload(fkb_out);
%%
good = mfr.vars.total_optical_depth_filter5.data>0 & mfr.vars.total_optical_depth_filter5.data<1;
ii = 0;
%%
tic
%%
for x = 1:10
ii = ii+1;
[good(good)] = hmadf_span(mfr.vars.total_optical_depth_filter5.data(good), 15, 2);
sum_good(ii) = sum(good);
disp(num2str(sum(good)));
semilogy(serial2doy(mfr.time),  mfr.vars.total_optical_depth_filter5.data,'r.',serial2doy(mfr.time(good)),  mfr.vars.total_optical_depth_filter5.data(good),'b.'); 
title(['Iterations = ',num2str(ii),'  good = ',num2str(sum(good))])
pause(.25)
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
pause(.25)

%%
toc
%repeat about 15 times to cull non-physical high values.
%%
figure; semilogy(serial2doy(mfr.time),  mfr.vars.total_optical_depth_filter5.data,'r.',serial2doy(mfr.time(good)),  mfr.vars.total_optical_depth_filter5.data(good),'b.'); title(['good = ',num2str(sum(good))])
figure; semilogy(serial2doy(mfr.time),  mfr.vars.total_optical_depth_filter2.data,'r.',serial2doy(mfr.time(good)),  mfr.vars.total_optical_depth_filter2.data(good),'g.'); title(['good = ',num2str(sum(good))])

%%
post_good = false(size(mfr.time));
for d = floor(mfr.time(end)):-1:floor(mfr.time(1))
   disp(['Day ',num2str(d-floor(mfr.time(1)))])
   day = (mfr.time>=d)&(mfr.time<(d+1))&(mfr.vars.total_optical_depth_filter5.data>0)...
      &isfinite(mfr.vars.total_optical_depth_filter5.data);
   if sum(day)>0
   [good(day)] =post_screen(serial2doy(mfr.time(day)), mfr.vars.total_optical_depth_filter2.data(day), good(day),15,4);
   end
end
post_good = good;
post_good_ii = find(post_good);

semilogy(serial2doy(mfr.time),  mfr.vars.total_optical_depth_filter5.data,'r.',serial2doy(mfr.time(post_good)),  mfr.vars.total_optical_depth_filter5.data(post_good),'b.'); title(['post\_good = ',num2str(sum(post_good))])
axis(v)
%figure; semilogy(serial2doy(mfr.time),  mfr.vars.total_optical_depth_filter2.data,'r.',serial2doy(mfr.time(post_good)),  mfr.vars.total_optical_depth_filter2.data(post_good),'g.'); title(['post\_good = ',num2str(sum(post_good))])

%%
[aero, eps, aero_eps, mad, abs_dev] = aod_screen(serial2doy(mfr.time(post_good)), mfr.vars.total_optical_depth_filter5.data(post_good),0, 1,15, 3, 1e-3,20,20,.02);
figure; plot(serial2doy(mfr.time(post_good)), mfr.vars.total_optical_depth_filter2.data(post_good),'b.',serial2doy(mfr.time(post_good_ii(aero))), mfr.vars.total_optical_depth_filter2.data(post_good_ii(aero)),'g.'); title(['good = ',num2str(sum(eps<1e-3))]);

%%