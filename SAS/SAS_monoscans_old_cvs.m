function mono = SAS_monoscans_old_cvs(indir)
if ~exist('indir','var')
   indir = getdir;
end
ridni = fliplr(indir);
pmt = fliplr(strtok(ridni(2:end),filesep));

%% SAS monoscans
% Reading Albert's data files
% pname = ['C:\case_studies\ARRA\SAS\Avantes\monoscans\0911134U1_2048\all\'];
% pname = ['C:\case_studies\ARRA\SAS\Avantes\monoscans\0911145U1_NIR\all\'];
%    %
   pname = indir;
   dark_files = dir([pname,'*_Back.csv']);
   for dk = length(dark_files):-1:1

      [dmp,tmp] = strtok(dark_files(dk).name,'_');
      dark_nm(dk) = sscanf(dmp,'%d');
     [tint, tmp]= strtok(tmp,'_');
     tint = sscanf(tint, '%d');
     dark_tint(dk) = tint;
     CCD_dark = load([pname,dark_files(dk).name]);
     dark_cts(:,dk) = CCD_dark(:,2);

   end
% sort dark counts in order of tint
[dark_tints] = unique(dark_tint);
for dk = length(dark_tints):-1:1
   dk_tf = dark_tint==dark_tints(dk);
   if sum(dk_tf)==1
      darks.tint(dk) = dark_tint(dk_tf);
      darks.cts(:,dk) = dark_cts(:,dk_tf);
   else
      darks.tint(dk) = mean(dark_tint(dk_tf));
      darks.cts(:,dk) = mean(dark_cts(:,dk_tf),2);
   end
end
%%
   
   %%
   mono_files = dir([pname,'*avg.csv']);
   for m = length(mono_files):-1:1
      [dmp,tmp] = strtok(mono_files(m).name,'_');
      mono.scan_nm(m) = sscanf(dmp,'%d');
     [tint, tmp]= strtok(tmp,'_');
     mono.tint(m) = sscanf(tint, '%d');
     light = load([pname,mono_files(m).name]);
     mono.raw(:,m) = light(:,2);
     dark_patch = light(:,1)>(mono.scan_nm(m)+100);
     dark_match = mean(light(dark_patch,2))...
        ./ mean(darks.cts(dark_patch,darks.tint==mono.tint(m)));
     mono.spec(:,m) = mono.raw(:,m) - dark_match.*(darks.cts(:,darks.tint==mono.tint(m)));
   end
   %%
   
   
   [scan_nm,sind] = sort(mono.scan_nm);
   mono.scan_nm = mono.scan_nm(sind);
   mono.tint = mono.tint(sind);
   mono.raw = mono.raw(:,sind);
   mono.spec = mono.spec(:,sind);
     mono.norm = mono.spec./(ones([size(mono.spec,1),1])*mono.tint);
     maxes = max(mono.norm); 
     mono.norm = mono.norm./(ones([size(mono.norm,1),1])*maxes);
   %%
mono.sn = pmt;
mono.darks = darks;

nm = light(:,1);
[tmp,I,J] = unique(nm,'first'); % B = A(I)
mono.nm = interp1(I,tmp, [1:length(nm)],'linear','extrap')';

nm_file = dir([pname,'*MapPixToWave.csv']);
if ~isempty(nm_file)
   nm_map = load([pname, nm_file(1).name]);
   mono.nm = nm_map(:,1);
end

% 
% 
% figure; imagesc(mono.nm,mono.scan_nm, real(log10(mono.norm))'); 
% axis('xy'); caxis([-5,0]); colorbar
% title(pmt, 'interp','none');
% ylabel('scan nm')
% xlabel('pixel')

B = fill_img_nogap(mono.norm, mono.scan_nm);
mono.normB = B;
%%
% ii = 61;
% % disp(num2str(mono.scan_nm(ii)))
% figure; semilogy(mono.nm, mono.norm(:,ii),'-');
% title(['monochromator wavelength: ',num2str(mono.scan_nm(ii)), ' nm']);
% xlabel('pixel wavelength [nm]');
% ylabel('normalized signal [raw - dark]')
%%
save([indir,pmt,'.mat'],'-struct','mono')
figure; 
%%
nm_ = mono.scan_nm>=550 & mono.scan_nm<=800;
imagesc(mono.nm, mono.scan_nm(nm_), real(log10(B(:,nm_)))'); 
axis('xy'); caxis([-3,0]); cb=colorbar;
cb_title = get(cb,'title');
set(cb_title,'string','log_1_0(signal)');
title({pmt,'max signal normalized to unity'}, 'interp','none');
ylabel('scan nm (de-gapped)')
xlabel('pixel wavelength [nm]')
%
saveas(gcf,[indir,pmt,'_monoscan.png']);

return
     