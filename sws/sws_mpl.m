%%
sws = ancload(getfullname_('*.cdf','sws','Select sws file.'));
%%

sws_aux = ancload(getfullname_('*.cdf','sws_aux','Select SWS aux file.'));
%%
figure; 
ax(1) = subplot(3,1,1); semilogy(serial2Hh(sws.time), sws.vars.zen_spec_calib.data(300,:),'r-')
title('SWS InGaAs problem');
ylabel('radiance');
legend('1.6 um, InGaAs')
ax(2) = subplot(3,1,2); plot(serial2Hh(sws_aux.time), sws_aux.vars.InGaAs_spect_temp.data,'.');
ylabel('InGaAs Temp (C)')
ax(3) = subplot(3,1,3); semilogy(serial2Hh(sws.time), sws.vars.zen_spec_calib.data(132,:), 'g'); 
ylabel('radiance');
legend('789 nm, Si')
linkaxes(ax,'x'); zoom('on')
xlim(xl)

%%
sws_noon = ancload(getfullname_('*.cdf','sws','Select sws file.'));
%%
figure; semilogy(serial2Hh(sws_noon.time), sws_noon.vars.zen_spec_calib.data([100,200,300,400],:),'-');
title('sky radiance, Oct 31 2008')
ylabel('radiance W/m^2/nm/sr')
xlabel('hours UTC');
legend(sprintf('%1.0f nm',sws_noon.vars.wavelength.data(100)),sprintf('%1.0f nm',sws_noon.vars.wavelength.data(200)),...
   sprintf('%1.0f nm',sws_noon.vars.wavelength.data(300)),sprintf('%1.0f nm',sws_noon.vars.wavelength.data(400)))

%%

mpl = ancload(getfullname_('*.cdf','mpl','Select mpl file.'));
%%
vceil = ancload(getfullname_('*.cdf','vceil','Select mpl file.'));
%%
cop = mpl.vars.polarization_control_voltage.data < mean(mpl.vars.polarization_control_voltage.data);
%%
figure; semilogy(mpl.vars.range.data, mean(mpl.vars.signal_return.data(:,cop),2),'r.',...
    mpl.vars.range.data, mean(mpl.vars.signal_return.data(:,~cop),2), 'b.');
legend('cop','crs')
%%
w = madf_span(sws.vars.zen_spec_calib.data(53,:),10,3);
w(w) = madf_span(sws.vars.zen_spec_calib.data(53,w),10,3);
w_526 = 53;
a = .25*.032*.031/(.033*.0314);
b = .002*.029./.034;
mpl_bg = apply_generic_dtc(40*mpl.vars.background_signal.data)./40;
figure; semilogy(serial2Hh(vceil.time), b.*vceil.vars.background_light.data, 'r.',...
    serial2Hh(mpl.time(~cop)), a.* mpl_bg(~cop), 'c.',...
    serial2Hh(mpl.time(cop)), a.* mpl_bg(cop), 'g.',...
        serial2Hh(sws.time(w)), sws.vars.zen_spec_calib.data(53,w),'k.')
%%
size(mpl.vars.signal_return.data)
%%
