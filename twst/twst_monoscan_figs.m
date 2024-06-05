%twst monoscans

% full-scan
 twst = twst4_to_struct;
twst.norm_A = twst.sig_A ./ (ones(size(twst.wl_A))*max(twst.sig_A));
twst.norm_B = twst.sig_B ./ (ones(size(twst.wl_B))*max(twst.sig_B));
twst.lnorm_A = real(log10(twst.norm_A)); twst.lnorm_A(twst.norm_A<=0) = NaN;
twst.lnorm_B = real(log10(twst.norm_B)); twst.lnorm_B(twst.norm_B<=0) = NaN;
 figure; 
 sb(1) = subplot(1,2,1);
 imagesc(twst.wl_A,[1:length(twst.time)],twst.lnorm_A'); axis('xy'); caxis([-3,0])
 title('ch A')
 xlabel('wavelength ch A (nm)');
 ylabel('scanning index');
  sb(2) = subplot(1,2,2);
 imagesc(twst.wl_B,[1:length(twst.time)],twst.lnorm_B'); axis('xy'); caxis([-3,0])
 title('ch B')
 xlabel('wavelength ch A (nm)');
 ylabel('scanning index');
 linkaxes(sb,'y');
 h_mt = mtit(twst.fname)
h_mt.th.Position(2) =h_mt.th.Position(2) + .05


 figure; 
 sc(1) = subplot(1,2,1);
 imagesc(twst.wl_A,[1:length(twst.time)],real(log10(twst.sig_A'))); axis('xy'); ca = caxis;
 title('ch A')
 xlabel('wavelength ch A (nm)');
 ylabel('scanning index');
  sc(2) = subplot(1,2,2);
 imagesc(twst.wl_B,[1:length(twst.time)],real(log10(twst.sig_B'))); axis('xy'); caxis(ca)
 title('ch B')
 xlabel('wavelength ch A (nm)');
 ylabel('scanning index');
 linkaxes(sc,'y');
 h_mt = mtit(twst.fname)
h_mt.th.Position(2) =h_mt.th.Position(2) + .05

 figure; 
 sc(1) = subplot(1,2,1);
 imagesc(twst.wl_A,[1:length(twst.time)],real(log10(twst.zenrad_A'))); axis('xy'); ca = caxis;
 title('Radiance ch A')
 xlabel('wavelength ch A (nm)');
 ylabel('scanning index');
  sc(2) = subplot(1,2,2);
 imagesc(twst.wl_B,[1:length(twst.time)],real(log10(twst.zenrad_B'))); axis('xy'); caxis(ca)
 title('Radiance ch B')
 xlabel('wavelength ch A (nm)');
 ylabel('scanning index');
 linkaxes(sc,'y');
 h_mt = mtit(twst.fname)
h_mt.th.Position(2) =h_mt.th.Position(2) + .05
