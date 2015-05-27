function [fig,si_ax,in_ax] = plot_sws_raw(sws_raw);
if ~exist('sws_raw','var')|isempty(sws_raw)
   [sws_raw] = read_sws_raw;
end
darks = ~(sws_raw.shutter==0);

if sum(darks)>0
   if ~isfield(sws_raw,'Si_dark')
      if sum(darks)>1
         sws_raw.Si_dark = mean(sws_raw.Si_DN(:,darks),2);
      else
         sws_raw.Si_dark = sws_raw.Si_DN(:,darks);
      end
   end
   if ~isfield(sws_raw,'In_dark')
      if sum(darks)>1
         sws_raw.In_dark = mean(sws_raw.In_DN(:,darks),2);
      else
         sws_raw.In_dark = sws_raw.In_DN(:,darks);
      end
   end
   sws_raw.Si_spec = sws_raw.Si_DN - sws_raw.Si_dark*ones(size(sws_raw.time));
   sws_raw.In_spec = sws_raw.In_DN - sws_raw.In_dark*ones(size(sws_raw.time));
   
   [pp,ff,xx] = fileparts(sws_raw.filename);
   
   si_ax(1) = subplot(3,2,1); semilogy(sws_raw.Si_lambda, sws_raw.Si_DN(:,~darks), '.b-');
   title([ff,xx],'interp','none')
   legend(sprintf('tint=%d',unique(sws_raw.Si_ms)));
   ylabel('raw DN')
   xlabel('wavelength(nm)');
   in_ax(1) = subplot(3,2,2); semilogy(sws_raw.In_lambda, sws_raw.In_DN(:,~darks),'.r-');
   legend(sprintf('tint=%d',unique(sws_raw.In_ms)));
   ylabel('raw DN')
   xlabel('wavelength(nm)');
   
   si_ax(2) = subplot(3,2,3); plot(sws_raw.Si_lambda, sws_raw.Si_dark, 'k-');
   title([ff,xx],'interp','none')
   ylabel('raw dark DN')
   xlabel('wavelength(nm)');
   in_ax(2) = subplot(3,2,4); plot(sws_raw.In_lambda, sws_raw.In_dark,'k-');
   ylabel('raw dark DN')
   xlabel('wavelength(nm)');
   
   si_ax(3) = subplot(3,2,5); lines = semilogy(sws_raw.Si_lambda, sws_raw.Si_spec(:,~darks), '-');
   lines = recolor(lines,sws_raw.time(~darks));
   ylabel('DN - dark')
   xlabel('wavelength(nm)');
   in_ax(3) = subplot(3,2,6); lines= semilogy(sws_raw.In_lambda, sws_raw.In_spec(:,~darks),'r-');
   lines = recolor(lines,sws_raw.time(~darks));
   ylabel('DN - dark')
   xlabel('wavelength(nm)');
   linkaxes(si_ax,'x');
   linkaxes(in_ax,'x');
   [pname,fname,ext] = fileparts(sws_raw.filename);
   title(si_ax(1),fname,'interp','none');
else
   
   [pp,ff,xx] = fileparts(sws_raw.filename);
   
   si_ax(1) = subplot(2,1,1); plot(sws_raw.Si_lambda, sws_raw.Si_DN, '.b-');
   title([ff,xx],'interp','none');
   legend(sprintf('tint=%d',unique(sws_raw.Si_ms)));
   ylabel('raw DN')
   xlabel('wavelength(nm)');
   in_ax(1) = subplot(2,1,2); plot(sws_raw.In_lambda, sws_raw.In_DN,'.r-');
   legend(sprintf('tint=%d',unique(sws_raw.In_ms)));
   ylabel('raw DN')
   xlabel('wavelength(nm)');
   
   [pname,fname,ext] = fileparts(sws_raw.filename);
   title(si_ax(1),fname,'interp','none');
   
   
   
end
disp(unique(sws_raw.Si_ms))


return