function assess_sgpmplpolfsb1_2015

if ~exist('mpl_inarg','var')
   mpl_inarg = define_mpl_inarg;
else
   mpl_inarg = populate_mpl_inarg(mpl_inarg);
end

batch_fsb1todaily(mpl_inarg)


mplb1 = anc_load;

figure_(4); 
imagesc(serial2Hh(mplb1.time), mplb1.vdata.height,...
    real(log10(mplb1.vdata.signal_return_co_pol-...
    ones([length(mplb1.vdata.height),1])*mplb1.vdata.background_signal_co_pol))); 
axis('xy'); ylim([0,20]);
menu('Zoom into a period to use for Rayleigh normalization.','OK, done')
tl = xlim; tl_ = serial2Hh(mplb1.time)>tl(1)&serial2Hh(mplb1.time)<tl(2);
mean_mpl = mean(mplb1.vdata.signal_return_co_pol(:,tl_)-ones([length(mplb1.vdata.height),1])...
    *mplb1.vdata.background_signal_co_pol(tl_));

ray = std_ray_atten(mplb1.vdata.height);
ray(mplb1.vdata.height<0)=NaN;
ray_by_r2 = ray./(mplb1.vdata.height.^2);

ol = interp1(mplb1.vdata.overlap_correction_heights,mplb1.vdata.overlap_correction,mplb1.vdata.height,'linear');
ol(isnan(ol)&mplb1.vdata.height>0)= 1;

r_cal = mplb1.vdata.height>10&mplb1.vdata.height<15;
ray_cal = mean(ray_by_r2(r_cal)./mean_mpl(r_cal));
figure_(5); 
plot(mplb1.vdata.height, mean_mpl.*ray_cal,'-', ...
    mplb1.vdata.height, ray./(mplb1.vdata.height.^2),'r-' ); logy

figure_(6); plot(mplb1.vdata.height, ray./ol,'-',mplb1.vdata.height, ray,'r--'); logy


return