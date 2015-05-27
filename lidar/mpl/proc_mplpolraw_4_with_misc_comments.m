function [polavg,ind] = proc_mplpolraw_4(mplpol,inarg)
%[polavg,ind] = proc_mplpolraw_4(mplpol,inarg)
% mplpol is a struct with mplpol lidar data
% inarg has the following optional elements 
%    .outdir 
%    .Nsecs
%    .ldr_snr
% polavg contains averaged mplpol data
% ind contains index of last used value from mplpol

% 2008/05/21 fixed ldr_snr computations
% Adding functional stubs back in

if ~exist('mplpol','var')||isempty(mplpol)
   mplpol = rd_Sigma;
   disp('Loaded file');
end
if ~exist('inarg','var');
   inarg = [];
   Nsecs = 60;
   ldr_snr = .25;
else
   if isfield(inarg,'out_dir')
      outdir = inarg.out_dir;
   else
      outdir = [];
   end
   if isfield(inarg,'Nsecs')
      Nsecs = inarg.Nsecs;
   else
     Nsecs = 60;
   end
   if isfield(inarg,'ldr_snr')
      ldr_snr = inarg.ldr_snr;
   else
      ldr_snr = .3;
   end
end
%%

polV = mean(mplpol.hk.pol_V1);
cop = (mplpol.hk.pol_V1<polV);
cop_ind = find(cop);
crs_ind = find(~cop);
if length(cop_ind)>1 && length(crs_ind)>1
   %determine Nsamples from raw averaging interval in the file.
   Nsamples = ceil((Nsecs+2)./etime(datevec(mplpol.time(cop_ind(end))),datevec(mplpol.time(cop_ind(end-1)))));
else
   Nsamples = 0;
end
% If I change Nsamples here, it will be propagated downstream.
cycles = floor(length(mplpol.time)/(2*Nsamples));
ind = 1 + cycles*(2*Nsamples);
if (abs(length(cop_ind)-length(crs_ind))>1)||(cycles<1)
   %We have too few profiles or too many of one or the other mode so abort for now
   disp('Not enough profiles or uneven number of pol states!')
   polavg = [];
   return
else
  
%Process into copol and crosspol
polavg.range = mplpol.range;
polavg.r = mplpol.r;
polavg.statics = mplpol.statics;
hk = fieldnames(mplpol.hk);
for h = 1:length(hk)
    polavg.hk.(hk{h}) = downsample(mplpol.hk.(hk{h}),2*Nsamples);
end

r.bg = (polavg.range>=40)&(polavg.range<58);
bin_time_ns = mplpol.statics.range_bin_time;
cnv_factor = 1e-3*bin_time_ns .* mplpol.hk.shots_summed(1) .* Nsamples;
% R_MHz = apply_generic_dtc(D_MHz)
dtc_fac = max(mplpol.rawcts(:))/14.5;
% mplpol.rawcts = (dtc_fac.*apply_generic_dtc(mplpol.rawcts./dtc_fac));
mplpol.rawcts = dtc_fac.*inarg.dtc(mplpol.rawcts./dtc_fac, mplpol.time(1));
% The idea here is to compute statistics on each profile before averaging
% together.  Then keep track of the statistics along with copol and
% crspool. Salient detail that will affect SNR is that copol and crosspol backgrounds and
% afterpulse are generally not the same.
for N = cycles:-1:1
   inds = (1:Nsamples)+(N-1)*Nsamples;
   polavg.time(N) = mean([mplpol.time(cop_ind(inds)) mplpol.time(crs_ind(inds))]);
   polavg.samples(N) = Nsamples;
   polavg.cop(:,N) = mean(mplpol.rawcts(:,cop_ind(inds)),2);
   polavg.crs(:,N) = mean(mplpol.rawcts(:,crs_ind(inds)),2);
   polavg.cop_std(:,N) = std(mplpol.rawcts(:,cop_ind(inds)),0,2)./sqrt(Nsamples);      
   polavg.crs_std(:,N) = std(mplpol.rawcts(:,crs_ind(inds)),0,2)./sqrt(Nsamples);         
   polavg.cop_noise(:,N) = sqrt(polavg.cop(:,N)./cnv_factor);
   polavg.crs_noise(:,N) = sqrt(polavg.crs(:,N)./cnv_factor);
   % I can plot cop_noise here to see if it reflects the right trend with
   % Nsamples.
   % I want to compute the expected statistics due to the measured bg
%    ne_bg = sqrt(mean(polavg.cop(r.bg,N))./cnv_factor);
   bg_val = mean(polavg.cop_noise(r.bg,N));
   bg_val = max([mean(polavg.cop_std(r.bg,N)),mean(polavg.cop_noise(r.bg,N))]);
   gtz = polavg.cop_noise(:,N)>0;
   gtz = polavg.cop_noise(:,N)>bg_val;
   polavg.cop_noise(:,N) = gtz.*polavg.cop_noise(:,N) + (~gtz).*bg_val;
%    ne_bg = sqrt(mean(polavg.crs(r.bg,N))./cnv_factor);
   bg_val = mean(polavg.crs_noise(r.bg,N));
   bg_val = max([mean(polavg.crs_std(r.bg,N)),mean(polavg.crs_noise(r.bg,N))]);   
   gtz = polavg.crs_noise(:,N)>0;
   gtz = polavg.crs_noise(:,N)>bg_val;   
   polavg.crs_noise(:,N) = gtz.*polavg.crs_noise(:,N) + (~gtz).*bg_val;
   polavg.hk.cop_energy_monitor(N) = mean(mplpol.hk.energy_monitor(cop_ind(inds)));
   polavg.hk.crs_energy_monitor(N) = mean(mplpol.hk.energy_monitor(crs_ind(inds)));
%    polavg.cop_bg(N) = mean(mplpol.vars.background_signal.data(cop_ind(inds)));
%    polavg.crs_bg(N) = mean(mplpol.vars.background_signal.data(crs_ind(inds)));
%    polavg.std_cop_bg(N) = std(mplpol.vars.background_signal.data(cop_ind(inds)));
%    polavg.std_crs_bg(N) = std(mplpol.vars.background_signal.data(crs_ind(inds)));
%    polavg.cop_bg_std(N) = mean(mplpol.vars.background_signal_std.data(cop_ind(inds)));
%    polavg.crs_bg_std(N) =
%    mean(mplpol.vars.background_signal_std.data(crs_ind(inds)));
%    disp(['Cycle ',num2str(N), ' of ',num2str(cycles)])
end

% then subtract bg, ap, ...
ap = inarg.ap(polavg.range,polavg.time(1));
polavg.cop_ap = ap.cop;
polavg.crs_ap = ap.crs;
polavg.cop = polavg.cop - polavg.cop_ap*ones(size(polavg.time));
polavg.crs = polavg.crs - polavg.crs_ap*ones(size(polavg.time));

% ap = inarg.ap;
% ap = loadinto('taihu_ap.mat'); ap = ap.ap;
% % polavg.cop = polavg.cop - ap_2(:,2)*ones(size(polavg.time));
% % polavg.crs = polavg.crs - ap_2(:,2)*ones(size(polavg.time));
% polavg.cop = polavg.cop - interp1(ap(:,1), ap(:,2), polavg.range,'nearest','extrap')*ones(size(polavg.time));
% polavg.crs = polavg.crs - interp1(ap(:,1), ap(:,2), polavg.range,'nearest','extrap')*ones(size(polavg.time));

% polavg.cop = polavg.cop - ap.cop*ones(size(polavg.time));
% polavg.crs = polavg.crs - ap.crs*ones(size(polavg.time));
% This block for SGP
% ap = loadinto('C:\case_studies\mpl_fastsw\slow_ap.mat');
% polavg.cop = polavg.cop - ap.cop_smoothed*ones(size(polavg.time));
% polavg.crs = polavg.crs - ap.crs_smoothed*ones(size(polavg.time));
% polavg.cop_ap = ap.cop_smoothed';
% polavg.crs_ap = ap.crs_smoothed';


% This block for ISDAC
% ap_time = datenum('2008-04-07_2338','yyyy-mm-dd_HHMM');
% if polavg.time(1)<ap_time
%    disp('Applying pre-April 7 afterpulse corrections for ISDAC')
% ap = loadinto('C:\case_studies\ISDAC\MPL\MPL_corrs\afterpulse.isdac.2008-04-03_2300.dat');
% else
% ap = loadinto('C:\case_studies\ISDAC\MPL\MPL_corrs\afterpulse.isdac.2008-04-07_2338.dat');
%    disp('Applying post-April 7 afterpulse corrections for ISDAC')
% end
%  polavg.cop = polavg.cop - ap.cop_smooth'*ones(size(polavg.time));
%  polavg.crs = polavg.crs - ap.crs_smooth'*ones(size(polavg.time));
%  polavg.cop_ap = ap.cop_smooth';
% polavg.crs_ap = ap.crs_smooth';
 %end ISDAC block

% % This block for Taihu


% % 
% End Taihu block

%Now do background subtraction
polavg.hk.cop_bg = mean(polavg.cop(r.bg,:),1);
polavg.hk.crs_bg = mean(polavg.crs(r.bg,:),1);
polavg.cop = polavg.cop - ones(size(polavg.range))*polavg.hk.cop_bg;
polavg.crs = polavg.crs - ones(size(polavg.range))*polavg.hk.crs_bg;

% Then compute SNR, dpr, ...
polavg.cop_snr = polavg.cop ./ polavg.cop_noise;
polavg.crs_snr = polavg.crs ./ polavg.crs_noise;
cop_lin_noise = sqrt(polavg.cop_noise.^2 + polavg.crs_noise.^2);
cop_lin_snr = (polavg.cop + polavg.crs)./cop_lin_noise;
polavg.attn_bscat = (polavg.cop + 2.* polavg.crs);
polavg.attn_bscat_noise = sqrt(cop_lin_noise.^2 +polavg.crs_noise.^2);
polavg.attn_bscat_snr = (polavg.cop + 2.* polavg.crs)./polavg.attn_bscat_noise;
polavg.ldr = zeros(size(polavg.cop));
gtz = find(((polavg.cop(:)+polavg.crs(:))>0)&(polavg.crs(:)>0));
polavg.ldr(gtz) = polavg.crs(gtz)./(polavg.cop(gtz) + polavg.crs(gtz));
% d = 2Dm/(1+Dm)
polavg.d = 2.*polavg.ldr ./(1+polavg.ldr);
% Okay, so far so good.  Only error was way upstream when I neglected to
% divide cop and crs noise by Nsamples.
polavg.ldr_snr = 1./ sqrt( 1./polavg.crs_snr.^2 + 1./cop_lin_snr.^2);

% Apply overlap correction
% ol_corr_old = hsrl_ol_corr(polavg.range.*1000);
% ol_corr = olcorr_sgp_20090623(polavg.range);
polavg.ol_corr = inarg.ol_corr(polavg.range,polavg.time(1));

% polavg.attn_bscat = polavg.attn_bscat .* ((polavg.ol_corr)*ones(size(polavg.time)));
% polavg.cop = polavg.cop .* ((polavg.ol_corr)*ones(size(polavg.time)));
% polavg.crs = polavg.crs .* ((polavg.ol_corr)*ones(size(polavg.time)));

polavg.attn_bscat = polavg.attn_bscat .* ((polavg.ol_corr.*(polavg.range.^2))*(1./polavg.hk.energy_monitor));
polavg.cop = polavg.cop .* ((polavg.ol_corr.*(polavg.range.^2))*(1./polavg.hk.energy_monitor));
polavg.crs = polavg.crs .* ((polavg.ol_corr.*(polavg.range.^2))*(1./polavg.hk.energy_monitor));
% polavg.attn_bscat = polavg.attn_bscat .*
% ((polavg.range.^2)*ones(size(polavg.time)));
% polavg.cop = polavg.cop .* ((polavg.range.^2)*ones(size(polavg.time)));
% polavg.crs = polavg.crs .* ((polavg.range.^2)*ones(size(polavg.time)));
% polavg.cop = polavg.cop./(ones(size(polavg.range))*polavg.hk.energy_monitor);
% polavg.crs = polavg.crs./(ones(size(polavg.range))*polavg.hk.energy_monitor);
[polavg.std_attn_prof] = std_ray_atten(polavg.range);


%Now clean up, remove fields, etc.
polavg.scene_variability = (polavg.cop_std./polavg.cop_noise)-1;
% polavg = rmfield(polavg,'cop');
polavg = rmfield(polavg,'cop_noise');
polavg = rmfield(polavg,'cop_std');
% polavg.crs_variability = (polavg.crs_std./polavg.crs_noise)-1;
% % polavg = rmfield(polavg,'crs');
% polavg.scene_variability = zeros(size(polavg.cop_variability));
% polavg.scene_variability(:) = max([polavg.cop_variability(:),polavg.crs_variability(:)],[],2);
polavg = rmfield(polavg,'crs_noise');
polavg = rmfield(polavg,'crs_std');

polavg = rmfield(polavg,'attn_bscat_noise');
% polavg = rmfield(polavg ,'cop_lin_noise');
pols = fieldnames(polavg);
range_dim = length(polavg.range);
polavg.r.strip = (polavg.range<=0)|(polavg.range>30);
for p = 1:length(pols)
   if (size(polavg.(pols{p}),1)==range_dim)
      if (size(polavg.(pols{p}),2)==1)
         polavg.(pols{p})(polavg.r.strip)=[];
      else
         polavg.(pols{p})(polavg.r.strip,:)=[];
      end
   elseif (size(polavg.(pols{p}),2)==range_dim)
      polavg.(pols{p})(:,polavg.r.strip)=[];
   end
end
polavg.r.lte_5(polavg.r.strip)=[];
polavg.r.lte_15(polavg.r.strip)=[];
polavg.r.lte_10(polavg.r.strip)=[];
polavg.r.lte_20(polavg.r.strip)=[];
% polavg.r.lte_25(polavg.r.strip)=[];
% polavg.r.lte_30(polavg.r.strip)=[];
% polavg.r = rmfield(polavg.r, 'lte_20');
polavg.r = rmfield(polavg.r, 'lte_25');
polavg.r = rmfield(polavg.r, 'lte_30');
polavg.r = rmfield(polavg.r, 'strip');
% % ol_corr = inarg.ol_corr(polavg.range.*1000);
% polavg.cop = polavg.cop .* ((ol_corr)*ones(size(polavg.time)));
% polavg.crs = polavg.crs .* ((ol_corr)*ones(size(polavg.time)));
% load nsamplpol_olcorr.mat
% load sgpmpl.ol_patch.20060610.mat
% load sgpmpl.ol.patched.20060610.mat
% r.patch = ol.range>=ol_patch.range(1) & ol.range<=ol_patch.range(end);
% ol.corr(r.patch) = ol.corr(r.patch) ./ ol_patch.ol;

%The following overlap correction derived by matching MPL profile on
%4/17/2007 to sonde attenuated backscatter profile
% polavg.attn_bscat = polavg.attn_bscat ./ (ol.corr * ones(size(polavg.time)));
end
%%
