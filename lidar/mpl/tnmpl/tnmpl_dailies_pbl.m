function tnmpl_dailies
% figure; semilogy(mplz.range, mean(mplz.prof(:,mplz.hk.zenith==91)')','g.',mplz.range, mean(mplz.prof(:,mplz.hk.zenith==91)')'.*ol_corr(:,2))
% ol_corr = [mplz.range, real(10.^(polyval(P,mplz.range))./(10.^(logprof)))];
% save('C:\case_studies\tnmpl\mpl\cals\ol_corr_raw.mat', 'ol_corr', '-mat')
% !!
%%
ol_corr = loadinto('C:\case_studies\tnmpl\mpl\cals\ol_corr_raw.mat');
ol_corr(ol_corr(:,1)>7,2)==1;

base = 'C:\case_studies\tnmpl\mpl\';
image_base = 'C:\case_studies\tnmpl\mpl\processed\';
zen = [0];
if length(zen) == 1
    zen_dir = ['zen_',num2str(zen)];
else
    zen_dir = ['zen_',num2str(zen(1)),'_',num2str(zen(2))];
end
if ~exist([image_base,zen_dir],'dir')
    mkdir(image_base, zen_dir);
    mkdir([image_base,zen_dir], 'images');
end 


for daynum = [datenum('2006_09_12','yyyy_mm_dd') datenum('2006_09_24','yyyy_mm_dd')]
    day = ['tnmplzen.',datestr(daynum,'yyyy_mm_dd'),'*.mat'];
    day_file = ['tnmplzen.',datestr(daynum,'yyyy_mm_dd'),'.dat.mat'];
    clear mplz_day;
    if exist([base,'processed\day_mat\',day_file],'file')
        load([base,'processed\day_mat\',day_file]);
    else
        mat_dir = dir([base,'four\',day]);
        for m = length(mat_dir):-1:1
            mplz = loadinto([base,'four\', mat_dir(m).name]);
            if ~exist('mplz_day','var')
                mplz_day = mplz;
            else
                mplz_day = tnmpl_tcat(mplz_day,mplz);
            end
        end
        clear mplz;
        mplz_day = remove_nans(mplz_day);
        save([base,'processed\day_mat\tnmplzen.',datestr(mplz_day.time(1),'yyyy_mm_dd'),'.dat.mat'],'mplz_day');
    end

    ol_mat = ol_corr(:,2)*ones(size(mplz_day.time));
    % fig = figure;
    % Adjusting for zenith angle offset
    % Essentially, we're ignoring the offset for zenith and 45 since it is
    % insignificant
    zen = zen + (zen>50)*.6;
    if length(zen)==1
        zz = logical(abs(mplz_day.hk.zenith-zen)<=.1);
    else
        zz = logical(((mplz_day.hk.zenith-zen(1))>=.1)&(mplz_day.hk.zenith-zen(2)<=.1));
        zen = mean(zen);
    end
    zen = zen - (zen>50)*.6;
    
%     zz = logical(abs(mplz_day.hk.zenith-89.6)<=.2);
%     disp('Currently selecting horizontal profiles')
    t =(mplz_day.time(zz));
    A = real(log10(ol_mat(mplz_day.r.lte_10,zz).*mplz_day.prof(mplz_day.r.lte_10,(zz))));
    [B,t_grid] = fill_img(A, t);
    cza = cos(mplz_day.hk.zenith(zz)*pi/180);
    if length(cza)>1
        cza = mean(cza);
    end
    y = cza * mplz_day.range(mplz_day.r.lte_10);
    plot_points(t_grid,y,B);
    clear mplz_day
    pause(.5);
    close('all');
    pause(.1);
end

% colormap('nasa'); colorbar
% corr_prof = ol_mat.*mplz_day.prof;
% mplz_day = apply_ap_to_mpl(mplz_day, ap_mpl105_20060808(mpl.range));
% mplz_day.rawcts = mplz_day.prof ./ ((mplz_day.range .^2)*ones(size(mplz_day.time)));
%
% mplz_day = apply_ol_to_mpl(mplz_day, ol_mpl105_20060808(mplz_day.range));
% figure; imagesc(serial2Hh(mplz_day.time((mplz_day.hk.zenith==0))), mplz_day.range(mplz_day.r.lte_10), real(log10(corr_prof(mplz_day.r.lte_10,(mplz_day.hk.zenith==0))))); colormap('jet'); caxis([-1 2]);colorbar
% exit

% 18 stories = ~180 feet or 60 meters
% 4120 = adjacent
% 60 = opposite
% ==> angle = 0.83 degrees = 90.83
% We record 91.33, so zenith = hk.zenith - .5;
function plot_points(x,y,z,this);
%vc = plot_points(vc);
%%
pname = 'C:\case_studies\tnmpl\mpl\processed\pbl\';
fname = ['PBL_visual.',datestr(x(1),'yyyymmdd')];
while exist([pname,'txt\',fname,'.txt'],'file')
    fname = [fname, '_'];
end
figname = ['PBL_visual.',datestr(x(1),'yyyymmdd')];
while exist([pname,'images\',figname,'.png'],'file')
    figname = [figname, '_'];
    
end
done=0;

while ~done
    H = figure;

    imagesc(serial2Hh(x), y, z);
    axis('xy'); colormap('jet'); colorbar
    v = axis; axis([round(v(1)), round(v(2)),0,5]);colormap('jet');
%    caxis([0,12]); colorbar;
    caxis([-.5,1.5]); colorbar
    title(['MPL profiles and visual PBL estimate: ',datestr(x(1), 'yyyy-mm-dd')]);
    ylabel('height AGL (km)');
    xlabel('time (LST)')
    % hold('on'); plot(serial2Hh(mplz_day.time(1:3:end)), pbl(1:3:end), 'r.');
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
imagesc(serial2Hh(x), y, z);
axis('xy'); colormap('jet'); colorbar
v = axis; axis([round(v(1)), round(v(2)),0,5]);colormap('jet');
%caxis([0,12]); colorbar
caxis([-.5,1.5]); colorbar
title(['MPL profiles and visual PBL estimate: ',datestr(x(1), 'yyyy-mm-dd')]);
ylabel('height AGL (km)');
xlabel('time (LST)')
% hold('on'); plot(serial2Hh(mplz_day.time(1:3:end)), pbl(1:3:end), 'r.');
hold('on'); plot(pnts.x,smooth(pnts.x,pnts.y,.2,'lowess'),'ko',pnts.x,smooth(pnts.x,pnts.y,.2,'lowess'),'w')
legend('PBL (visually estimated)')
disp('Adjust figure as desired then hit any key.')
pause
% saveas(gcf, [pname, figname, '.fig'], 'fig');
print(gcf,'-dpng',[pname,'images\', figname,'.png'])
%%

V = datevec(x);
% [pname,fname] = !!;
yyyy = ones(size(pnts.x))*V(1,1);
mm = ones(size(pnts.x))*V(1,2);
dd = ones(size(pnts.x))*V(1,3);
HHhh = pnts.x;
pbl = pnts.y;
%%
txt_out = [yyyy, mm, dd, HHhh, pbl];
header_row = ['yyyy, mm, dd, HH_LST, PBL_km'];
format_str = ['%d, %d, %d, %4.4g, %4.4g \n'];
%%
fid = fopen([pname, 'txt\',fname, '.txt'],'wt');
fprintf(fid,'%s \n',header_row );
fprintf(fid,format_str,txt_out');
fclose(fid);

return
function  mpl = remove_nans(mpl)
inds = find(~isnan(mpl.hk.zenith));
mpl.time = mpl.time(inds);
mpl.prof = mpl.prof(:,inds);
mpl.noise_MHz = mpl.noise_MHz(:,inds);

fields = fieldnames(mpl.hk);
for f = 1:length(fields)
    mpl.hk.(char(fields(f))) = mpl.hk.(char(fields(f)))(inds);
end

return
