
mpl = ancload('C:\case_studies\mplnor\hi_cld_tests\sgpmplnor1campC1.c1.20030105.000015.cdf');
%%
% figure ;imagegap([1:length(mpl.time)],mpl.vars.height.data, real(log10(mpl.vars.backscatter.data))); colorbar
% caxis([-3,1]); zoom('on')
%%
[atten_bscat,tau, ray_tod] = std_ray_atten(mpl.vars.height.data);
%%
n_height = length(mpl.vars.height.data);
bscat = 10000.*mpl.vars.backscatter.data./((mpl.vars.height.data.^2)*ones([1,length(mpl.time)]));
height = mpl.vars.height.data;
mol = 25.*atten_bscat;
clear base top bs tp
for t = length(mpl.time):-1:1
   disp(t)
tim = serial2Hh(mpl.time(t));
bs = NaN; tp = NaN;
[bs, tp] = MPLbase_sub1(tim,n_height , double(bscat(:,t)) ,double(height) , double(mol) );
base(t) = bs; top(t) = tp;
end
%
figure ;imagegap([1:length(mpl.time)],mpl.vars.height.data, real(log10(mpl.vars.backscatter.data))); colorbar
caxis([-3,1]); 
yl = ylim;
hold('on'); plot([1:length(mpl.time)], base, 'ko',[1:length(mpl.time)], top, 'kx');
hold('off')
ylim(yl);
zoom('on')

%%
figure; semilogy(height, mpl.vars.backscatter.data(:,120)./50,'k-', height, 1e2.*atten_bscat,'r-')