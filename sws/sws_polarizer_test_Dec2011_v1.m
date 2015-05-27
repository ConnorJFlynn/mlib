% SWS spectral polarization tests, Dec 06 2011 at PNNL.
% One Glan-T polarizer located at light source 8 mm apeture both sides of polarizer
% % to limit stray light.
% Iris ~ 18" from source
% SWS ~ 7' = 84" away from iris.
% Polarizer rotated 180-deg every 10 degree steps
% Start time: 21:38
% From Albert's notes:
% % Deg       Start Time
% 0       21:38
% 10      21:39
% 20      21:40
% 30      21:41
% 40  :42 (possible hall light contamination)
% 50      :43
% 60      :44
% 70      :45
% 80      :46
% 90      :47
% 100     :48
% 110     :49
% 120     :50
% 130     :51
% 140:    :52
% 150     :53
% 160     :54
% 170     :55
% 180     :56


test_dir = 'C:\case_studies\SWS\SWS_pol_test_at_PNNL\';

sws_files = dir([test_dir,'sgpsws*.dat']);
sws = read_sws_raw([test_dir, sws_files(1).name]);
for s = length(sws_files):-1:2
sws = cat_sws_raw(sws,read_sws_raw([test_dir, sws_files(s).name]));
end
%%
pol.deg = [0:10:180];
pol.time(1) = datenum('2011-12-06 21:38', 'yyyy-mm-dd HH:MM')
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
pol.Si_norm = pol.Si_spec ./(mean(pol.Si_spec,2)*ones([1,19]));
pol.In_norm = pol.In_spec ./(mean(pol.In_spec,2)*ones([1,19]));
%%
figure; lines = plot(pol.deg, pol.Si_norm(50:10:200,:), '-'); recolor(lines,sws.Si_lambda(50:10:200));colorbar;
xlabel('polarizer rotation (degrees)');
ylabel('relative signal');
title('Si Array relative polarization response')
saveas(gcf,[test_dir,'Si_pol_test.png']);
%%

figure; lines = plot(pol.deg, pol.In_norm(10:10:230,:), '-');
recolor(lines,sws.In_lambda(10:10:230));colorbar;
xlabel('polarizer rotation (degrees)');
ylabel('relative signal');
title('InGaAs Array relative polarization response')
saveas(gcf,[test_dir,'InGaAs_pol_test.png']);

%%
sws.Si_darks = sws.Si_DN(:,sws.shutter==1);
sws.In_darks = sws.In_DN(:,sws.shutter==1);

sws.Si_dark = mean(sws.Si_darks,2);
sws.In_dark = mean(sws.In_darks,2);
%%
figure; lines = plot(sws.Si_lambda, sws.Si_darks - sws.Si_dark*ones([1,sum(sws.shutter==1)]), '-');
lines = recolor(lines, serial2doy(sws.time(sws.shutter==1)));
%%
sws.Si_spec(:,sws.shutter==0) = sws.Si_DN(:,sws.shutter==0) - sws.Si_dark*ones([1,sum(sws.shutter==0)]);
sws.Si_spec(:,sws.shutter==0) = sws.Si_spec(:,sws.shutter==0) ./ mean(sws.Si_ms(sws.shutter==0));
sws.Si_norm = sws.Si_spec ./ (max(sws.Si_spec,[],2)*ones([1,length(sws.time)]));
%%
sws.In_spec(:,sws.shutter==0) = sws.In_DN(:,sws.shutter==0) - sws.In_dark*ones([1,sum(sws.shutter==0)]);
sws.In_spec(:,sws.shutter==0) = sws.In_spec(:,sws.shutter==0) ./ mean(sws.In_ms(sws.shutter==0));
sws.In_norm = sws.In_spec ./ (max(sws.In_spec,[],2)*ones([1,length(sws.time)]));

%%
figure; lines = semilogy(ts(sws.shutter==0), sws.In_norm(50:5:200,sws.shutter==0),'-');
recolor(lines,[sws.In_lambda(50:5:200)]);colorbar
%%
n05 = sws.time> datenum('2011-12-06 20:38:00','yyyy-mm-dd HH:MM:SS') & sws.time< datenum('2011-12-06 20:39:00','yyyy-mm-dd HH:MM:SS');
nom0 = sws.time> datenum('2011-12-06 20:39:00','yyyy-mm-dd HH:MM:SS') & sws.time< datenum('2011-12-06 20:40:00','yyyy-mm-dd HH:MM:SS');
p05 = sws.time> datenum('2011-12-06 20:40:00','yyyy-mm-dd HH:MM:SS') & sws.time< datenum('2011-12-06 20:41:00','yyyy-mm-dd HH:MM:SS');

%%
figure; plot(ts, sws.Si_norm(120,:),'kx',ts(nom0), sws.Si_norm(120,nom0),'go',ts(p05), sws.Si_norm(120,p05),'ro');

%%
figure; plot(ts, sws.Si_DN(120,:),'ro')