function in_spec = SAS_monoscans_4
%%

% close('all')
%%
% mono = SAS_monoscans_3(indir)
% reads new spectrometer format with header row and N lines of data
in_spec = SAS_read_Albert_csv;
last_dir = in_spec.pname;
last_dir = fliplr(strtok(fliplr(last_dir),filesep));
in_spec.scan_nm = in_spec.Wavelength;
[dmp,sn] = strtok(char(in_spec.fname),'_');
[in_spec.sn,~] = strtok(sn(2:end),'.');
 

   
   %% This attempts to obtain a better dark counts subtraction by scaling 
   % the mean dark (measured while the shutter was closed)
   % to the measured spectra while shutter was open but at a wavelength
   % range well above the monochromator scan wavelength
   % by using not only times when it was shuttered but also by using pixels beyond the monochromator wavelength
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
   
   open_shut = find(in_spec.Shuttered_0==1);
  [scan_nm,sind] = sort(in_spec.scan_nm(open_shut));
  in_spec.scan_nm = in_spec.scan_nm(open_shut(sind));
   in_spec.Intgration = in_spec.Intgration(open_shut(sind));
   in_spec.spec = in_spec.spec(open_shut(sind),:);
   in_spec.spec_less_dark = in_spec.spec_less_dark(open_shut(sind),:);
     in_spec.norm = in_spec.spec_less_dark./(in_spec.Intgration*ones([1,size(in_spec.spec,2)]));
     maxes = max(in_spec.norm,[],2); 
     in_spec.norm = in_spec.norm./(maxes*ones([1,size(in_spec.norm,2)]));

     for nn = length(in_spec.scan_nm):-1:1
         nm_ = in_spec.norm(nn,:)>0.05 & in_spec.norm(nn,:)<0.99 & abs(in_spec.nm-in_spec.scan_nm(nn))<20;
         [sigma(nn),mu(nn),A(nn),FWHM(nn),peak(nn)]=mygaussfit(in_spec.nm(nm_),in_spec.norm(nn,nm_),0);
     end
   figure; plot(in_spec.scan_nm,FWHM,'o-')
 cleaned = false;
 flagged = false(size(in_spec.scan_nm));
while ~cleaned
       
    OK = menu('Zoom in and click OK to trim points outside the vertical range','Trim','Done');

    if OK == 1
        xl = xlim; yl = ylim;
        sub = in_spec.scan_nm>=xl(1) & in_spec.scan_nm<=xl(2) ;
        flagged(sub) = FWHM(sub)<yl(1)|FWHM(sub)>yl(2);
    elseif OK==2
        cleaned = true;
    end
    P1 = polyfit(in_spec.scan_nm(~flagged), FWHM(~flagged)',1);
    P2 = polyfit(in_spec.scan_nm(~flagged), FWHM(~flagged)',2);
    
    plot(in_spec.scan_nm(~flagged),FWHM(~flagged),'ko',...
        in_spec.scan_nm(~flagged),polyval(P1,in_spec.scan_nm(~flagged)),'b-',...
        in_spec.scan_nm(~flagged),polyval(P2,in_spec.scan_nm(~flagged)),'r-');
    
end   
in_spec.flagged = flagged;
in_spec.FWHM = FWHM;
in_spec.P1 = P1;

% scan_nm = in_spec.scan_nm(~flagged);
% smooth_FWHM = smooth(FWHM(~flagged),12);
% [scan_nm, ij] = unique(round(scan_nm));
% smooth_FWHM = smooth_FWHM(ij);
% in_spec.FWHM(isnan(in_spec.FWHM)) = interp1(in_spec.scan_nm(~flagged),in_spec.FWHM(~flagged),in_spec.scan_nm(isnan(in_spec.FWHM)),'pchip');
% in_spec.FWHM(isnan(in_spec.FWHM)) = interp1(in_spec.scan_nm(~flagged),FWHM(~flagged),in_spec.scan_nm(isnan(in_spec.FWHM)),'nearest','extrap');
% %%
% figure; lines = plot(in_spec.nm, in_spec.spec_less_dark,'-');
% lines = recolor(lines, in_spec.scan_nm');
% colorbar
title({last_dir;in_spec.sn}, 'interp','none');
%  saveas(gcf,[in_spec.pname,in_spec.sn,'_monoscan_traces.emf']);
%   saveas(gcf,[in_spec.pname,in_spec.sn,'_monoscan_traces.png']);



%%

% 

figure; imagegap(in_spec.nm,in_spec.scan_nm, real(log10(in_spec.spec_less_dark))); 
axis('xy');  colorbar
title({last_dir;in_spec.sn}, 'interp','none');
ylabel('scan nm')
xlabel('pixel')
%  saveas(gcf,[in_spec.pname,in_spec.sn,'_monoscan_raw_image.emf']);
%   saveas(gcf,[in_spec.pname,in_spec.sn,'_monoscan_raw_image.png']);

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
% axis([900 1550  900  1500]);
% axis([350 1000  300  1100]);
%  saveas(gcf,[in_spec.pname,in_spec.sn,'_monoscan_rel_image.emf']);
%   saveas(gcf,[in_spec.pname,in_spec.sn,'_monoscan_rel_image.png']);

 %%

return
     