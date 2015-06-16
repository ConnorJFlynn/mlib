function sas = make_sas_instr_fnt;

ins = SAS_read_Albert_csv;

ins.darks = mean(ins.spec(ins.Shuttered_0==0,:)); ins.lights = mean(ins.spec(ins.Shuttered_0==1,:));
if sum(ins.Shuttered_0==0)>0&&sum(ins.Shuttered_0==1)>0
   lights = ins.lights-ins.darks;
   max_light = max(lights);
%    figure;
   ax(1) = subplot(2,1,1);
   these = semilogy(ins.nm, lights./max_light, 'b-');
   hold('on');
   ax(2) = subplot(2,1,2);
   these = plot(ins.nm, lights./max_light, 'b-');
   linkaxes(ax,'x');
   hold('on');

ok = menu('Zoom in to the desired x-range and click OK when ready','OK')
%%

xl = xlim;
yl = ylim; yl(1) = min(lights(lights>0)./max_light);

nm_in = [312.57	400
   313.154	320
   313.184	320
   334.15	41
   365.01	800
   365.48	200
   366.33	150
   404.66	767
   407.78	61.4
   433.922	7.5
   434.751	15
   435.834	1569.7
   491.607	7
   546.075	2258.4
   576.96	297.9
   579.07	300.6
   623.440 0.1
   667.82	0.4
   671.704	0.1
   675.35	0.1
   687.13	0.07
   690.75	3
   696.54	45
   706.72	8.7
   714.7	1.2
   727.29	6
   738.4	7.2
   750.39	21
   751.47	9
   763.51	23
   772.4	15
   794.82	6.5
   800.616	5
   801.479	4.0
   810.37	7.0
   811.53	14.0
   826.45	11
   840.82	4.6
   842.45	8
   852.14	3.7
   866.79	0.5
   912.3	11.6
   922.45	2.3
   935.422 0.2
   965.778	3.8
   978.4503 0.3
   1013.98	5	];



% line_lib = getfullname('*.h5');
line_lib = 'D:\case_studies\radiation_cals\spectral_lines_library.h5';
%%
h5disp(line_lib,'/','min')
%%

Ar = h5read(line_lib,'/Ar');
[Ar, Ar_] = clean_lines(Ar);

Hg = h5read(line_lib,'/Hg');
[Hg, Hg_] = clean_lines(Hg);


wl = Ar.Wavelength>xl(1)&Ar.Wavelength<xl(2);
XX = [Ar.Wavelength(wl),Ar.Wavelength(wl),Ar.Wavelength(wl)]';
YY = ones(size(XX));
YY(1,:) = yl(1);
YY(2,:) = Ar.Intensity(wl)./max(Ar.Intensity(wl));
YY(3,:) = NaN;
Xa = XX(:);
Ya = YY(:);
% hold('on');
wl = Hg.Wavelength>xl(1)&Hg.Wavelength<xl(2);
XX = [Hg.Wavelength(wl),Hg.Wavelength(wl),Hg.Wavelength(wl)]';
YY = zeros(size(XX));
YY(1,:) = yl(1);
YY(2,:) = Hg.Intensity(wl)./max(Hg.Intensity(wl));
YY(3,:) = NaN;
Xb = XX(:);
Yb = YY(:);


 
% if sum(ins.Shuttered_0==0)>0&&sum(ins.Shuttered_0==1)>0   
   axes(ax(1))
   semilogy([Xa],[Ya], 'r-',...
      [Xb],[Yb], 'g-');
   legend('spec','Ar','Hg')
   title('4STAR Spectra with HgAr lamp and reference lines');
   xlim(xl);
   axes(ax(2))
   plot([Xa],[Ya], 'r-',...
      [Xb],[Yb], 'g-');
   legend('spec','Ar','Hg')
%    xlim(xl);
   
   done = false; p = 1;
   while ~done
      ok = menu('Zoom in on a peak and select OK, or select Done.','OK','Done');
      if ok==2
         done = true;
      else
         xl_fit = xlim;
         xl_fit_ = ins.nm>=xl_fit(1)&ins.nm<=xl_fit(2);
         peak = process_spectral_peak(ins.nm(xl_fit_), lights(xl_fit_)./max_light);
         peaks.cwl(p) = peak.mu; peaks.fwhm(p) = peak.fwhm;
         [peaks.cwl, inds] = unique(round(peaks.cwl*2)); peaks.cwl = peaks.cwl./2; peaks.fwhm = peaks.fwhm(inds);
         if length(inds)==p
               axes(ax(1)); semilogy([peak.mu,peak.mu],yl, 'k--');
               axes(ax(2)); plot([peak.mu,peak.mu],yl, 'k--'); 
               p = p+1;
         end

      end
   end
   save([ins.pname, strrep(ins.fname{:},'.csv','.peaks.mat')],'-struct','peaks');
end

return