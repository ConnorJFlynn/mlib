function [sashe, he_vis_1,he_vis_2] = proc_sashe_hisun(sashe)
% [sashe, he_vis_1,he_vis_2] = proc_sashe_hisun(sasze)
% 1.  Move Inner Band to Low Bound:  
% 2.  Acquire Dark low limit:  Dark Counts at the lower band limit
% 3.  Acquire A:  Take one second of data at the low limit
% 4.  Move to Low Scatter:  
% 5.  Acquire B:  
% 6.  Scan B to C:  Scan the band from the negative scatter angle to the positive scatter angle
% 7.  Acquire C:  
% 8.  Move to 0:  
% 9.  Acquire D (0):  
% 10.  Move to High Limit:  
% 11.  Acquire Dark High Limit:  
% 12.  Acquire E:  
% 13.  Move to Scatter High:  
% 14.  Acquire C:  
% 15.  Scan C to B:  
% 16.  Acquire B:  
% 17.  Move to Vertical (0):  
% 18.  Acquire vertical:  
% 19.  Move to Low Bound:  
%
% Subtract darks, tags 2 & 11
% th = tags 3 & 12
% bk = tag 9 & 18 = diff - band
% side B: 5,16
% side C: 7,14
% subtract bk from mean of sides to get direct_raw
% subtract direct_uncorr from th to get diffuse_raw
% apply cosine correction to direct_raw to get direct_corr
% apply cosine correcton to diffuse_raw to get diffuse_corr
% Add direct_corr to diffuse_corr to get th_corr
% normalize by integration time
% Divide direct_corr by diffuse_corr to get dir/dif
% divide by responsivity
%%
if ~exist('sashe','var')
    sashe = ancload(getfullname_('*sashevishisun*.cdf','sashevishisun_cdf'));
end
if ~isstruct(sashe)&&ischar(sashe)
    sashe = ancload(sashe);
end
% sashe_nir = ancload(getfullname_('*sashenirhisun*.cdf','sashenirhisun_cdf'));
% vis_ms =
% rd_raw_SAS(getfullname_('SASHe_HiSun_vis_ms*.csv','sashe_hisun'));

%%
vis_nm = sashe.vars.wavelength.data>=340 & sashe.vars.wavelength.data<1020;
% nir_nm = sashe_nir.vars.wavelength.data>920 & sashe_nir.vars.wavelength.data<1700;
%%
sashe_all_darks = sashe.vars.spectra.data(:,sashe.vars.shutter_state.data==0);
vis_darks = NaN(size(sashe.vars.spectra.data));
for pix = length(sashe.vars.wavelength.data):-1:1
   vis_darks(pix,:) = interp1(find(sashe.vars.shutter_state.data==0),sashe_all_darks(pix,:), [1:length(sashe.time)],'nearest');
end
%%
% sashe_nir_all_darks = sashe_nir.vars.spectra.data(:,sashe_nir.vars.shutter_state.data==0);
% nir_darks = NaN(size(sashe_nir.vars.spectra.data));
% for pix = length(sashe_nir.vars.wavelength.data):-1:1
%    nir_darks(pix,:) = interp1(find(sashe_nir.vars.shutter_state.data==0),sashe_nir_all_darks(pix,:), [1:length(sashe_nir.time)],'nearest');
% end
% %%   
% sashe_nir_light_ms = (sashe_nir.vars.spectra.data - nir_darks)./(ones(size(sashe_nir.vars.wavelength.data))*sashe_nir.vars.spectrometer_integration_time.data);
% nir_resp_ = sgpsashe_InGaAs_resp_p8in_20110307';
% nir_resp = sgpsashe_InGaAs_resp_3p16in_20110307';
% sashe_nir_light_rad = sashe_nir_light_ms./(nir_resp(:,2)*ones(size(sashe_nir.time)));
%%
sashe_light_ms = (sashe.vars.spectra.data - vis_darks)./(ones(size(sashe.vars.wavelength.data))*sashe.vars.spectrometer_integration_time.data);
if min(sashe.vars.wavelength.data)<500
    resp = sgpsashe_Si_resp_p8in_20110307';
else
    resp = sgpsashe_InGaAs_resp_3p16in_20110307';
end
% vis_resp = sgpsashe_Si_resp_3p16in_20110307';
sashe_light_rad = sashe_light_ms./(resp(:,2)*ones(size(sashe.time)));

% figure; plot([vis_resp(:,1); nir_resp(:,1)],[vis_resp_(:,2)./vis_resp(:,2);nir_resp_(:,2)./nir_resp(:,2)], '-');
% title('Responsivity at 0.8" / 3.16" Back-reflection?')
% xlabel('wavelength [nm]');
%%
TH_1 = sashe.vars.tag.data==3;
TH_1_ii = find(TH_1);
TH_1_ii = TH_1_ii(diff(TH_1_ii)==10); 

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

%%
TH_2 = sashe.vars.tag.data==12;
TH_2_ii = find(TH_2);
TH_2_ii = TH_2_ii(diff(TH_2_ii)==10); 

good_seq = sashe.vars.tag.data(TH_2_ii)==12 & sashe.vars.tag.data(TH_2_ii+1)==14 ...
    & sashe.vars.tag.data(TH_2_ii+2)==16 & sashe.vars.tag.data(TH_2_ii+3)==18;
TH_2_ii = TH_2_ii(good_seq);
SB_2_ii = TH_2_ii+1; 
SA_2_ii = TH_2_ii+2;
BK_2_ii = TH_2_ii+3;

TH_2 = false(size(TH_2)); TH_2(TH_2_ii) = true;
SA_2 = false(size(TH_2)); SA_2(SA_2_ii) = true;
SB_2 = false(size(TH_2)); SB_2(SB_2_ii) = true;
BK_2 = false(size(TH_2)); BK_2(BK_2_ii) = true;


%%
he_vis_1.time = mean([sashe.time(TH_1);sashe.time(SA_1);...
   sashe.time(BK_1);sashe.time(SB_1)]);
he_vis_1.TH = sashe_light_rad(:,TH_1);
he_vis_1.SA = sashe_light_rad(:,SA_1);
he_vis_1.SB = sashe_light_rad(:,SB_1);
he_vis_1.BK = sashe_light_rad(:,BK_1);
he_vis_1.dS = (he_vis_1.SA-he_vis_1.SB);
%%
he_vis_1.S = (he_vis_1.SA+he_vis_1.SB)./2;
he_vis_1.dirh_raw = he_vis_1.S - he_vis_1.BK;
he_vis_1.diff_raw = he_vis_1.TH - he_vis_1.dirh_raw;
he_vis_1.sza = sashe.vars.solar_zenith.data(TH_1);
he_vis_1.saz = sashe.vars.solar_azimuth.data(TH_1);
he_vis_1.cos_corr = sgpsashe_coscorr_from_PNNL_predeploy(he_vis_1.sza);
% he_vis_1.cos_corr = sgpsashe_coscorr_vs_nimfr(he_vis_1.sza);
he_vis_1.dirn_raw = he_vis_1.dirh_raw ./ (ones([size(he_vis_1.dirh_raw,1),1])*cos(pi.*he_vis_1.sza./180));
he_vis_1.dirn = he_vis_1.dirn_raw ./ (ones([size(he_vis_1.dirh_raw,1),1])*he_vis_1.cos_corr);
%%
% nim = ancload(getfullname_('sgpnimfr*.cdf','nimfr'));
% %%
% figure; ss(1) = subplot(2,1,1); plot(serial2doy(he_vis_1.time), he_vis_1.dirn(380,:),'-', ...
%     serial2doy(nim.time), (1020./1060).*8e2.* nim.vars.direct_normal_narrowband_filter2.data,'r-');
% grid('on');
% ss(2) = subplot(2,1,2); plot(serial2doy(sashe.time), smooth(sashe.vars.chiller_temperature.data,50,'sgolay',2),'.-')
% grid('on');
% linkaxes(ss,'x')
%%
he_vis_2.time = mean([sashe.time(TH_2);sashe.time(SA_2);...
   sashe.time(BK_2);sashe.time(SB_2)]);
he_vis_2.TH = sashe_light_rad(:,TH_2);
he_vis_2.SA = sashe_light_rad(:,SA_2);
he_vis_2.SB = sashe_light_rad(:,SB_2);
he_vis_2.BK = sashe_light_rad(:,BK_2);
he_vis_2.dS = (he_vis_2.SA-he_vis_2.SB);
he_vis_2.S = (he_vis_2.SA+he_vis_2.SB)./2;
he_vis_2.dirh_raw = he_vis_2.S - he_vis_2.BK;
he_vis_2.diff_raw = he_vis_2.TH - he_vis_2.dirh_raw;
he_vis_2.sza = sashe.vars.solar_zenith.data(TH_2);
he_vis_2.saz = sashe.vars.solar_azimuth.data(TH_2);

he_vis_2.cos_corr = sgpsashe_coscorr_from_PNNL_predeploy(he_vis_2.sza);
% he_vis_2.cos_corr = sgpsashe_coscorr_vs_nimfr(he_vis_2.sza);
% he_vis_2.dirn = he_vis_2.dirh_raw ./ (ones([size(he_vis_2.dirh_raw,1),1])*he_vis_2.cos_corr.*cos(pi.*he_vis_2.sza./180));
he_vis_2.dirn_raw = he_vis_2.dirh_raw ./ (ones([size(he_vis_2.dirh_raw,1),1])*cos(pi.*he_vis_2.sza./180));
he_vis_2.dirn = he_vis_2.dirn_raw ./ (ones([size(he_vis_2.dirh_raw,1),1])*he_vis_2.cos_corr);

% %%
% he_nir_1.time = mean([sashe.time(TH_1);sashe.time(SA_1);...
%    sashe.time(BK_1);sashe.time(SB_1)]);
% he_nir_1.TH = sashe_nir_light_rad(:,TH_1);
% he_nir_1.SA = sashe_nir_light_rad(:,SA_1);
% he_nir_1.SB = sashe_nir_light_rad(:,SB_1);
% he_nir_1.BK = sashe_nir_light_rad(:,BK_1);
% he_nir_1.dS = (he_nir_1.SA-he_nir_1.SB);
% he_nir_1.S = (he_nir_1.SA+he_nir_1.SB)./2;
% he_nir_1.dirh_raw = he_nir_1.S - he_nir_1.BK;
% he_nir_1.diff_raw = he_nir_1.TH - he_nir_1.dirh_raw;
% he_nir_1.sza = sashe.vars.solar_zenith.data(TH_1);
% he_nir_1.cos_corr = sgpsashe_coscorr_from_PNNL_predeploy(he_nir_1.sza);
% % he_nir_1.cos_corr = sgpsashe_coscorr_vs_nimfr(he_nir_1.sza);
% % he_nir_1.dirn = he_nir_1.dirh_raw ./ (ones([size(he_nir_1.dirh_raw,1),1])*he_nir_1.cos_corr.*cos(pi.*he_nir_1.sza./180));
% he_nir_1.dirn_raw = he_nir_1.dirh_raw ./ (ones([size(he_nir_1.dirh_raw,1),1])*cos(pi.*he_nir_1.sza./180));
% he_nir_1.dirn = he_nir_1.dirn_raw ./ (ones([size(he_nir_1.dirh_raw,1),1])*he_nir_1.cos_corr);
% 
% he_nir_2.time = mean([sashe.time(TH_2);sashe.time(SA_2);...
%    sashe.time(BK_2);sashe.time(SB_2)]);
% he_nir_2.TH = sashe_nir_light_rad(:,TH_2);
% he_nir_2.SA = sashe_nir_light_rad(:,SA_2);
% he_nir_2.SB = sashe_nir_light_rad(:,SB_2);
% he_nir_2.BK = sashe_nir_light_rad(:,BK_2);
% he_nir_2.dS = (he_nir_2.SA-he_nir_2.SB);
% he_nir_2.S = (he_nir_2.SA+he_nir_2.SB)./2;
% he_nir_2.dirh_raw = he_nir_2.S - he_nir_2.BK;
% he_nir_2.diff_raw = he_nir_2.TH - he_nir_2.dirh_raw;
% he_nir_2.sza = sashe.vars.solar_zenith.data(TH_2);
% he_nir_2.cos_corr = sgpsashe_coscorr_from_PNNL_predeploy(he_nir_2.sza);
% % he_nir_2.cos_corr = sgpsashe_coscorr_vs_nimfr(he_nir_2.sza);
% % he_nir_2.dirn = he_nir_2.dirh_raw ./ (ones([size(he_nir_2.dirh_raw,1),1])*he_nir_2.cos_corr.*cos(pi.*he_nir_2.sza./180));
% he_nir_2.dirn_raw = he_nir_2.dirh_raw ./ (ones([size(he_nir_2.dirh_raw,1),1])*cos(pi.*he_nir_2.sza./180));
% he_nir_2.dirn = he_nir_2.dirn_raw ./ (ones([size(he_nir_2.dirh_raw,1),1])*he_nir_2.cos_corr);
%%
% figure(12)
% wl = [415,500,615,870];
% pix = interp1(sashe.vars.wavelength.data,[1:length(sashe.vars.wavelength.data)],wl,'nearest');
% plot(serial2Hh(he_vis_1.time), (he_vis_1.dirh_raw(pix,:)./(max(he_vis_1.dirh_raw(pix,:),[],2)*ones([1,354])))', '.-',...
%   serial2Hh(he_vis_1.time), (he_vis_1.diff_raw(pix,:)./(max(he_vis_1.diff_raw(pix,:),[],2)*ones([1,354])))', 'k-');
% legend('415 nm','500 nm', '615 nm', '870 nm');
% xlabel('time (UTC hour)');
% ylabel('irrad W/m2-um');
% title(datestr(he_vis_1.time(1)));
% %%
% figure(14)
% wl = [415,500,615,870];
% pix = interp1(sashe.vars.wavelength.data,[1:length(sashe.vars.wavelength.data)],wl,'nearest');
% plot(serial2Hh(he_vis_1.time), (he_vis_1.dirh_raw(pix,:)./he_vis_1.diff_raw(pix,:))', '-');
% legend('415 nm','500 nm', '615 nm', '870 nm');
% xlabel('time (UTC hour)');
% ylabel('irrad W/m2-um');
% title(datestr(he_vis_1.time(1)));

%%
% figure(99);
% mfr_file = getfullname_('pghmfrsr*.cdf','pghmfrsr','Select MFRSR file.');
% mfr = ancload(mfr_file);
% %%
% figure;plot(serial2Hh(mfr.time),[mfr.vars.direct_horizontal_narrowband_filter1.data; ...
%     mfr.vars.direct_horizontal_narrowband_filter2.data; mfr.vars.direct_horizontal_narrowband_filter3.data;...
%     mfr.vars.direct_horizontal_narrowband_filter5.data],'.-',...
%     serial2Hh(mfr.time),[mfr.vars.diffuse_hemisp_narrowband_filter1.data; ...
%     mfr.vars.diffuse_hemisp_narrowband_filter2.data; mfr.vars.diffuse_hemisp_narrowband_filter3.data; ...
%     mfr.vars.diffuse_hemisp_narrowband_filter5.data],':');

% %%
% plot_qcs(sashe)

%%
figure(13);
plot(serial2doy(sashe.time), [sashe.vars.solar_azimuth.data],'ro',...
    serial2doy(sashe.time), sashe.vars.band_azimuth.data, 'gx');
legend('solar azimuth','band axis tracking');
xlabel('day of year');
ylabel('degrees')
%%
% 
% figure(2)
% wl = [415,500,615,870];
% pix = interp1(sashe.vars.wavelength.data,[1:length(sashe.vars.wavelength.data)],wl,'nearest');
% plot(serial2doy(he_vis_1.time), he_vis_1.dirh_raw(pix,:)', '-',...
%   serial2doy(he_vis_2.time), he_vis_2.dirh_raw(pix,:)', 'k-');
% legend('415 nm','500 nm', '615 nm', '870 nm');
% xlabel('time (day of year)');
% ylabel('irrad W/m2-um');
% %%
% [~,max_ii] = max(he_vis_1.dirh_raw(pix(2),:));
% figure(3); 
% plot(sashe.vars.wavelength.data(vis_nm), he_vis_1.dirh_raw(vis_nm,max_ii),'-',...
% sashe_nir.vars.wavelength.data(nir_nm), he_nir_1.dirh_raw(nir_nm,max_ii),'-');
% title(['SGP SAS-He direct horizontal irradiance: ', datestr(sashe.time(max_ii),'mmm dd, yyyy')]);
% xlabel('wavelength [nm]');
% ylabel('irrad W/m2-um');
% %%
% nimfr = ancload(getfullname_('sgpnimfr*.cdf'));
% [ainb, bina] = nearest(he_vis_1.time, nimfr.time);
% %%
% wl = [sscanf(nimfr.atts.filter1_CWL_measured.data,'%f'), sscanf(nimfr.atts.filter2_CWL_measured.data,'%f'),...
%    sscanf(nimfr.atts.filter3_CWL_measured.data,'%f'),sscanf(nimfr.atts.filter4_CWL_measured.data,'%f'),...
%    sscanf(nimfr.atts.filter5_CWL_measured.data,'%f')];
% pix = interp1(sashe.vars.wavelength.data,[1:length(sashe.vars.wavelength.data)],wl,'nearest');
% nimfr_at_sashe.filter1 = interp1(nimfr.time, nimfr.vars.direct_normal_narrowband_filter1.data, he_vis_1.time, 'linear');
% nimfr_at_sashe.filter2 = interp1(nimfr.time, nimfr.vars.direct_normal_narrowband_filter2.data, he_vis_1.time, 'linear');
% nimfr_at_sashe.filter3 = interp1(nimfr.time, nimfr.vars.direct_normal_narrowband_filter3.data, he_vis_1.time, 'linear');
% nimfr_at_sashe.filter4 = interp1(nimfr.time, nimfr.vars.direct_normal_narrowband_filter4.data, he_vis_1.time, 'linear');
% nimfr_at_sashe.filter5 = interp1(nimfr.time, nimfr.vars.direct_normal_narrowband_filter5.data, he_vis_1.time, 'linear');
% match(5) = nimfr_at_sashe.filter5(max_ii)./he_vis_1.dirn_raw(pix(5),max_ii);
% match(1) = nimfr_at_sashe.filter1(max_ii)./he_vis_1.dirn_raw(pix(1),max_ii);
% match(2) = nimfr_at_sashe.filter2(max_ii)./he_vis_1.dirn_raw(pix(2),max_ii);
% match(3) = nimfr_at_sashe.filter3(max_ii)./he_vis_1.dirn_raw(pix(3),max_ii);
% match(4) = nimfr_at_sashe.filter4(max_ii)./he_vis_1.dirn_raw(pix(4),max_ii);
% track1 = nimfr_at_sashe.filter1./he_vis_1.dirn_raw(pix(1),:)./match(1);
% track2 = nimfr_at_sashe.filter2./he_vis_1.dirn_raw(pix(2),:)./match(2);
% track3 = nimfr_at_sashe.filter3./he_vis_1.dirn_raw(pix(3),:)./match(3);
% track4 = nimfr_at_sashe.filter4./he_vis_1.dirn_raw(pix(4),:)./match(4);
% track5 = nimfr_at_sashe.filter5./he_vis_1.dirn_raw(pix(5),:)./match(5);
% %%
% figure; plot(serial2Hh(nimfr.time), nimfr.vars.direct_normal_narrowband_filter2.data,'.');
% %%
% 
% figure; plot(serial2Hh(he_vis_1.time), he_vis_1.dS(pix(1),:)./he_vis_1.S(pix(1),:),'r.',...
%    serial2Hh(he_vis_2.time), he_vis_2.dS(pix(1),:)./he_vis_2.S(pix(1),:),'b.');
% %%
% figure; plot(wl,1./match,'-o');
% xlabel('wavelength')
% ylabel('sashe/nimfr')
% 
% %%
%  figure; plot(serial2doy(he_vis_1.time), [nimfr_at_sashe.filter1;nimfr_at_sashe.filter2;...
% nimfr_at_sashe.filter3;nimfr_at_sashe.filter4;nimfr_at_sashe.filter5],'.',...
% serial2doy(he_vis_1.time),[he_vis_1.dirn_raw(pix(1),:).*match(1);he_vis_1.dirn_raw(pix(2),:).*match(2);...
% he_vis_1.dirn_raw(pix(3),:).*match(3);he_vis_1.dirn_raw(pix(4),:).*match(4);he_vis_1.dirn_raw(pix(5),:).*match(5)],'x')
% %%
% figure; plot(serial2doy(he_vis_1.time), [1./track1;1./track2;1./track3;1./track4;1./track5; ], '.',...
%    serial2doy(he_vis_1.time),he_nir_1.cos_corr,'k.');
% legend('1','2','3','4','5')
% %%
% am = he_vis_1.saz<180;
% figure; plot(serial2doy(he_vis_1.time), he_vis_1.saz,'.')
% 
% %%
% figure; plot(cos(he_vis_1.sza(am).*pi./180), [1./track3(am);1./track4(am) ], '.',...
%     cos(he_vis_1.sza(am).*pi./180), he_nir_1.cos_corr(am),'k.');
% legend('3','4');
% 
% %%
% %%
% figure; plot(he_vis_1.sza(am), mean([1./track3(am);1./track4(am) ],1), '.',...
%     he_vis_1.sza(am), he_nir_1.cos_corr(am),'k.');
% legend('3','4');
% 
% %%
% % Determine new cosine correction for el>9
% am = he_vis_1.saz<180 & he_vis_1.sza<180;
% new_cos_corr(1,:) = [10:81];
% new_cos_corr(2,:) = interp1(cos(he_vis_1.sza(am).*pi./180), mean([1./track3(am);1./track4(am) ],1), cos([10:81].*pi./180),'pchip','extrap');
% new_cos_corr(2,new_cos_corr(2,:)<.3) = NaN;
% % new_cos_corr(2,new_cos_corr(1,:)<16) = 1;
% he_vis_1.new_cos_corr = interp1(cos(new_cos_corr(1,:).*pi./180), new_cos_corr(2,:),cos(he_vis_1.sza(am).*pi./180),'pchip','extrap');
% 
%  figure; plot(cos(he_vis_1.sza(am).*pi./180),...
%      he_vis_1.new_cos_corr,'b.',cos((10:81).*pi./180),new_cos_corr(2,:), 'r.');
%  
% he_vis_2.new_cos_corr = interp1(cos(new_cos_corr(1,:).*pi./180), new_cos_corr(2,:),cos(he_vis_2.sza(am).*pi./180),'pchip','extrap');
% %%
% % saveasp(new_cos_corr,'sgpsashe_coscorr_vs_nimfr_')
% %%
%  figure; plot(cos(he_vis_1.sza(am).*pi./180),...
%      mean([1./track3(am);1./track4(am) ],1),'b.',cos((10:81).*pi./180),new_cos_corr(2,:), 'r.')
% %    serial2doy(he_vis_1.time),he_nir_1.cos_corr,'k.');
% legend('1','2','3','4','5')
% %
% % Next, apply new_cos_corr to dirn, compute Langleys, TOA(pix), resp(pix)
% % Generate output, CSV
% %%
% figure; scatter(he_vis_1.sza, 1./track1, 8,[1:length(he_vis_1.sza)]);colorbar
% %%
% % Combine sequence 1 and 2
% [he_vis.time, it] = sort([he_vis_1.time, he_vis_2.time]);

%%

return