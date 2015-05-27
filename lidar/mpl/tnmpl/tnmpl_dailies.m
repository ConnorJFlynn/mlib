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
all_zens = [0.0 45.0000 70.0000 75.0000 79.0000 82.0000 84.0000 85.0000 86.0000 87.0000 87.5000 88.0000 88.3400 88.6700 89.0000 89.3400 89.6700 90.0000 90.3300 90.6600 91.0000 91.3300];
all_zens = [89.0000 89.3400 89.6700 90.0000 90.3300 90.6600];
all_zens = fliplr(all_zens);
for daynum = [datenum('2006_09_01','yyyy_mm_dd'):datenum('2006_09_03','yyyy_mm_dd')]
    day = ['tnmplzen.',datestr(daynum,'yyyy_mm_dd'),'*.mat'];
    day_file = ['tnmplzen.',datestr(daynum,'yyyy_mm_dd'),'.dat.mat'];
    clear mplz_day;
    if exist([base,'processed\day_mat\',day_file],'file')
        load([base,'processed\day_mat\',day_file]);
    else
        mat_dir = dir([base,'four\',day]);
        for m = length(mat_dir):-1:1
            mplz = loadinto([base,'four\', mat_dir(m).name]);
            %    figure; subplot(2,1,1); semilogy(mplz.range, mean(mplz.prof(:,mplz.hk.zenith==90.66)')'./(mplz.range.^2),'r');
            %    title(['Mean horiz profile for ',datestr(mplz.time(1),'yyyy-mm-dd HH:00')]);
            %    v1 = [ 0   20    0.0007    6.1832];    axis(v1);
            %    subplot(2,1,2); semilogy(mplz.range, mean(mplz.prof(:,mplz.hk.zenith==90.66)')','g');
            %    v2 = [0,20,0.0858 ,4.3164]; axis(v2)
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
    day_dir = [datestr(mplz_day.time(1),'yyyy_mm_dd')];
    if ~exist([image_base,day_dir],'dir')
        mkdir(image_base,day_dir);
    end
    ol_mat = ol_corr(:,2)*ones(size(mplz_day.time));
    A = real(log10(ol_mat(mplz_day.r.lte_10,:).*mplz_day.prof(mplz_day.r.lte_10,:)));
    
%% Remove when done with Jochen slices
A = A(2:end,:);
range = mplz_day.range(mplz_day.r.lte_10(2:end));
%%

    for zen = all_zens
       jochen_slices_agu
        if length(zen) == 1
            zen_dir = ['zen_',num2str(zen)];
        else
            zen_dir = ['zen_',num2str(zen(1)),'_',num2str(zen(2))];
        end
        if ~exist([image_base,zen_dir],'dir')
            mkdir(image_base, zen_dir);
            mkdir([image_base,zen_dir], 'images');
        end
        %%
        % ol_mat = ol_corr(:,2)*ones(size(mplz.time));
        % figure; imagesc(serial2Hh(mplz.time(~isnan(mplz.hk.zenith))), mplz.range(mplz.r.lte_15), ol_mat(mplz.r.lte_10,~isnan(mplz.hk.zenith)).*mplz.prof(mplz.r.lte_10,(~isnan(mplz.hk.zenith)))); colormap('jet'); colorbar
        % caxis([0,10]);colorbar
%         ol_mat = ol_corr(:,2)*ones(size(mplz_day.time));
        % fig = figure;
        % Adjusting for zenith angle offset
        % Essentially, we're ignoring the offset for zenith and 45 since it is
        % insignificant
        %         zen = zen + (zen>50)*.6;
        if length(zen)==1
            zz = logical(abs(mplz_day.hk.zenith-zen)<=.1);
        else
%            zz = logical(((mplz_day.hk.zenith-zen(1))>=.1)&(mplz_day.hk.zenith-zen(2)<=.1));
           zz = logical((mplz_day.hk.zenith>=(.1+min(zen)))&(mplz_day.hk.zenith<=(.1+max(zen))));
           zen = mean(zen);
        end
        %         zen = zen - (zen>50)*.6;

        %     zz = logical(abs(mplz_day.hk.zenith-89.6)<=.2);
        %     disp('Currently selecting horizontal profiles')
        t =(mplz_day.time(zz));
%         A = real(log10(ol_mat(mplz_day.r.lte_10,zz).*mplz_day.prof(mplz_day.r.lte_10,(zz))));
        [B,t_grid] = fill_img(A(:,zz), t);
        fig = figure;
        set(fig,'visible','off');
        imagesc(serial2Hh(t_grid), mplz_day.range(mplz_day.r.lte_10), B);
        %     imagesc(serial2Hh(t), mplz_day.range(mplz_day.r.lte_10), A);
        axis('xy');
        colormap('jet');
        caxis([-.25 1.5]); % use for log10 scale
        %caxis([0 12]);% use for linear scale
        xlabel('time (hour LST)')
        ylabel('range from lidar (km)')
        title(['lidar profile, zenith angle=',num2str(zen),datestr(t_grid(1),': mmm dd yyyy')]);
        %     figname = ['tnmplzen.',datestr(daynum,'yyyy_mm_dd'),'.fig'];
        %     saveas(fig,[base,'..\figures\',figname]);
        pngname = ['tnmplzen_',num2str(zen),'.',datestr(daynum,'yyyy_mm_dd'),'.png'];
        while exist([image_base,day_dir,'\',pngname],'file')
            pngname = ['_',pngname];
        end
        print(fig, [image_base,day_dir,'\',pngname],'-dpng');
        print(fig, [image_base,zen_dir,'\',pngname],'-dpng')
% 
%         while exist([image_base,zen_dir,'\images\',pngname],'file')
%             pngname = ['_',pngname];
%         end
%         print(fig, [image_base,zen_dir,'\images\',pngname],'-dpng');
        %     close(fig)
        %     cza = cos(mplz_day.hk.zenith(zz)*pi/180);
        %     if length(cza)>1
        %         cza = mean(cza);
        %     end
        %     y = cza * mplz_day.range(mplz_day.r.lte_10);
        %     plot_points(t_grid,y,B);

        %Step through, plot, all profiles within a vertical sequence.

        %
        %         pause(.5);
        close('all');
        %         pause(.1);
    end
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
pname = 'C:\case_studies\tnmpl\mpl\pbl\';
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
    caxis([0,12]); colorbar
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
caxis([0,12]); colorbar
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
