function [mplavg] = proc_mplraw(mpl,inarg)
%[mplavg,ind] = proc_mplraw(mpl,inarg)
% mplavg contains averaged mpl data
% ind contains index of last used value from mpl
% mpl is an ancstruct with mpl data
% inarg has the following optional elements 
% .outdir 
% .Nsecs
% .ldr_snr
% 2008/05/21 fixed ldr_snr computations
% Adding functional stubs back in

if ~exist('mpl','var')||isempty(mpl)
   mpl = read_mpl;
   disp('Loaded file');
end
if ~exist('inarg','var');
   inarg = [];
   Nsecs = 60;
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
end
%%

   Nsamples = ceil((Nsecs+2)./etime(datevec(mpl.time(end)),datevec(mpl.time(end-1))));

   % If I change Nsamples here, it will be propagated downstream.
cycles = floor(length(mpl.time)/(Nsamples));
ind = 1 + cycles*Nsamples;
  
%Process into copol and crosspol
mplavg.range = mpl.range;
mplavg.r = mpl.r;
mplavg.statics = mpl.statics;
hk = fieldnames(mpl.hk);
for h = 1:length(hk)
    mplavg.hk.(hk{h}) = downsample(mpl.hk.(hk{h}),Nsamples);
end

r.bg = (mplavg.range>=40)&(mplavg.range<58);
bin_time_ns = mpl.statics.range_bin_time;
cnv_factor = 1e-3*bin_time_ns .* mpl.hk.shots_summed(1) .* Nsamples;
% R_MHz = apply_generic_dtc(D_MHz)
dtc_fac = max(mpl.rawcts(:))/14.5;
% mpl.rawcts = (dtc_fac.*apply_generic_dtc(mpl.rawcts./dtc_fac));
mpl.rawcts = dtc_fac.*inarg.dtc(mpl.rawcts./dtc_fac, mpl.time(1));
% The idea here is to compute statistics on each profile before averaging
% together.  Then keep track of the statistics along with copol and
% crspool. Salient detail that will affect SNR is that copol and crosspol backgrounds and
% afterpulse are generally not the same.
for N = cycles:-1:1
   inds = (1:Nsamples)+(N-1)*Nsamples;
   mplavg.time(N) = mean(mpl.time(inds));
   mplavg.samples(N) = Nsamples;
   mplavg.rawcts(:,N) = mean(mpl.rawcts(:,inds),2);
   mplavg.rawcts_std(:,N) = std(mpl.rawcts(:,inds),0,2)./sqrt(Nsamples);      
   mplavg.rawcts_noise(:,N) = sqrt(mplavg.rawcts(:,N)./cnv_factor);
   % I can plot rawcts_noise here to see if it reflects the right trend with
   % Nsamples.
   % I want to compute the expected statistics due to the measured bg
%    ne_bg = sqrt(mean(mplavg.rawcts(r.bg,N))./cnv_factor);

   bg_val = max([mean(mplavg.rawcts_std(r.bg,N)),mean(mplavg.rawcts_noise(r.bg,N))]);
   gtz = mplavg.rawcts_noise(:,N)>bg_val;
   mplavg.rawcts_noise(:,N) = gtz.*mplavg.rawcts_noise(:,N) + (~gtz).*bg_val;
%    ne_bg = sqrt(mean(mplavg.crs(r.bg,N))./cnv_factor);
   mplavg.hk.energy_monitor(N) = mean(mpl.hk.energy_monitor(inds));
   mplavg.bg(N) = mean(mpl.hk.bg(inds));
end

% then subtract bg, ap, ...
ap = inarg.ap(mplavg.range,mplavg.time(1));
mplavg.ap = ap.prof;
mplavg.rawcts = mplavg.rawcts - mplavg.ap*ones(size(mplavg.time));

%Now do background subtraction
mplavg.hk.rawcts_bg = mean(mplavg.rawcts(r.bg,:),1);
mplavg.rawcts = mplavg.rawcts - ones(size(mplavg.range))*mplavg.hk.rawcts_bg;

% Then compute SNR, dpr, ...
mplavg.snr = mplavg.rawcts ./ mplavg.rawcts_noise;
mplavg.attn_bscat = mplavg.rawcts;
mplavg.attn_bscat_noise = mplavg.rawcts_noise;
mplavg.attn_bscat_snr = (mplavg.rawcts)./mplavg.attn_bscat_noise;

% Apply overlap correction
% ol_corr_old = hsrl_ol_corr(mplavg.range.*1000);
% ol_corr = olcorr_sgp_20090623(mplavg.range);
mplavg.ol_corr = inarg.ol_corr(mplavg.range,mplavg.time(1));

% mplavg.attn_bscat = mplavg.attn_bscat .* ((mplavg.ol_corr)*ones(size(mplavg.time)));
% mplavg.rawcts = mplavg.rawcts .* ((mplavg.ol_corr)*ones(size(mplavg.time)));
% mplavg.crs = mplavg.crs .* ((mplavg.ol_corr)*ones(size(mplavg.time)));

mplavg.attn_bscat = mplavg.attn_bscat .* ((mplavg.ol_corr.*(mplavg.range.^2))*(1./mplavg.hk.energy_monitor));
[mplavg.std_attn_prof] = std_ray_atten(mplavg.range);
%Now clean up, remove fields, etc.
mplavg.scene_variability = (mplavg.rawcts_std./mplavg.rawcts_noise)-1;
mplavg = rmfield(mplavg,'attn_bscat_noise');
pols = fieldnames(mplavg);
range_dim = length(mplavg.range);
mplavg.r.strip = (mplavg.range<=0)|(mplavg.range>30);
for p = 1:length(pols)
   if (size(mplavg.(pols{p}),1)==range_dim)
      if (size(mplavg.(pols{p}),2)==1)
         mplavg.(pols{p})(mplavg.r.strip)=[];
      else
         mplavg.(pols{p})(mplavg.r.strip,:)=[];
      end
   elseif (size(mplavg.(pols{p}),2)==range_dim)
      mplavg.(pols{p})(:,mplavg.r.strip)=[];
   end
end
% mplavg.r.lte_5(mplavg.r.strip)=[];
% mplavg.r.lte_15(mplavg.r.strip)=[];
% mplavg.r.lte_10(mplavg.r.strip)=[];
% mplavg.r.lte_20(mplavg.r.strip)=[];
mplavg.r = rmfield(mplavg.r, 'lte_25');
mplavg.r = rmfield(mplavg.r, 'lte_30');
mplavg.r = rmfield(mplavg.r, 'strip');
%%
