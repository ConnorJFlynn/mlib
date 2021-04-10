function in_spec = SAS_monoscans_3(indir)
%%

% close('all')
%%
% mono = SAS_monoscans_3(indir)
% reads new spectrometer format with header row and N lines of data
in_spec = SAS_read_Albert_csv;
last_dir = in_spec.pname;
last_dir = fliplr(strtok(fliplr(last_dir),filesep));
in_spec.scan_nm = in_spec.Wavelength;

   
   %%
   disp(' This is giving NaNs for WL > 1700, fix someday...')
in_spec.spec_less_dark = NaN(size(in_spec.spec));
in_spec.norm = in_spec.spec_less_dark;
   for m = length(in_spec.time):-1:1
     dark_patch = in_spec.nm>(in_spec.Wavelength(m)+100);
     dark_match = mean(in_spec.spec(m,dark_patch))...
        ./ mean(mean(in_spec.spec(in_spec.Shuttered_0==0,dark_patch)));
     in_spec.spec_less_dark(m,:) = in_spec.spec(m,:) - dark_match.*(mean(in_spec.spec(in_spec.Shuttered_0==0,:),1));
   end
   %%
   
   
  [scan_nm,sind] = sort(in_spec.scan_nm);
  in_spec.scan_nm = in_spec.scan_nm(sind);
   in_spec.Intgration = in_spec.Intgration(sind);
   in_spec.spec = in_spec.spec(sind,:);
   in_spec.spec_less_dark = in_spec.spec_less_dark(sind,:);
     in_spec.norm = in_spec.spec_less_dark./(in_spec.Intgration*ones([1,size(in_spec.spec,2)]));
     maxes = max(in_spec.norm(in_spec.Shuttered_0==1,:),[],2); 
     in_spec.norm(in_spec.Shuttered_0==1,:) = in_spec.norm(in_spec.Shuttered_0==1,:)./(maxes*ones([1,size(in_spec.norm,2)]));
   
%%
figure; lines = plot(in_spec.nm, in_spec.spec_less_dark,'-');
lines = recolor(lines, in_spec.scan_nm');
colorbar
title({last_dir;in_spec.sn}, 'interp','none');



%%

% 

figure; imagegap(in_spec.nm,in_spec.scan_nm, real(log10(in_spec.spec_less_dark))); 
axis('xy');  colorbar
title({last_dir;in_spec.sn}, 'interp','none');
ylabel('scan nm')
xlabel('pixel')
%%
% B = fill_img_nogap(in_spec.norm, in_spec.scan_nm');
% 
% %%
% ii = 61;
% % disp(num2str(in_spec.scan_nm(ii)))
% figure; semilogy(in_spec.nm, in_spec.norm(ii,:),'-');
% title(['monochromator wavelength: ',num2str(in_spec.scan_nm(ii)), ' nm']);
% xlabel('pixel wavelength [nm]');
% ylabel('normalized signal [raw - dark]')
%%

figure; 
imagegap(in_spec.nm, in_spec.scan_nm, real(log10(in_spec.norm))); 
axis('xy'); caxis([-3,0]); cb=colorbar;
cb_title = get(cb,'title');
set(cb_title,'string','log_1_0(signal)');
title({last_dir;[in_spec.sn, ': max signal normalized to unity']}, 'interp','none');
ylabel('scan nm (de-gapped)')
xlabel('pixel wavelength [nm]')
% %
axis([900 1550  1100  1500]);
 saveas(gcf,[in_spec.pname,in_spec.sn,'_monoscan.emf']);
 %%

return
     