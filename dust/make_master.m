function [master, fout_name] = make_master;
% Find description of master file, identify columns and sources.
% This makes a more sparse data set than make_master2
% Read Aeronet data set(s):
% bani_vol = read_cimel_aip('C:\case_studies\dust\Banizoumbou.v2\040101_071231_Banizoumbou.vol');
% bani_rin = read_cimel_aip('C:\case_studies\dust\Banizoumbou.v2\040101_071231_Banizoumbou.rin');
% bani_aot = read_cimel_aip('C:\case_studies\dust\Banizoumbou.v2\040101_071231_Banizoumbou.aot');
bani_vol = read_cimel_aip('*.vol');
bani_rin = read_cimel_aip('*.rin');
bani_aot = read_cimel_aip('*.aot');

pname = [bani_vol.pname,'..',filesep,'MFRSR_forward_scat_corrs',filesep];
file_str = 'master.txt';
fig1_str = 'aod_vs_time_1.png';
fig2_str = 'MFRSR_vs_Aeronet_1.png';
fig3_str = 'Ang_vs_MFRSR_over_Aeronet_1.png';
if findstr('aniz',bani_vol.fname)
   site_str = 'bani.';
else
   site_str = 'nim.';
end
   fout_name = [pname site_str file_str];
   fig1_name = [pname site_str fig1_str];
   fig2_name = [pname site_str fig2_str];
   fig3_name = [pname site_str fig3_str];

%Combine aeronet into one file
aeronet.time = bani_vol.time;
aeronet.jday = bani_vol.Julian_Day;
aeronet.time = bani_vol.time;
aeronet.jday = bani_vol.Julian_Day;
aeronet.cf = bani_vol.VolCon_F;
aeronet.rvf = bani_vol.VolMedianRad_F;
aeronet.sdf = bani_vol.StdDev_F;
aeronet.cc  = bani_vol.VolCon_C;
aeronet.rvc = bani_vol.VolMedianRad_C;
aeronet.sdc = bani_vol.StdDev_C;
aeronet.sza = bani_vol.solar_zenith_angle;  
aeronet.REFR_441_ = bani_rin.REFR_441_;
aeronet.REFR_675_ = bani_rin.REFR_675_;

if isfield(bani_rin,'REFR_869_')
   aeronet.REFR_869_ = bani_rin.REFR_869_;
else
   aeronet.REFR_869_ = bani_rin.REFR_870_;
end
aeronet.REFI_441_ = bani_rin.REFI_441_;
aeronet.REFI_675_ = bani_rin.REFI_675_;
if isfield(bani_rin,'REFI_869_')
   aeronet.REFI_869_ = bani_rin.REFI_869_;
else
   aeronet.REFI_869_ = bani_rin.REFI_870_;
end

% Use angstrom to desired wl below
aeronet.angA = bani_aot.alpha440_870;
% aoda = [bani_aot.AOT_440, bani_aot.AOT_675, bani_aot.AOT_870];
aeronet.aot415A = bani_aot.AOT_440 .* (440/415).^(aeronet.angA);
aeronet.aot500A = bani_aot.AOT_440 .* (440/500).^(aeronet.angA);
aeronet.aot615A = bani_aot.AOT_675 .* (675/615).^(aeronet.angA);
aeronet.aot673A = bani_aot.AOT_675 .* (675/675).^(aeronet.angA);
aeronet.aot870A = bani_aot.AOT_870; %.* (869/870).^(aeronet.angA);

aeronet.vapor_cm = bani_aot.Water_cm_;

aeronet.Reff = bani_vol.EffRad_T;
aeronet.pct_sphere = bani_vol.pct_sphericity;

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


% Assume that the Aeronet cloudscreen is sufficient, find nearest MFRSR
% % points to existing Aeronet points
% bbina = interp1(barn.time, [1:length(barn.time)], aeronet.time,'nearest','extrap');
% Read Barnard Banizoumbu AOD
% barn = read_nimbarnod('C:\case_studies\dust\MFRSR_Barnard_Bani\2006_barnard_aod_banizoumbou_v20071130.dat');
barn = read_nimbarnod;

[ainb, bina] =nearest(aeronet.time, barn.time);

% year jday.ff(UT) from aeronet .vol Julian_Day
master.time = aeronet.time(ainb);
master.jday = aeronet.jday(ainb);
master.cf = aeronet.cf(ainb);
master.rvf = aeronet.rvf(ainb);
master.sdf = aeronet.sdf(ainb);
master.cc  = aeronet.cc(ainb);
master.rvc = aeronet.rvc(ainb);
master.sdc = aeronet.sdc(ainb);
master.sza = aeronet.sza(ainb);  
% Interpolate rr and ri to desired wl below
refr = [aeronet.REFR_441_(ainb),aeronet.REFR_675_(ainb),aeronet.REFR_869_(ainb)];
refi = [aeronet.REFI_441_(ainb),aeronet.REFI_675_(ainb),aeronet.REFI_869_(ainb)];
aeronet_wl = [441,675,869];
mfrsr_wl = [415,500,615,673,870];
for wl = mfrsr_wl
   master.(['rr',num2str(wl)]) = interp1(aeronet_wl,refr',wl,'linear','extrap')';
   master.(['ri',num2str(wl)]) = interp1(aeronet_wl,refi',wl,'linear','extrap')';
end

% Use angstrom to desired wl below
master.angA = aeronet.angA(ainb);
% aoda = [bani_aot.AOT_440(ainb), bani_aot.AOT_675(ainb), bani_aot.AOT_870(ainb)];
master.aod415A =aeronet.aot415A(ainb) .* (440/415).^(aeronet.angA(ainb));
master.aod500A = aeronet.aot500A(ainb) .* (440/500).^(aeronet.angA(ainb));
master.aod615A = aeronet.aot615A(ainb) .* (675/615).^(aeronet.angA(ainb));
master.aod673A = aeronet.aot673A(ainb) .* (675/673).^(aeronet.angA(ainb));
master.aod870A = aeronet.aot870A(ainb) .* (869/870).^(aeronet.angA(ainb));

master.vapor_cm = aeronet.vapor_cm(ainb);

master.Reff = aeronet.Reff(ainb);
master.pct_sphere = aeronet.pct_sphere(ainb);

% Read entirety of Barnard Banizoumbu MFRSR AOD data set

% From barnard aod file:
%Hours(LST) Frac_day(LST) YEAR Mu0    AOT_415 AOT_500 AOT_615 AOT_673 AOT_870 AOT_940 Angstrom  PWV    Azimuth Long_cf Michalsky_cf

master.azimuth = barn.az(bina);    
master.aod415M = barn.aod_415(bina);  
master.aod500M = barn.aod_500(bina);   
master.aod615M = barn.aod_615(bina);
master.aod673M = barn.aod_673(bina);
master.aod870M = barn.aod_870(bina);
master.angM = barn.ang(bina);
master.date = str2num(datestr(barn.time(bina),'yyyymmdd'));

master_fields = fieldnames(master);
missing = false(size(master.time));
% missing = missing | aeronet.time<barn.time(1) | aeronet.time>barn.time(end);
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
xlabel('MFRSR AOD'); ylabel('Aeronet AOD'); 
xl = xlim; yl = ylim; maxl = max([xl;yl]); xlim(maxl);ylim(maxl);
hold('on');plot(maxl,maxl,'k--'); hold('off');colorbar
[blah, title_str,ex] = fileparts(fig2_name);
title(title_str, 'interpreter','none');
print(gcf,fig2_name, '-dpng')

figure; scatter( master.angM,master.aod500A./master.aod500M, 16,serial2doy(master.time), 'filled');
ylabel('Aeronet / MFRSR'); xlabel('Angstrom Exponent (MFRSR)') ; colorbar
[blah, title_str,ex] = fileparts(fig3_name);
title(title_str, 'interpreter','none');
print(gcf,fig3_name, '-dpng')

V = datevec(master.time);
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
      title(['angM vs aod_A/aod_M for ',datestr(master.time(mon_ind(1)),'mmm yyyy')],'interpreter','none');
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
   master.rr415, master.rr500, master.rr615, master.rr673, master.rr870, ...   
   master.ri415, master.ri500, master.ri615, master.ri673, master.ri870, ...   
   master.aod415A, master.aod500A, master.aod615A, master.aod673A, master.aod870A, ...   
   master.vapor_cm, master.angA, master.Reff, master.pct_sphere, master.azimuth, ...  
master.aod415M, master.aod500M, master.aod615M, master.aod673M, master.aod870M, ...      
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
% fid = fopen(['C:\case_studies\dust\MFRSR_forward_scat_corrs\master.txt'],'w+');
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
