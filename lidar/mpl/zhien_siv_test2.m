
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
figure ;imagegap([1:length(mpl.time)],mpl.vars.height.data, real(log10(mpl.vars.backscatter.data))); colorbar
caxis([-3,1]); 
ylim([0,15]);
yl = ylim;
figure
hcb = zeros([50,length(in_time)]);
hct = zeros([50],length(in_time));

tic

for t = length(mpl.time):-1:1
% for t = 1050:-1:1
    gtz = mpl.vars.backscatter.data(:,t)>0;
    semilogy(height(gtz), mpl.vars.backscatter.data(gtz,t),'r-');
    title(num2str(t));
  [base(t),top(t),hcb(:,t),hct(:,t),ii(t)] = cloud_zwang2(height, bscat(:,t), mol, in_time(t));

%  pause(.05);

end
toc
%
figure ;imagegap([1:length(mpl.time)],mpl.vars.height.data, real(log10(mpl.vars.backscatter.data))); colorbar
caxis([-3,1]); 
ylim(yl);
hold('on'); plot([1:length(mpl.time(1:1050))], base, 'k.',[1:length(mpl.time(1:1050))], top, 'k.');
hold('off')
ylim(yl);
zoom('on')
