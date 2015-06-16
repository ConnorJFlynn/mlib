
fullname = getfullname('*.hdf','hsrl','Select hdf file')
%Get HDF info
[pathname, filename, ext] = fileparts(fullname);
pathname = [pathname filesep];
filename = [filename, ext];

S = hdfinfo([pathname,filename]);

%Read in variable names
names = {S.SDS.Name};
%%



% C:\case_studies\ISDAC\HSRL\20080412_L1_sub.hdf

% Wow, look at 6th/7th
% See about a merged image with HSRL above, MPL below on 3/4/5 with cloud
% deck
%Look at 10th for depolarizing features comparison

%%

% filename = handles.filename;
%read in the data of interest
gps_time = hdfread([pathname filename],'gps_time');
gps_date = hdfread([pathname filename],'gps_date');
hsrl.time = (datenum(gps_date,'mm/dd/yyyy')+double(mod(gps_time,24))'./24);
hsrl.lat = hdfread([pathname filename],'gps_lat');
hsrl.lon = hdfread([pathname filename],'gps_lon');
site.lat = 71.3199996948242;
site.lon = -156.619995117188;
hsrl.dist = geodist(hsrl.lat,hsrl.lon,site.lat, site.lon);
near_site = 5000;
hsrl.near_site = hsrl.dist <= near_site;

hsrl.altitude = hdfread([pathname filename],'Altitude');
hsrl.Temperature = hdfread([pathname filename],'Temperature');
hsrl.Pressure = hdfread([pathname filename],'Pressure');
hsrl.Number_Density = hdfread([pathname filename],'Number_Density');
hsrl.x532_ext = hdfread([pathname filename],'532_ext'); %Has NaNs
hsrl.x532_bsc = hdfread([pathname filename],'532_bsc');
hsrl.x532_bsr = hdfread([pathname filename],'532_bsr');
hsrl.x532_bsc_Sa = hdfread([pathname filename],'532_bsc_Sa');
hsrl.x532_dep = hdfread([pathname filename],'532_dep');
hsrl.x532_total_attn_bsc = hdfread([pathname filename],'532_total_attn_bsc');
%%
[min_dist,ind] = min(hsrl.dist);
[atten_topdown,tau] = lidar_atten_profs(fliplr(hsrl.altitude), hsrl.Temperature(ind,:),hsrl.Pressure(ind,:), 532e-9, hsrl.x532_ext(ind,:), hsrl.x532_bsc(ind,:));
figure; semilogx(hsrl.x532_total_attn_bsc(ind,:),hsrl.altitude,'g-', atten_topdown,hsrl.altitude,'r-' )
%These compare fairly well, except for the discontinuity at the top,
%probably due to the leading/trailing NaNs.
[atten,tau] = lidar_atten_profs((hsrl.altitude), hsrl.Temperature(ind,:),hsrl.Pressure(ind,:), 532e-9, hsrl.x532_ext(ind,:), hsrl.x532_bsc(ind,:));
%compare this to MPL, and also compare dpr for both.

figure; scatter(hsrl.lat,hsrl.lon,32,hsrl.dist./1000,'filled'); colorbar;caxis([0,10]); hold('on'); plot(site.lat, site.lon,'go');

figure; scatter(hsrl.lat,hsrl.lon,4.^2,abs(hsrl.dist))
colorbar
figure; scatter(hsrl.lat,hsrl.lon,4.^2,abs(hsrl.dist)/1000); colorbar

figure; scatter(hsrl.lat,hsrl.lon,4.^2,(hsrl.dist)/1000); colorbar


%%

[polavg] = proc_mplpolraw;
[tmp,mind] = min(abs(polavg.time-hsrl.time(ind)));

C:\mlib\lidar\mpl\Rd_Sigma.m is a case-insensitive match and will be used instead.
You can improve the performance of your code by using exact
name matches and we therefore recommend that you update your
usage accordingly. Alternatively, you can disable this warning using
warning('off','MATLAB:dispatcher:InexactCaseMatch').
This warning will become an error in future releases.
> In <a href="matlab: opentoline('C:\mlib\lidar\mpl\proc_mplpolraw.m',13,1)">proc_mplpolraw at 13</a>
Select a raw ASRC MPL file:
filename: C:\case_studies\ISDAC\MPL\MPL_raw\200804122200_0.mpl
file size = 16232840
Profile size = 15992
Packetsize = 16120
1007 complete profiles
Loaded file
Applying post-April 7 afterpulse corrections for ISDAC
done
%%
%%

figure; semilogx(1e-3*polavg.attn_bscat(:,mind), 1000*polavg.range,'r',atten, hsrl.altitude,'b')
Warning: Negative data ignored
%%
figure; semilogx(polavg.ldr(:,mind), 1000*polavg.range,'r',hsrl.x532_dep(ind,:), hsrl.altitude,'b')

Warning: Negative data ignored
%%
figure; semilogx(polavg.ldr(:,mind), 1000*polavg.range,'r',hsrl.x532_dep(ind,:), hsrl.altitude,'b')
figure; plot(polavg.ldr(:,mind), 1000*polavg.range,'r',hsrl.x532_dep(ind,:), hsrl.altitude,'b')
Warning: Negative data ignored
datestr(hsrl.time(ind))

ans =

12-Apr-2008 21:19:51

datestr(polavg.time(mind))

ans =

12-Apr-2008 22:00:29

%%

[polavg] = proc_mplpolraw;
[tmp,mind] = min(abs(polavg.time-hsrl.time(ind)));
Select a raw ASRC MPL file:
filename: C:\case_studies\ISDAC\MPL\MPL_raw\200804122100_0.mpl
file size = 16248960
Profile size = 15992
Packetsize = 16120
1008 complete profiles
Loaded file
Applying post-April 7 afterpulse corrections for ISDAC
done
datestr(polavg.time([mind]))

ans =

12-Apr-2008 21:19:49

datestr(polavg.time([mind-5 mind+5]))

ans =

12-Apr-2008 21:14:28
12-Apr-2008 21:25:10

%%

figure; semilogx(1e-3*polavg.attn_bscat(:,mind), 1000*polavg.range,'r',atten, hsrl.altitude,'b')
Warning: Negative data ignored
%%

figure; semilogx(1e-3*mean(polavg.attn_bscat(:,[mind-5:mind+5]),2), 1000*polavg.range,'r',atten, hsrl.altitude,'b')
Warning: Negative data ignored
Warning: Negative data ignored
%%

figure; semilogx(1.5e-3*mean(polavg.attn_bscat(:,[mind-5:mind+5]),2), 1000*polavg.range,'r',atten, hsrl.altitude,'b')
Warning: Negative data ignored
%%
mpl_attn_bscat = downsample(mean(polavg.attn_bscat(:,[mind-5:mind+5]),2),2,1);
mpl_dwn_range = downsample(1000*polavg.range,2);
%%
mpl_attn_bscat = downsample(mean(polavg.attn_bscat(:,[mind-5:mind+5]),2),2,1);
mpl_dwn_range = downsample(1000*polavg.range,2);
cmp_atten_bscat = interp1(mpl_dwn_range, mpl_attn_bscat,hsrl.altitude, 'linear')

figure; semilogx(1.5e-3*mpl_attn_bscat, mpl_dwn_range,'r',atten, hsrl.altitude,'b');
Warning: Negative data ignored
%%
figure; semilogx(1.5e-3*cmp_atten_bscat, hsrl.altitude,'r',atten, hsrl.altitude,'b');
Warning: Negative data ignored
%%
figure; semilogx(1.5e-3*cmp_atten_bscat, hsrl.altitude,'r',atten, hsrl.altitude,'b');
figure; semilogx(atten./(1.5e-3*cmp_atten_bscat), hsrl.altitude,'k');
Warning: Negative data ignored
%%
figure; semilogx(1.5e-3*cmp_atten_bscat, hsrl.altitude,'r',atten, hsrl.altitude,'b');
figure; semilogx(atten./(1.5e-3*cmp_atten_bscat), hsrl.altitude,'.k');
Warning: Negative data ignored
%%
figure; semilogx(1.5e-3*cmp_atten_bscat, hsrl.altitude,'r',atten, hsrl.altitude,'b');
figure; semilogx(atten./(1.5e-3*cmp_atten_bscat), hsrl.altitude,'.-k');
Warning: Negative data ignored
%%
figure; semilogx(1.5e-3*cmp_atten_bscat, hsrl.altitude,'r',atten, hsrl.altitude,'b');
ol_ratio_raw = atten./(1.5e-3*cmp_atten_bscat);
figure; semilogx(ol_ratio_raw, hsrl.altitude,'.-k');
%Looks like altitude from 200m to 5km is a good range to fit.

ol_fit_alt = hsrl.altitude>=200&hsrl.altitude<=5000;
[hsrl.altitude(ol_fit_alt), ol_ratio_raw(ol_fit_alt)];

%%
figure; semilogx(1.5e-3*cmp_atten_bscat, hsrl.altitude,'r',atten, hsrl.altitude,'b');
ol_ratio_raw = atten./(1.5e-3*cmp_atten_bscat);
figure; semilogx(ol_ratio_raw, hsrl.altitude,'.-k');
%Looks like altitude from 200m to 5km is a good range to fit.

ol_fit_alt = hsrl.altitude>=200&hsrl.altitude<=5000;
% Wrong direction? [hsrl.altitude(ol_fit_alt), ol_ratio_raw(ol_fit_alt)]'
%%
figure; semilogx(1.5e-3*cmp_atten_bscat, hsrl.altitude,'r',atten, hsrl.altitude,'b');
ol_ratio_raw = atten./(1.5e-3*cmp_atten_bscat);
figure; semilogx(ol_ratio_raw, hsrl.altitude,'.-k');
%Looks like altitude from 200m to 5km is a good range to fit.

ol_fit_alt = hsrl.altitude>=200&hsrl.altitude<=5000;
[hsrl.altitude(ol_fit_alt); ol_ratio_raw(ol_fit_alt)]';

%%
figure; semilogx(1.5e-3*cmp_atten_bscat, hsrl.altitude,'r',atten, hsrl.altitude,'b');
ol_ratio_raw = atten./(1.5e-3*cmp_atten_bscat);
figure; semilogx(ol_ratio_raw, hsrl.altitude,'.-k');
%Looks like altitude from 200m to 5km is a good range to fit.

ol_fit_alt = hsrl.altitude>=200&hsrl.altitude<=5000;
save_me = [hsrl.altitude(ol_fit_alt); ol_ratio_raw(ol_fit_alt)]';
[pname, dmp] = fileparts(polavg.statics.fname);
save([pname,'ol_raw_fit.txt'],save_me,'-ASCII -TABS');
Warning: Negative data ignored
??? Error using ==> save
Argument must contain a string.

%%
figure; semilogx(1.5e-3*cmp_atten_bscat, hsrl.altitude,'r',atten, hsrl.altitude,'b');
ol_ratio_raw = atten./(1.5e-3*cmp_atten_bscat);
figure; semilogx(ol_ratio_raw, hsrl.altitude,'.-k');
%Looks like altitude from 200m to 5km is a good range to fit.

ol_fit_alt = hsrl.altitude>=200&hsrl.altitude<=5000;
save_me = [hsrl.altitude(ol_fit_alt); ol_ratio_raw(ol_fit_alt)]';
[pname, dmp] = fileparts(polavg.statics.fname);
save([pname,'ol_raw_fit.txt'],'save_me','-ASCII -TABS');
Warning: Negative data ignored
??? Error using ==> save
Unknown command option.

%%
figure; semilogx(1.5e-3*cmp_atten_bscat, hsrl.altitude,'r',atten, hsrl.altitude,'b');
ol_ratio_raw = atten./(1.5e-3*cmp_atten_bscat);
figure; semilogx(ol_ratio_raw, hsrl.altitude,'.-k');
%Looks like altitude from 200m to 5km is a good range to fit.

ol_fit_alt = hsrl.altitude>=200&hsrl.altitude<=5000;
save_me = [hsrl.altitude(ol_fit_alt); ol_ratio_raw(ol_fit_alt)]';
[pname, dmp] = fileparts(polavg.statics.fname);
save([pname,'ol_raw_fit.txt'],'save_me','-ASCII','-TABS');
Warning: Negative data ignored
Warning: Attempt to write an unsupported data type to an ASCII file.
	Variable 'save_me' not written to file.
%%
figure; semilogx(1.5e-3*cmp_atten_bscat, hsrl.altitude,'r',atten, hsrl.altitude,'b');
ol_ratio_raw = atten./(1.5e-3*cmp_atten_bscat);
figure; semilogx(ol_ratio_raw, hsrl.altitude,'.-k');
%Looks like altitude from 200m to 5km is a good range to fit.

ol_fit_alt = hsrl.altitude>=200&hsrl.altitude<=5000;
save_me = [hsrl.altitude(ol_fit_alt); ol_ratio_raw(ol_fit_alt)]';
[pname, dmp] = fileparts(polavg.statics.fname);
save([pname,'ol_raw_fit.txt'],'save_me','-ASCII');
Warning: Negative data ignored
Warning: Attempt to write an unsupported data type to an ASCII file.
	Variable 'save_me' not written to file.
%%
figure; semilogx(1.5e-3*cmp_atten_bscat, hsrl.altitude,'r',atten, hsrl.altitude,'b');
ol_ratio_raw = atten./(1.5e-3*cmp_atten_bscat);
figure; semilogx(ol_ratio_raw, hsrl.altitude,'.-k');
%Looks like altitude from 200m to 5km is a good range to fit.

ol_fit_alt = hsrl.altitude>=200&hsrl.altitude<=5000;
save_me = double([hsrl.altitude(ol_fit_alt); ol_ratio_raw(ol_fit_alt)])';
[pname, dmp] = fileparts(polavg.statics.fname);
save([pname,'ol_raw_fit.txt'],'save_me','-ASCII');
Warning: Negative data ignored
%%

[polavg] = proc_mplpolraw;
[tmp,mind] = min(abs(polavg.time-hsrl.time(ind)));
Select a raw ASRC MPL file:
filename: C:\case_studies\ISDAC\MPL\MPL_raw\200804122100_0.mpl
file size = 16248960
Profile size = 15992
Packetsize = 16120
1008 complete profiles
Loaded file
Applying post-April 7 afterpulse corrections for ISDAC
<a href="matlab: opentoline('C:\mlib\lidar\mpl\proc_mplpolraw.m',175,1)">175 </a>ol_corr = hsrl_ol_corr(polavg.range);
ol_corr = hsrl_ol_corr(polavg.range);
figure; semilogx(ol_corr, polavg.range, '.')
ol_corr = hsrl_ol_corr(polavg.range./1000);
figure; semilogx(ol_corr, polavg.range, '.')

<a href="matlab: opentoline('C:\mlib\lidar\mpl\proc_mplpolraw.m',175,1)">175 </a>ol_corr = hsrl_ol_corr(polavg.range.*1000);
