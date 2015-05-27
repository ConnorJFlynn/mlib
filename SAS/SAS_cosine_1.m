function spec = SAS_cosine_2(indir)
% spec = SAS_cosine_2(indir)
% This version reads files containing multiple spectra, darks and lights at
% varying angles
% 
if ~exist('indir','var')
   indir = getdir;
end
ridni = fliplr(indir);
pmt = fliplr(strtok(ridni(2:end),filesep));

   dark_files = dir([indir,'*_Back.csv']);
   for dk = length(dark_files):-1:1

      [dmp,tmp] = strtok(dark_files(dk).name,'_');
%       dark_nm(dk) = sscanf(dmp,'%d');
     [tint, tmp]= strtok(tmp,'_');
     tint = sscanf(tint, '%d');
     dark_tint(dk) = tint;
     CCD_dark = load([indir,dark_files(dk).name]);
     dark_cts(:,dk) = CCD_dark(:,2);

   end
% sort dark counts in order of tint
[dark_tints] = unique(dark_tint);
for dk = length(dark_tints):-1:1
   dk_tf = dark_tint==dark_tints(dk);
   if sum(dk_tf)==1
      darks.tint(dk) = dark_tint(dk_tf);
      darks.cts(:,dk) = dark_cts(:,dk_tf);
   else
      darks.tint(dk) = mean(dark_tint(dk_tf));
      darks.cts(:,dk) = mean(dark_cts(:,dk_tf),2);
   end
end
%%
   
   %%
   cos_files = dir([indir,'*avg.csv']);
   for m = length(cos_files):-1:1
      [dmp,tmp] = strtok(cos_files(m).name,'_');
      mono.zen_deg(m) = sscanf(dmp,'%d');
     [tint, tmp]= strtok(tmp,'_');
     mono.tint(m) = sscanf(tint, '%d');
     light = load([indir,cos_files(m).name]);
     mono.raw(:,m) = light(:,2);
     mono.spec(:,m) = mono.raw(:,m) - darks.cts(:,darks.tint==mono.tint(m));
   end
   %%
   normal = mono.zen_deg==0;

     mono.norm = mono.spec./(ones([size(mono.spec,1),1])*mono.tint);
        if sum(normal)>1
      norm_spec = mean(mono.norm(:,normal),2);
        else
           norm_spec = mono.norm(:,normal);
        end
     mono.norm = mono.norm./(norm_spec*ones([1,size(mono.norm,2)]));
   %%
   [mono.zen_deg,zind] = sort(mono.zen_deg);
   mono.tint = mono.tint(zind);
   mono.raw = mono.raw(:,zind);
   mono.spec = mono.spec(:,zind);  
   mono.norm = mono.norm(:,zind);  
   
   mono.cos_zen = cos(mono.zen_deg.*pi./180);
   mono.cos_zen(mono.cos_zen<.01) = NaN;
   mono.cos_corr = mono.norm./(ones(size(norm_spec))*mono.cos_zen);
wl = [350:25:950];
   figure; lines = plot(mono.zen_deg, mono.cos_corr(wl,:),'-');
   recolor(lines, wl);colorbar
   title({pmt,['Cosine correction measurement by pixel']},'interp','none')
   xlabel('zenith angle')
   ylabel('unitless');
   zoom('on');
   
   %%


saveas(gcf,[indir,pmt,'_monoscan.png']);
% %%
% mfr = ancload;
% %%
% figure; plot(mfr.vars.bench_angle.data-90, [mfr.vars.cosine_correction_we_filter1.data,...
%    mfr.vars.cosine_correction_we_filter2.data,mfr.vars.cosine_correction_we_filter3.data,...
%    mfr.vars.cosine_correction_we_filter4.data, mfr.vars.cosine_correction_we_filter5.data], '-');
% zoom('on');
% legend('filter 1', 'filter 2', 'filter 3', 'filter 4', 'filter 5');
%    xlabel('zenith angle')
%    ylabel('unitless');
% title('MFRSR NS cosine correction');
% 
% figure; plot(mfr.vars.bench_angle.data-90, [mfr.vars.cosine_correction_we_filter1.data,...
%    mfr.vars.cosine_correction_we_filter2.data,mfr.vars.cosine_correction_we_filter3.data,...
%    mfr.vars.cosine_correction_we_filter4.data, mfr.vars.cosine_correction_we_filter5.data], '-');
% legend('filter 1', 'filter 2', 'filter 3', 'filter 4', 'filter 5');
% zoom('on');
%    xlabel('zenith angle')
%    ylabel('unitless');
% title('MFRSR EW cosine correction');
% 
% %%

return
     