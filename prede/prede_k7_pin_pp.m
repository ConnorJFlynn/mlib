pp_37 = read_k7_pp(['C:\case_studies\4STAR\ftp.science.arc.nasa.gov\Data\MLO_Aug_2008\Cimel\unit037.PP1']);
pp_101 = read_k7_pp(['C:\case_studies\4STAR\ftp.science.arc.nasa.gov\Data\MLO_Aug_2008\Cimel\unit101.PP1']);
alml_37 = read_k7_alml(['C:\case_studies\4STAR\ftp.science.arc.nasa.gov\Data\MLO_Aug_2008\Cimel\unit037.ALL']);
almr_37 = read_k7_almr(['C:\case_studies\4STAR\ftp.science.arc.nasa.gov\Data\MLO_Aug_2008\Cimel\unit037.ALR']);
done = false;
while ~done
   prede = read_prede('*.RDM');
   prede = cal_prede_rad(prede);
   prede = prede_sky_scans(prede);
   figure(999); plot(serial2doy(prede.time(prede.ppl>0)), prede.SA(prede.ppl>0),'.g-',...
serial2doy(prede.time(prede.ppl_below)), prede.SA(prede.ppl_below),'bo',...
serial2doy(prede.time(prede.ppl_above)), prede.SA(prede.ppl_above),'ro', ...
serial2doy(prede.time(prede.alm>0)), prede.SA(prede.alm>0),'.r-',...
serial2doy(prede.time(prede.alm_l)), prede.SA(prede.alm_l),'bo',...
serial2doy(prede.time(prede.alm_r)), prede.SA(prede.alm_r),'ro');
%    line([star.tlim(2), star.tlim(2)], [min(prede.SA(prede.ppl>0)), max(prede.SA(prede.ppl>0))],'color','r');
   for c = 1:length(pp_37.time);
      line([serial2doy(pp_37.time(c)) ,serial2doy(pp_37.time(c))], [min(prede.SA(prede.ppl>0)), max(prede.SA(prede.ppl>0))],'color','k','linestyle','-');
   end
   for c = 1:length(alml_37.time);
      line([serial2doy(alml_37.time(c)) ,serial2doy(alml_37.time(c))], [min(prede.SA(prede.ppl>0)), max(prede.SA(prede.ppl>0))],'color','g','linestyle',':');
   end
   for c = 1:length(almr_37.time);
      line([serial2doy(almr_37.time(c)) ,serial2doy(almr_37.time(c))], [min(prede.SA(prede.ppl>0)), max(prede.SA(prede.ppl>0))],'color','r','linestyle','--');
   end

%    for c = 1:length(k7_37.time);
%       line([serial2doy(k7_451.time(c)) ,serial2doy(k7_451.time(c))], [min(prede.SA(prede.ppl>0)), max(prede.SA(prede.ppl>0))],'color','b');
%    end
   zoom('on')
   ok = menu('Select "New Prede File" or "Done" when zoomed into desired scan.','New File','Done');
   if ok==2
      done = true;
   end
end
xl = xlim;
xlim(xl)
this = (prede.ppl>0)&(serial2doy(prede.time)>=xl(1))&(serial2doy(prede.time)<= xl(2));

that_pp = (serial2doy(pp_37.time)>xl(1))&(serial2doy(pp_37.time)<= xl(2));
that_alml = (serial2doy(alml_37.time)>xl(1))&(serial2doy(alml_37.time)<= xl(2));
that_almr = (serial2doy(almr_37.time)>xl(1))&(serial2doy(almr_37.time)<= xl(2));

figure; 
ax = [];
ax(2) = subplot(2,1,2); semilogy(abs(prede.SA(this&prede.ppl_above)),[prede.skyrad_filter_2(this&prede.ppl_above);...
   prede.skyrad_filter_3(this&prede.ppl_above);prede.skyrad_filter_4(this&prede.ppl_above);...
   prede.skyrad_filter_5(this&prede.ppl_above)],'-o'); 
title('Prede sky scan')
legend(num2str(prede.header.wl(2)),num2str(prede.header.wl(3)),num2str(prede.header.wl(4)),num2str(prede.header.wl(5)));
ax(1) = subplot(2,1,1);
semilogy(pp_37.scat_deg, pp_37.pp_raw(that_pp,:), '.')
linkaxes(ax,'x');
zoom('on')
ok = menu('Zoom in to select a single SA as calibration point and click done.','Done');
xl2 = xlim;
xlim(xl2)
cal.SA_cimel = (abs(pp_37.scat_deg)>=xl2(1))&(abs(pp_37.scat_deg)<=xl2(2));
cal.SA_prede = this&prede.ppl_above&(abs(prede.SA)>=xl2(1))&(abs(prede.SA)<=xl2(2));
% Now match only at 675nm, 870nm, and 1020nm
match_675 = mean(prede.skyrad_filter_4(cal.SA_prede))./mean(pp_37.pp_raw(that_pp&pp_37.nominal_wl==0.67,cal.SA_cimel));
match_870 = mean(prede.skyrad_filter_5(cal.SA_prede))./mean(pp_37.pp_raw(that_pp&pp_37.nominal_wl==0.87,cal.SA_cimel));
match_1020 = mean(prede.skyrad_filter_7(cal.SA_prede))./mean(pp_37.pp_raw(that_pp&pp_37.nominal_wl==1.02,cal.SA_cimel));

pp_37.pp = NaN(size(pp_37.pp_raw));
pp_37.pp(pp_37.nominal_wl==0.67,:) = pp_37.pp_raw(pp_37.nominal_wl==0.67,:).* match_675;
pp_37.pp(pp_37.nominal_wl==0.87,:) = pp_37.pp_raw(pp_37.nominal_wl==0.87,:).* match_870;
pp_37.pp(pp_37.nominal_wl==1.02,:) = pp_37.pp_raw(pp_37.nominal_wl==01.02,:).* match_1020;


figure; 
semilogy(abs(prede.SA(this&prede.ppl_above)),[prede.skyrad_filter_4(this&prede.ppl_above);...
   prede.skyrad_filter_5(this&prede.ppl_above);prede.skyrad_filter_7(this&prede.ppl_above); ],'-o', ...
   pp_37.scat_deg, pp_37.pp(that_pp&(pp_37.nominal_wl==0.67|pp_37.nominal_wl==0.87|pp_37.nominal_wl==1.02),:), '.')
legend('675nm','870nm','1020nm')
title('Prede is circles, cimel is dots')
xlabel('scattering angle')
ylabel('radiance')