function [master, fout_name] = make_master3;
% This makes a larger data set than make_master.m
% Maybe a small problem with maker2 involving failure to prescreen barn aod
% for cf_mich==1 as missing.
% In an effort to get more points for comparison try the following:
% 1. Load full MFRSR AOD data set
barn = read_nimbarnod;
% barn = read_nimbarnod('C:\case_studies\dust\MFRSR_Barnard_Bani\2006_barnard_aod_banizoumbou_v20071130.dat');
% Screen out NANs
barn = rmfield(barn,'eps');
fields = fieldnames(barn);
missing = false(size(barn.time));
missing = missing | barn.cf_mich<1;
for af = 1:length(fields)
   if all(size(barn.(fields{af}))==size(missing))
      missing = missing|isNaN(barn.(fields{af}));
   end
end
for af = 1:length(fields)
   if all(size(barn.(fields{af}))==size(missing))
      barn.(fields{af})(missing) = [];
   end
end

% 2. Load aeronet sun and sky AOD and AOT data sets
anet_aod = read_cimel_aod;
anet_fullname = getfullname('*.aot','anet');
anet_aip = read_cimel_aip(anet_fullname);


file_str = 'master2.txt';
fig1_str = 'aod_vs_time_2.png';
fig2_str = 'MFRSR_vs_Aeronet_2.png';
fig3_str = 'Ang_vs_MFRSR_over_Aeronet_2.png';
pname = [anet_aip.pname,'..',filesep,'MFRSR_forward_scat_corrs',filesep];

if findstr('aniz',anet_aip.fname)
   site_str = 'bani.';
else
   site_str = 'nim.';
end
   fout_name = [pname site_str file_str];
   fig1_name = [pname site_str fig1_str];
   fig2_name = [pname site_str fig2_str];
   fig3_name = [pname site_str fig3_str];
   
anet.time = [anet_aod.time; anet_aip.time];
anet.angA = [anet_aod.Angstrom_440_870; anet_aip.alpha440_870];
anet.aod415A = [anet_aod.AOT_440 .* (440/415).^(anet_aod.Angstrom_440_870) ; anet_aip.AOT_440 .* (440/415).^(anet_aip.alpha440_870) ];
if isfield(anet_aod,'AOT_500')&&isfield(anet_aip,'AOT_500')
   anet.aod500A = [anet_aod.AOT_500 ; anet_aip.AOT_500];
elseif isfield(anet_aod,'AOT_500')
   anet.aod500A = [anet_aod.AOT_500  ; anet_aip.AOT_440 .* (440/500).^(anet_aip.alpha440_870) ];
elseif isfield(anet_aip,'AOT_500')
   anet.aod500A = [anet_aod.AOT_440 .* (440/500).^(anet_aod.Angstrom_440_870) ;  anet_aip.AOT_500 ];
else
   anet.aod500A = [anet_aod.AOT_440 .* (440/500).^(anet_aod.Angstrom_440_870) ; anet_aip.AOT_440 .* (440/500).^(anet_aip.alpha440_870) ];
end
if isfield(anet_aod,'AOT_675')
   anet.aod615A = [anet_aod.AOT_675 .* (675/615).^(anet_aod.Angstrom_440_870) ; anet_aip.AOT_675 .* (675/615).^(anet_aip.alpha440_870) ];
   anet.aod675A = [anet_aod.AOT_675 ; anet_aip.AOT_675 ];
else
   anet.aod615A = [anet_aod.AOT_673 .* (673/615).^(anet_aod.Angstrom_440_870) ; anet_aip.AOT_673 .* (673/615).^(anet_aip.alpha440_870) ];
   anet.aod675A = [anet_aod.AOT_673 .* (673/675).^(anet_aod.Angstrom_440_870) ; anet_aip.AOT_673 .* (673/675).^(anet_aip.alpha440_870) ];
end
anet.aod870A = [anet_aod.AOT_870 ; anet_aip.AOT_870 ];
anet.vapor_cm = [anet_aod.Water_cm_; anet_aip.Water_cm_];

fields = fieldnames(anet);
missing = false(size(anet.time));
for af = 1:length(fields)
   if all(size(anet.(fields{af}))==size(missing))
      missing = missing|isNaN(anet.(fields{af}));
   end
end
for af = 1:length(fields)
   if all(size(anet.(fields{af}))==size(missing))
      anet.(fields{af})(missing) = [];
   end
end

[anet.time, ind] = unique(anet.time);
anet.angA = anet.angA(ind);
anet.aod415A = anet.aod415A(ind);
anet.aod500A = anet.aod500A(ind);
anet.aod615A = anet.aod615A(ind);
anet.aod675A = anet.aod675A(ind);
anet.aod870A = anet.aod870A(ind);
anet.vapor_cm = anet.vapor_cm(ind);

% 3. Select all aeronet data that is also deemed cloud-free by MFRSR
[ainm, mina] = nearest(anet.time, barn.time);

% anet.cf_mich = interp1(barn.time, barn.cf_mich, anet.time);
fields = fieldnames(anet);
missing = false(size(anet.time));
missing(~ainm) = true; 

for af = 1:length(fields)
   if all(size(anet.(fields{af}))==size(missing))
      anet.(fields{af})(missing) = [];
   end
end
% These are good cloud-free times




% Find description of master file, identify columns and sources.

% Read Aeronet data set(s):
% anet_vol = read_cimel_aip('C:\case_studies\dust\Banizoumbou.v2\040101_071231_Banizoumbou.vol');
% anet_rin = read_cimel_aip('C:\case_studies\dust\Banizoumbou.v2\040101_071231_Banizoumbou.rin');
% anet_aot = read_cimel_aip('C:\case_studies\dust\Banizoumbou.v2\040101_071231_Banizoumbou.aot');
[anet_pname, anet_fname, ext] = fileparts(anet_fullname);
anet_vol = read_cimel_aip([anet_pname, filesep,anet_fname,'.vol']);
anet_rin = read_cimel_aip([anet_pname, filesep,anet_fname,'.rin']);


%Combine aeronet into one file
aeronet.time = anet_vol.time;
aeronet.cf = anet_vol.VolCon_F;
aeronet.rvf = anet_vol.VolMedianRad_F;
aeronet.sdf = anet_vol.StdDev_F;
aeronet.cc  = anet_vol.VolCon_C;
aeronet.rvc = anet_vol.VolMedianRad_C;
aeronet.sdc = anet_vol.StdDev_C;
aeronet.sza = anet_vol.solar_zenith_angle;
aeronet.REFR_441_ = anet_rin.REFR_441_;
aeronet.REFR_675_ = anet_rin.REFR_675_;
if isfield(anet_rin,'REFR_869_')
   aeronet.REFR_869_ = anet_rin.REFR_869_;
else
   aeronet.REFR_869_ = anet_rin.REFR_870_;
end
aeronet.REFI_441_ = anet_rin.REFI_441_;
aeronet.REFI_675_ = anet_rin.REFI_675_;
if isfield(anet_rin,'REFI_869_')
   aeronet.REFI_869_ = anet_rin.REFI_869_;
else
   aeronet.REFI_869_ = anet_rin.REFI_870_;
end

aeronet.Reff = anet_vol.EffRad_T;
aeronet.pct_sphere = anet_vol.pct_sphericity;

%Screen for NaNs, removing the times with NaNs
aero_fields = fieldnames(aeronet);
missing = false(size(aeronet.time));
% missing = missing | aeronet.time<barn.time(1) | aeronet.time>barn.time(end);
for af = 1:length(aero_fields)
   missing = missing|isNaN(aeronet.(aero_fields{af}));
end
for af = 1:length(aero_fields)
   aeronet.(aero_fields{af})(missing) = [];
end
for af = 1:length(aero_fields)
   %Interpolate onto anet.time grid.
   if ~strcmp('time',aero_fields{af})
      anet.(aero_fields{af}) = interp1(aeronet.time, aeronet.(aero_fields{af}), anet.time,'linear','extrap');
   end
end

[ainb, bina] =nearest(anet.time, barn.time);

% year jday.ff(UT) from aeronet .vol Julian_Day
master.time = anet.time(ainb);
master.jday = serial2doy(anet.time(ainb));
master.cf = anet.cf(ainb);
master.rvf = anet.rvf(ainb);
master.sdf = anet.sdf(ainb);
master.cc  = anet.cc(ainb);
master.rvc = anet.rvc(ainb);
master.sdc = anet.sdc(ainb);
[zen, az, soldst, ha, dec, el, am] = sunae(anet_aod.lat, anet_aod.lon, master.time);
master.sza = zen';
% Interpolate rr and ri to desired wl below
refr = [anet.REFR_441_(ainb),anet.REFR_675_(ainb),anet.REFR_869_(ainb)];
refi = [anet.REFI_441_(ainb),anet.REFI_675_(ainb),anet.REFI_869_(ainb)];
aeronet_wl = [441,675,869];
mfrsr_wl = [415,500,615,675,870];
for wl = mfrsr_wl
   master.(['rr',num2str(wl)]) = interp1(aeronet_wl,refr',wl,'linear','extrap')';
   master.(['ri',num2str(wl)]) = interp1(aeronet_wl,refi',wl,'linear','extrap')';
end

% Use angstrom to desired wl below
master.angA = anet.angA(ainb);
master.aod415A =anet.aod415A(ainb);
master.aod500A = anet.aod500A(ainb);
master.aod615A = anet.aod615A(ainb);
master.aod675A = anet.aod675A(ainb);
master.aod870A = anet.aod870A(ainb);
master.vapor_cm = anet.vapor_cm(ainb);
master.Reff = anet.Reff(ainb);
master.pct_sphere = anet.pct_sphere(ainb);

% Read entirety of Barnard Banizoumbu MFRSR AOD data set

% From barnard aod file:
%Hours(LST) Frac_day(LST) YEAR Mu0    AOT_415 AOT_500 AOT_615 AOT_673 AOT_870 AOT_940 Angstrom  PWV    Azimuth Long_cf Michalsky_cf

master.azimuth = barn.az(bina);
master.aod415M = barn.aod_415(bina);
master.aod500M = barn.aod_500(bina);
master.aod615M = barn.aod_615(bina);
master.aod675M = barn.aod_673(bina);
master.aod870M = barn.aod_870(bina);
master.angM = barn.ang(bina);
master.date = str2num(datestr(barn.time(bina),'yyyymmdd'));

master_fields = fieldnames(master);
missing = false(size(master.time));
% missing = missing | anet.time<barn.time(1) | anet.time>barn.time(end);
for af = 1:length(master_fields)
   missing = missing|isNaN(master.(master_fields{af}));
end
for af = 1:length(master_fields)
   master.(master_fields{af})(missing) = [];
end


figure; plot(master.time - datenum(datestr(master.time(1),'yyyy-01-01')), master.aod500A, 'ro', master.time - datenum(datestr(master.time(1),'yyyy-01-01')), master.aod500M, 'go');
xlabel('day of year'); ylabel('AOD')
legend('Aeronet','MFRSR')
[blah, title_str,ex] = fileparts(fig1_name);
title(title_str, 'interpreter','none');
print(gcf,fig1_name, '-dpng')

figure; scatter(master.aod500M, master.aod500A, 16, serial2doy(master.time),'filled');
xlabel('MFRSR AOD'); ylabel('Aeronet AOD'); colorbar
xl = xlim; yl = ylim; maxl = max([xl;yl]); xlim(maxl);ylim(maxl);
hold('on');plot(maxl,maxl,'k--'); hold('off')
[blah, title_str,ex] = fileparts(fig2_name);
title(title_str, 'interpreter','none');

print(gcf,fig2_name, '-dpng')

figure; scatter( master.angM,master.aod500A./master.aod500M, 16,serial2doy(master.time), 'filled');
ylabel('Aeronet / MFRSR'); xlabel('Angstrom Exponent (MFRSR)') ; colorbar
[blah, title_str,ex] = fileparts(fig3_name);
title(title_str, 'interpreter','none');
print(gcf,fig3_name, '-dpng')

V = datevec(master.time);
day = 300;
   after = serial2doy(master.time)>=day;
   if any(after)
      day_ind = find(after);
      figure(13); 
      plot( master.angM(~after),master.aod500A(~after)./master.aod500M(~after),'k.', ...
         master.angM(after),master.aod500A(after)./master.aod500M(after),'r.');
      set(get(gca,'children'), 'markersize',15)
      leg_str = [];
      if any(~after)
         leg_str{length(leg_str)+1} = 'before';
      end
      if any(after)
         leg_str{length(leg_str)+1} = 'after';
      end
      legend(leg_str)
      ylabel('Aeronet / MFRSR'); xlabel('Angstrom Exponent (MFRSR)') ; 
      title([site_str,': angM vs aod_A/aod_M for ',datestr(master.time(day_ind(1)),'mmm yyyy')],'interpreter','none');
      fig_str = 'Ang_vs_MFRSR_over_Aeronet_1.';
      month_str = datestr(master.time(day_ind(1)),'mmm');
      print(gcf,[pname site_str fig_str month_str '.png'], '-dpng')
   end

% !!

for v = 1:12
   before = V(:,2)<v;
   after = V(:,2)>v;
   mon = V(:,2)==v;
   if any(mon)
      mon_ind = find(mon);
      figure(12); 
%       scatter( master.angM,master.aod500A./master.aod500M, 4,V(:,2), 'filled');
%       hold('on');
      plot( master.angM(before),master.aod500A(before)./master.aod500M(before),'k.', ...
         master.angM(after),master.aod500A(after)./master.aod500M(after),'r.', ...
         master.angM(mon),master.aod500A(mon)./master.aod500M(mon),'g.');
      set(get(gca,'children'), 'markersize',15)
      leg_str = [];
      if any(before)
         leg_str{length(leg_str)+1} = 'before';
      end
      if any(after)
         leg_str{length(leg_str)+1} = 'after';
      end
      if any(mon)
         leg_str{length(leg_str)+1} = datestr(master.time(mon_ind(1)),'mmm yyyy');
      end
      legend(leg_str)
      ylabel('Aeronet / MFRSR'); xlabel('Angstrom Exponent (MFRSR)') ; 
      title([site_str,': angM vs aod_A/aod_M for ',datestr(master.time(mon_ind(1)),'mmm yyyy')],'interpreter','none');
      fig_str = 'Ang_vs_MFRSR_over_Aeronet_1.';
      month_str = datestr(master.time(mon_ind(1)),'mmm');
      print(gcf,[pname site_str fig_str month_str '.png'], '-dpng')
   end
end

header_str = ' year jday (UT)     cf        rvf        sdf       cc        rvc      sdc      sza       rr415     rr500     rr615     rr673     rr870     ri415     ri500     ri615     ri673     ri870    aot415A   aot500A   aot615A   aot673A   aot870A   vapor(cm)  angA       Reff   %sphere   azimuth    aot415M   aot500M   aot615M   aot673M   aot870M    angM     date';

V = datevec(master.time);
yyyy = V(:,1);
% txt_out needs to be composed of data oriented as column vectors.
txt_out = [yyyy, master.jday, ...
   master.cf, master.rvf, master.sdf, ...
   master.cc, master.rvc, master.sdc, ...
   master.sza, ...
   master.rr415, master.rr500, master.rr615, master.rr675, master.rr870, ...
   master.ri415, master.ri500, master.ri615, master.ri675, master.ri870, ...
   master.aod415A, master.aod500A, master.aod615A, master.aod675A, master.aod870A, ...
   master.vapor_cm, master.angA, master.Reff, master.pct_sphere, master.azimuth, ...
   master.aod415M, master.aod500M, master.aod615M, master.aod675M, master.aod870M, ...
   master.angM, master.date ];
%
header_row = ['year  jday (UT)   cf      rvf      sdf   '];
header_row = [header_row, '  cc       rvc      sdc     sza   '];
header_row = [header_row, '   rr415    rr500     rr615     rr673     rr870  '];
header_row = [header_row, '   ri415     ri500     ri615     ri673     ri870   '];
header_row = [header_row, 'aot415A   aot500A  aot615A  aot673A   aot870A  '];
header_row = [header_row, 'vapor(cm)  angA       Reff   %sphere   azimuth  '];
header_row = [header_row, 'aot415M   aot500M   aot615M   aot673M   aot870M  '];
header_row = [header_row, 'angM     date'];




fid = fopen(fout_name,'w+');
fprintf(fid,'%s \n',header_row );

format_str = ['%d  %2.5f  %2.5f  %2.5f  %2.5f  ']; % 4
format_str = [format_str, '%2.5f  %2.5f  %2.5f %2.5f ']; % 4
format_str = [format_str, '%2.5f %2.5f  %2.5f  %2.5f %2.5f '];  % 5 rr
format_str = [format_str, '%2.5f %2.5f  %2.5f  %2.5f %2.5f '];  % 5 ri
format_str = [format_str, '%2.5f %2.5f  %2.5f  %2.5f %2.5f '];  % 5 aod Aeronet
format_str = [format_str, '%2.5f %2.5f  %2.5f  %2.5f %2.5f '];  % 5
format_str = [format_str, '%2.5f %2.5f  %2.5f  %2.5f %2.5f '];  % 5 aod MFRSR
format_str = [format_str, '%2.5f, %d \n'];

fprintf(fid,format_str,txt_out');
fclose(fid);
