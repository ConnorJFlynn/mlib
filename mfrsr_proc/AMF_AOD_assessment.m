% AMF AOD assessment, and news release

%% FKB plots

fkb = ancload(getfullname('*.cdf','amfaod')); % loads one file
fkb.vars = rmfield(fkb.vars, 'alltime_hemisp_broadband');

%%
tmp = ancload(getfullname('*.cdf','amfaod'));
tmp.vars = rmfield(tmp.vars, 'alltime_hemisp_broadband');

fkb = anccat(fkb,tmp); % concatenating two structures 
%%
% Screen out -9999 values as missing. Set to NaN to avoid plotting them.

missing = fkb.vars.aerosol_optical_depth_filter1.data<-9990 & fkb.vars.aerosol_optical_depth_filter1.data> -10000;
fkb.vars.aerosol_optical_depth_filter1.data(missing) = NaN;
missing = fkb.vars.aerosol_optical_depth_filter2.data<-9990 & fkb.vars.aerosol_optical_depth_filter2.data> -10000;
fkb.vars.aerosol_optical_depth_filter2.data(missing) = NaN;
missing = fkb.vars.aerosol_optical_depth_filter3.data<-9990 & fkb.vars.aerosol_optical_depth_filter3.data> -10000;
fkb.vars.aerosol_optical_depth_filter3.data(missing) = NaN;
missing = fkb.vars.aerosol_optical_depth_filter4.data<-9990 & fkb.vars.aerosol_optical_depth_filter4.data> -10000;
fkb.vars.aerosol_optical_depth_filter4.data(missing) = NaN;
missing = fkb.vars.aerosol_optical_depth_filter5.data<-9990 & fkb.vars.aerosol_optical_depth_filter5.data> -10000;
fkb.vars.aerosol_optical_depth_filter5.data(missing) = NaN;

missing = fkb.vars.angstrom_exponent.data<-9990 & fkb.vars.angstrom_exponent.data> -10000;
fkb.vars.angstrom_exponent.data(missing) = NaN;
%%
plots_ppt; % thickens lines and fonts for publication
figure;
s(1)= subplot(2,1,1);
plot(serial2doy(fkb.time), [fkb.vars.aerosol_optical_depth_filter1.data;fkb.vars.aerosol_optical_depth_filter2.data;...
fkb.vars.aerosol_optical_depth_filter3.data;fkb.vars.aerosol_optical_depth_filter4.data;...
fkb.vars.aerosol_optical_depth_filter5.data],'.');
legend('415 nm','500 nm', '615 nm','673 nm', '870 nm');
ylabel('aod');
grid('on');
s(2) = subplot(2,1,2);
plot(serial2doy(fkb.time), fkb.vars.angstrom_exponent.data,'k.');
ylabel('ang. exp.');
xlabel('time [day of year]');
grid('on');
linkaxes(s,'x')
%%
figure;
plots_default; % goes back to thin lines
N_edges = 50;
N_in = sum(~isNaN(fkb.vars.aerosol_optical_depth_filter2.data))
norm_factor = N_edges./N_in;
[N_out,x_out] = hist(fkb.vars.aerosol_optical_depth_filter2.data,N_edges);
figure; 
bb1=bar(x_out,N_out./trapz(x_out,N_out));

