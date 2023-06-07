% 2023 polarization analysis of new SASZe head without 45-deg mirror.
% According to Thorlabs, I could do even better with protected silver but
% cuts out ~425 nm Might be fine.
clear pol Tr
fnames = getfullname('*.ttt','ava_txt');
[~,exp_name,~] = fileparts(fnames{1}); %[~,tok] = strtok(exp_name,'_'); [~,kot] = strtok(fliplr(tok(2:end)),'_'); exp_name = fliplr(kot(2:end))
for f = 1:length(fnames)

   in_file = read_ava_txt(fnames{f});
   if ~isavar('pol')
      pol.nm = in_file.nm;
      pol.Tr = in_file.Tr;
   else
      pol.Tr = [pol.Tr, in_file.Tr];


   end
end


Tr = pol.Tr';

if any(pol.nm>1500) % Then it is NIR
 bad_wl = pol.nm<1050 | ((pol.nm>1300)&(pol.nm<1450)) | pol.nm>1700;
else
 bad_wl = pol.nm<550 | pol.nm>950;
end
Tr(:,bad_wl) = NaN;
figure; lines = plot([0:20:360],Tr,'-'); colormap('jet'); recolor(lines,pol.nm); title(exp_name)
% figure; lines = plot(pol.nm, Tr','-'); colormap(jej); recolor(lines,[0:20:360]); title(exp_name)

% This block of code removes the dependence of a 360 degree rotation due to
% whatever is causing it leaving only higher modes such the 180-degree that
% is due to the polarization orientation leaving the polarizer.
Tr_ifft = ifft(Tr,[],1);
Tr_ifft(2,:) = 0;
Tr_ifft(end,:) = 0;
Tr_fft = fft(Tr_ifft,[],1);
figure; lines = plot([0:20:360], real(Tr_fft),'-'); colormap('jet'); recolor(lines,pol.nm); title(exp_name)
figure; lines = plot(pol.nm, real(Tr_fft)','-'); colormap(jej); recolor(lines,[0:20:360]); title(exp_name)

