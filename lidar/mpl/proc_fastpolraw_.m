 function [polavg,ind] = proc_fastpolraw_(fastpol,inarg)
%[polavg,ind] = proc_mplpolraw_(mplpol,inarg)
% polavg contains averaged fastpol data
% ind contains index of last used value from mplpol
% fastpol is a lidar struct with fast-switching polarized data
% inarg has the following optional elements 
% .outdir 
% .Nsec
% .ldr_snr
% 2008/05/21 fixed ldr_snr computations

if ~exist('fastpol','var')||isempty(fastpol)
   fastpol = rd_Sigma;
   disp('Loaded file');
end
if ~exist('inarg','var');
   inarg = [];
   Nsecs = 60;
   ldr_snr = .25;
else
   if isfield(inarg,'outdir')
      outdir = inarg.outdir;
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

% Probably want to base Nsamples on Nsecs.
Nsamples = ceil(Nsecs./etime(datevec(fastpol.time(end)),datevec(fastpol.time(end-1))));
cycles = floor(length(fastpol.time)/(Nsamples));
polavg.range = fastpol.range;
polavg.r = fastpol.r;
polavg.statics = fastpol.statics;
fastpol.hk = rmfield(fastpol.hk,'bg');
hk = fieldnames(fastpol.hk);
for h = 1:length(hk)
   if length(fastpol.hk.(hk{h}))==length(fastpol.time)
    polavg.hk.(hk{h}) = downsample(fastpol.hk.(hk{h}),Nsamples);
   elseif isstruct(fastpol.hk.(hk{h}))
      subs = fieldnames(fastpol.hk.(hk{h}));
      for s = 1:length(subs)
         if length(fastpol.hk.(hk{h}).(subs{s}))==length(fastpol.time)
            polavg.hk.(hk{h}).(subs{s}) = downsample(fastpol.hk.(hk{h}).(subs{s}),Nsamples);
         end % of if
      end % for s
   end % of istruct
end % for h

r.bg = false(size(fastpol.r.lte_10));
r.bg(fastpol.r.bg) = true;
bin_time_ns = fastpol.statics.range_bin_time;
cnv_factor = 1e-3*bin_time_ns .* (fastpol.hk.shots_summed(1)./2).* Nsamples;
cnv_factor = 1e-3*bin_time_ns .* (fastpol.hk.shots_summed(1)).* Nsamples;

dtc_fac = max([max(fastpol.rawcts.ch_1(:))/14.5,max(fastpol.rawcts.ch_2(:))/14.5,1]);
fastpol.rawcts.ch_2 = dtc_fac.*apply_generic_dtc(fastpol.rawcts.ch_2./dtc_fac);
fastpol.rawcts.ch_1 = dtc_fac.*apply_generic_dtc(fastpol.rawcts.ch_1./dtc_fac);

for N = cycles:-1:1
   inds = (1:Nsamples)+(N-1)*Nsamples;
   polavg.time(N) = mean(fastpol.time(inds));
   polavg.cop(:,N) = mean(fastpol.rawcts.ch_2(:,inds),2);
   polavg.crs(:,N) = mean(fastpol.rawcts.ch_1(:,inds),2);
   polavg.cop_std(:,N) = std(fastpol.rawcts.ch_2(:,inds),0,2)./sqrt(Nsamples);      
   polavg.crs_std(:,N) = std(fastpol.rawcts.ch_1(:,inds),0,2)./sqrt(Nsamples);         
   polavg.cop_noise(:,N) = sqrt(polavg.cop(:,N)./cnv_factor);
   polavg.crs_noise(:,N) = sqrt(polavg.crs(:,N)./cnv_factor);
 % I can plot cop_noise here to see if it reflects the right trend with Nsamples.
   bg_val = mean(polavg.cop_noise(r.bg,N));
   gtz = polavg.cop_noise(:,N)>0;
   polavg.cop_noise(:,N) = gtz.*polavg.cop_noise(:,N) + (~gtz).*bg_val;
   bg_val = mean(polavg.crs_noise(r.bg,N));
   gtz = polavg.crs_noise(:,N)>0;
   polavg.crs_noise(:,N) = gtz.*polavg.crs_noise(:,N) + (~gtz).*bg_val;
   polavg.hk.energy_monitor(N) = mean(fastpol.hk.energy_monitor(inds));
%    disp(['Cycle ',num2str(N), ' of ',num2str(cycles)])
end

% then subtract bg, ap, ...
% This block for spare at SGP
ap = loadinto('C:\case_studies\mpl_fastsw\fast_ap.mat');
polavg.cop_ap = zeros(size(polavg.range));
polavg.crs_ap = polavg.cop_ap;
% polavg.cop(polavg.range>=0,:) = polavg.cop(polavg.range>=0,:) - ap.cop_smoothed*ones(size(polavg.time));
% polavg.crs(polavg.range>=0,:) = polavg.crs(polavg.range>=0,:) - ap.crs_smoothed*ones(size(polavg.time)); 

%Now do background subtraction
polavg.hk.cop_bg = mean(polavg.cop(polavg.r.bg,:),1);
polavg.hk.crs_bg = mean(polavg.crs(polavg.r.bg,:),1);
polavg.cop = polavg.cop - ones(size(polavg.range))*polavg.hk.cop_bg;
polavg.crs = polavg.crs - ones(size(polavg.range))*polavg.hk.crs_bg;

% Then compute SNR, dpr, ...
polavg.cop_snr = polavg.cop ./ polavg.cop_noise;
polavg.crs_snr = polavg.crs ./ polavg.crs_noise;
polavg.cop_lin_noise = sqrt(polavg.cop_noise.^2 + polavg.crs_noise.^2);
polavg.cop_lin_snr = (polavg.cop + polavg.crs)./polavg.cop_lin_noise;
polavg.cop_lin_snr(polavg.cop_lin_snr<0)=0;
polavg.ldr = zeros(size(polavg.cop));
gtz = find(((polavg.cop(:)+polavg.crs(:))>0)&(polavg.crs(:)>0));
polavg.ldr(gtz) = polavg.crs(gtz)./(polavg.cop(gtz) + polavg.crs(gtz));
% d = 2Dm/(1+2Dm)
polavg.d = 2.*polavg.ldr ./(1+2*polavg.ldr);
polavg.ldr_snr = 1./ sqrt( 1./polavg.crs_snr.^2 + 1./polavg.cop_lin_snr.^2);
polavg.cop = polavg.cop .* ((polavg.range.^2)*ones(size(polavg.time)));
polavg.crs = polavg.crs .* ((polavg.range.^2)*ones(size(polavg.time)));
% Apply overlap correction
% ol_corr = hsrl_ol_corr(polavg.range.*1000);
% % ol_corr = inarg.ol_corr(polavg.range.*1000);
polavg.ol_corr = ones(size(polavg.range));
% polavg.cop = polavg.cop .* ((ol_corr)*ones(size(polavg.time)));
% polavg.crs = polavg.crs .* ((ol_corr)*ones(size(polavg.time)));
polavg.attn_bscat = polavg.cop + 2.* polavg.crs;
[polavg.std_attn_prof] = std_ray_atten(polavg.range);
ind = cycles*Nsamples;

return
