function vc = plot_points(vc);
%vc = plot_points(vc);
% vertical scale adjusted for assumed 45 degree tilt.
if ~exist('vc','var')
    uiload
end
%%
pname = 'C:\case_studies\tnmpl\vceil\';
fname = ['PBL_visual.',datestr(vc.time(1),'yyyymmdd')];
while exist([pname,fname,'.txt'],'file')
    fname = [fname, '_'];
end
figname = ['PBL_visual.',datestr(vc.time(1),'yyyymmdd')];
while exist([pname,figname,'.fig'],'file')
    figname = [figname, '_'];
end
vc.time = vc.time - 5/24;
r_max = find(vc.range>=3,1,'first');
%pbl = pbl_filter(sin(45*pi/180)*vc.range(1:r_max), vc.bscat(1:r_max,:),[4:6]);
mask = vc.bscat <= 0;
for r = (length(vc.range)-2):-1:3
for t = (length(vc.time)-2) : -1:3
mask(r,t) = any(any(vc.bscat((r-1):(r+1),(t-1):(t+1))<=0));
end; end

done=0;

while ~done
H = figure;
imagesc(serial2doy(vc.time), sin(45*pi/180)*vc.range, real((vc.bscat.*~mask))); 
axis('xy'); colormap('jet'); colorbar
v = axis; axis([(v(1)), (v(2)),0,2]);colormap('jet');caxis([0,15]);colorbar
title(['Ceilometer profiles and visual PBL estimate: ',datestr(vc.time(1), 'yyyy-mm-dd')]);
ylabel('height AGL (km)');
xlabel('time (LST)')
% hold('on'); plot(serial2Hh(vc.time(1:3:end)), pbl(1:3:end), 'r.');
[pnts.x, pnts.y] = ginput;
hold('on'); plot(pnts.x, pnts.y, 'w.',pnts.x, pnts.y, 'ko','MarkerSize',15);
plot(pnts.x,smooth(pnts.x,pnts.y,.1,'lowess'),'k')
K = menu('Okay?','Yes, done.','No, repeat.');
close(H);
if K==1
    done=1;
else
    
end
end
H = figure;
imagesc(serial2Hh(vc.time), sin(45*pi/180)*vc.range, real(log10(vc.bscat))); 
axis('xy'); colormap('jet'); colorbar
v = axis; axis([round(v(1)), round(v(2)),0,2]);colormap('jet');caxis([0,3]);
title(['Ceilometer profiles and visual PBL estimate: ',datestr(vc.time(1), 'yyyy-mm-dd')]);
ylabel('height AGL (km)');
xlabel('time (LST)')
% hold('on'); plot(serial2Hh(vc.time(1:3:end)), pbl(1:3:end), 'r.');
hold('on'); plot(pnts.x,smooth(pnts.x,pnts.y,.2,'lowess'),'wo',pnts.x,smooth(pnts.x,pnts.y,.2,'lowess'),'w')
legend('wavelet filter', 'visual trace')
disp('Adjust figure as desired then hit any key.')
pause
saveas(gcf, [pname, figname, '.fig'], 'fig');
print(gcf,'-dpng',[pname, figname,'.png'])
%%

V = datevec(vc.time -5/24);
% [pname,fname] = !!;
yyyy = V(1:length(pnts.x),1);
mm = V(1:length(pnts.x),2);
dd = V(1:length(pnts.x),3);
HHhh = pnts.x;
pbl = pnts.y;
%%
txt_out = [yyyy, mm, dd, HHhh, pbl];
header_row = ['yyyy, mm, dd, HH_LST, PBL_km'];
format_str = ['%d, %d, %d, %4.4g, %4.4g \n'];
%%
fid = fopen([pname, fname, '.txt'],'wt');
fprintf(fid,'%s \n',header_row );
fprintf(fid,format_str,txt_out');
fclose(fid);