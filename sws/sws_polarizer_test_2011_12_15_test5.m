% SWS spectral polarization tests, Dec 15 2011 at PNNL.
% Have gone to integrating sphere to eliminate all questions of intrinsic polarization in source.
% This test uses a dichroic polarizer (no wobble effects) and has the 4STAR window removed. 
% Need distances and so on.  Sphere is using two lamps @ 2.8 Amps each
% Polarizer rotated 360-deg every 20 degree steps
% Start time: 23:52
% % Deg       Start Time
% 0     23:52
% 20    23:53
% 40    23:54
% 60    23:55
% 80    23:56
%100    23:57
%120    23:58
%140    23:59
%160    00:00
%180    00:01
% 200   00:02  
% 220   00:03
% 240   00:04
% 260   00:05
% 280:  00:06
% 300   00:07
% 320   00:08
% 340   00:09
% 360   00:10


test_dir = 'C:\case_studies\SWS\sws_pol_integ_sphere_at_PNNL\Test_5_dichroic_with_window\';

sws_files = dir([test_dir,'sgpsws*.dat']);
sws = read_sws_raw([test_dir, sws_files(1).name]);
for s = length(sws_files):-1:2
sws = cat_sws_raw(sws,read_sws_raw([test_dir, sws_files(s).name]));
end
%%
pol.deg = [0:20:360];
pol.time(1) = datenum('2011-12-14 23:52', 'yyyy-mm-dd HH:MM')
for t = 2 : length(pol.deg)
    pol.time(t) = pol.time(t-1) + 1./(24.*60);
end
%%
for t = 2 : length(pol.deg)
    pol.time(t) = pol.time(t-1) + 1./(24.*60);
end


%%
sws.Si_spec(:,sws.shutter==0) = sws.Si_DN(:,sws.shutter==0) - sws.Si_dark*ones([1,sum(sws.shutter==0)]);
sws.Si_spec(:,sws.shutter==0) = sws.Si_spec(:,sws.shutter==0) ./ mean(sws.Si_ms(sws.shutter==0));
sws.Si_norm = sws.Si_spec ./ (max(sws.Si_spec,[],2)*ones([1,length(sws.time)]));
sws.In_spec(:,sws.shutter==0) = sws.In_DN(:,sws.shutter==0) - sws.In_dark*ones([1,sum(sws.shutter==0)]);
sws.In_spec(:,sws.shutter==0) = sws.In_spec(:,sws.shutter==0) ./ mean(sws.In_ms(sws.shutter==0));
sws.In_norm = sws.In_spec ./ (max(sws.In_spec,[],2)*ones([1,length(sws.time)]));

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
figure; lines = plot(pol.deg, pol.Si_norm(50:10:200,:), '-'); recolor(lines,sws.Si_lambda(50:10:200));colorbar;
xlabel('polarizer rotation (degrees)');
ylabel('relative signal');
title('Si Array relative polarization response')
saveas(gcf,[test_dir,'Si_pol_test.png']);
%%
% 
% figure; lines = plot(pol.deg, pol.In_norm(10:10:230,:), '-');
% recolor(lines,sws.In_lambda(10:10:230));colorbar;
% xlabel('polarizer rotation (degrees)');
% ylabel('relative signal');
% title('InGaAs Array relative polarization response')
% saveas(gcf,[test_dir,'InGaAs_pol_test.png']);
%%
pol.Si_ifft = ifft(pol.Si_norm,[],2);
figure; plot([1:length(pol.deg)],abs(pol.Si_ifft(50,:)),'-o');
pol.Si_ifft0 = pol.Si_ifft; pol.Si_ifft0(:,2) = 0;pol.Si_ifft0(:,end) = 0;
pol.Si_fft0 = fft(pol.Si_ifft0,[],2);
figure; lines = plot(pol.deg, real(pol.Si_fft0(10:10:230,:)),'-');
recolor(lines, sws.Si_lambda(10:10:230)); colorbar;
ylabel('filtered');
%%
pol.In_ifft = ifft(pol.In_norm,[],2);
figure; plot([1:length(pol.deg)],abs(pol.In_ifft(50,:)),'-o');
pol.In_ifft0 = pol.In_ifft; pol.In_ifft0(:,2) = 0;pol.In_ifft0(:,end) = 0;
pol.In_fft0 = fft(pol.In_ifft0,[],2);
figure; lines = plot(pol.deg, real(pol.In_fft0(10:10:230,:)),'-');
recolor(lines, sws.In_lambda(10:10:230)); colorbar;
ylabel('filtered');
%%
sws.Si_darks = sws.Si_DN(:,sws.shutter==1);
sws.In_darks = sws.In_DN(:,sws.shutter==1);

sws.Si_dark = mean(sws.Si_darks,2);
sws.In_dark = mean(sws.In_darks,2);
%%
