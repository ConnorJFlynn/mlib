function [polavg,ind] = proc_mplpolfsraw_4(mplpol,inarg)
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
%    ldr_snr = .25;
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
%    if isfield(inarg,'ldr_snr')
%       ldr_snr = inarg.ldr_snr;
%    else
%       ldr_snr = .3;
%    end
end
%%

Nsamples = ceil((Nsecs+2)./etime(datevec(mplpol.time(end)),datevec(mplpol.time(end-1))));

% If I change Nsamples here, it will be propagated downstream.
cycles = floor(length(mplpol.time)/(Nsamples));
ind = 1 + cycles*(Nsamples);
  
%Process into copol and crosspol
polavg.range = mplpol.range;
polavg.r = mplpol.r;
polavg.statics = mplpol.statics;
hk = fieldnames(mplpol.hk);
% Average the raw data down a coarser time grid.
for h = 1:length(hk)
    polavg.hk.(hk{h}) = downsample(mplpol.hk.(hk{h}),Nsamples);
end

% Define the backgroudn range.
if any(polavg.range<0)
    r.bg = polavg.range<-.1;
else
    r.bg = (polavg.range>=40)&(polavg.range<58);
end
bin_time_ns = mplpol.statics.range_bin_time;
% cnv_factor converts the raw data reported in MHz to actual counts
% This factor is necessary for computing statistics.
cnv_factor = 1e-3*bin_time_ns .* mplpol.hk.shots_summed(1) .* Nsamples;
% R_MHz = apply_generic_dtc(D_MHz)
% dtc_fac = max(mplpol.rawcts_copol(:))/14.5;
% mplpol.rawcts_copol = dtc_fac.*inarg.dtc(mplpol.rawcts_copol./dtc_fac, mplpol.time(1));
% dtc_fac = max(mplpol.rawcts_crosspol(:))/14.5;
% mplpol.rawcts_crosspol = dtc_fac.*inarg.dtc(mplpol.rawcts_crosspol./dtc_fac, mplpol.time(1));
disp('remove me')
% The idea here is to compute statistics on each profile before averaging
% together.  Then keep track of the statistics along with copol and
% crspool. Salient detail that will affect SNR is that copol and crosspol backgrounds and
% afterpulse are generally not the same.
for N = cycles:-1:1
   inds = (1:Nsamples)+(N-1)*Nsamples;
   polavg.time(N) = mean([mplpol.time(inds)]);
   polavg.samples(N) = Nsamples;
   polavg.cop(:,N) = mean(mplpol.rawcts_copol(:,inds),2);
   polavg.crs(:,N) = mean(mplpol.rawcts_crosspol(:,inds),2);
   polavg.cop_std(:,N) = std(mplpol.rawcts_copol(:,inds),0,2)./sqrt(Nsamples);      
   polavg.crs_std(:,N) = std(mplpol.rawcts_crosspol(:,inds),0,2)./sqrt(Nsamples);         
   polavg.cop_noise(:,N) = sqrt(polavg.cop(:,N)./cnv_factor);
   polavg.crs_noise(:,N) = sqrt(polavg.crs(:,N)./cnv_factor);
%    bg_val = mean(polavg.cop_noise(r.bg,N));
   bg_val = max([mean(polavg.cop_std(r.bg,N)),mean(polavg.cop_noise(r.bg,N))]);
%    gtz = polavg.cop_noise(:,N)>0;
   gtz = polavg.cop_noise(:,N)>bg_val;
   polavg.cop_noise(:,N) = gtz.*polavg.cop_noise(:,N) + (~gtz).*bg_val;
%    bg_val = mean(polavg.crs_noise(r.bg,N));
   bg_val = max([mean(polavg.crs_std(r.bg,N)),mean(polavg.crs_noise(r.bg,N))]);   
%    gtz = polavg.crs_noise(:,N)>0;
   gtz = polavg.crs_noise(:,N)>bg_val;   
   polavg.crs_noise(:,N) = gtz.*polavg.crs_noise(:,N) + (~gtz).*bg_val;
   polavg.hk.cop_energy_monitor(N) = mean(mplpol.hk.energy_monitor(inds));
   polavg.hk.crs_energy_monitor(N) = mean(mplpol.hk.energy_monitor(inds));
%    disp(['Cycle ',num2str(N), ' of ',num2str(cycles)])
end

% then subtract bg, ap, ...
% ap = inarg.ap(polavg.range,polavg.time(1));
% polavg.cop_ap = ap.cop;
% polavg.crs_ap = ap.crs;
% polavg.cop = polavg.cop - polavg.cop_ap*ones(size(polavg.time));
% polavg.crs = polavg.crs - polavg.crs_ap*ones(size(polavg.time));

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

%mpl_dr = crs/cop;
%ldr = mpl_dr / (mpl_dr + 1)
%    = crs/cop / (crs/cop +1)
%     = crs / (crs + cop)

polavg.ldr(gtz) = polavg.crs(gtz)./(polavg.cop(gtz) + polavg.crs(gtz));
% ldr = d/(2-d)
% d = ldr(2-d)
% d(1+ldr) =2ldr
% d = 2ldr/(1+ldr)
polavg.d = 2.*polavg.ldr ./(1+polavg.ldr);
polavg.ldr_snr = 1./ sqrt( 1./polavg.crs_snr.^2 + 1./cop_lin_snr.^2);

% Apply overlap correction and energy monitor normalization
if ~isfield(polavg.r,'ol_corr')
polavg.r.ol_corr = inarg.ol_corr(polavg.range,polavg.time(1));
end
polavg.attn_bscat = polavg.attn_bscat .* ((polavg.r.ol_corr.*(polavg.range.^2))*(1./polavg.hk.energy_monitor));
polavg.cop = polavg.cop .* ((polavg.r.ol_corr.*(polavg.range.^2))*(1./polavg.hk.energy_monitor));
polavg.crs = polavg.crs .* ((polavg.r.ol_corr.*(polavg.range.^2))*(1./polavg.hk.energy_monitor));

% Also include an attenuated molecular/Rayleigh backscatter profile for a "standard"
% atmospheric profile.  This will be used in later processes to construct a
% non-calibrated aerosol backscatter ratio.  It is weakly sensitive to
% the actual T and P profile. 
[polavg.std_attn_prof] = std_ray_atten(polavg.range);


%Now clean up, remove fields, etc.
polavg.scene_variability = (polavg.cop_std./polavg.cop_noise)-1;
polavg = rmfield(polavg,'cop_noise');
polavg = rmfield(polavg,'cop_std');
polavg = rmfield(polavg,'crs_noise');
polavg = rmfield(polavg,'crs_std');
polavg = rmfield(polavg,'attn_bscat_noise');
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

polavg.r = rmfield(polavg.r, 'lte_25');
polavg.r = rmfield(polavg.r, 'lte_30');
polavg.r = rmfield(polavg.r, 'strip');

end
%%
