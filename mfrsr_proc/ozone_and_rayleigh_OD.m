%%

cm = aod.vars.Ozone_column_amount.data./1000;
oz_od_filter1 = cm.* aod.vars.Ozone_absorption_coefficient_filter1.data;
oz_od_filter2 = cm.* aod.vars.Ozone_absorption_coefficient_filter2.data;
oz_od_filter3 = cm.* aod.vars.Ozone_absorption_coefficient_filter3.data;
oz_od_filter4 = cm.* aod.vars.Ozone_absorption_coefficient_filter4.data;
oz_od_filter5 = cm.* aod.vars.Ozone_absorption_coefficient_filter5.data;
oz_by_ray_filter1 = oz_od_filter1./aod.vars.Rayleigh_optical_depth_filter1.data;
oz_by_ray_filter2 = oz_od_filter2./aod.vars.Rayleigh_optical_depth_filter2.data;
oz_by_ray_filter3 = oz_od_filter3./aod.vars.Rayleigh_optical_depth_filter3.data;
oz_by_ray_filter4 = oz_od_filter4./aod.vars.Rayleigh_optical_depth_filter4.data;
oz_by_ray_filter5 = oz_od_filter5./aod.vars.Rayleigh_optical_depth_filter5.data;

%%
figure; s(1) = subplot(2,1,1); plot([415,500,615,676,870],...
   [oz_od_filter1,oz_od_filter2,oz_od_filter3,oz_od_filter4,oz_od_filter5],'-o');
ylabel('od');
xlabel('nm');
s(2) = subplot(2,1,2);
plot([415,500,615,676,870],...
   [oz_by_ray_filter1,oz_by_ray_filter2,oz_by_ray_filter3,oz_by_ray_filter4,oz_by_ray_filter5],'-o');
ylabel('od by ray');
xlabel('nm');
linkaxes(s,'x')

%%