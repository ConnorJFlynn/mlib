function ins = POL_SAS_Ze(infile)
%ins = _read_ava(infile)
% Reads one of Albert's Labview files for with multiple AvaSpec spectra per data file.
%
if ~exist('infile','var')
   infile= getfullname('*.csv','SAS_tests');
end
    
if ~isstruct(infile)&exist(infile,'file')
    ins = SAS_read_Albert_csv(infile);
end

fname =    ins.fname{1};
pname =    ins.pname;
emanp = fliplr(pname);
tok = fliplr(deblank(strtok(emanp,'\')));

ins.sig = ins.spec(ins.Shuttered_0==1,:)- (ones([sum(ins.Shuttered_0==1),1])*mean(ins.spec(ins.Shuttered_0==0,:)));
maxmax = max(max(ins.sig));
ins.norm = ins.sig ./(ones([sum(ins.Shuttered_0==1),1])*max(ins.sig));
ins.norm(ins.sig<0.2*maxmax) = NaN;
if length(ins.nm)>500
    fac = 10;
    nml = [450,1000];
    nm_ii = interp1(ins.nm, [1:length(ins.nm)],nml,'nearest');
    nms = (nm_ii(1):nm_ii(2));
    det = 'VIS';
else
    fac = 2;
    nml = [1000,1600];
    nm_ii = interp1(ins.nm, [1:length(ins.nm)],nml,'nearest');
    nms = (nm_ii(1):nm_ii(2));
    det = 'NIR';
end
down.nm = downsample(ins.nm,fac);
down.spec = downsample(ins.spec,fac,2);
down.sig = down.spec(ins.Shuttered_0==1,:)- (ones([sum(ins.Shuttered_0==1),1])*mean(down.spec(ins.Shuttered_0==0,:)));
down.norm = down.sig ./(ones([sum(ins.Shuttered_0==1),1])*max(down.sig));
down.norm(down.sig<0.2*maxmax) = NaN;
dnm_ii = interp1(down.nm, [1:length(down.nm)],nml,'nearest');
dnms = (dnm_ii(1):dnm_ii(2));
degs = ins.Angle(ins.Shuttered_0==1);
% figure; 
 %%
% figure; plot(ins.nm(nms), ins.sig(:,nms),'-')
% 
% %%
%%
figure; 
% s(1) = subplot(2,1,1);
lines = plot(degs, down.norm(:,dnms)' , '-'); 
%
%
recolor(lines',down.nm(dnms));
colorbar
%%
%%
down.norm_ifft = ifft(down.norm,[],1);
% figure; plot([1:length(degs)],abs(down.norm_ifft(:,50)),'-o');
down.norm_ifft0 = down.norm_ifft; 
down.norm_ifft0(2,:) = 0;
down.norm_ifft0(end,:) = 0;
down.norm_fft0 = fft(down.norm_ifft0,[],1);
figure; lines = plot(degs, real(down.norm_fft0(:,dnms)),'-');
recolor(lines, down.nm(dnms)); colorbar;
ylabel('filtered');
title({[det, ' spectrometer'];tok},'interp','none');
tok = strrep(tok,' ','');
saveas(gcf,[pname, fname,'.',det,tok,'.png']) 

%%

return
