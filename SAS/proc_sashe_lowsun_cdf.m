function [sashe, he_low] = proc_sashe_lowsun(sashe)
% [sashe, he_low] = proc_sashe_lowsun(sasze)
% Experiment Low sun, one band
% 1.  Move Inner Band to High:  Move Inner Band to High
% 2.  Acquire Dark High:  Acquire Dark High
% 3.  Acquire A:  Acquire A
% 4.  Move to low scat ang:  Move to low scat ang
% 5.  Acquire B:  Acquire B
% 6.  Scan B to C:  Scan B to C
% 7.  Acquire C:  Acquire C
% 8.  Block sun:  Block sun
% 9.  Acquire D blocked:  Acquire D blocked
%
% Subtract darks, tag 2
% th = tags 3
% bk = tag 9
% side B: tag 5
% side C: tag7
% subtract bk from mean of sides to get direct_raw
% subtract direct_uncorr from th to get diffuse_raw
% apply cosine correction to direct_raw to get direct_corr
% apply cosine correcton to diffuse_raw to get diffuse_corr
% Add direct_corr to diffuse_corr to get th_corr
% normalize by integration time
% Divide direct_corr by diffuse_corr to get dir/dif
% divide by responsivity
%%
sashe = ancload(getfullname('*sashe???lowsun*.cdf','sashevislowsun_cdf'));

%%
nm = sashe.vars.wavelength.data>=340 & sashe.vars.wavelength.data<1020;
%%
sashe_all_darks = sashe.vars.spectra.data(:,sashe.vars.shutter_state.data==0);
vis_darks = NaN(size(sashe.vars.spectra.data));
for pix = length(sashe.vars.wavelength.data):-1:1
   vis_darks(pix,:) = interp1(find(sashe.vars.shutter_state.data==0),sashe_all_darks(pix,:), [1:length(sashe.time)],'nearest');
end
%%
sashe_light_ms = (sashe.vars.spectra.data - vis_darks)./(ones(size(sashe.vars.wavelength.data))*sashe.vars.spectrometer_integration_time.data);
vis_resp = sgpsashe_Si_resp_p8in_20110307';
sashe_light_rad = sashe_light_ms./(vis_resp(:,2)*ones(size(sashe.time)));

% figure; plot([vis_resp(:,1); nir_resp(:,1)],[vis_resp_(:,2)./vis_resp(:,2);nir_resp_(:,2)./nir_resp(:,2)], '-');
% title('Responsivity at 0.8" / 3.16" Back-reflection?')
% xlabel('wavelength [nm]');
%%
TH_1 = sashe.vars.tag.data==3;
TH_1_ii = find(TH_1);
TH_1_ii = TH_1_ii(diff(TH_1_ii)==5); 

good_seq = sashe.vars.tag.data(TH_1_ii)==3 & sashe.vars.tag.data(TH_1_ii+1)==5 ...
    & sashe.vars.tag.data(TH_1_ii+2)==7 & sashe.vars.tag.data(TH_1_ii+3)==9;
TH_1_ii = TH_1_ii(good_seq);
SA_1_ii = TH_1_ii+1; 
SB_1_ii = TH_1_ii+2;
BK_1_ii = TH_1_ii+3;

TH_1 = false(size(TH_1)); TH_1(TH_1_ii) = true;
SA_1 = false(size(TH_1)); SA_1(SA_1_ii) = true;
SB_1 = false(size(TH_1)); SB_1(SB_1_ii) = true;
BK_1 = false(size(TH_1)); BK_1(BK_1_ii) = true;

he_low.time = mean([sashe.time(TH_1);sashe.time(SA_1);...
   sashe.time(BK_1);sashe.time(SB_1)]);
he_low.TH = sashe_light_rad(:,TH_1);
he_low.SA = sashe_light_rad(:,SA_1);
he_low.SB = sashe_light_rad(:,SB_1);
he_low.BK = sashe_light_rad(:,BK_1);
he_low.dS = (he_low.SA-he_low.SB);
he_low.S = (he_low.SA+he_low.SB)./2;
he_low.dirh_raw = he_low.S - he_low.BK;
he_low.diff_raw = he_low.TH - he_low.dirh_raw;
he_low.sza = sashe.vars.solar_zenith.data(TH_1);
he_low.saz = sashe.vars.solar_azimuth.data(TH_1);
he_low.cos_corr = sgpsashe_coscorr_from_PNNL_predeploy(he_low.sza);
% he_low.cos_corr = sgpsashe_coscorr_vs_nimfr(he_low.sza);
he_low.dirn_raw = he_low.dirh_raw ./ (ones([size(he_low.dirh_raw,1),1])*cos(pi.*he_low.sza./180));
he_low.dirn = he_low.dirn_raw ./ (ones([size(he_low.dirh_raw,1),1])*he_low.cos_corr);
%%
figure(2)
wl = [415,500,615,870];
pix = interp1(sashe.vars.wavelength.data,[1:length(sashe.vars.wavelength.data)],wl,'nearest');
plot(serial2doy(he_low.time), he_low.dirh_raw(pix,:)', '.-',...
  serial2doy(he_low.time), he_low.diff_raw(pix,:)', ':',...
  serial2doy(he_low.time), he_low.TH(pix,:)', '--');
legend('415 nm','500 nm', '615 nm', '870 nm');
xlabel('time (day of year)');
ylabel('irrad W/m2-um');
title(datestr(he_low.time(1)));

%%
figure(3);
plot(serial2doy(sashe.time), [sashe.vars.solar_azimuth.data],'ro',...
    serial2doy(sashe.time), mod((90+sashe.vars.band_azimuth.data),360), 'gx');
legend('solar azimuth','band axis tracking');
xlabel('day of year');
ylabel('degrees')
%%

% figure(2)
% wl = [415,500,615,870];
% pix = interp1(sashe.vars.wavelength.data,[1:length(sashe.vars.wavelength.data)],wl,'nearest');
% plot(serial2doy(he_low.time), he_low.dirh_raw(pix,:)', '-');
% legend('415 nm','500 nm', '615 nm', '870 nm');
% xlabel('time (day of year)');
% ylabel('irrad W/m2-um');

%%
% nimfr = ancload(getfullname('sgpnimfr*.cdf'));
% [ainb, bina] = nearest(he_low.time, nimfr.time);
% %%
% wl = [sscanf(nimfr.atts.filter1_CWL_measured.data,'%f'), sscanf(nimfr.atts.filter2_CWL_measured.data,'%f'),...
%    sscanf(nimfr.atts.filter3_CWL_measured.data,'%f'),sscanf(nimfr.atts.filter4_CWL_measured.data,'%f'),...
%    sscanf(nimfr.atts.filter5_CWL_measured.data,'%f')];
% pix = interp1(sashe.vars.wavelength.data,[1:length(sashe.vars.wavelength.data)],wl,'nearest');
% nimfr_at_sashe.filter1 = interp1(nimfr.time, nimfr.vars.direct_normal_narrowband_filter1.data, he_low.time, 'linear');
% nimfr_at_sashe.filter2 = interp1(nimfr.time, nimfr.vars.direct_normal_narrowband_filter2.data, he_low.time, 'linear');
% nimfr_at_sashe.filter3 = interp1(nimfr.time, nimfr.vars.direct_normal_narrowband_filter3.data, he_low.time, 'linear');
% nimfr_at_sashe.filter4 = interp1(nimfr.time, nimfr.vars.direct_normal_narrowband_filter4.data, he_low.time, 'linear');
% nimfr_at_sashe.filter5 = interp1(nimfr.time, nimfr.vars.direct_normal_narrowband_filter5.data, he_low.time, 'linear');
% match(5) = nimfr_at_sashe.filter5(max_ii)./he_low.dirn_raw(pix(5),max_ii);
% match(1) = nimfr_at_sashe.filter1(max_ii)./he_low.dirn_raw(pix(1),max_ii);
% match(2) = nimfr_at_sashe.filter2(max_ii)./he_low.dirn_raw(pix(2),max_ii);
% match(3) = nimfr_at_sashe.filter3(max_ii)./he_low.dirn_raw(pix(3),max_ii);
% match(4) = nimfr_at_sashe.filter4(max_ii)./he_low.dirn_raw(pix(4),max_ii);
% track1 = nimfr_at_sashe.filter1./he_low.dirn_raw(pix(1),:)./match(1);
% track2 = nimfr_at_sashe.filter2./he_low.dirn_raw(pix(2),:)./match(2);
% track3 = nimfr_at_sashe.filter3./he_low.dirn_raw(pix(3),:)./match(3);
% track4 = nimfr_at_sashe.filter4./he_low.dirn_raw(pix(4),:)./match(4);
% track5 = nimfr_at_sashe.filter5./he_low.dirn_raw(pix(5),:)./match(5);
% %%
% figure; plot(serial2Hh(nimfr.time), nimfr.vars.direct_normal_narrowband_filter2.data,'.');
% %%
% 
% figure; plot(serial2Hh(he_low.time), he_low.dS(pix(1),:)./he_low.S(pix(1),:),'r.',...
%    serial2Hh(he_vis_2.time), he_vis_2.dS(pix(1),:)./he_vis_2.S(pix(1),:),'b.');
% %%
% figure; plot(wl,1./match,'-o');
% xlabel('wavelength')
% ylabel('sashe/nimfr')
% 
% %%
%  figure; plot(serial2doy(he_low.time), [nimfr_at_sashe.filter1;nimfr_at_sashe.filter2;...
% nimfr_at_sashe.filter3;nimfr_at_sashe.filter4;nimfr_at_sashe.filter5],'.',...
% serial2doy(he_low.time),[he_low.dirn_raw(pix(1),:).*match(1);he_low.dirn_raw(pix(2),:).*match(2);...
% he_low.dirn_raw(pix(3),:).*match(3);he_low.dirn_raw(pix(4),:).*match(4);he_low.dirn_raw(pix(5),:).*match(5)],'x')
% %%
% figure; plot(serial2doy(he_low.time), [1./track1;1./track2;1./track3;1./track4;1./track5; ], '.',...
%    serial2doy(he_low.time),he_nir_1.cos_corr,'k.');
% legend('1','2','3','4','5')
% %%
% am = he_low.saz<180;
% figure; plot(serial2doy(he_low.time), he_low.saz,'.')
% 
% %%
% figure; plot(cos(he_low.sza(am).*pi./180), [1./track3(am);1./track4(am) ], '.',...
%     cos(he_low.sza(am).*pi./180), he_nir_1.cos_corr(am),'k.');
% legend('3','4');
% 
% %%
% %%
% figure; plot(he_low.sza(am), mean([1./track3(am);1./track4(am) ],1), '.',...
%     he_low.sza(am), he_nir_1.cos_corr(am),'k.');
% legend('3','4');
% 
% %%
% % Determine new cosine correction for el>9
% am = he_low.saz<180 & he_low.sza<180;
% new_cos_corr(1,:) = [10:81];
% new_cos_corr(2,:) = interp1(cos(he_low.sza(am).*pi./180), mean([1./track3(am);1./track4(am) ],1), cos([10:81].*pi./180),'pchip','extrap');
% new_cos_corr(2,new_cos_corr(2,:)<.3) = NaN;
% % new_cos_corr(2,new_cos_corr(1,:)<16) = 1;
% he_low.new_cos_corr = interp1(cos(new_cos_corr(1,:).*pi./180), new_cos_corr(2,:),cos(he_low.sza(am).*pi./180),'pchip','extrap');
% 
%  figure; plot(cos(he_low.sza(am).*pi./180),...
%      he_low.new_cos_corr,'b.',cos((10:81).*pi./180),new_cos_corr(2,:), 'r.');
%  
% he_vis_2.new_cos_corr = interp1(cos(new_cos_corr(1,:).*pi./180), new_cos_corr(2,:),cos(he_vis_2.sza(am).*pi./180),'pchip','extrap');
% %%
% % saveasp(new_cos_corr,'sgpsashe_coscorr_vs_nimfr_')
% %%
%  figure; plot(cos(he_low.sza(am).*pi./180),...
%      mean([1./track3(am);1./track4(am) ],1),'b.',cos((10:81).*pi./180),new_cos_corr(2,:), 'r.')
% %    serial2doy(he_low.time),he_nir_1.cos_corr,'k.');
% legend('1','2','3','4','5')
% %
% % Next, apply new_cos_corr to dirn, compute Langleys, TOA(pix), resp(pix)
% % Generate output, CSV
% %%
% figure; scatter(he_low.sza, 1./track1, 8,[1:length(he_low.sza)]);colorbar
% %%
% % Combine sequence 1 and 2
% [he_vis.time, it] = sort([he_low.time, he_vis_2.time]);

%%

return