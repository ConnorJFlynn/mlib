function in_spec = SAS_monoscans_6
%% Tried to reduce ambient noise levels with smoothing.  Works OK for VIS, not so well for NIR.
% For NIR use SAS_monoscans_5 

% close('all')
%%
% mono = SAS_monoscans_3(indir)
% reads new spectrometer format with header row and N lines of data
in_spec = SAS_read_Albert_csv;

last_dir = in_spec.pname;
last_dir = fliplr(strtok(fliplr(last_dir),filesep));

[dmp,sn] = strtok(char(in_spec.fname),'_');
[in_spec.sn,~] = strtok(sn(2:end),'.');

span = 8;

for t = length(in_spec.time):-1:1
   in_spec.spec_sm(t,:) = smooth(in_spec.spec(t,:),span);
end
%  Interpolate between Shutter == 0 to yield a darks the same size and
 %  shape as spec
 dark_span = 8;
 dark_times = find(in_spec.Shuttered_0==0);
 for n = length(in_spec.nm):-1:1
    darks(:,n) = interp1(in_spec.time(dark_times), smooth(in_spec.spec_sm(dark_times,n),dark_span)',in_spec.time,'linear');
 end
 
 in_spec.sig = in_spec.spec - darks;  in_spec.sig_sm = in_spec.spec_sm - darks;
 in_spec.rate = in_spec.sig ./ (in_spec.Intgration * ones([1,length(in_spec.nm)]));
 in_spec.rate_sm = in_spec.sig_sm ./ (in_spec.Intgration * ones([1,length(in_spec.nm)]));
 
 lights = find(in_spec.Shuttered_0==1);
  N_pix = length(in_spec.nm);
for li = 1:length(lights)
   xx = lights(li);
   [peak,max_ii] = max(in_spec.rate(xx,:));below = max([1,max_ii-1]); above = min([max_ii+1,length(in_spec.nm)]);
   while below>1 && in_spec.rate(xx,below)>in_spec.rate_sm(below)
      below = below -1;
   end
   while below>1 && in_spec.rate(xx,below)<=in_spec.rate_sm(below)
      below = below -1;
   end
   while above<N_pix && in_spec.rate(xx,above)>in_spec.rate_sm(above)
      above = above +1;
   end
   while above<N_pix && in_spec.rate(xx,above)<=in_spec.rate_sm(above)
      above = above +1;
   end
   in_spec.rate_sm(xx,below:above) = in_spec.rate(xx,below:above);  
end
 
 
   open_shut = find(in_spec.Shuttered_0==1);
  [scan_nm,sind] = unique(round(in_spec.Wavelength(open_shut).*2)./2);
  in_spec.scan_nm = in_spec.Wavelength(open_shut(sind));
     in_spec.norm = in_spec.rate_sm(open_shut(sind),:);
     
     maxes = max(in_spec.norm,[],2); 
     in_spec.norm = in_spec.norm./(maxes*ones([1,size(in_spec.norm,2)]));
     for nn = length(in_spec.scan_nm):-1:1
         nm_ = in_spec.norm(nn,:)>0.05 & in_spec.norm(nn,:)<0.99 & abs(in_spec.nm-in_spec.scan_nm(nn))<20;
         if sum(nm_)>2
            [sigma(nn),mu(nn),A(nn),FWHM(nn),peak(nn)]=mygaussfit(in_spec.nm(nm_),in_spec.norm(nn,nm_),0);
         else
            sigma(nn)=NaN;mu(nn)=NaN;A(nn)=NaN;FWHM(nn)=NaN;peak(nn)=NaN;
         end
     end
   figure; plot(in_spec.scan_nm,FWHM,'o-'); zoom('on');
 cleaned = false;
 flagged = isnan(FWHM);
while ~cleaned
       
    OK = menu('Zoom in and click OK to trim points outside the vertical range','Trim','Done');

    if OK == 1
        xl = xlim; yl = ylim;
        sub = in_spec.scan_nm>=xl(1) & in_spec.scan_nm<=xl(2) ;
        flagged(sub) = flagged(sub)|FWHM(sub)<yl(1)|FWHM(sub)>yl(2);
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

scan_nm = in_spec.scan_nm(~flagged);
smooth_FWHM = smooth(FWHM(~flagged),12);
[scan_nm, ij] = unique(round(scan_nm));
smooth_FWHM = smooth_FWHM(ij);
in_spec.FWHM(isnan(in_spec.FWHM)) = interp1(in_spec.scan_nm(~flagged),in_spec.FWHM(~flagged),in_spec.scan_nm(isnan(in_spec.FWHM)),'pchip');
in_spec.FWHM(isnan(in_spec.FWHM)) = interp1(in_spec.scan_nm(~flagged),FWHM(~flagged),in_spec.scan_nm(isnan(in_spec.FWHM)),'nearest','extrap');
%%





figure; lines = plot(in_spec.nm, in_spec.rate_sm(open_shut(sind),:),'-');logy
lines = recolor(lines, in_spec.scan_nm');
colorbar
title({last_dir;in_spec.sn}, 'interp','none');

title({last_dir;in_spec.sn}, 'interp','none');
%  saveas(gcf,[in_spec.pname,in_spec.sn,'_monoscan_traces.emf']);
%   saveas(gcf,[in_spec.pname,in_spec.sn,'_monoscan_traces.png']);

figure; imagegap(in_spec.nm,in_spec.scan_nm, real(log10(in_spec.rate_sm(open_shut(sind),:)))); 
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
axis('xy'); caxis([-3.5,0]); cb=colorbar;
cb_title = get(cb,'title');
set(cb_title,'string','log_1_0(signal)');
title({last_dir;[in_spec.sn, ': max signal normalized to unity']}, 'interp','none');
ylabel('scan nm (de-gapped)')
xlabel('pixel wavelength [nm]')
% %
% axis([900 1550  900  1500]);
if ~any(in_spec.nm>1500)
axis([350 1050  350  1050]); axis('square');
end
caxis([-3.7,0])
%  saveas(gcf,[in_spec.pname,in_spec.sn,'_monoscan_rel_image.emf']);
%   saveas(gcf,[in_spec.pname,in_spec.sn,'_monoscan_rel_image.png']);

 %%

return
     