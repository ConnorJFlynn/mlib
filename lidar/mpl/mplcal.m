function [mpl, status] = mplcal(filename)

if nargin==0
    [fid, fname, pname] = getfile('*.*', 'mpl_data');
    filename = [pname fname];
    fclose(fid);
end
mpl_pname = ['F:\datastream\sgp\sgpmplC1\cdf\'];
mfrsrod_pname = ['F:\datastream\sgp\sgpnimfrod1barnmichE13.c1\cdf\'];
% cmdlaos_pname = ['F:\datastream\sgp\sgpcmdlaosC1\cdf\'];
% twrmr_pname = ['F:\datastream\sgp\sgp1twrmrC1\cdf\'];
sonde_pname = ['F:\datastream\sgp\sgplssondeC1\cdf\'];

[mpl,status] = mpl_con_nor(filename);
[mpl.sonde] = time4sonde(mpl.range, [sonde_pname fname]);
%[mpl.sonde] = time4sonde(mpl.range(mpl.r.lte_30), [sonde_pname fname]);
[mpl.sonde.alpha_R, mpl.sonde.beta_R] = ray_a_b(mpl.sonde.temperature, mpl.sonde.pressure);
mpl.sonde.ray_15_25 = mean(mpl.sonde.atten_prof(mpl.r.ge15_le25)); % is our calibration 
mpl.sonde.tau_15_25 = mean(mpl.sonde.tau(mpl.r.ge15_le25));

%figure; plot(serial2doy0(mpl.time), mpl.hk.ray_15_25,'r', serial2doy0(mpl.time), mpl.hk.ray_20_25,'g')

Jd0 = serial2doy0(mpl.time);
disp('Getting MFRSR Optical Depths');
[mpl.mfrsrod] = time4mfrsrod(Jd0, [mfrsrod_pname fname]);
% disp('Getting cmdlaos data.')
% [mpl.cmdlaos] = time4cmdlaos(Jd0, [cmdlaos_pname fname]);
% figure; plot(serial2doy0(mpl.time), mpl.cmdlaos.Bbsp_G_1um_RefRH); title(['Bbsp Grn 1um vs Time'])
%disp('Getting twrmr data.')
%[mpl.twrmr] = time4twrmr(Jd0, [twrmr_pname fname]);

% disp('Renormalizing with AOS Bbsp');
% mpl.hk.Bbsp_sfc = mpl.cmdlaos.Bbsp_G_1um_RefRH/1000 + mpl.sonde.beta_R(1);
% for t = length(mpl.time):-1:1
%    mpl.prof(:,t) = mpl.prof(:,t) * (mpl.hk.Bbsp_sfc(t)/mpl.prof(3,t));
% end
% % 
% figure; image(serial2doy0(mpl.time), mpl.range(2:750),(1.5e1)*mpl.prof(2:750,:)), axis('xy'); colormap('jet'); title(['MPL attenuated backscatter: ' datestr(mpl.time(1), 1)]); zoom
disp('Calculating lidar calibration.')

mpl.hk.atm_trans =  exp(-2 * mpl.mfrsrod.aod_523);
mpl.hk.lidar_C = (mpl.hk.atm_trans * mpl.sonde.ray_15_25)./mpl.hk.ray_15_25;
%mpl.hk.lidar_C = (mpl.hk.atm_trans * mpl.sonde.ray_15_25)./mean(mpl.hk.ray_15_25);
% mpl.hk.attenuation =  mpl.sonde.ray_15_25 * exp(-2 * mpl.mfrsrod.aod_523);
% mpl.hk.lidar_C = mpl.hk.attenuation / mean(mpl.hk.ray_15_25); 
% % mpl.hk.ray_15_25 is a time_series of upper atmosphere signal
% disp('Applying calibration.');
% 
% for t = length(mpl.time):-1:1
% mpl.prof(:,t) = mpl.prof(:,t) * mpl.hk.lidar_C(t);
% end
% 
mpl.hk.integrated_bkscatter = trapz(mpl.range(mpl.r.lte_30),mpl.prof(mpl.r.lte_30,:));
