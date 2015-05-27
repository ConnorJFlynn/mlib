
mpl = ancload('C:\case_studies\mplnor\hi_cld_tests\sgpmplnor1campC1.c1.20030105.000015.cdf');
%%
[atten_bscat,tau, ray_tod] = std_ray_atten(mpl.vars.height.data);
%%
n_height = length(mpl.vars.height.data);
bscat = mpl.vars.backscatter.data./((mpl.vars.height.data.^2)*ones([1,length(mpl.time)]));
height = mpl.vars.height.data;
mol = atten_bscat;
in_time = serial2Hh(mpl.time);
clear base top
tic
for t = length(mpl.time):-1:1
[base(t), top(t)] = cloud_zwang(height, bscat(:,t), mol, in_time(t));
end
toc
%
figure ;imagegap([1:length(mpl.time)],mpl.vars.height.data, real(log10(mpl.vars.backscatter.data))); colorbar
caxis([-3,1]); 
yl = ylim;
hold('on'); plot([1:length(mpl.time)], base, 'k.',[1:length(mpl.time)], top, 'k.');
hold('off')
ylim(yl);
zoom('on')
