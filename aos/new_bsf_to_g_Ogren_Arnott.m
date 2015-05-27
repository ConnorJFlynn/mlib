aip = ancload;
%%
bsf = aip.vars.bsf_G_Dry_1um.data;
%%
bsf = .3;
a = -7.143889;
b = 7.464439;
c = -3.96356;
d = 0.9893;

g = a.*bsf.^3 + b.*bsf.^2 + c.*bsf + d;

good = bsf>0 & g>0 & g<1 & bsf<1 & aip.vars.asymmetry_parameter_G_Dry_1um.data>0 & aip.vars.asymmetry_parameter_G_Dry_1um.data<1;
figure; plot(serial2doy(aip.time(good)), [aip.vars.asymmetry_parameter_G_Dry_1um.data(good); g(good)],'x');
legend('old','new');
%%
P = polyfit(aip.vars.asymmetry_parameter_G_Dry_1um.data(good), g(good),1);
figure; plot(aip.vars.asymmetry_parameter_G_Dry_1um.data(good), g(good), '.',...
   [0,1],[0,1],'r--',...
   aip.vars.asymmetry_parameter_G_Dry_1um.data(good), polyval(P,aip.vars.asymmetry_parameter_G_Dry_1um.data(good)),'k-');
title({['Old: ',aip.vars.asymmetry_parameter_G_Dry_1um.atts.equation.data(45:end)];...
   ['new: g =-7.143889.*bsf.^3 + 7.464439.*bsf.^2 - 3.96356.*bsf + 0.9893;']})
xlabel('old two-part fit');
ylabel('new fit of g from bsf');
%%

hist(aip.vars.asymmetry_parameter_G_Dry_1um.data(good),50)
title(['old fit: ',aip.vars.asymmetry_parameter_G_Dry_1um.atts.equation.data(45:end)]);
%%
figure;
hist(g(good),50)
title({['new: g =-7.143889.*bsf.^3 + 7.464439.*bsf.^2 - 3.96356.*bsf + 0.9893;']})