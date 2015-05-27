% These scraps were used to investigate anomolous behavior from the MFRSR
% at Barrow during the period of 24-hour sun.  It appears that it is an 
% inherent inability of the band to rotate a full 360 degrees. 
%%
a0 = ancload('*nsamfrsrC1.*.cdf','nsamfrsr');
%%
b1 = ancload('*nsamfrsrC1.*.cdf','nsamfrsr');
c1 = ancload('*nsamfrsraod1michC1.*.cdf','nsamfrsr');
%%
b1_ = ancload('nsamfrsrC1.*.cdf','nsamfrsr_prob');
c1_ = ancload('*nsamfrsraod1michC1.*.cdf','nsamfrsr_prob');
%%
figure; 
s(1) = subplot(2,1,1); 
plot(serial2doy(b1_.time), b1_.vars.direct_horizontal_narrowband_filter5.data, 'o', ...
serial2doy(c1_.time), c1_.vars.direct_horizontal_narrowband_filter5.data, '.');
title('direct horizontal filter5');
legend('b1 new','c1 new');
s(2) = subplot(2,1,2); 
plot(serial2doy(b1.time), b1.vars.direct_horizontal_narrowband_filter5.data, 'o', ...
serial2doy(c1.time), c1.vars.direct_horizontal_narrowband_filter5.data, '.');
legend('b1 old','c1 old');
linkaxes(s,'xy');

%%
figure; 
plot(serial2doy(a0.time), [a0.vars.hemisp_narrowband_filter5.data;a0.vars.diffuse_hemisp_narrowband_filter5.data;...
    a0.vars.direct_horizontal_narrowband_filter5.data;], '.');
legend('total hemisp','diffuse hemisp','direct horiz');
ylabel('raw counts')
xlabel('day of year')
[pname,fname,ext] = fileparts(a0.fname);
title(fname, 'interp','none')
%%
figure; 
s(1) = subplot(2,1,1); 
plot(serial2doy(b1_.time), b1_.vars.diffuse_hemisp_narrowband_filter5.data, 'o', ...
serial2doy(c1_.time), c1_.vars.diffuse_hemisp_narrowband_filter5.data, '.');

legend('b1 new','c1 new');
title('diffuse hemispheric filter 5')
s(2) = subplot(2,1,2); 
plot(serial2doy(b1.time), b1.vars.diffuse_hemisp_narrowband_filter5.data, 'o', ...
serial2doy(c1.time), c1.vars.diffuse_hemisp_narrowband_filter5.data, '.');
legend('b1 old','c1 old');
linkaxes(s,'xy')

%%
figure; plot(serial2doy(c1.time), 90-c1.vars.solar_zenith_angle.data,'.');
s(3) = gca;
title('solar elevation angle');

%%
figure; plot(serial2doy(b1_.time), [b1_.vars.computed_cosine_correction_filter1.data;...
    b1_.vars.computed_cosine_correction_filter2.data; b1_.vars.computed_cosine_correction_filter3.data;...
    b1_.vars.computed_cosine_correction_filter4.data;b1_.vars.computed_cosine_correction_filter5.data;],'.')
