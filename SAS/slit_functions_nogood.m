%recent history:
% It looks like the monochromator was configured to provide light volume to
% permit recycled light detection, but were thus too broad in wavelength to
% permit determination of the slit function of the SAS and SWS specs. 

SAS_monoscans_4
help  my_fit
in_spec.Wavelength(30)
in_spec.scan_nm(25)
figure; plot(in_spec.nm, in_spec.norm(25,:),'-'); zoom;
logy
nm_ = in_spec.norm(25,:)>0.1 & in_spec.norm(25,:)<0.98;
figure; plot(in_spec.nm, in_spec.norm(25,:),'r-',in_spec.nm(nm_), in_spec.norm(25,nm_),'k-'); zoom;
nm_ = in_spec.norm(25,:)>0.1 & in_spec.norm(25,:)<0.97;
figure; plot(in_spec.nm, in_spec.norm(25,:),'r-',in_spec.nm(nm_), in_spec.norm(25,nm_),'k-'); zoom;
nm_ = in_spec.norm(25,:)>0.1 & in_spec.norm(25,:)<0.99;
figure; plot(in_spec.nm, in_spec.norm(25,:),'r-',in_spec.nm(nm_), in_spec.norm(25,nm_),'k-'); zoom;
logy
nm_ = in_spec.norm(25,:)>0.02 & in_spec.norm(25,:)<0.99;
figure; plot(in_spec.nm, in_spec.norm(25,:),'r-',in_spec.nm(nm_), in_spec.norm(25,nm_),'k-'); zoom;
logy
nm_ = in_spec.norm(25,:)>0.05 & in_spec.norm(25,:)<0.99;
figure; plot(in_spec.nm, in_spec.norm(25,:),'r-',in_spec.nm(nm_), in_spec.norm(25,nm_),'k-'); zoom;
logy
for nn = length(in_spec.scan_nm):-1:1
nm_ = in_spec.norm(nn,:)>0.05 & in_spec.norm(nn,:)<0.99;
[sigma(nn),mu(nn),A(nn),FWHM(nn),peak(nn)]=mygaussfit(in_spec.nm(nm_),in_spec.norm(nn,nm_),1);
end
figure; plot(in_spec.scan_nm,FWHM,'o-')
figure; plot(in_spec.nm, in_spec.norm(25,:),'r-',in_spec.nm(nm_), in_spec.norm(25,nm_),'k-'); zoom;
nn = 25;
nm_ = in_spec.norm(nn,:)>0.05 & in_spec.norm(nn,:)<0.99;
figure; plot(in_spec.nm, in_spec.norm(25,:),'r-',in_spec.nm(nm_), in_spec.norm(25,nm_),'k-'); zoom;
figure; plot(in_spec.nm, in_spec.norm(nn,:),'r-',in_spec.nm(nm_), in_spec.norm(nn,nm_),'k-'); zoom;
[sigma(nn),mu(nn),A(nn),FWHM(nn),peak(nn)]=mygaussfit(in_spec.nm(nm_),in_spec.norm(nn,nm_),1);
figure; plot(x,y,'o-')
[sigma(nn),mu(nn),A(nn),FWHM(nn),peak(nn)]=mygaussfit(in_spec.nm(nm_),in_spec.norm(nn,nm_),0);
for nn = length(in_spec.scan_nm):-1:1
nm_ = in_spec.norm(nn,:)>0.05 & in_spec.norm(nn,:)<0.99;
[sigma(nn),mu(nn),A(nn),FWHM(nn),peak(nn)]=mygaussfit(in_spec.nm(nm_),in_spec.norm(nn,nm_),0);
end
figure; plot(in_spec.scan_nm,FWHM,'o-')
length(unique(in_spec.scan_nm))
min(in_spec.scan_nm)
%%
figure; lines = plot(in_spec.nm, in_spec.spec_less_dark,'-');
lines = recolor(lines, in_spec.scan_nm');
colorbar
title({last_dir;in_spec.sn}, 'interp','none');
nn = 10;
in_spec.scan_nm(nn)
nn = 7;
in_spec.scan_nm(nn)
figure; plot(in_spec.nm, in_spec.norm(nn,:),'r-',in_spec.nm(nm_), in_spec.norm(nn,nm_),'k-'); zoom;
nm_ = in_spec.norm(nn,:)>0.05 & in_spec.norm(nn,:)<0.99;
figure; plot(in_spec.nm, in_spec.norm(nn,:),'r-',in_spec.nm(nm_), in_spec.norm(nn,nm_),'k-'); zoom;
nm_ = in_spec.norm(nn,:)>0.05 & in_spec.norm(nn,:)<0.99 & abs(in_spec.nm-in_spec.scan_nm(nn))<20;
figure; plot(in_spec.nm, in_spec.norm(nn,:),'r-',in_spec.nm(nm_), in_spec.norm(nn,nm_),'k-'); zoom;
for nn = length(in_spec.scan_nm):-1:1
nm_ = in_spec.norm(nn,:)>0.05 & in_spec.norm(nn,:)<0.99 & abs(in_spec.nm-in_spec.scan_nm(nn))<20;
[sigma(nn),mu(nn),A(nn),FWHM(nn),peak(nn)]=mygaussfit(in_spec.nm(nm_),in_spec.norm(nn,nm_),0);
end
figure; plot(in_spec.scan_nm,FWHM,'o-')
SAS_monoscans_4
clear; close('all')
SAS_monoscans_4
plot(in_spec.scan_nm(~flagged),FWHM(~flagged),'o-',in_spec.scan_nm(flagged),smooth(FWHM(flagged)),'kx')
help smooth
plot(in_spec.scan_nm(~flagged),FWHM(~flagged),'o-',in_spec.scan_nm(flagged),smooth(FWHM(flagged),7),'kx')
plot(in_spec.scan_nm(~flagged),FWHM(~flagged),'o-',in_spec.scan_nm(~flagged),smooth(FWHM(~flagged),7),'kx')
plot(in_spec.scan_nm(~flagged),FWHM(~flagged),'o-',in_spec.scan_nm(~flagged),smooth(FWHM(~flagged),10),'kx')
plot(in_spec.scan_nm(~flagged),FWHM(~flagged),'o-',in_spec.scan_nm(~flagged),smooth(in_spec.scan_nm(~flagged),FWHM(~flagged),.2,'rloess'),'kx')
plot(in_spec.scan_nm(~flagged),FWHM(~flagged),'o-',in_spec.scan_nm(~flagged),smooth(in_spec.scan_nm(~flagged),FWHM(~flagged),.3,'rloess'),'kx')
plot(in_spec.scan_nm(~flagged),FWHM(~flagged),'o-',in_spec.scan_nm(~flagged),smooth(FWHM(~flagged),50),'kx')
plot(in_spec.scan_nm(~flagged),FWHM(~flagged),'o-',in_spec.scan_nm(~flagged),smooth(FWHM(~flagged),15),'kx')
plot(in_spec.scan_nm(~flagged),FWHM(~flagged),'o-',in_spec.scan_nm(~flagged),smooth(FWHM(~flagged),12),'kx')
SAS_monoscans_4
in_spec.FWHM = NaN(size(in_spec.scan_nm));
in_spec.FWHM(~flagged) = smooth(FWHM(~flagged),12);
plot(in_spec.scan_nm(~flagged),FWHM(~flagged),'o-',in_spec.scan_nm(~flagged),in_spec.FWHM(~flagged),'rx');
in_spec.FWHM(isnan(in_spec.FWHM)) = interp1(in_spec.scan_nm(~flagged),in_spec.FWHM(~flagged),in_spec.scan_nm(isnan(in_spec.FWHM)),'pchip');
in_spec.scan_nm(isnan(in_spec.FWHM))
in_spec.scan_nm(~flagged)
interp1(in_spec.scan_nm(~flagged),in_spec.FWHM(~flagged),in_spec.scan_nm(isnan(in_spec.FWHM)),'pchip')
interp1(in_spec.scan_nm(~flagged),in_spec.FWHM(~flagged),in_spec.scan_nm(isnan(in_spec.FWHM)),'linear')
sum(~isflagged)
sum(~flagged)
diff(in_spec.scan_nm(~flagged)
diff(in_spec.scan_nm(~flagged))
help smooth
help unique
SAS_monoscans_4
scan_nm = in_spec.scan_nm(~flagged);
smooth_FWHM = smooth(FWHM(~flagged),12);
scan_nm
diff(scan_nm)
scan_nm
scan_nm = in_spec.scan_nm(~flagged);
smooth_FWHM = smooth(FWHM(~flagged),12);
[scan_nm, ij] = unique(round(scan_nm));
smooth_FWHM = smooth_FWHM(ij);
scan_nm = in_spec.scan_nm(~flagged);
smooth_FWHM = smooth(FWHM(~flagged),12);
[scan_nm, ij] = unique(round(scan_nm));
smooth_FWHM = smooth_FWHM(ij);
diff(scan_nm)
SAS_monoscans_4
figure; lines = plot(in_spec.nm, in_spec.spec_less_dark,'-');
lines = recolor(lines, in_spec.scan_nm');
colorbar
title({last_dir;in_spec.sn}, 'interp','none');