function sbs = Kassianov_plots

% HSRL plots for Evgueni:
% load hsrl file. Add time.  Concat up to 4 days.
% Develop  mask as the union of qc_mask~=1 with big (bscat > bscat_min) and
% thin (OD < OD_max)

in_list = getfullname('*.nc','hsrl');

sbs = anc_load(in_list{1});
sbs.time = epoch2serial(double(sbs.vdata.base_time) + sbs.vdata.time);
for in = 2:length(in_list)
    disp(['Loading ',in_list{in}])
sbs2 = anc_load(in_list{in});
sbs2.time = epoch2serial(double(sbs2.vdata.base_time) + sbs2.vdata.time);
sbs = anc_cat(sbs, sbs2);
end
bad = zeros(size(sbs.vdata.linear_depol));
bad(bitget(sbs.vdata.qc_mask,1)~=1) = NaN;

thin = double(sbs.vdata.od<1.25); thin(thin==0) = NaN;

big =double(sbs.vdata.beta_a_backscat>1e-8&sbs.vdata.beta_a_backscat<1e-6); big(~big)= NaN;


% figure; imagesc(serial2doys(sbs.time)-serial2doy(datenum(2011,3,0)), sbs.vdata.altitude-2759, real(log10((sbs.vdata.od)))); axis('xy'); ylim([0,12e3]);colorbar;

figure; imagesc(serial2doys(sbs.time)-serial2doy(datenum(2011,3,0)), sbs.vdata.altitude-2759, real(log10((100.*sbs.vdata.circular_depol+bad+thin+big)))); axis('xy'); 
ylim([0,12e3]);colorbar;caxis([-1,2]); ax(1) = gca;

figure; imagesc(serial2doys(sbs.time)-serial2doy(datenum(2011,3,0)), sbs.vdata.altitude-2759, real(log10((sbs.vdata.beta_a_backscat+bad)))); axis('xy'); 
ylim([0,12e3]);colorbar;; ax(2) = gca;
linkaxes(ax,'xy');


figure; 
imagesc(sbs.time, (sbs.vdata.altitude-2759)./1000, real(((100.*sbs.vdata.linear_depol+bad+thin+big)))); axis('xy'); 
ylim([0,15]); ylabel('km AGL'); 
xlabel('Date');dynamicDateTicks
cb = colorbar;caxis([0.1,100]); set(get(cb,'title'),'string','%')

return