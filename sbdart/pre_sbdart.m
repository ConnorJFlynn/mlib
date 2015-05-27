% Get mfrC1 mat file
%%

mwr_path = ['C:\case_studies\Alive\data\sgpmwrlosC1.b1\'];
beflux_path  = ['C:\case_studies\Alive\data\sgpbeflux1longC1.c1\'];
sbdart_path = ['c:\cygwin\usr\local\sbdart\'];
% Define time subset
disp(['Load the mfr mat file.'])
[fname, pname] = uigetfile(['C:\case_studies\Alive\data\*.mat'])
load([pname, fname])

date_string = datestr(mfr.time(1),'yyyymmdd');
mwr_list = dir([mwr_path, '*', date_string, '*.cdf']);
if length(mwr_list)>0
    mwr = ancload([mwr_path, mwr_list(1).name]);
else
    disp('No MWR file found!');
    return
end

flux_list = dir([beflux_path, '*', date_string, '*.cdf']);
if length(flux_list)>0
    beflux = ancload([beflux_path, flux_list(1).name]);
else
    disp('No BE_flux file found!');
    return
end

%%
close('all')
taus = ([mfr.aod_415nm',mfr.aod_500nm',...
    mfr.aod_615nm',mfr.aod_673nm', ...
    mfr.aod_870nm']);
figure; plot(serial2Hh(mfr.time), taus', '.'); zoom on
legend('415nm', '500nm', '615nm', '673nm', '870nm')
title('Zoom into desired time and hit enter')
disp('Zoom into desired time and hit enter')
pause
v = axis;

mfr.t.sbdart = find((serial2Hh(mfr.time)>=v(1))&(serial2Hh(mfr.time)<=v(2)));
pres = mean(mfr.pres(mfr.t.sbdart));
o3 = mfr.toms;
solfac = mean(mfr.r_au(mfr.t.sbdart));
cos_sol_zen = 1./mean(mfr.airmass(mfr.t.sbdart));

mwr.t.sbdart = find((serial2Hh(mwr.time)>=v(1))&(serial2Hh(mwr.time)<=v(2)));
water_vap = mean(mwr.vars.vap.data(mwr.t.sbdart));

mean_ang = mean(mfr.ang_500by870(mfr.t.sbdart));
mean_taus = mean(taus(mfr.t.sbdart,:));

beflux.t.sbdart = find((serial2Hh(beflux.time)>=v(1))&(serial2Hh(beflux.time)<=v(2)));
down_sw_direct = mean(beflux.vars.short_direct_normal.data(beflux.t.sbdart) .* cos(pi*beflux.vars.zenith.data(beflux.t.sbdart)/180));

%([mfr.aod_415nm(mfr.t.sbdart)',mfr.aod_500nm(mfr.t.sbdart)',...
%    mfr.aod_615nm(mfr.t.sbdart)',mfr.aod_673nm(mfr.t.sbdart)', ...
%    mfr.aod_870nm(mfr.t.sbdart)'])

fid = fopen([sbdart_path, 'INPUT'],'wt');
y = (['$INPUT']);
fprintf(fid,'%s \n',y);
y = (['IDATM = 2']);
fprintf(fid,'%s \n',y);
y = (['ISAT = 0']);
fprintf(fid,'%s \n',y);
y = (['NF = -1']);
fprintf(fid,'%s \n',y);
y = (['NSTR = 4']);
fprintf(fid,'%s \n',y);
y = (['WLINF = 0.3']);
fprintf(fid,'%s \n',y);
fprintf(fid,'%s \n',y);
y = (['WLSUP = 3.3']);
fprintf(fid,'%s \n',y);
y = (['WLINC = 0.025']);
fprintf(fid,'%s \n',y);

y = (['PBAR = ',num2str(pres)]);
fprintf(fid,'%s \n',y);
y = (['UO3 = ',num2str(o3/1000)]);
fprintf(fid,'%s \n',y);
y = (['SOLFAC = ',num2str(solfac)]);
fprintf(fid,'%s \n',y);
y = (['CSZA = ',num2str(cos_sol_zen)]);
fprintf(fid,'%s \n',y);
y = (['UW = ',num2str(water_vap)]);
fprintf(fid,'%s \n',y);
y = (['IAER = 5']);
fprintf(fid,'%s \n',y);
y = (['ABAER = ',num2str(mean_ang)]);
fprintf(fid,'%s \n',y);
y = (['WLBAER = ',num2str([mfr.cw_415nm,mfr.cw_500nm,mfr.cw_615nm,...
    mfr.cw_673nm,mfr.cw_870nm]/1000)]);
fprintf(fid,'%s \n',y);
y = (['QBAER = ',num2str(mean_taus)]);
fprintf(fid,'%s \n',y);
y = (['WBAER = 0.89, 0.89, 0.89, 0.89, 0.89']);
fprintf(fid,'%s \n',y);
y = (['GBAER = 0.63, 0.63, 0.63, 0.63, 0.63']);
fprintf(fid,'%s \n',y);
y = (['IDB = 20*0']);
fprintf(fid,'%s \n',y);
y = (['IOUT = 10']);
fprintf(fid,'%s \n',y);
y = (['$END']);
fprintf(fid,'%s \n',y);
fclose(fid);

disp(['Best estimate Downwelling SW Direct: ', num2str(down_sw_direct)])
pname = pwd;

cd(sbdart_path)
[s,w] = system(['C:\cygwin\bin\bash -c sbdart']);
cd(pname);
while length(w)>1;
[t1,w] = strtok(w);
[t2,w] = strtok(w);
end
sbdart_down_sw_direct = max([str2num(t1), str2num(t2)]);
disp(['SBDART estimate Downwelling SW Direct: ',num2str(sbdart_down_sw_direct)]);
disp(['Model - measured = ', num2str(sbdart_down_sw_direct-down_sw_direct)]);
%%
