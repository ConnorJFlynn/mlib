function sws_mono_cat = sws_new_nir_art;

% Load monoscan data one directory at a time, subtracting appropriate
% darks, stripping records when monochromator was moving, taking final
% averages.

%  C:\case_studies\SWS\calibration\sws_art_all\sws_art_nir\Feb3_tint_60ms
% load dark
%%
pname = ['D:\case_studies\SWS\calibration\sws_art_all\sws_art_nir\Feb3_tint_60ms\'];
pname = ['D:\case_studies\SWS\calibration\sws_art_all\sws_art_nir\Feb4_dual_800_1100nm_200ms\'];
darkfile = ['dark\sgpswscf.00.20110203.104355.raw.dat'];
darkfile = ['dark\sgpswscf.00.20110204.115046.raw.dat'];
sws_60 = read_sws_raw([pname, darkfile]);
dark = mean(sws_60.In_DN,2);
%%
files = dir([pname, 'sgpsws*.dat']);
sws_60 = read_sws_raw([pname,files(1).name]);
for f = 2:length(files)
   sws_60 = cat_sws_raw(sws_60,read_sws_raw([pname,files(f).name]));
end
      
%%
sws_60.In_spec = (sws_60.In_DN - dark * ones(size(sws_60.time)))./unique(sws_60.In_ms);
%%
figure; lines = plot(sws_60.In_lambda, sws_60.In_spec,'-');
recolor(lines,[1:length(sws_60.time)]);
colorbar
hold('on');
lines = plot(sws_60.Si_lambda, sws_60.Si_spec,'-');
recolor(lines,[1:length(sws_60.time)]);
%  C:\case_studies\SWS\calibration\sws_art_all\sws_art_nir\Feb3_tint_60ms
% load dark
%%
pname = ['C:\case_studies\SWS\calibration\sws_art_all\sws_art_nir\Feb3_single_mono_1100LP_tint_90ms\'];
darkfile = ['\dark\sgpswscf.00.20110203.121030.raw.dat'];
sws = read_sws_raw([pname, darkfile]);
pix = sws.In_lambda>1585 & sws.In_lambda<1590;
dark_t = sws.In_DN(pix,:)<100;
dark_90 = mean(sws.In_DN(:,dark_t),2);
%%
files = dir([pname, 'sgpsws*.dat']);
sws_90 = read_sws_raw([pname,files(1).name]);
for f = 2:length(files)
   sws_90 = cat_sws_raw(sws_90,read_sws_raw([pname,files(f).name]));
end
      
%%
sws_90.In_spec = (sws_90.In_DN - dark_90 * ones(size(sws_90.time)))./unique(sws_90.In_ms);
%%
figure; lines = semilogy(sws_90.In_lambda, sws_90.In_spec,'-');
recolor(lines,[1:length(sws_90.time)]);
colorbar

%%
pname = ['C:\case_studies\SWS\calibration\sws_art_all\sws_art_nir\Feb3_single_mono_1100LP_tint_200ms\'];
darkfile = ['\dark\sgpswscf.00.20110203.124703.raw.dat'];
sws = read_sws_raw([pname, darkfile]);
pix = sws.In_lambda>1805 & sws.In_lambda<1810;
dark_t = sws.In_DN(pix,:)<5000;
dark_200 = mean(sws.In_DN(:,dark_t),2);
%%
files = dir([pname, 'sgpsws*.dat']);
sws_200 = read_sws_raw([pname,files(1).name]);
for f = 2:length(files)
   sws_200 = cat_sws_raw(sws_200,read_sws_raw([pname,files(f).name]));
end
      
%%
sws_200.In_spec = (sws_200.In_DN - dark_200 * ones(size(sws_200.time)))./unique(sws_200.In_ms);
%%
figure; lines = semilogy(sws_200.In_lambda, sws_200.In_spec,'-');
recolor(lines,[1:length(sws_200.time)]);
colorbar

%%
pname = ['C:\case_studies\SWS\calibration\sws_art_all\sws_art_nir\Feb3_single_mono_1100LP_tint_400ms\'];
darkfile = ['\dark\sgpswscf.00.20110203.130338.raw.dat'];
sws = read_sws_raw([pname, darkfile]);
pix = sws.In_lambda>1935 & sws.In_lambda<1940;
dark_t = sws.In_DN(pix,:)<10000;
dark_400 = mean(sws.In_DN(:,dark_t),2);
%%
files = dir([pname, 'sgpsws*.dat']);
sws_400 = read_sws_raw([pname,files(1).name]);
for f = 2:length(files)
   sws_400 = cat_sws_raw(sws_400,read_sws_raw([pname,files(f).name]));
end
      
%%
sws_400.In_spec = (sws_400.In_DN - dark_400 * ones(size(sws_400.time)))./unique(sws_400.In_ms);
%%
figure; lines = semilogy(sws_400.In_lambda, sws_400.In_spec,'-');
recolor(lines,[1:length(sws_400.time)]);
colorbar

%%
pname = ['C:\case_studies\SWS\calibration\sws_art_all\sws_art_nir\Feb4_dual_800_1100nm_200ms\'];
darkfile = ['\dark\sgpswscf.00.20110204.115046.raw.dat'];
sws = read_sws_raw([pname, darkfile]);
pix = sws.In_lambda>2035 & sws.In_lambda<2040;
dark_t = sws.In_DN(pix,:)<10000;
dark_200_dual = mean(sws.In_DN(:,dark_t),2);
%%
files = dir([pname, 'sgpsws*.dat']);
sws_200_dual = read_sws_raw([pname,files(1).name]);
for f = 2:length(files)
   sws_200_dual = cat_sws_raw(sws_200_dual,read_sws_raw([pname,files(f).name]));
end
      
%%
sws_200_dual.In_spec = (sws_200_dual.In_DN - dark_200_dual * ones(size(sws_200_dual.time)))./unique(sws_200_dual.In_ms);
%%
figure; lines = semilogy(sws_200_dual.In_lambda, sws_200_dual.In_spec,'-');
recolor(lines,[1:length(sws_200_dual.time)]);
colorbar

%%
%%
pname = ['C:\case_studies\SWS\calibration\sws_art_all\sws_art_nir\Feb4_dual_800_1100nm_100ms\'];
darkfile = ['\dark\sgpswscf.00.20110204.121313.raw.dat'];
sws = read_sws_raw([pname, darkfile]);
pix = sws.In_lambda>1115 & sws.In_lambda<1120;
dark_t = sws.In_DN(pix,:)<1000;
dark_100 = mean(sws.In_DN(:,dark_t),2);
%%
files = dir([pname, 'sgpsws*.dat']);
sws_100 = read_sws_raw([pname,files(1).name]);
for f = 2:length(files)
   sws_100 = cat_sws_raw(sws_100,read_sws_raw([pname,files(f).name]));
end
      
%%
sws_100.In_spec = (sws_100.In_DN - dark_100 * ones(size(sws_100.time)))./unique(sws_100.In_ms);
%%
figure; lines = semilogy(sws_100.In_lambda, sws_100.In_spec,'-');
recolor(lines,[1:length(sws_100.time)]);
colorbar

%%

% Not bad.  Now step through each of the sws_* structs to identify
% contiguous maxima indices.  Take the mean of 
% Looks pretty good.  Maybe something, lambda/2 1050 to 1100 nm. 
sws_mono_cat.In_lambda = sws_60.In_lambda;
sws_mono_cat.In_spec = [sws_60.In_spec, sws_90.In_spec, sws_200.In_spec, ...
   sws_400.In_spec, sws_200_dual.In_spec, sws_100.In_spec];
[sws_mono_cat.In_max, sws_mono_cat.max_ii] = max(sws_mono_cat.In_spec);
same = false(size(sws_mono_cat.In_max));
same(2:end) = sws_mono_cat.max_ii(1:end-1)==sws_mono_cat.max_ii(2:end);
%%
s = 0;
ss = 0;
while s < length(same)
   s = s +1;
   while same(s)
      ss = ss +1;
      while same(s)
         s = s +1;
      end
   end
end
sws_mono_cat.In_peak = NaN([length(sws_mono_cat.In_lambda),ss]);
sws_mono_cat.peak_nm = NaN([1,ss]);
sws_mono_cat.peak_num = NaN([1,ss]);
s = 0;
ss = 0;
while s < length(same)
   s = s +1;
   while same(s)
      ss = ss +1;
      n = 0;
      In_spec = sws_mono_cat.In_spec(:,s);
      peak_nm = sws_mono_cat.In_lambda(sws_mono_cat.max_ii(s));
      while same(s)
         n = n + 1;
         s = s +1;
         In_spec = sws_mono_cat.In_spec(:,s)+ In_spec;
      end
       sws_mono_cat.In_peak(:,ss)= In_spec./n;
       sws_mono_cat.peak_nm(ss) = peak_nm;
       sws_mono_cat.peak_num(ss) = n;
   end
end
% now we know how many peaks
%%
peak_nm = sws_mono_cat.peak_nm;
%%
[sws_mono_cat.peak_nm,inds] = unique(peak_nm);
sws_mono_cat.peak_num = sws_mono_cat.peak_num(inds);
sws_mono_cat.In_peak= sws_mono_cat.In_peak(:,inds);

%%
maxes = max(sws_mono_cat.In_peak);
%%
sws_mono_cat.peak_nm(maxes<2)= [];
sws_mono_cat.peak_num(maxes<2)= [];
sws_mono_cat.In_peak(:,maxes<2) = [];
%%
sws_mono_cat.In_sig = sws_mono_cat.In_peak ./ (ones(size(sws_mono_cat.In_lambda))*max(sws_mono_cat.In_peak))
%%
figure;
imagegap(sws_mono_cat.In_lambda, sws_mono_cat.peak_nm,  sws_mono_cat.In_peak'); axis('xy')

%%
figure;
imagegap(sws_mono_cat.In_lambda, sws_mono_cat.peak_nm,  real(log10(sws_mono_cat.In_sig'))); axis('xy')
colorbar;
caxis([-4,0]);
%%
figure;
imagegap(sws_mono_cat.peak_nm,sws_mono_cat.In_lambda,   real(log10(sws_mono_cat.In_sig))); axis('xy')
colorbar;
caxis([-4,0]);
xlabel('monochromator wavelength');
ylabel('spectrometer pixel wavelength');
saveas(gcf,['C:\case_studies\SWS\calibration\sws_art_all\sws_nir_post_replacement_monoscan.png'])
%%
figure; plot([1:length(sws_mono_cat.peak_nm)],max(sws_mono_cat.In_peak),'o')
%%
return
      
      
      
%%