% SWS spectral polarization tests, Dec 08 2011 at PNNL.
% To determine whether 7% variability is in light source (lamp) or in
% optics of SWS, we now introduce the depolarizer before the Glan-Thompson
% polarizer.  During the course of the previous test Albert noticed some wobble of
% the spot near the SWS as the polarizer is rotated.  In this test, the depolarizer and GT polarizer 
% have been moved away from the light source and closer to the SWS.  Iris
% remained back near light source.
% In this test, polarizer is rotated through full 360 degrees to help
% distinguish wobble from polarization.
% Iris ~ 18" from source
% SWS ~ 7' = 84" away from iris.
% Polarizer rotated 180-deg every 10 degree steps
% Start time: 23:25
% % Deg       Start Time
% 0     23:25
% 10    23:26
% 20    23:27
% 30    23:28
% 40    23:29
% 50    23:30
% 60    23:31
% 70    23:32
% 80    23:33
% 90    23:34
% 100   23:35  
% 110   23:36
% 120     :37
% 130     :38
% 140:    :39
% 150   23:40
% 160   23:41
% 170   23:42
% 180     :43
% 190   23:44
% 200   23:45
% 21    23:46
% 20    23:47
% 30    23:48
%240    23:49
% 250   23:50
% 260   23:51
% 270   23:52
% 280   23:53  
% 290   23:54
% 300     :55
% 310     :56
% 320:    :57
% 330   23:58
% 340   23:59
% 350   00:00
%360    00:01

test_dir = 'C:\case_studies\SWS\sws_pol_depol_day2_2011_12_08_test1\test_3\';

sws_files = dir([test_dir,'sgpsws*.dat']);
sws = read_sws_raw([test_dir, sws_files(1).name]);
for s = length(sws_files):-1:2
sws = cat_sws_raw(sws,read_sws_raw([test_dir, sws_files(s).name]));
end
%%
pol.deg = [0:10:360];
pol.time(1) = datenum('2011-12-08 23:25', 'yyyy-mm-dd HH:MM')
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
title('Si Array relative polarization response, shifted baseline, maybe wobble')
saveas(gcf,[test_dir,'Si_pol_test.png']);
%%

figure; lines = plot(pol.deg, pol.In_norm(10:10:230,:), '-');
recolor(lines,sws.In_lambda(10:10:230));colorbar;
xlabel('polarizer rotation (degrees)');
ylabel('relative signal');
title('InGaAs Array relative polarization response')
saveas(gcf,[test_dir,'InGaAs_pol_test.png']);
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
