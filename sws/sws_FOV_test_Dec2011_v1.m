% SWS spectral FOV tests, Dec 2011 at PNNL.
% One continuous run sequence, steps in 1/2 degree from -5 to 5.
% 

test_dir = 'C:\case_studies\SWS\sws_FOV_test_Dec2011\';

sws_files = dir([test_dir,'sgpsws*.dat']);
sws = read_sws_raw([test_dir, sws_files(1).name]);
for s = length(sws_files):-1:2
sws = cat_sws_raw(sws,read_sws_raw([test_dir, sws_files(s).name]));
end
%%
ts = 1:length(sws.shutter);
figure; semilogy(ts(sws.shutter~=1), sws.Si_spec(120,sws.shutter~=1)./max(sws.Si_spec(120,sws.shutter~=1)),'o')

%%

sws.Si_darks = sws.Si_DN(:,sws.shutter==1);
sws.In_darks = sws.In_DN(:,sws.shutter==1);

sws.Si_dark = mean(sws.Si_darks,2);
sws.In_dark = mean(sws.In_darks,2);
sws.In_dark_mean_over_T = mean(sws.In_darks);
sws.In_dark_mean_over_T =sws.In_dark_mean_over_T./mean(sws.In_dark_mean_over_T);
sws.In_mean_dark_over_t = interp1(sws.time(sws.shutter==1),sws.In_dark_mean_over_T,sws.time, 'pchip','extrap');
%%
figure; lines = plot(sws.In_lambda, sws.In_darks - sws.In_dark*sws.In_dark_mean_over_T, '-');
lines = recolor(lines, serial2doy(sws.time(sws.shutter==1)));
%%
figure; lines = plot(sws.In_lambda, sws.In_darks - sws.In_dark*ones([1,sum(sws.shutter==1)]), '-');
lines = recolor(lines, serial2doy(sws.time(sws.shutter==1)));
%%
sws.Si_spec(:,sws.shutter==0) = sws.Si_DN(:,sws.shutter==0) - sws.Si_dark*ones([1,sum(sws.shutter==0)]);
sws.Si_spec(:,sws.shutter==0) = sws.Si_spec(:,sws.shutter==0) ./ mean(sws.Si_ms(sws.shutter==0));
sws.Si_norm = sws.Si_spec ./ (max(sws.Si_spec,[],2)*ones([1,length(sws.time)]));
sws.In_spec(:,sws.shutter==0) = sws.In_DN(:,sws.shutter==0) - sws.In_dark*sws.In_mean_dark_over_t(sws.shutter==0);
sws.In_spec(:,sws.shutter==0) = sws.In_spec(:,sws.shutter==0) ./ mean(sws.In_ms(sws.shutter==0));
sws.In_norm = sws.In_spec ./ (max(sws.In_spec,[],2)*ones([1,length(sws.time)]));

%%
figure; lines = semilogy(ts(sws.shutter==0), sws.In_norm(50:5:200,sws.shutter==0),'-');
recolor(lines,[sws.In_lambda(50:5:200)]);colorbar
%%

fov.deg = [-5:.5:5];
%%
fov.time(1) = datenum('2011-12-06 20:26', 'yyyy-mm-dd HH:MM');
fov.time(2) = datenum('2011-12-06 20:29', 'yyyy-mm-dd HH:MM');
fov.time(3) = datenum('2011-12-06 20:31', 'yyyy-mm-dd HH:MM');
fov.time(4) = datenum('2011-12-06 20:32', 'yyyy-mm-dd HH:MM');
fov.time(5) = datenum('2011-12-06 20:33', 'yyyy-mm-dd HH:MM');
fov.time(6) = datenum('2011-12-06 20:34', 'yyyy-mm-dd HH:MM');
fov.time(7) = datenum('2011-12-06 20:35', 'yyyy-mm-dd HH:MM');
fov.time(8) = datenum('2011-12-06 20:36', 'yyyy-mm-dd HH:MM');
fov.time(9) = datenum('2011-12-06 20:37', 'yyyy-mm-dd HH:MM');
fov.time(10) = datenum('2011-12-06 20:38', 'yyyy-mm-dd HH:MM');
fov.time(11) = datenum('2011-12-06 20:39', 'yyyy-mm-dd HH:MM');
fov.time(12) = datenum('2011-12-06 20:40', 'yyyy-mm-dd HH:MM');
fov.time(13) = datenum('2011-12-06 20:41', 'yyyy-mm-dd HH:MM');
fov.time(14) = datenum('2011-12-06 20:42', 'yyyy-mm-dd HH:MM');
fov.time(15) = datenum('2011-12-06 20:43', 'yyyy-mm-dd HH:MM');
fov.time(16) = datenum('2011-12-06 20:44', 'yyyy-mm-dd HH:MM');
fov.time(17) = datenum('2011-12-06 20:45', 'yyyy-mm-dd HH:MM');
fov.time(18) = datenum('2011-12-06 20:46', 'yyyy-mm-dd HH:MM');
fov.time(19) = datenum('2011-12-06 20:47', 'yyyy-mm-dd HH:MM');
fov.time(20) = datenum('2011-12-06 20:48', 'yyyy-mm-dd HH:MM');
fov.time(21) = datenum('2011-12-06 20:49', 'yyyy-mm-dd HH:MM');

%%

for t = 1 : length(fov.deg)
    subt = sws.time> (fov.time(t) + 5./(24.*60.*60)) &  sws.time< (fov.time(t) + 55./(24.*60.*60));
    fov.Si_spec(:,t) = mean(sws.Si_spec(:,subt&sws.shutter==0),2);
    fov.In_spec(:,t) = mean(sws.In_spec(:,subt&sws.shutter==0),2);
end
fov.In_spec(:,21) = 0;
fov.Si_norm = fov.Si_spec ./ (max(fov.Si_spec,[],2)*ones([1,21]));
fov.In_norm = fov.In_spec ./ (max(fov.In_spec,[],2)*ones([1,21]));
%%
figure; lines = plot(fov.deg, fov.Si_norm(20:20:220,:),'-');
recolor(lines,sws.Si_lambda(20:20:220)); colorbar
grid('on');
title('SWS FOV test at PNNL, Si CCD')
xlabel('degrees off-axis');
ylabel('normalized signal');
%%
saveas(gcf, [test_dir, 'SWS_Si_FOV_at_PNNL.logy.png']);
%%

figure; lines = plot(fov.deg, fov.In_norm(40:20:220,:),'-');
recolor(lines,sws.In_lambda(40:20:220)); colorbar
grid('on');
title('SWS FOV test at PNNL, InGaAs')
xlabel('degrees off-axis');
ylabel('normalized signal');
%%
saveas(gcf, [test_dir, 'SWS_InGaAs_FOV_at_PNNL.logy.png']);

%%
