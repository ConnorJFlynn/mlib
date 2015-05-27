% anet_pp = read_anet_pp(['C:\case_studies\4STAR\ftp.science.arc.nasa.gov\Data\MLO_Aug_2008\Cimel\2008_08_29_Mauna_Loa.ppl']);
anet_pp = read_anet_pp(['C:\case_studies\4STAR\ftp.science.arc.nasa.gov\Data\MLO_Aug_2008\Cimel\20080824_20080902_Mauna_Loa.ppl']);

% almr_37 = read_k7_almr(['C:\case_studies\4STAR\ftp.science.arc.nasa.gov\Data\MLO_Aug_2008\Cimel\unit037.ALR']);
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
   for c = 1:length(anet_pp.time);
      line([serial2doy(anet_pp.time(c)) ,serial2doy(anet_pp.time(c))], [min(prede.SA(prede.ppl>0)), max(prede.SA(prede.ppl>0))],'color','k','linestyle','-');
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

that_pp = (serial2doy(anet_pp.time)>xl(1))&(serial2doy(anet_pp.time)<= xl(2));
% that_alml = (serial2doy(alml_37.time)>xl(1))&(serial2doy(alml_37.time)<= xl(2));
% that_almr = (serial2doy(almr_37.time)>xl(1))&(serial2doy(almr_37.time)<= xl(2));

figure; 
semilogy(abs(prede.SA(this&prede.ppl_above)),[prede.skyrad_filter_4(this&prede.ppl_above);...
   prede.skyrad_filter_5(this&prede.ppl_above);prede.skyrad_filter_7(this&prede.ppl_above)],'-o', ...
   anet_pp.scat_deg, anet_pp.pp(that_pp,:), '.'); 
title('Prede sky scan')
legend(num2str(prede.header.wl(4)),num2str(prede.header.wl(5)),num2str(prede.header.wl(7)),'Aeronet');
ax(1) = subplot(2,1,1);
semilogy(anet_pp.scat_deg, anet_pp.pp(that_pp,:), 'x')

zoom('on')
ylabel('radiance')