% From Ian:
% Lat:     40 27' 18.55021" = 40.45515;
% Lon:  -106 44' 40.03441" = -106.74445
% 3203 m = 10508.5 ft (via Google-Earth altitude...)

% stp_files = dir([stp_path, '*.txt'])
% stp_od = read_nrel_od([stp_path, stp_files(1).name]);
% stp_fields = fieldnames(stp_od);
% for f = length(stp_files):-1:2
%    tmp = read_nrel_od([stp_path, stp_files(f).name]);
%    [stp_od.time, inds] = unique([stp_od.time; tmp.time]);
%    for ff = 4:length(stp_fields)
%       dmp = [stp_od.(stp_fields{ff});tmp.(stp_fields{ff})];
%       stp_od.(stp_fields{ff}) = dmp(inds);
%    end
% end
%%

%!!
od = loadinto('C:\case_studies\StormPeak\head11\spl_od_all.mat');
%first multiply-screen the data.
%%
i = 0;
good = true(size(od.OD_500nm));
%%
i = i+1;
[good(good)] = hmadf_span(od.OD_500nm(good), 45, 2);
%repeat about 15 times to cull non-physical high values.
%%
figure; semilogy(od.time, od.OD_500nm,'r.',od.time(good), od.OD_500nm(good),'b.'); title(['good = ',num2str(sum(good))])
%%
% Next, use post-screen to recapture some of the culled data.
% Post-screen accepts point initially flagged bad if they don't exceed a
% MAD threshold of "good" points within the post-window.  Or if they are
% less than the hmean of nearby good points.
[post_good] =post_screen(od.time, od.OD_500nm, good,45,2);
figure; semilogy(od.time, od.OD_500nm,'r.',od.time(post_good), od.OD_500nm(post_good),'g.',od.time(good), od.OD_500nm(good),'b.'); title(['good = ',num2str(sum(good))])
%%
figure; plot(od.time(post_good), od.OD_860nm(post_good),'g.');
% Then pass through aod_screen or eps_screen.
%%
[aero, eps, aero_eps, mad, abs_dev] = aod_screen(od.time(post_good), od.OD_860nm(post_good),0, 1.5,45, 3, 1e-4,60,.02);
post_good_ii = find(post_good);
%%
figure; plot(od.time, od.OD_500nm,'b.',od.time(post_good_ii(eps<5e-5)), od.OD_500nm(post_good_ii(eps<5e-5)),'g.'); title(['good = ',num2str(sum(eps<1e-3))])
%%
od_fields = fieldnames(od);
od_out.(od_fields{1}) = od.(od_fields{1});
od_out.(od_fields{2}) = od.(od_fields{2});
for odf = 3:length(od_fields)
od_out.(od_fields{odf}) = od.(od_fields{odf})(post_good);
end
od_out.aero = aero;
od_out.eps = eps;
od_out.fname = [od_out.pname, 'spl_od_screened.mat'];
save(od_out.fname, 'od_out');

%!!
spl_path = 'C:\case_studies\StormPeak\head11\';
spl_od = loadinto([spl_path,'spl_od_screened.mat']);
%%

%%

bads = (spl_od.OD_415nm==0)|(spl_od.OD_500nm==0)|(spl_od.OD_610nm==0)...
|(spl_od.OD_665nm==0)|(spl_od.OD_860nm==0)|(spl_od.OD_940nm==0);
%%
od_fields = fieldnames(spl_od);
for odf = 3:length(od_fields)
spl_od.(od_fields{odf})(bads) = [];
end
%%
save(spl_od.fname, 'spl_od');

%%

tod_ray = loadinto('C:\matlib\tod_ray.mat');
o3_coef = loadinto('C:\matlib\o3_coef.mat');
% OD415 ,   OD500 ,   OD610 ,   OD665 ,   OD860 
cw = [415, 500, 610, 665, 860];
for i = 1:length(cw);
            raw_filter.nominal = cw(i);
            raw_filter.nm = tod_ray(:,1);
            raw_filter.T = gaussian(tod_ray(:,1),cw(i),10);
            trace{i} = process_mfr_filter(raw_filter);
            trace{i}.spc.tod_ray = interp1(tod_ray(:,1), tod_ray(:,2), trace{i}.nm, 'pchip',0);
            trace{i}.spc.o3_coef = interp1(o3_coef(:,1), o3_coef(:,2), trace{i}.nm, 'pchip',0);
            trace{i}.normed.tod_ray = trapz(trace{i}.nm, trace{i}.normed.T .* trace{i}.spc.tod_ray);
            trace{i}.normed.o3_coef = trapz(trace{i}.nm, trace{i}.normed.T .* trace{i}.spc.o3_coef);
end

% 1. Next, load and screen Ozone DU
stp_ozone = ancload(['C:\case_studies\StormPeak\stormpeak_ozone.cdf']);
NaNs = isNaN(stp_ozone.vars.ozone.data);
stp_ozone.vars.ozone.data(NaNs) = interp1(stp_ozone.time(~NaNs), stp_ozone.vars.ozone.data(~NaNs), stp_ozone.time(NaNs),'linear','extrap');

%2. Next load and screen pressure for airmass fraction.
stp_met = loadinto('C:\case_studies\StormPeak\met.mat');
erat = diff2(stp_met.pres);
n = 2 ;bad = ((abs(erat(2:end))>n)&((abs(erat(1:(end-1)))>n)|isNaN(erat(1:(end-1)))))|((abs(erat(1:(end-1)))>n)&((abs(erat(2:end))>n)|isNaN(erat(2:end))));
bad_ii = find(bad);
% figure; plot(stp_met.time, stp_met.pres,'-b.',stp_met.time(bad_ii), stp_met.pres(bad_ii), 'ro')
stp_met.pres(bad_ii) = NaN;
NaNs = isNaN(stp_met.pres);
stp_met.pres(NaNs) = interp1(stp_met.time(~NaNs), stp_met.pres(~NaNs), stp_met.time(NaNs),'linear','extrap');
%%
%Now we have screened time series of optical depth, ozone,and pressure with NaNs replaced
%by interpolated values. 
spl_fields =fieldnames(spl_od);
spl_od.trace = trace;

spl_od.pres = interp1(stp_met.time, stp_met.pres, spl_od.time, 'linear','extrap');
spl_od.ozone = interp1(stp_ozone.time,stp_ozone.vars.ozone.data, spl_od.time, 'nearest','extrap');
%%
spl_od.ray_OD_415nm = spl_od.trace{1}.normed.tod_ray .* spl_od.pres ./ 1013.25;
spl_od.ray_OD_500nm = spl_od.trace{2}.normed.tod_ray .* spl_od.pres ./ 1013.25;
spl_od.ray_OD_610nm = spl_od.trace{3}.normed.tod_ray .* spl_od.pres ./ 1013.25;
spl_od.ray_OD_665nm = spl_od.trace{4}.normed.tod_ray .* spl_od.pres ./ 1013.25;
spl_od.ray_OD_860nm = spl_od.trace{5}.normed.tod_ray .* spl_od.pres ./ 1013.25;

spl_od.O3_OD_415nm = spl_od.trace{1}.normed.o3_coef .* spl_od.ozone ./ 1000;
spl_od.O3_OD_500nm = spl_od.trace{2}.normed.o3_coef .* spl_od.ozone ./ 1000;
spl_od.O3_OD_610nm = spl_od.trace{3}.normed.o3_coef .* spl_od.ozone ./ 1000;
spl_od.O3_OD_665nm = spl_od.trace{4}.normed.o3_coef .* spl_od.ozone ./ 1000;
spl_od.O3_OD_860nm = spl_od.trace{5}.normed.o3_coef .* spl_od.ozone ./ 1000;

spl_od.AOD_415nm = spl_od.OD_415nm -spl_od.ray_OD_415nm -spl_od.O3_OD_415nm;
spl_od.AOD_500nm = spl_od.OD_500nm -spl_od.ray_OD_500nm -spl_od.O3_OD_500nm;
spl_od.AOD_610nm = spl_od.OD_610nm -spl_od.ray_OD_610nm -spl_od.O3_OD_610nm;
spl_od.AOD_665nm = spl_od.OD_665nm -spl_od.ray_OD_665nm -spl_od.O3_OD_665nm;
spl_od.AOD_860nm = spl_od.OD_860nm -spl_od.ray_OD_860nm -spl_od.O3_OD_860nm;
%%

spl_od.ang_415_860 = (log(spl_od.AOD_415nm)-log(spl_od.AOD_860nm))./log(860/415);
spl_od.ang_500_860 = (log(spl_od.AOD_500nm)-log(spl_od.AOD_860nm))./log(860/500);
%%
spl_od.all_pos = (spl_od.AOD_415nm>0)&(spl_od.AOD_500nm>0)&(spl_od.AOD_610nm>0)&(spl_od.AOD_665nm>0)&(spl_od.AOD_860nm>0);
%%
figure; 
xx(1)= subplot(2,1,1); 
plot(spl_od.time(spl_od.all_pos&(spl_od.eps<5e-5)), [spl_od.AOD_415nm(spl_od.all_pos&(spl_od.eps<5e-5)), spl_od.AOD_500nm(spl_od.all_pos&(spl_od.eps<5e-5)), spl_od.AOD_860nm(spl_od.all_pos&(spl_od.eps<5e-5))],'.');
legend('415 nm','500 nm','860 nm');
ylabel('aod');
xlabel('time (year)')
title('Aerosol optical depths at Storm Peaks Laboratories from 1999 to 2008');
datetick('keeplimits');
xx(2)= subplot(2,1,2); 
plot(spl_od.time(spl_od.all_pos&(spl_od.eps<5e-5)), [spl_od.ang_415_860(spl_od.all_pos&(spl_od.eps<5e-5)),spl_od.ang_500_860(spl_od.all_pos&(spl_od.eps<5e-5))],'.');
lg = legend('ang(415nm/860nm)','ang(500nm/860nm');
xlabel('time (year)')
ylabel('alpha')
title('Angstrom exponents (alpha)')
set(lg,'interp','none')
datetick('keeplimits')
linkaxes(xx,'x')
%%
datetick(xx(1),'keeplimits');
datetick(xx(2),'keeplimits');
%%

% Output year, month, day, hour, minute, sza, airmass,               % 7
% AOD_415nm, AOD_500nm, AOD_610nm, AOD_665nm, AOD_860nm,             % 5
% Ang_415_860, Ang_500_860, all_pos, aero, eps, pres_mB, ozone_DU     % 7
% OD_415nm, OD_500nm, OD_610nm, OD_665nm, OD_860nm, OD_940nm         % 6
% O3_OD_415nm, O3_OD_500nm, O3_OD_610nm, O3_OD_665nm, O3_OD_860nm    % 5
% Ray_OD_415nm, Ray_OD_500nm, Ray_OD_610nm, Ray_OD_665nm, Ray_OD_860nm    % 5

%
header_row = ['yyyy, mm, dd, HH, MM, sza, airmass, ']; %7
header_row = [header_row, 'aod_415nm, aod_500nm, aod_610nm, aod_665nm, aod_860nm, ']; %5
header_row = [header_row, 'Ang_415_860, Ang_500_860, all_pos, aero, eps, pres_mB, ozone_DU, ']; %7
header_row = [header_row, 'od_415nm, od_500nm, od_610nm, od_665nm, od_860nm, od_940nm, ']; %6
header_row = [header_row, 'O3_OD_415nm, O3_OD_500nm, O3_OD_610nm, O3_OD_665nm, O3_OD_860nm, ']; %5
header_row = [header_row, 'Ray_OD_415nm, Ray_OD_500nm, Ray_OD_610nm, Ray_OD_665nm, Ray_OD_860nm']; %5
V = datevec(spl_od.time);
txt_out = [V(:,1), V(:,2), V(:,3), V(:,4), V(:,5), spl_od.sza, spl_od.airmass, ...
spl_od.AOD_415nm, spl_od.AOD_500nm, spl_od.AOD_610nm, spl_od.AOD_665nm, spl_od.AOD_860nm, ...
spl_od.ang_415_860, spl_od.ang_500_860, spl_od.all_pos, spl_od.aero, spl_od.eps, spl_od.pres, spl_od.ozone, ...
spl_od.OD_415nm, spl_od.OD_500nm, spl_od.OD_610nm, spl_od.OD_665nm, spl_od.OD_860nm, spl_od.OD_940nm, ...
spl_od.O3_OD_415nm, spl_od.O3_OD_500nm, spl_od.O3_OD_610nm, spl_od.O3_OD_665nm, spl_od.O3_OD_860nm, ...
spl_od.ray_OD_415nm, spl_od.ray_OD_500nm, spl_od.ray_OD_610nm, spl_od.ray_OD_665nm, spl_od.ray_OD_860nm]; 
%%

format_str = ['%d, %d, %d, %d, %d, %1.1f, %3.3f, ']; %7
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, %2.3f, '];%5
format_str = [format_str, '%2.3f, %2.3f, %d, %d, %2.3f, %2.3f, %2.3f,  '];%7
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, '];%6
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, %2.3f, '];%5
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, %2.3f \n'];%5
%%

fout = 'C:\case_studies\StormPeak\SPL_screened_aod.csv';
fid = fopen(fout,'w');
%

fprintf(fid,'%s \n',header_row );
status = fprintf(fid,format_str,txt_out');
fclose(fid)

%%

%
header_row = ['yyyy, mm, dd, HH, MM, sza, airmass, ']; %7
header_row = [header_row, 'aod_415nm, aod_500nm, aod_610nm, aod_665nm, aod_860nm, ']; %5
header_row = [header_row, 'Ang_415_860, Ang_500_860, eps, pres_mB, ozone_DU, ']; %5
header_row = [header_row, 'od_415nm, od_500nm, od_610nm, od_665nm, od_860nm, od_940nm, ']; %6
header_row = [header_row, 'O3_OD_415nm, O3_OD_500nm, O3_OD_610nm, O3_OD_665nm, O3_OD_860nm, ']; %5
header_row = [header_row, 'Ray_OD_415nm, Ray_OD_500nm, Ray_OD_610nm, Ray_OD_665nm, Ray_OD_860nm']; %5
V = datevec(spl_od.time);
txt_out = [V(:,1), V(:,2), V(:,3), V(:,4), V(:,5), spl_od.sza, spl_od.airmass, ...
spl_od.AOD_415nm, spl_od.AOD_500nm, spl_od.AOD_610nm, spl_od.AOD_665nm, spl_od.AOD_860nm, ...
spl_od.ang_415_860, spl_od.ang_500_860, spl_od.eps, spl_od.pres, spl_od.ozone, ...
spl_od.OD_415nm, spl_od.OD_500nm, spl_od.OD_610nm, spl_od.OD_665nm, spl_od.OD_860nm, spl_od.OD_940nm, ...
spl_od.O3_OD_415nm, spl_od.O3_OD_500nm, spl_od.O3_OD_610nm, spl_od.O3_OD_665nm, spl_od.O3_OD_860nm, ...
spl_od.ray_OD_415nm, spl_od.ray_OD_500nm, spl_od.ray_OD_610nm, spl_od.ray_OD_665nm, spl_od.ray_OD_860nm]; 
%
keep = spl_od.all_pos& spl_od.aero;
txt_out = txt_out(keep,:);

format_str = ['%d, %d, %d, %d, %d, %1.1f, %3.3f, ']; %7
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, %2.3f, '];%5
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, %2.3f,  '];%7
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, %2.3f, %2.3f, '];%6
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, %2.3f, '];%5
format_str = [format_str, '%2.3f, %2.3f, %2.3f, %2.3f, %2.3f \n'];%5
%

fout = 'C:\case_studies\StormPeak\SPL_pos_aero_aod.csv';
fid = fopen(fout,'w');
%

fprintf(fid,'%s \n',header_row );
status = fprintf(fid,format_str,txt_out');
fclose(fid)