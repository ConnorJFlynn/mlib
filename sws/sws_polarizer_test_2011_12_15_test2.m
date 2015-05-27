function sws_polarizer_test_2011_12_15_test2
% SWS spectral polarization tests, Dec 15 2011 at PNNL.
% Have gone to integrating sphere to eliminate all questions of intrinsic polarization in source.
% This test uses GT polarizer and has the SWS window in place.  This is a repeat test. 
% Need distances and so on.  Sphere is using two lamps @ 2.8 Amps each
% Polarizer rotated 360-deg every 20 degree steps
% Start time: 22:23
% % Deg       Start Time
% 0     22:23
% 20    23:24
% 40    23:25
% 60    23:26
% 80    23:27
%100    23:28
%120    23:29
%140    23:30
%160    00:31
%180    00:32
% 200   00:33  
% 220   00:34
% 240   00:35
% 260   00:36
% 280:  00:37
% 300   00:38
% 320   00:39
% 340   00:40
% 360   00:41


test_dir = 'C:\case_studies\SWS\sws_pol_integ_sphere_at_PNNL\Test_2_GT_with_window\';

sws_files = dir([test_dir,'sgpsws*.dat']);
sws = read_sws_raw([test_dir, sws_files(1).name]);
for s = length(sws_files):-1:2
sws = cat_sws_raw(sws,read_sws_raw([test_dir, sws_files(s).name]));
end
%%
pol.deg = [0:20:360];
pol.time(1) = datenum('2011-12-14 22:23', 'yyyy-mm-dd HH:MM')
for t = 2 : length(pol.deg)
    pol.time(t) = pol.time(t-1) + 1./(24.*60);
end
%%
sws.mean_Si_dark = mean(sws.Si_DN(:,sws.shutter==1),2);
sws.Si_dark_means = zeros(size(sws.time));
sws.Si_dark_means(sws.shutter==1) = mean(sws.Si_DN(:,sws.shutter==1));
sws.Si_dark_means(sws.shutter==1) = sws.Si_dark_means(sws.shutter==1)./mean(sws.Si_dark_means(sws.shutter==1));
sws.Si_dark_means(sws.shutter==0) = interp1(sws.time(sws.shutter==1)-sws.time(1), sws.Si_dark_means(sws.shutter==1),...
    sws.time(sws.shutter==0)-sws.time(1), 'pchip','extrap');

sws.mean_In_dark = mean(sws.In_DN(:,sws.shutter==1),2);
sws.In_dark_means = zeros(size(sws.time));
sws.In_dark_means(sws.shutter==1) = mean(sws.In_DN(:,sws.shutter==1));
sws.In_dark_means(sws.shutter==1) = sws.In_dark_means(sws.shutter==1)./mean(sws.In_dark_means(sws.shutter==1));
sws.In_dark_means(sws.shutter==0) = interp1(sws.time(sws.shutter==1)-sws.time(1), sws.In_dark_means(sws.shutter==1),...
    sws.time(sws.shutter==0)-sws.time(1), 'pchip','extrap');

%%

sws.Si_spec(:,sws.shutter==0) = sws.Si_DN(:,sws.shutter==0) - sws.mean_Si_dark*sws.Si_dark_means(sws.shutter==0);
sws.Si_spec(:,sws.shutter==0) = sws.Si_spec(:,sws.shutter==0) ./ mean(sws.Si_ms(sws.shutter==0));
sws.Si_norm = sws.Si_spec ./ (max(sws.Si_spec,[],2)*ones([1,length(sws.time)]));

sws.In_spec(:,sws.shutter==0) = sws.In_DN(:,sws.shutter==0) - sws.mean_In_dark*sws.In_dark_means(sws.shutter==0);
sws.In_spec(:,sws.shutter==0) = sws.In_spec(:,sws.shutter==0) ./ mean(sws.In_ms(sws.shutter==0));
sws.In_norm = sws.In_spec ./ (max(sws.In_spec,[],2)*ones([1,length(sws.time)]));
% sws.Si_spec(:,sws.shutter==0) = sws.Si_DN(:,sws.shutter==0) - sws.Si_dark*ones([1,sum(sws.shutter==0)]);
% sws.Si_spec(:,sws.shutter==0) = sws.Si_spec(:,sws.shutter==0) ./ mean(sws.Si_ms(sws.shutter==0));
% sws.Si_norm = sws.Si_spec ./ (max(sws.Si_spec,[],2)*ones([1,length(sws.time)]));
% sws.In_spec(:,sws.shutter==0) = sws.In_DN(:,sws.shutter==0) - sws.In_dark*ones([1,sum(sws.shutter==0)]);
% sws.In_spec(:,sws.shutter==0) = sws.In_spec(:,sws.shutter==0) ./ mean(sws.In_ms(sws.shutter==0));
% sws.In_norm = sws.In_spec ./ (max(sws.In_spec,[],2)*ones([1,length(sws.time)]));

%%
for t = 1 : length(pol.deg)
    subt = sws.time> (pol.time(t) + 5./(24.*60.*60)) &  sws.time< (pol.time(t) + 55./(24.*60.*60));
    pol.Si_spec(:,t) = mean(sws.Si_spec(:,subt&sws.shutter==0),2);
    pol.In_spec(:,t) = mean(sws.In_spec(:,subt&sws.shutter==0),2);
end

%%
pol.Si_norm = pol.Si_spec ./(mean(pol.Si_spec,2)*ones(size(pol.deg)));
pol.In_norm = pol.In_spec ./(mean(pol.In_spec,2)*ones(size(pol.deg)));
%%
figure; lines = plot(pol.deg, pol.Si_norm(50:10:250,:), '-'); recolor(lines,sws.Si_lambda(50:10:250));colorbar;
xlabel('polarizer rotation (degrees)');
ylabel('relative signal');
title('Si Array relative polarization response')
saveas(gcf,[test_dir,'Si_pol_test.png']);
%%

figure; lines = plot(pol.deg, pol.In_norm(1:10:230,:), '-');
recolor(lines,sws.In_lambda(1:10:230));colorbar;
xlabel('polarizer rotation (degrees)');
ylabel('relative signal');
title('InGaAs Array relative polarization response')
saveas(gcf,[test_dir,'InGaAs_pol_test.png']);
%%
pol.Si_ifft = ifft(pol.Si_norm,[],2);
figure; plot([1:length(pol.deg)],abs(pol.Si_ifft(50,:)),'-o');
pol.Si_ifft0 = pol.Si_ifft; pol.Si_ifft0(:,2) = 0;pol.Si_ifft0(:,end) = 0;
pol.Si_fft0 = fft(pol.Si_ifft0,[],2);
figure; lines = plot(pol.deg, real(pol.Si_fft0(40:5:220,:)),'-');
recolor(lines, sws.Si_lambda(40:5:220)); colorbar;
ylabel('filtered');
%%
pol.In_ifft = ifft(pol.In_norm,[],2);
figure; plot([1:length(pol.deg)],abs(pol.In_ifft(50,:)),'-o');
pol.In_ifft0 = pol.In_ifft; pol.In_ifft0(:,2) = 0;pol.In_ifft0(:,end) = 0;
pol.In_fft0 = fft(pol.In_ifft0,[],2);
figure; lines = plot(pol.deg, real(pol.In_fft0(10:10:160,:)),'-');
recolor(lines, sws.In_lambda(10:10:160)); colorbar;
ylabel('filtered');
%%
sws.Si_darks = sws.Si_DN(:,sws.shutter==1);
sws.In_darks = sws.In_DN(:,sws.shutter==1);

sws.Si_dark = mean(sws.Si_darks,2);
sws.In_dark = mean(sws.In_darks,2);
%%
