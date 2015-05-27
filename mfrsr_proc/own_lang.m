function lang = own_lang;
% It's not clear that this function is needed at all.  It may be entirely
% superceded by common_mfr_lang and dependents.
%%
in_dir = 'E:\case_studies\fkb\fkbmfrsrM1.b1\';
in_file = dir([in_dir, 'fkbmfrsr*.cdf']);
%%
for in = 1:length(in_file)
   disp(['reading ',num2str(in),' of ',num2str(length(in_file))])
day = ancload([in_dir, in_file(in).name]);

am = day.vars.direct_normal_narrowband_filter5.data > 0 & day.vars.airmass.data > 0 & day.vars.azimuth_angle.data <180 & day.vars.elevation_angle.data >14;
pm = day.vars.direct_normal_narrowband_filter5.data > 0 & day.vars.airmass.data > 0 & day.vars.azimuth_angle.data >180& day.vars.elevation_angle.data >18;
if sum(am)>100
[lang.Vo(1+2*(in-1)),lang.tau(1+2*(in-1)),lang.Vo_(1+2*(in-1)), lang.tau_(1+2*(in-1)), good] = ...
   dbl_lang(day.vars.airmass.data(am),day.vars.direct_normal_narrowband_filter5.data(am),2,50,5,2);

lang.time(1+2*(in-1)) = mean(day.time(good)); lang.Ngood(1+2*(in-1))= sum(good); 
lang.good_1(1+2*(in-1)) = min(day.time(good)); lang.good_end(1+2*(in-1)) = max(day.time(good));
else
   lang.Vo(1+2*(in-1)) = NaN;
   lang.tau(1+2*(in-1)) = NaN;
   lang.Vo_(1+2*(in-1)) = NaN;
   lang.tau_(1+2*(in-1))= NaN;
   lang.time(1+2*(in-1)) = day.time(1);
   lang.Ngood(1+2*(in-1))= sum(am); 
   lang.good_1(1+2*(in-1)) = day.time(min([1,find(am)])); 
   lang.good_end(1+2*(in-1)) = day.time(max([1,find(am)]));
end
if sum(pm)>100
[lang.Vo(2*in),lang.tau(2*in),lang.Vo_(2*in), lang.tau_(2*in), good] = dbl_lang(day.vars.airmass.data(pm),day.vars.direct_normal_narrowband_filter5.data(pm),2,50,5,2);
lang.Ngood(2*in)= sum(good); lang.good_1(2*in) = min(day.time(good)); lang.good_end(1+2*in) = max(day.time(good));
lang.time(2*in) = mean(day.time(good));
else
   lang.Vo(2*in) = NaN;
   lang.tau(2*in) = NaN;
   lang.Vo_(2*in) = NaN;
   lang.tau_(2*in)= NaN;
   lang.time(2*in) = day.time(end)
   lang.Ngood(2*in)= sum(am); 
   lang.good_1(2*in) = day.time(min([1,find(am)])); 
   lang.good_end(2*in) = day.time(max([1,find(am)]));
end
end
 
