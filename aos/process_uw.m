function [uw_filtered, uw_col, uw] = process_uw(filename)
%[uw_filtered, uw_col, uw] = process_uw(filename)
close('all')
if nargin==0
    [fname pname] = uigetfile('C:\case_studies\Aerosol_IOP\Evgueni\TwinOtter\fresh_from_archive\*.txt');
    filename = [pname, fname];
end
disp(['Processing ',fname]);
slash = max(findstr(filename, '\'));
pname = filename(1:slash);
fname = filename(slash+1:end);
uw.fname = fname;
uw.pname = pname;
temp = load([pname fname]);
uw.mission_time = temp(:,1);
uw.alt = temp(:,2)/1000; %alt in km
uw.tscat_blu_amb = temp(:,3);
uw.tscat_grn_amb = temp(:,4);
uw.tscat_red_amb = temp(:,5);
uw.bscat_blu_amb = temp(:,6);
uw.bscat_grn_amb = temp(:,7);
uw.bscat_red_amb = temp(:,8);
uw.bap_blu_amb = temp(:,9);
uw.bap_grn_amb = temp(:,10);
uw.bap_red_amb = temp(:,11);

uw.tscat_blu_stp = temp(:,12);
uw.tscat_grn_stp = temp(:,13);
uw.tscat_red_stp = temp(:,14);
uw.bscat_blu_stp = temp(:,15);
uw.bscat_grn_stp = temp(:,16);
uw.bscat_red_stp = temp(:,17);
uw.bap_blu_stp = temp(:,18);
uw.bap_grn_stp = temp(:,19);
uw.bap_red_stp = temp(:,20);

uw.gamma = temp(:,21);
uw.frh = temp(:,22);
uw.T_neph = temp(:,23);
uw.P_neph = temp(:,24);
uw.RH_neph = temp(:,25);
uw.T_amb = temp(:,26);
uw.P_amb = temp(:,27);
uw.RH_amb = temp(:,28);
uw.RH_lowNeph = temp(:,29);
uw.RH_medNeph = temp(:,30);
uw.RH_hiNeph = temp(:,31);
uw.humid_flag = temp(:,32);

uw.utc = 14.6 + uw.mission_time./(60*60);
rest = fname;
[bit,rest] = strtok(rest, ['_','.']);
[bit,rest] = strtok(rest, ['_','.']);
rest = fname;
[bit,rest] = strtok(rest, ['_','.']);
[bit,rest] = strtok(rest, ['_','.']);
[bit,rest] = strtok(rest, ['_','.']);
uw.time = uw.utc/24 + datenum(bit(1:6),'yymmdd');
%=(E2>5)*(H2>1)*(E2>H2)*(K2>0.01)*(BA2<0.1)
uw.ext_blu =(uw.tscat_blu_amb + uw.bap_blu_amb);
uw.ext_grn = (uw.tscat_grn_amb + uw.bap_grn_amb);
uw.ext_red = (uw.tscat_red_amb + uw.bap_red_amb);
uw.ssa_blu = uw.tscat_blu_amb ./ uw.ext_blu;
uw.ssa_grn = uw.tscat_grn_amb ./ uw.ext_grn;
uw.ssa_red = uw.tscat_red_amb ./ uw.ext_red;
uw.bsf_blu = uw.bscat_blu_amb ./ (uw.tscat_blu_amb);
uw.bsf_grn = uw.bscat_grn_amb ./ (uw.tscat_grn_amb);
uw.bsf_red = uw.bscat_red_amb ./ (uw.tscat_red_amb);
%g parameterization -7.14*AK2^3 + 7.46 * AK2^2 -3.96*AK2+0.99
uw.g_blu = -7.14 * uw.bsf_blu .^3 + 7.46 * uw.bsf_blu .^2 -3.96*uw.bsf_blu + .99;
uw.g_grn = -7.14 * uw.bsf_grn .^3 + 7.46 * uw.bsf_grn .^2 -3.96*uw.bsf_grn + .99;
uw.g_red = -7.14 * uw.bsf_red .^3 + 7.46 * uw.bsf_red .^2 -3.96*uw.bsf_red + .99;

uw.rh_rel_del = 2*abs(uw.RH_amb(1:end-1)-uw.RH_amb(2:end))./(uw.RH_amb(1:end-1)+uw.RH_amb(2:end));
uw.rh_rel_del = [0;uw.rh_rel_del];
uw.ts_test = uw.tscat_red_amb > 5;
uw.bs_test = uw.bscat_red_amb > 1;
uw.bf_test = uw.tscat_red_amb > uw.bscat_red_amb;
uw.bap_test = uw.bap_red_amb > 0.01;
uw.rh_test = uw.rh_rel_del < .1;
uw.X = uw.ts_test & uw.bs_test & uw.bf_test & uw.bap_test & uw.rh_test;
[alt,uw.alt_ind] = sort(uw.alt(uw.X));

uw_fields = fieldnames(uw);
uw_filtered.fname = uw.fname;
uw_filtered.pname = uw.pname;
for i = 1:length(uw_fields)
    if length(uw.(char(uw_fields(i))))==length(uw.time)
        uw_filtered.(char(uw_fields(i))) = uw.(char(uw_fields(i)))(uw.X);
    end
end
uw_fields = fieldnames(uw_filtered);
for i = 1:length(uw_fields)
    if length(uw_filtered.(char(uw_fields(i))))==length(uw_filtered.time)
        uw_filtered.(char(uw_fields(i))) = uw_filtered.(char(uw_fields(i)))(uw.alt_ind);
    end
end

uw_filtered = rmfield(uw_filtered, 'X');
uw_filtered.tscat_blu_dist = uw_filtered.tscat_blu_amb / trapz(uw_filtered.alt/1000, uw_filtered.tscat_blu_amb);
uw_filtered.tscat_grn_dist = uw_filtered.tscat_grn_amb / trapz(uw_filtered.alt/1000, uw_filtered.tscat_grn_amb);
uw_filtered.tscat_red_dist = uw_filtered.tscat_red_amb / trapz(uw_filtered.alt/1000, uw_filtered.tscat_red_amb);
uw_filtered.ext_blu_dist = uw_filtered.ext_blu / trapz(uw_filtered.alt/1000, uw_filtered.ext_blu);
uw_filtered.ext_grn_dist = uw_filtered.ext_grn / trapz(uw_filtered.alt/1000, uw_filtered.ext_grn);
uw_filtered.ext_red_dist = uw_filtered.ext_red / trapz(uw_filtered.alt/1000, uw_filtered.ext_red);

% uw_col.mean_tscat_blu = mean(uw_filtered.tscat_blu_amb);
% uw_col.mean_tscat_grn = mean(uw_filtered.tscat_grn_amb);
% uw_col.mean_tscat_red = mean(uw_filtered.tscat_red_amb);
% uw_col.mean_bap_blu = mean(uw_filtered.bap_blu_amb);
% uw_col.mean_bap_grn = mean(uw_filtered.bap_grn_amb);
% uw_col.mean_bap_red = mean(uw_filtered.bap_red_amb);
uw_col.tscat_blu = trapz(uw_filtered.alt/1000, uw_filtered.tscat_blu_amb);
uw_col.tscat_grn = trapz(uw_filtered.alt/1000, uw_filtered.tscat_grn_amb);
uw_col.tscat_red = trapz(uw_filtered.alt/1000, uw_filtered.tscat_red_amb);
uw_col.bap_blu = trapz(uw_filtered.alt/1000, uw_filtered.bap_blu_amb);
uw_col.bap_grn = trapz(uw_filtered.alt/1000, uw_filtered.bap_grn_amb);
uw_col.bap_red = trapz(uw_filtered.alt/1000, uw_filtered.bap_red_amb);

uw_col.ext_blu = trapz(uw_filtered.alt/1000, uw_filtered.ext_blu);
uw_col.ext_grn = trapz(uw_filtered.alt/1000, uw_filtered.ext_grn);
uw_col.ext_red = trapz(uw_filtered.alt/1000, uw_filtered.ext_red);
% uw_col.mean_ext_blu = mean(uw_filtered.ext_blu);
% uw_col.mean_ext_grn = mean(uw_filtered.ext_grn);
% uw_col.mean_ext_red = mean(uw_filtered.ext_red);

uw_col.ssa_blu = uw_col.tscat_blu / uw_col.ext_blu;
uw_col.ssa_grn = uw_col.tscat_grn / uw_col.ext_grn;
uw_col.ssa_red = uw_col.tscat_red / uw_col.ext_red;
uw_col.mean_ssa_blu = mean(uw_filtered.ssa_blu);
uw_col.mean_ssa_grn = mean(uw_filtered.ssa_grn);
uw_col.mean_ssa_red = mean(uw_filtered.ssa_red);
% uw_col.ssa_mean_blu = mean(uw_filtered.tscat_blu_amb)/mean(uw_filtered.ext_blu);
% uw_col.ssa_mean_grn = mean(uw_filtered.tscat_grn_amb)/mean(uw_filtered.ext_grn);
% uw_col.ssa_mean_red = mean(uw_filtered.tscat_red_amb)/mean(uw_filtered.ext_red);

uw_col.bscat_blu = trapz(uw_filtered.alt/1000, uw_filtered.bscat_blu_amb);
uw_col.bscat_grn = trapz(uw_filtered.alt/1000, uw_filtered.bscat_grn_amb);
uw_col.bscat_red = trapz(uw_filtered.alt/1000, uw_filtered.bscat_red_amb);
uw_col.bsf_blu = uw_col.bscat_blu / uw_col.tscat_blu;
uw_col.bsf_grn = uw_col.bscat_grn / uw_col.tscat_grn;
uw_col.bsf_red = uw_col.bscat_red / uw_col.tscat_red;
% uw_col.mean_bsf_blu = mean(uw_filtered.bsf_blu);
% uw_col.mean_bsf_grn = mean(uw_filtered.bsf_grn);
% uw_col.mean_bsf_red = mean(uw_filtered.bsf_red);
uw_col.g_blu_1 = trapz(uw_filtered.alt/1000,uw_filtered.g_blu .* uw_filtered.tscat_blu_dist);
uw_col.g_grn_1 = trapz(uw_filtered.alt/1000,uw_filtered.g_grn .* uw_filtered.tscat_grn_dist);
uw_col.g_red_1 = trapz(uw_filtered.alt/1000,uw_filtered.g_red .* uw_filtered.tscat_red_dist);
uw_col.g_blu_2 = -7.14 * uw_col.bsf_blu .^3 + 7.46 * uw_col.bsf_blu .^2 -3.96*uw_col.bsf_blu + .99;
uw_col.g_grn_2 = -7.14 * uw_col.bsf_grn .^3 + 7.46 * uw_col.bsf_grn .^2 -3.96*uw_col.bsf_grn + .99;
uw_col.g_red_2 = -7.14 * uw_col.bsf_red .^3 + 7.46 * uw_col.bsf_red .^2 -3.96*uw_col.bsf_red + .99;
uw_col.mean_g_blu = mean(uw_filtered.g_blu);
uw_col.mean_g_grn = mean(uw_filtered.g_grn);
uw_col.mean_g_red = mean(uw_filtered.g_red);

% uw_col.g_mean_bsf_blu_1 = -7.14 * uw_col.mean_bsf_blu .^3 + 7.46 * uw_col.mean_bsf_blu .^2 -3.96*uw_col.mean_bsf_blu + .99;
% uw_col.g_mean_bsf_grn_1 = -7.14 * uw_col.mean_bsf_grn .^3 + 7.46 * uw_col.mean_bsf_grn .^2 -3.96*uw_col.mean_bsf_grn + .99;
% uw_col.g_mean_bsf_red_1 = -7.14 * uw_col.mean_bsf_red .^3 + 7.46 * uw_col.mean_bsf_red .^2 -3.96*uw_col.mean_bsf_red + .99;


% %Plot ssa
% figure; plot(serial2Hh(uw.time(uw.X)), uw.ssa_red(uw.X), 'r',serial2Hh(uw.time(~uw.X)), uw.ssa_red(~uw.X), 'rx',serial2Hh(uw.time(uw.X)), uw.ssa_grn(uw.X), 'g',serial2Hh(uw.time(~uw.X)), uw.ssa_grn(~uw.X), 'gx' ,serial2Hh(uw.time(uw.X)), uw.ssa_blu(uw.X), 'b',serial2Hh(uw.time(~uw.X)), uw.ssa_blu(~uw.X), 'bx' );
% title(['SSA vs time for ', datestr(uw.time(1),29) ]);
% xlabel('time (UTC)');
% ylabel('SSA');
% v = axis;
% axis([v(1), v(2), 0.85, 1])
%
status = i_write_data_files(uw_filtered, uw_col, uw);
i_quicklooks(uw_filtered, uw_col, uw);

disp(['finished with: ', fname]);
end


function i_quicklooks(uw_filtered, uw_col, uw)
pname = uw_filtered.pname;
ssa_plot_min = 0;
ssa_plot_max = 1.1;
g_plot_min = 0;
g_plot_max = 1.1;

max_alt = max(uw.alt);

fig1 = figure; 
subplot(2,1,1); 
plot(serial2Hh(uw.time(uw.X)), uw.tscat_red_amb(uw.X), 'r.',serial2Hh(uw.time(uw.X)), uw.tscat_grn_amb(uw.X), 'g.',serial2Hh(uw.time(uw.X)), uw.tscat_blu_amb(uw.X), 'b.')
title(['Aerosol total scattering on: ', datestr(uw.time(1),29) ]);
ylabel('total scattering (1/Mm)');
subplot(2,1,2);
plot(serial2Hh(uw.time(uw.X)), uw.bap_red_amb(uw.X), 'r.',serial2Hh(uw.time(uw.X)), uw.bap_grn_amb(uw.X), 'g.',serial2Hh(uw.time(uw.X)), uw.bap_blu_amb(uw.X), 'b.');
title(['Aerosol absorption ']);
xlabel('time (UTC)');
ylabel('absorption (1/Mm)');
v = axis;
graph_name = 'tscat_abs_vs_time.';
full_file_name = [pname, 'processed\', datestr(uw.time(1),'yyyymmdd.'),datestr(uw.time(1),'HHMMSS.'),graph_name,'png'];
print('-dmeta', full_file_name);

fig2 = figure; 
subplot(2,1,1); 
plot( uw.tscat_red_amb(uw.X),uw.alt(uw.X), 'r.', uw.tscat_grn_amb(uw.X),(uw.alt(uw.X)), 'g.', uw.tscat_blu_amb(uw.X),uw.alt(uw.X), 'b.')
title(['Aerosol total scattering on: ', datestr(uw.time(1),29) ]);
xlabel('total scattering (1/Mm)');
ylabel('Altitude (km msl)')
subplot(2,1,2);
plot( uw.bap_red_amb(uw.X),uw.alt(uw.X), 'r.', uw.bap_grn_amb(uw.X),(uw.alt(uw.X)), 'g.', uw.bap_blu_amb(uw.X),uw.alt(uw.X), 'b.')
title(['Aerosol absorption ']);
ylabel('Altitude (km msl)')
xlabel('absorption (1/Mm)');
v = axis;
graph_name = 'tscat_abs_vs_alt.';
full_file_name = [pname, 'processed\', datestr(uw.time(1),'yyyymmdd.'),datestr(uw.time(1),'HHMMSS.'),graph_name,'png'];
print('-dmeta', full_file_name);

fig3 = figure; 
subplot(2,1,1); 
plot( uw.tscat_red_amb(uw.X),uw.alt(uw.X), 'r.', uw.tscat_grn_amb(uw.X),(uw.alt(uw.X)), 'g.', uw.tscat_blu_amb(uw.X),uw.alt(uw.X), 'b.', ...
    uw.bscat_red_amb(uw.X),uw.alt(uw.X), 'r.', uw.bscat_grn_amb(uw.X),(uw.alt(uw.X)), 'g.', uw.bscat_blu_amb(uw.X),uw.alt(uw.X), 'b.');
title(['Aerosol total scatter and backscatter on: ', datestr(uw.time(1),29) ]);
xlabel('scattering (1/Mm)');
ylabel('Altitude (km msl)')
subplot(2,1,2);
plot( uw.bsf_red(uw.X),uw.alt(uw.X), 'r.', uw.bsf_grn(uw.X),(uw.alt(uw.X)), 'g.', uw.bsf_blu(uw.X),uw.alt(uw.X), 'b.')
title(['Aerosol backscatter fraction']);
ylabel('Altitude (km msl)')
xlabel('backscatter fraction (unitless)');
v = axis;
graph_name = 'bsf_vs_alt.';
full_file_name = [pname, 'processed\', datestr(uw.time(1),'yyyymmdd.'),datestr(uw.time(1),'HHMMSS.'),graph_name,'png'];
print('-dmeta', full_file_name);


fig1 = figure; plot(serial2Hh(uw.time(uw.X)), uw.ssa_red(uw.X), 'r.',serial2Hh(uw.time(uw.X)), uw.ssa_grn(uw.X), 'g.',serial2Hh(uw.time(uw.X)), uw.ssa_blu(uw.X), 'b.');
title(['SSA vs time for ', datestr(uw.time(1),29) ]);
xlabel('time (UTC)');
ylabel('SSA');
v = axis;
axis([v(1), v(2), ssa_plot_min, ssa_plot_max])
graph_name = 'SSA_vs_time.';
full_file_name = [pname, 'processed\', datestr(uw.time(1),'yyyymmdd.'),datestr(uw.time(1),'HHMMSS.'),graph_name,'png'];
print('-dmeta', full_file_name);

fig2 = figure; plot(uw.ssa_red(uw.X),uw.alt(uw.X), 'r.', uw.ssa_grn(uw.X),uw.alt(uw.X), 'g.', uw.ssa_blu(uw.X),uw.alt(uw.X), 'b.');
title(['SSA vs altitude for ', datestr(uw.time(1),29), ]);
xlabel('SSA');
ylabel('altitude (km)');
axis([ssa_plot_min,ssa_plot_max , 0, ceil(max_alt)])
graph_name = 'SSA_vs_alt.';
full_file_name = [pname, 'processed\', datestr(uw.time(1),'yyyymmdd.'),datestr(uw.time(1),'HHMMSS.'),graph_name,'png'];
print('-dmeta', full_file_name);
%Now plot g

% figure; plot(serial2Hh(uw.time(uw.X)), uw.g_red(uw.X), 'r',serial2Hh(uw.time(~uw.X)), uw.g_red(~uw.X), 'rx',serial2Hh(uw.time(uw.X)), uw.g_grn(uw.X), 'g',serial2Hh(uw.time(~uw.X)), uw.g_grn(~uw.X), 'gx' ,serial2Hh(uw.time(uw.X)), uw.g_blu(uw.X), 'b',serial2Hh(uw.time(~uw.X)), uw.g_blu(~uw.X), 'bx' );
% title(['Asymmetry parameter g vs time for ', datestr(uw.time(1),29) ]);
% xlabel('time (UTC)');
% ylabel('asymmetry parameter g');
% v = axis;
% axis([v(1), v(2), 0.5, 1])

fig3 = figure; plot(serial2Hh(uw.time(uw.X)), uw.g_red(uw.X), 'r.',serial2Hh(uw.time(uw.X)), uw.g_grn(uw.X), 'g.',serial2Hh(uw.time(uw.X)), uw.g_blu(uw.X), 'b.');
title(['Asymmetry parameter g vs time for ', datestr(uw.time(1),29) ]);
xlabel('time (UTC)');
ylabel('asymmetry parameter g');
v = axis;
axis([v(1), v(2),g_plot_min,g_plot_max ])
graph_name = 'g_vs_time.';
full_file_name = [pname, 'processed\', datestr(uw.time(1),'yyyymmdd.'),datestr(uw.time(1),'HHMMSS.'),graph_name,'png'];
print('-dmeta', full_file_name);

fig4 = figure; plot(uw.g_red(uw.X),uw.alt(uw.X), 'r.', uw.g_grn(uw.X),uw.alt(uw.X), 'g.', uw.g_blu(uw.X),uw.alt(uw.X), 'b.');
title(['Asymmetry parameter g vs altitude for ', datestr(uw.time(1),29), ]);
xlabel('asymmetry parameter g');
ylabel('altitude (km)');
axis([g_plot_min,g_plot_max , 0, ceil(max_alt)])
graph_name = 'g_vs_alt.';
full_file_name = [pname, 'processed\', datestr(uw.time(1),'yyyymmdd.'),datestr(uw.time(1),'HHMMSS.'),graph_name,'png'];
print('-dmeta', full_file_name);

figure(fig4);figure(fig3);figure(fig2); figure(fig1);

% close('all')
end

function [status] = i_write_data_files(uw_filtered, uw_col, uw);
pname = uw_filtered.pname;
day_frac = serial2doy0(uw.time(uw.X))-floor(serial2doy0(uw.time(uw.X)));
out_by_time = [day_frac, uw.alt(uw.X)];
out_by_time = [out_by_time, uw.g_red(uw.X), uw.g_grn(uw.X), uw.g_blu(uw.X)];
out_by_time = [out_by_time, uw.ssa_red(uw.X), uw.ssa_grn(uw.X), uw.ssa_blu(uw.X)];
out_by_time = [out_by_time, uw.ext_red(uw.X), uw.ext_grn(uw.X), uw.ext_blu(uw.X)];
out_by_time = [out_by_time, uw.bsf_red(uw.X),uw.bsf_grn(uw.X),uw.bsf_blu(uw.X)];
out_by_time = [out_by_time, uw.bap_red_amb(uw.X), uw.bap_grn_amb(uw.X), uw.bap_blu_amb(uw.X)];
out_by_time = [out_by_time, uw.tscat_red_amb(uw.X), uw.tscat_grn_amb(uw.X), uw.tscat_blu_amb(uw.X)];
out_by_time = [out_by_time, uw.bscat_red_amb(uw.X), uw.bscat_grn_amb(uw.X), uw.bscat_blu_amb(uw.X)];

out_by_alt = out_by_time(uw.alt_ind,[2,1,3:end]);


full_file_name = [uw_filtered.pname, 'processed\', 'twin_otter_iap.',datestr(uw.time(1),'yyyymmdd.'), datestr(uw.time(1),'HHMMSS.'),'vs_time.txt'];
save(full_file_name, '-ascii','-tabs', 'out_by_time');

full_file_name = [pname, 'processed\', 'twin_otter_iap.', datestr(uw.time(1),'yyyymmdd.'),datestr(uw.time(1),'HHMMSS.'),'vs_alt.txt'];
save(full_file_name, '-ascii','-tabs', 'out_by_alt');

full_file_name = [pname, 'processed\', 'twin_otter_iap.', datestr(uw.time(1),'yyyymmdd.'),datestr(uw.time(1),'HHMMSS.'),'column.txt'];
 V = datevec(mean(uw.time([1,end])));
 yyyy = V(:,1);
 mm = V(:,2);
 dd = V(:,3);
 HH = V(:,4);
 MM = V(:,5);
 SS = V(:,6);
 doy0 = serial2doy0(mean(uw_filtered.time([1,end])))';
 HHhh = (doy0 - floor(doy0)) *24;
 txt_out = [yyyy, mm, dd, HH, MM, SS, doy0, HHhh, ...
     uw_col.tscat_blu, uw_col.tscat_grn, uw_col.tscat_red, ...
     uw_col.bap_blu, uw_col.bap_grn, uw_col.bap_red, ...
     uw_col.ext_blu, uw_col.ext_grn, uw_col.ext_red, ...
     uw_col.ssa_blu, uw_col.ssa_grn, uw_col.ssa_red, ...
     uw_col.mean_ssa_blu, uw_col.mean_ssa_grn, uw_col.mean_ssa_red, ...
     uw_col.bscat_blu, uw_col.bscat_grn, uw_col.bscat_red, ...
     uw_col.bsf_blu, uw_col.bsf_grn, uw_col.bsf_red, ...
     uw_col.g_blu_1, uw_col.g_grn_1, uw_col.g_red_1, ...
     uw_col.g_blu_2, uw_col.g_grn_2, uw_col.g_red_2, ...
     uw_col.mean_g_blu, uw_col.mean_g_grn, uw_col.mean_g_red];
 fid = fopen([full_file_name],'wt');
fprintf(fid, '%s ','yyyy, mm, dd, HH, MM, SS, doy0, HHhh, ') ;
fprintf(fid, '%s ', 'tscat_blu, tscat_grn, tscat_red, ');
fprintf(fid, '%s ', 'bap_blu, bap_grn, bap_red, ');
fprintf(fid, '%s ', 'ext_blu, ext_grn, ext_red, ');
fprintf(fid, '%s ', 'ssa_blu, ssa_grn, ssa_red, ');
fprintf(fid, '%s ', 'mean_ssa_blu, mean_ssa_grn, mean_ssa_red, ');
fprintf(fid, '%s ', 'bscat_blu, bscat_grn, bscat_red, ');
fprintf(fid, '%s ', 'bsf_blu, bsf_grn, bsf_red, ');
fprintf(fid, '%s ', 'g_blu_1, g_grn_1, g_red_1, ');
fprintf(fid, '%s ', 'g_blu_2, g_grn_2, g_red_2, ');
fprintf(fid, '%s \n', 'mean_g_blu, mean_g_grn, mean_g_red');
fprintf(fid,'%d, %d, %d, %d, %d, %d, %3.6f, %2.4f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f \n',txt_out');
 fclose(fid);
status = 1;
end
