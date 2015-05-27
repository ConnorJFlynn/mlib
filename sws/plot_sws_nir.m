function [sws_raw] = plot_sws_nir(sws_raw);
% [sws_raw] = plot_sws_nir(sws_raw);
if ~exist('sws_raw','var')|isempty(sws_raw)
   [sws_raw] = read_sws_raw;
end
darks = ~(sws_raw.shutter==0);

if sum(darks)>0
   if ~isfield(sws_raw,'In_dark')
      if sum(darks)>1
         sws_raw.In_dark = mean(sws_raw.In_DN(:,darks),2);
      else
         sws_raw.In_dark = sws_raw.In_DN(:,darks);
      end
   end
   sws_raw.In_spec = sws_raw.In_DN - sws_raw.In_dark*ones(size(sws_raw.time));
   
   [pp,ff,xx] = fileparts(sws_raw.filename);
   
   ax(1) = subplot(3,1,1); semilogy(sws_raw.In_lambda, sws_raw.In_DN(:,~darks), '.b-');
   title([ff,xx],'interp','none')
   legend(sprintf('tint=%d',unique(sws_raw.In_ms)));
   ylabel('raw DN')
   xlabel('wavelength(nm)');
   ax(2) = subplot(3,1,2); plot(sws_raw.In_lambda, sws_raw.In_dark,'k-');
   ylabel('raw dark DN')
   xlabel('wavelength(nm)');
   
   ax(3) = subplot(3,1,3); lines= semilogy(sws_raw.In_lambda, sws_raw.In_spec(:,~darks),'r-');
   lines = recolor(lines,sws_raw.time(~darks));
   ylabel('DN - dark')
   xlabel('wavelength(nm)');
   linkaxes(ax,'x');
   [pname,fname,ext] = fileparts(sws_raw.filename);
   title(ax(1),fname,'interp','none');
else
   
   [pp,ff,xx] = fileparts(sws_raw.filename);
   
   plot(sws_raw.In_lambda, sws_raw.In_DN, '.b-');
   title([ff,xx],'interp','none');
   legend(sprintf('tint=%d',unique(sws_raw.In_ms)));
   ylabel('raw DN')
   xlabel('wavelength(nm)');
   
   [pname,fname,ext] = fileparts(sws_raw.filename);
   title(si_ax(1),fname,'interp','none');
end

return