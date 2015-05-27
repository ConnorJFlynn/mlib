sasze = ancload(getfullname_('pvc*.cdf','pvcsasze'));
%%

fields = fieldnames(sasze.vars);
wavelength = [];
for f = 1:length(fields)
    fld = fields{f};
    if ~isempty(strfind(fld,'zenith_radiance_'))||~isempty(strfind(fld,'zenith_transmittance_'))
        sasze.vars.(fld).data(sasze.vars.(fld).data<-1) = NaN;
            wavelength = unique([wavelength, sscanf(fld, 'zenith_transmittance_%d')]);
    end


    
end
sasze.vars.wavelength.data = wavelength;
for wl = length(wavelength):-1:1
    sasze.vars.zenith_transmittance.data(wl,:) = sasze.vars.(sprintf('zenith_transmittance_%dnm',wavelength(wl))).data;
end

good_wl = wavelength>0;
good_wl(wavelength>760&wavelength<770) = false;
good_wl(wavelength>933&wavelength<960) = false;
good_wl(wavelength>1100&wavelength<1200) = false;
good_wl(wavelength>1250&wavelength<1525) = false;
good_wl(wavelength>970&wavelength<980) = false;
good_t = sasze.vars.solar_zenith.data < 73;
good_ti = find(good_t);
figure; lines = plot(sasze.vars.wavelength.data(good_wl), sasze.vars.zenith_transmittance.data(good_wl,good_ti(1:100:end)),'-'); recolor(lines,serial2Hh(sasze.time(good_ti(1:100:end)))); colorbar
% radiance units W/(m^2 um sr)
%% NFOV2
nfov2 = ancload(getfullname_('pvc*.cdf','pvcnfov2'));
nfov2 = anccat(nfov2, ancload(getfullname_('pvc*.cdf','pvcnfov2')));

%%
ppl = aeronet_zenith_radiance;
% units µW/cm^2/sr/nm = mW/cm^2/sr/um
%  ==> W/cm2/sr/um
% 
%%
cldrad = read_chiu_cloudrads;
% W/m/sr/micron

%%
if exist('ppl','var')&&exist('sasze','var')
    ppl_t = ppl.time>sasze.time(1)&ppl.time<sasze.time(end);
end
if exist('cldrad','var')&&exist('sasze','var')
    cld_t = cldrad.time>sasze.time(1) & cldrad.time<sasze.time(end);
end
%  0.4400    0.5000    0.6700    0.8700    1.0200    1.6400
% ( '440 nm', '500 nm', '675 nm', '870 nm','1020 nm', '1640 nm');
figure; 
ax(1) = subplot(2,2,1);
plot(serial2doy(sasze.time), sasze.vars.zenith_radiance_500nm.data,'-k',...
    serial2doy(ppl.time(ppl_t)), ppl.zen_rad_500_nm(ppl_t),'o',...
    serial2doy(cldrad.time(cld_t)), cldrad.sunrad(cld_t,2),'rx',...
    serial2doy(cldrad.time(cld_t)), cldrad.skyrad(cld_t,2),'c+');
legend('sasze','cimel PPL sky','cimel cldsun','cimel cldsky','location','northwest');
title('500 nm')
ylabel('W/(m^2 um sr)')
ax(2) = subplot(2,2,2);
plot(serial2doy(nfov2.time), 1000.*nfov2.vars.radiance_673nm.data-6.1,'r',...
    serial2doy(sasze.time), sasze.vars.zenith_radiance_673nm.data,'-k',...
    serial2doy(ppl.time(ppl_t)), ppl.zen_rad_670_nm(ppl_t),'o',...
    serial2doy(cldrad.time(cld_t)), cldrad.sunrad(cld_t,3),'rx',...
    serial2doy(cldrad.time(cld_t)), cldrad.skyrad(cld_t,3),'c+');
title('673 nm')
legend('nfov2','sasze','cimel PPL sky','cimel cldsun','cimel cldsky','location','northwest');
ylabel('W/(m^2 um sr)')
ax(3) = subplot(2,2,3);
plot(serial2doy(nfov2.time), 1000.*nfov2.vars.radiance_870nm.data-6.1,'r',...
    serial2doy(sasze.time), sasze.vars.zenith_radiance_870nm.data,'-k',...
    serial2doy(ppl.time(ppl_t)), ppl.zen_rad_870_nm(ppl_t),'o',...
    serial2doy(cldrad.time(cld_t)), cldrad.sunrad(cld_t,4),'rx',...
    serial2doy(cldrad.time(cld_t)), cldrad.skyrad(cld_t,4),'c+');
title('870 nm')
legend('nfov2','sasze','cimel PPL sky','cimel cldsun','cimel cldsky','location','northwest');
ylabel('W/(m^2 um sr)')
ax(4) = subplot(2,2,4);
plot(serial2doy(sasze.time), sasze.vars.zenith_radiance_1637nm.data,'-k',...
    serial2doy(ppl.time(ppl_t)), ppl.zen_rad_1640_nm(ppl_t),'o',...
    serial2doy(cldrad.time(cld_t)), cldrad.sunrad(cld_t,6),'rx',...
    serial2doy(cldrad.time(cld_t)), cldrad.skyrad(cld_t,6),'c+');
title('1640 nm')
legend('sasze','cimel PPL sky','cimel cldsun','cimel cldsky','location','northwest');
ylabel('W/(m^2 um sr)')
linkaxes(ax,'x')
zoom('on')
