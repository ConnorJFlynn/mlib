pause(.1)
close('all')
pause(.1)
clear
pause(.1)
[ncid, fname, pname] = get_ncid;
mpl.time = nc_time(ncid);
[date_str, dump] = strtok(datestr(mpl.time(1), 30),'T')
mpl.range = nc_getvar(ncid, 'range');
mpl.height = nc_getvar(ncid, 'height');
mpl.fixed_angles = nc_getvar(ncid, 'fixed_angles');
mpl.ocr_nsamples = nc_getvar(ncid, 'ocr_nsamples');
mpl.ocr_bg = nc_getvar(ncid, 'ocr_bg');
mpl.ocr_bg_std = nc_getvar(ncid, 'ocr_bg_std');
mpl.ocr_bg_noise = nc_getvar(ncid, 'ocr_bg_noise');
mpl.ocr = nc_getvar(ncid, 'ocr');
mpl.ocr_noise = nc_getvar(ncid, 'ocr_noise');
mpl.ocr_snr = nc_getvar(ncid, 'ocr_snr');
mpl.angle = nc_getvar(ncid, 'zenith_angle');
mpl.em = nc_getvar(ncid, 'energy_monitor');
%mpl.height_prof = nc_getvar(ncid, 'height_prof')
mpl.duration = nc_getvar(ncid, 'scene_duration');

ncmex('close',ncid);
ocr_fig = figure; imagesc(serial2doy0(mpl.time), mpl.range, mpl.ocr); axis('xy'); colormap('jet'); v = axis; axis([v(1), v(2), 0, 10, 0, 1.5, 0, 1.5])
title(['Slant-path range-corrected profiles: ', datestr(mpl.time(1),1)]);
xlabel('fractional day of year');
ylabel('range (km)');
disp('Adjust ocr_fig and continue...')

print(ocr_fig, '-dmeta', [pname, 'ipampl.',date_str, '.slant_paths.emf'])

%figure; imagesc(serial2doy0(mpl.time), mpl.height, mpl.height_prof); axis('xy'); axis([v(1),v(2),0,15,0,1,0,1]); colormap('jet')
%r.lte_40 = find(mpl.range<=40);
for p = [length(mpl.angle):-1:1]
    disp(['Processing record #', num2str(1+length(mpl.angle)-p), ' of ', num2str(length(mpl.angle))])
    height = mpl.range * cos(pi*mpl.angle(p)/180);
    %interpolate this height-profile to the finest height resolution
    mpl.vert_snr(:,p) = interp1(height, mpl.ocr_snr(:,p), mpl.height,'linear');
    vert_prof = interp1(height, mpl.ocr(:,p), mpl.height,'linear');
%     mpl.vert_prof(:,p) = vert_prof;
%     mpl.vert_prof_5(:,p) = smooth(height, vert_prof,5, 'lowess');
    mpl.vert_prof_20(:,p) = smooth(height, vert_prof,20, 'lowess');
%     mpl.vert_prof_50(:,p) = smooth(height, vert_prof,50, 'lowess');
%     mpl.vert_prof_100(:,p) = smooth(height, vert_prof,100, 'lowess');
end
% figure; imagesc(serial2doy0(mpl.time), mpl.height, mpl.vert_prof); axis('xy'); v = axis; axis([v(1),v(2),0,10,0,1,0,1]); colormap('jet')
% title('vert\_prof');
%  figure; imagesc(serial2doy0(mpl.time), mpl.height, mpl.vert_prof_5); axis('xy'); v = axis; axis([v(1),v(2),0,10,0,1,0,1]); colormap('jet')
%  title('vert\_prof\_5');

vert_20_fig=figure; imagesc(serial2doy0(mpl.time), mpl.height, mpl.vert_prof_20); axis('xy'); v = axis; axis([v(1),v(2),0,10,0,1,0,1]); colormap('jet')
title(['Vertical projection of range-corrected profiles: ', datestr(mpl.time(1),1)]);
xlabel('fractional day of year');
ylabel('height (AGL)');
disp('Adjust vert_20_fig and continue...')

print(vert_20_fig, '-dmeta', [pname, 'ipampl.',date_str, '.vert_prof.emf'])
% figure; imagesc(serial2doy0(mpl.time), mpl.height, mpl.vert_prof_50); axis('xy'); axis([v(1),v(2),0,10,0,1,0,1]); colormap('jet')
% title('vert\_prof\_50');
% figure; imagesc(serial2doy0(mpl.time), mpl.height, mpl.vert_prof_100); axis('xy'); axis([v(1),v(2),0,10,0,1,0,1]); colormap('jet')
% title('vert\_prof\_100');
v=axis;
vert_snr_fig=figure; imagesc(serial2doy0(mpl.time), mpl.height, real(log10(mpl.vert_snr))); axis('xy'); axis([v,-1, 2, -1, 2]), colormap('jet'); colorbar; 
title(['log(SNR) of vertical profiles: ', datestr(mpl.time(1),1)]);
xlabel('fractional day of year');
ylabel('height (AGL)');
disp('Adjust vert_snr_fig and continue...')

print(vert_snr_fig, '-dmeta', [pname, 'ipampl.',date_str, '.vert_snr.emf'])

mpl.secant = 1./cos(pi*mpl.angle/180);
%figure; plot(serial2doy0(mpl.time), [mpl.secant; 1+mpl.angle/90])
pos_angles = find(mpl.angle >0);
neg_angles = find(mpl.angle <0);
% top = mpl.time(400);
% bot = mpl.time(300);
%crossing = find((mpl.angle > 5) & (mpl.angle < 15));
figure(vert_20_fig); v=axis; axis([v,0,1.5,0,1.5]); zoom; 
disp(['Zoom into desired range region and hit enter when ready.'])
pause
v = axis; axis([v,0,2,0,2]);v = axis;
% sub_time = find((serial2doy0(mpl.time)>=v(1))&(serial2doy0(mpl.time)<=v(2)));
% sub_height = find((mpl.height>floor(v(3)))&(mpl.height<=ceil(v(4))));
%figure; imagesc(serial2doy0(mpl.time(sub_time)), mpl.height(sub_height), mpl.height_prof(sub_height,sub_time)); axis('xy');colormap('jet'); axis([v,0,2,0,2])

%mpl.sub_crossing = find((mpl.angle(sub_time) > 5) & (mpl.angle(sub_time) < 15));
%Note that this is a sub-list of sub_time.  
% To get actual times: mpl.time(sub_time(mpl.sub_crossing(i)))
mpl.marks = find((mpl.angle>75)|(mpl.angle<-75)|((mpl.angle<-9)&(mpl.angle>-11)));
mpl.tau_20 = NaN([length(mpl.height), length(mpl.marks)-1]);
mpl.crossing_time = NaN(size(mpl.marks(1:end-1)));
for i = length(mpl.marks):-1:2
    crs_times = [mpl.marks(i-1):mpl.marks(i)];
    mpl.crossing_time(i-1) = mean(mpl.time(crs_times));
end    
top_height = min(find(mpl.height>=v(4)));
bot_height = max(find(mpl.height<=.2));
%check the mark times to make sure they fall within the zoom window
first_mark = min(find(serial2doy0(mpl.time(mpl.marks))>=v(1)));
if isempty(first_mark)
    first_mark=2;
end
if first_mark==1
    first_mark=2;
end
last_mark = max(find(serial2doy0(mpl.time(mpl.marks))<=v(2)));
if isempty(last_mark)
    last_mark=length(mpl.marks);
end
%new_marks = mpl.marks(first_mark:last_mark); 
for i = last_mark:-1:first_mark
    disp(['Mark ',num2str(last_mark-i+1),' of ', num2str(last_mark-first_mark)]);
    %Find points in i'th sub_crossing interval
     crs_times = [mpl.marks(i-1):mpl.marks(i)];
%     mpl.crossing_time(i-1) = mean(mpl.time(crs_times));
    
    for b = top_height:-1:bot_height;
%         [p,s] = polyfit(2*mpl.secant(crs_times), real(log(mpl.vert_prof(b,crs_times))),1);
%         tau(b,i-1) = -p(1);
%          [p,s] = polyfit(2*mpl.secant(crs_times), real(log(mpl.vert_prof_5(b,crs_times))),1);
%          tau_5(b,i-1) = -p(1);

        [p,s] = polyfit(2*mpl.secant(crs_times), real(log(mpl.vert_prof_20(b,crs_times))),1);
        mpl.tau_20(b,i-1) = -p(1);
%         [p,s] = polyfit(2*mpl.secant(crs_times), real(log(mpl.vert_prof_50(b,crs_times))),1);
%         tau_50(b,i-1) = -p(1);
%         [p,s] = polyfit(2*mpl.secant(crs_times), real(log(mpl.vert_prof_100(b,crs_times))),1);
%         tau_100(b,i-1) = -p(1);
    end
end
%disp(['Mark ',num2str(length(mpl.marks)-i+1),' of ', num2str(length(mpl.marks))]);

% subplot('position', [.05, .3, .9, .65]); 
% figure; imagesc(serial2doy0(crossing_time), mpl.height, tau); axis('xy');colormap('jet'); axis([v,0,.5,0,.5]);
% title('tau')
%  figure; imagesc(serial2doy0(crossing_time), mpl.height, tau_5); axis('xy');colormap('jet'); axis([v,0,.5,0,.5]);colorbar
%  title('tau 5')

tau_20_fig = figure; imagesc(serial2doy0(mpl.crossing_time), mpl.height, mpl.tau_20); axis('xy');colormap('jet'); axis([v,0,.5,0,.5]);colorbar
title(['Total optical depth integrated from ground: ', datestr(mpl.time(1),1)]);
xlabel('fractional day of year');
ylabel('height (AGL)');
disp('Adjust tau_fig and continue...')

print(tau_20_fig, '-dmeta', [pname, 'ipampl.',date_str, '.tod.emf'])

% figure; imagesc(serial2doy0(crossing_time), mpl.height, tau_50); axis('xy');colormap('jet'); axis([v,0,.5,0,.5]);
% title('tau 50')
% figure; imagesc(serial2doy0(crossing_time), mpl.height, tau_100); axis('xy');colormap('jet'); axis([v,0,.5,0,.5]);
% title('tau 100')

disp('done')

% subplot('position', [.05, .05, .9, .15]);; plot(serial2doy0(mpl.time), mpl.angle);
% axis([v(1), v(2), -90, 90]);
