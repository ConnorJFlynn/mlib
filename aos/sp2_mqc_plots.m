function sp2_bcm = sp2_mqc_plots(sp2_bcm)
%sp2_bcm = sp2_mqc_plots(sp2_bcm)
% Generates several plots from Art's SP2 rBC mentor-edited files.

if ~exist('sp2_bcm','var')
   sp2_bcm = getfullname('*.sp2.*.m02.*','sp2_rbc','Select an mentor-edited SP2 file.');
end

if ~isstruct(sp2_bcm) % then it is a filename so read the corresponding file
   if ~isempty(strfind(sp2_bcm,'.mat'))
      sp2_bcm = load(sp2_bcm); % if it is a mat file, load it.
   elseif ~isempty(strfind(sp2_bcm,'.nc'))||~isempty(strfind(sp2_bcm,'.cdf'))
      sp2_bcm = anc_load(sp2_bcm); % if it is a netcdf file, anc_load it
   else
      sp2_bcm = rd_sp2_m02(sp2_bcm); % else it must be Art's csv file, so read it.
   end
end
   

% time series
figure(25); plot(serial2doys(sp2_bcm.time), sp2_bcm.vdata.rBC,'k.');
title(['Refractory BC mass concentration ',datestr(sp2_bcm.time(1),'yyyy-mm-dd HH:MM')]);
ylab = ylabel(sp2_bcm.vatts.rBC.units); 
xlabel(['day of year [',num2str(serial2doys(floor(sp2_bcm.time(1)))),' = ',datestr(floor(sp2_bcm.time(1)),'mmm dd'),']']);
xl = xlim(gca);

% time x diameter x N image plot for scattering and incandesence 
figure(26); 
s(1) = subplot(2,1,1); imagesc(serial2doys(sp2_bcm.time), sp2_bcm.vdata.diameter_geo, ...
   real((sp2_bcm.vdata.N_dN))); axis('xy'); colorbar;
title('size-resolved counts (incand.)'); 
ylabel('incand. [dNlogDp]'); 
caxis([0,60]); 
s(2) = subplot(2,1,2); imagesc(serial2doys(sp2_bcm.time), sp2_bcm.vdata.diameter_geo, ...
   real((sp2_bcm.vdata.N_dN_scattering))); axis('xy'); colorbar;
title('size-resolved counts (scattering)'); 
ylabel('scat. [dNlogDp]'); 
caxis([0,200]); 

xlabel(['day of year [',num2str(serial2doys(floor(sp2_bcm.time(1)))),' = ',datestr(floor(sp2_bcm.time(1)),'mmm dd'),']']);
linkaxes(s,'xy');

figure(26); 
s(1) = subplot(2,1,1); imagesc(serial2doys(sp2_bcm.time), sp2_bcm.vdata.diameter_geo, ...
   real(log10(sp2_bcm.vdata.N_dN))); axis('xy'); colorbar;
title('size-resolved counts log10(incand.)'); 
ylabel('incand. [dNlogDp]'); 
caxis([0,2]); 
s(2) = subplot(2,1,2); imagesc(serial2doys(sp2_bcm.time), sp2_bcm.vdata.diameter_geo, ...
   real(log10(sp2_bcm.vdata.N_dN_scattering))); axis('xy'); colorbar;
title('size-resolved counts log10(scattering)'); 
ylabel('scat. [dNlogDp]'); 
caxis([0,3]); 

xlabel(['day of year [',num2str(serial2doys(floor(sp2_bcm.time(1)))),' = ',datestr(floor(sp2_bcm.time(1)),'mmm dd'),']']);
linkaxes(s,'xy');

OK = menu('Zoom in to figure 26 to select a desired time and size range, then select "OK".','OK');

xl = xlim(s(1))
xl_ = serial2doys(sp2_bcm.time)>= xl(1) &serial2doys(sp2_bcm.time)<= xl(2);
% get ylim and apply to xlim of line plot
yl = ylim(s(1));



figure(27); ax(1) = subplot(2,1,1); these = plot(sp2_bcm.vdata.diameter_geo, sp2_bcm.vdata.N_dN(:,xl_),'-');
recolor(these, serial2hs(sp2_bcm.time(xl_))); cb1 = colorbar('location','North')
tl1 = title(['SP2 counts (incand) ',datestr(min(sp2_bcm.time(xl_)),'yyyy-mm-dd HH:MM')]);
ylabel(['counts dN/logDp']);
ax(2) = subplot(2,1,2); those = plot(sp2_bcm.vdata.diameter_geo, sp2_bcm.vdata.N_dN_scattering(:,xl_),'-');
recolor(those, serial2hs(sp2_bcm.time(xl_))); 
tl2 = title(['SP2 counts (scattering) ',datestr(min(sp2_bcm.time(xl_)),'yyyy-mm-dd HH:MM')]);
xlabel('diameter size bin [um]');
ylabel(['counts dN/logDp']);
yl_scat = ylim(ax(2));
linkaxes(ax,'xy')
ylim(yl_scat);
xlim(ax(1),yl)

return
