%twst monoscans

% full-scan
visfile = getfullname('*_vis_*.csv','sasze');
[pname, vis_stem,ext] = fileparts(visfile);
pname = strrep([pname, filesep], [filesep filesep], filesep);
vis_stem = 'sgpsaszevisS1';nir_stem = 'sgpsaszenirS1';
vis = rd_SAS_raw(visfile); nir = rd_SAS_raw([vis.pname{:},strrep(vis.fname{:},'vis','nir')]);

figure; imagesc(vis.rate); axis('xy')
imagesc(vis.rate ./ (max(vis.rate))); axis('xy'); caxis([0,cv(2)])

vnorm = vis.sig ./ (ones(size(vis.wl))*max(vis.sig));
nnorm = nir.sig ./ (max(nir.sig,[],2)*ones(size(nir.wl)));
lnorm_A = real(log10(vnorm)); lnorm_A(vnorm<=0) = NaN;
lnorm_B = real(log10(nnorm)); lnorm_B(nnorm<=0) = NaN;
 figure; 
 sb(1) = subplot(1,2,1);
imagesc(vis.wl,[1:length(vis.time)],vis.rate ./ (max(vis.rate,[],1))); 
cv = caxis; caxis([0,cv(2)])
axis('xy')
 title('vis')
 xlabel('wavelength (nm)');
 ylabel('scanning index');
  sb(2) = subplot(1,2,2);
 imagesc( nir.wl,[1:length(nir.time)], nir.rate ./ (max(nir.rate,[],1))); 
cv = caxis; caxis([0,cv(2)])
axis('xy')
 title('nir')
 xlabel('wavelength (nm)');
 ylabel('scanning index');
 linkaxes(sb,'y');
 h_mt = mtit(twst.fname)
h_mt.th.Position(2) =h_mt.th.Position(2) + .05


 
 figure; 
 sb(1) = subplot(1,2,1);
imagesc(vis.wl,[1:length(vis.time)],real(log10(vis.rate ./ (max(vis.rate,[],1))))); 
cv = caxis; caxis([-3,0])
axis('xy')
 title('vis')
 xlabel('wavelength (nm)');
 ylabel('scanning index');
  sb(2) = subplot(1,2,2);
 imagesc( nir.wl,[1:length(nir.time)], real(log10(nir.rate ./ (max(nir.rate,[],1))))); 
cv = caxis; caxis([-3,cv(2)])
axis('xy')
 title('nir')
 xlabel('wavelength (nm)');
 ylabel('scanning index');
 linkaxes(sb,'y');
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
