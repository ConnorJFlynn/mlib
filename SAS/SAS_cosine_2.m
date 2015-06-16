function spec = SAS_cosine_2(infile)
% spec = SAS_cosine_2(indir)
% This version reads files containing multiple spectra, darks and lights at
% varying angles
% 
spec = SAS_read_ava(getfullname('*.csv','ava','Select bare fiber spectra'));
%%
% figure; plot(spec.nm, spec.spec,'-');
%%
if isfield(spec,'Intgration')
   spec.Integration = spec.Intgration;
   spec = rmfield(spec,'Intgration');
end
if sum(spec.Shuttered_0==1)>sum(spec.Shuttered_0==0)
   %Then ==1 is light and ==0 is dark
   dark = spec.Shuttered_0==0;
else
   dark = spec.Shuttered_0==1;
end
wl_r = spec.nm>600&spec.nm<700;
%%
figure; plot([1:length(spec.time)],mean(spec.spec,2),'-')
%%
figure; plot(spec.nm, spec.spec(140:145,:),'-')
%%

% figure; subplot(2,1,1); 
% plot(spec.nm, spec.spec(dark,:), '-');
% subplot(2,1,2);
% plot(spec.nm, spec.spec(~dark,:), '-');
%%

dark = false(size(dark)); dark(dark_ii) = true;
spec.darks = mean(spec.spec(dark,:),1);
spec.lights = spec.spec-ones(size(spec.time))*spec.darks;
% figure; lines = semilogy(spec.nm, spec.lights,'-');
%    lines = recolor(lines,abs(spec.Angle)');colorbar
normal = spec.Angle==0 & ~dark;
%%
spec.norm = spec.lights./(spec.Integration*ones(size(spec.nm)));
     if sum(normal)>1
      norm_spec = mean(spec.norm(normal,:),1);
        else
           norm_spec = spec.norm(normal,:);
     end
     %%
%      figure; plot(spec.nm, norm_spec,'k-');
%      title({char(spec.fname);spec.pname})
     %%
     
     spec.norm = spec.norm./(ones(size(spec.time))*norm_spec);
   %%
   [spec.Angle,zind] = sort(spec.Angle);
   dark_zind = dark(zind);
   spec.Integration = spec.Integration(zind);
   spec.spec = spec.spec(zind,:);  
   spec.norm = spec.norm(zind,:);  
   
   spec.cos_zen = cos(spec.Angle.*pi./180);
   spec.cos_zen(spec.cos_zen<.01) = NaN;
   spec.cos_corr = spec.norm./(spec.cos_zen*ones(size(norm_spec)));
wl = [400:50:850];
%%
   figure; lines = plot(spec.Angle(~dark_zind), spec.cos_corr(~dark_zind,wl),'.');

   title({spec.sn,['Cosine correction measurement by pixel']},'interp','none')
   xlabel('zenith angle')
   ylabel('unitless');
   zoom('on');
   %%
   saveas(gcf,[spec.pname, char(spec.fname), '.png'])
   %%

%  saveas(gcf,[indir,pmt,'_monoscan.png']);
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
     