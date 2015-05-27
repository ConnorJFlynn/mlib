function sws_cal = read_sws_cal(in_dir);
% sws_cal = read_sws_cal(in_dir);
if ~exist('in_dir','var')
   in_dir = getdir([],'sws_cals');
end
if exist([in_dir,filesep,'light'],'dir')&&exist([in_dir,filesep,'dark'],'dir')
   darkfile = dir([in_dir,'dark',filesep,'*.dat']);
   [sws_dark, dk] = read_sws_raw([in_dir,'dark',filesep,darkfile(1).name]);
   lightfile = dir([in_dir,'light',filesep,'*.dat']);
   sws_light = read_sws_raw([in_dir,'light',filesep,lightfile(1).name],dk);
%    dk.Si_dark = Si_dark;
%    dk.In_dark = In_dark;
%    dk.time = dark_time;
%    sws_raw.Si_spec = sws_raw.Si_DN - Si_dark*ones([1,size(sws_raw.Si_DN,2)]);
%    sws_raw.In_spec = sws_raw.In_DN - In_dark*ones([1,size(sws_raw.In_DN,2)]);
sws_cal = sws_light;
sws_cal.Si_spec = sws_light.Si_DN - dk.Si_dark*ones([1,size(sws_light.Si_DN,2)]);
sws_cal.Si_spec = sws_cal.Si_spec ./ (ones(size(sws_cal.Si_lambda))*sws_cal.Si_ms);
sws_cal.In_spec = sws_light.In_DN - dk.In_dark*ones([1, size(sws_light.In_DN,2)]);
sws_cal.In_spec = sws_cal.In_spec ./ (ones(size(sws_cal.In_lambda))*sws_cal.In_ms);

figure; ax(1) = subplot(1,2,1); 
lines = semilogy(sws_cal.Si_lambda, sws_cal.Si_spec, '-');
title(['Si detector, t_int=',num2str(sws_cal.Si_ms(1))], 'interp','none');
lines = recolor(lines,sws_cal.time);
   ylabel('(DN - dark)/ms')
   xlabel('wavelength(nm)');
   ax(2) = subplot(1,2,2); 
   lines= semilogy(sws_cal.In_lambda, sws_cal.In_spec,'-');
   title(['InGaAs detector, t_int=',num2str(sws_cal.In_ms(1))], 'interp','none');
   lines = recolor(lines,sws_cal.time);
   ylabel('(DN - dark)/ms')
   xlabel('wavelength(nm)');

  [pname,fname,ext] = fileparts(sws_cal.filename);
  saveas(gcf,[pname,'..',filesep,'swscal.',datestr(sws_cal.time(1),'yyyymmdd.HHMM'),'.png'],'png')
     % Then plot an image with dark counts subtracted and normalized to
   % t_t. Filename (and title) should indicate t_int for both and also identify
   % max signal and lambda of max signal for both channels. This _should_
   % help identify the aperture in use. 
end
return
