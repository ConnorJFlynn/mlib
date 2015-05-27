function ann = nsa_yearly_aod_screen_3c

% Select a file from a desired directory.
% For all files in this directory, 
% Strip unnecessary fields
% Add new QC definition, but don't populate it.
% % Save resulting daily subset files in a subdirectory named for the year.
% 
% % For all files in the year subdirectory, read and concat.
% 
% % Then evaluate resutls of new screen.
% 
% % Step 1: strip out unneeded info, add new QC tests to AOD and angstrom
% 
% % First, create subset of monthly data with fewer fields
% % remove all direct_horiz and qc_direct_horiz
% % remove all filter 1 3 4 6
% % remove all total_optical_depth
% mfr = getfullname_('*mfr*.cdf','nimfr','Select an NIMFR file from the directory you want to process.');
% [pname, fname, ext] = fileparts(mfr);
% pname = [pname, filesep];
% subdir = [pname, 'subdir',filesep];
% if ~exist([pname, 'subdir'],'dir')
%     mkdir([pname, 'subdir']);
% end
% catdir = [pname, 'catdir',filesep];
% if ~exist([pname, 'catdir'],'dir')
%     mkdir([pname, 'catdir']);
% end
% 
% [ds,part] = strtok(fname,'.'); [dl,part] = strtok(part,'.'); [yearstr,part] = strtok(part,'.');
% 
% files = dir([pname, ds,'.',dl,'.*',ext]);
% for f = 1:length(files)
%     in = ancload([pname, files(f).name]);
%     in.fname = [subdir,files(f).name];
%     if isfield(in.dims, 'bench_angle')
%     in.dims = rmfield(in.dims, 'bench_angle');
%     end
%     if isfield(in.dims, 'wavelength')
%     in.dims = rmfield(in.dims, 'wavelength');
%     end
%     fields = fieldnames(in.vars);
%     for fld = length(fields):-1 :1
%         field =fields{fld};
%         if ~isempty(strfind(field,'direct_hor'))||~isempty(strfind(field,'total_optical'))||~isempty(strfind(field,'filter1'))...
%                 || ~isempty(strfind(field,'filter3'))||~isempty(strfind(field,'filter4'))||~isempty(strfind(field,'filter6'))...
%                 ||~isempty(strfind(field,'broadband'))||~isempty(strfind(field,'normalized_transmittance'))...
%                 ||~isempty(strfind(field,'wavelength_filter'))||~isempty(strfind(field,'wavelength_filter'))...
%                 ||~isempty(strfind(field,'_raw'))||~isempty(strfind(in.vars.(field).dims{:},'wavelength'))...
%                 ||~isempty(strfind(field,'bench_angle'))||~isempty(strfind(field,'Ozone'))...
%                 ||~isempty(strfind(field,'logger'))||~isempty(strfind(field,'head'))...
%                 ||~isempty(strfind(field,'Rayleigh'))||~isempty(strfind(field,'sun_to_earth'))...
%                 ||~isempty(strfind(field,'_we_'))||~isempty(strfind(field,'_sn_'))...
%                 ||~isempty(strfind(field,'diffuse'))||~isempty(strfind(field,'hemisp'))
%             in.vars = rmfield(in.vars,field);
%         end
%     end
%     in.vars.Tr_filter2 = in.vars.direct_normal_narrowband_filter2;
%     in.vars.Tr_filter2.atts.long_name.data = 'Line-of-sight atmospheric transmittance, Filter 2';
%     in.vars.Tr_filter2.atts.units.data = 'unitless';
%     %%
%     in.vars.Tr_filter2.data = in.vars.direct_normal_narrowband_filter2.data./sscanf(in.atts.filter2_TOA_direct_normal.data,'%g');
%     bad_Tr = in.vars.airmass.data<1|in.vars.elevation_angle.data<=0;
% %     figure; 
% %     ax(1) = subplot(2,1,1); 
% %     plot(serial2doy(in.time), in.vars.airmass.data, 'g.',...
% %         serial2doy(in.time(in.vars.airmass.data<1)), in.vars.airmass.data(in.vars.airmass.data<1),'r.')
% %         
% %     ax(2) = subplot(2,1,2);
% %         plot(serial2doy(in.time), in.vars.elevation_angle.data, 'g.',...
% %         serial2doy(in.time(in.vars.elevation_angle.data<0)), in.vars.airmass.data(in.vars.elevation_angle.data<0),'r.',...
% %         serial2doy(in.time(in.vars.elevation_angle.data>90)), in.vars.airmass.data(in.vars.elevation_angle.data>90),'k.');
% %     linkaxes(ax,'x')
%     
%     %%
% 
%     
%     in.vars.Tr_filter2.data(bad_Tr) = NaN;
%     qc_test.description = 'Tr_filter2 < 0.01';
%     qc_test.assessment = 'Bad';
% %     qc_test.value = in.vars.Tr_filter2.data<0.01;
%     qc_test.value = false;
%     
% %     qc_test.value = false;
% %      Bad_AOD_filter2 = in.vars.qc_aerosol_optical_depth_filter2.data>0;
%     [in.vars.qc_aerosol_optical_depth_filter2,bit] = vqc_addtest(in.vars.qc_aerosol_optical_depth_filter2,qc_test);
%     [in.vars.qc_aerosol_optical_depth_filter5,bit] = vqc_addtest(in.vars.qc_aerosol_optical_depth_filter5,qc_test);
%     [in.vars.qc_angstrom_exponent,bit] = vqc_addtest(in.vars.qc_angstrom_exponent,qc_test);
% 
%     
% %     plot_qcs(in);
%         %%
%     in.quiet = true;
%     in = anccheck(in); 
%     in.clobber = true;  
%     disp(['Writing ',files(f).name, ' , ',num2str(f),' of ',num2str(length(files))]);
%     ancsave(in);
% end
% disp('Done!')      
% clear in
% % Next, read and concat contents of yyyy directory.
% files = dir([subdir, '*.cdf']);
% nc = ancload([subdir, files(1).name]);
% for f = 2:length(files)
%     disp(['Reading ',num2str(f), ' of ',num2str(length(files))])
%     nc = anccat(nc, ancload([subdir, files(f).name]));
% end
% %
% nc.fname = [catdir,files(1).name];
% %
% nc = anccheck(nc);
% %
% nc.quiet = true;
% disp(['Writing ',nc.fname]);
% ancsave(nc);
% disp('Done!')
% 

%%
infile = getfullname_('*.cdf','aod_cat','Select the annual aod file.');
nc = ancload(infile);
%%

 nc.vars.Tr_filter2.data = nc.vars.direct_normal_narrowband_filter2.data./sscanf(nc.atts.filter2_TOA_direct_normal.data,'%g');
 %

% At this point, we have created a subset file with appropriate QC
% definitions, and concatenated the results into a single file, but have
% not evaluated the QC test.
%
% plot_qcs(nim);
% Clean up existing QC error with isolated variability flags at 00:00 UTC
% These tests are in AOD QC bits 3 and 7
% Clean this up for filter2
qc = nc.vars.qc_aerosol_optical_depth_filter2;
vari = bitget(uint32(qc.data),3);  %Test "3" for questionable variability
vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
qc.data = bitset(uint32(qc.data), 3,vari);

vari = bitget(uint32(qc.data),7); %Test "7" for 'bad' variability
vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
qc.data = bitset(uint32(qc.data), 3,vari);
nc.vars.qc_aerosol_optical_depth_filter2 = qc;


% Clean this up for filter5
qc = nc.vars.qc_aerosol_optical_depth_filter5;
vari = bitget(uint32(qc.data),3);  %Test "3" for questionable variability
vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
qc.data = bitset(uint32(qc.data), 3,vari);

vari = bitget(uint32(qc.data),7); %Test "7" for 'bad' variability
vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
qc.data = bitset(uint32(qc.data), 3,vari);
nc.vars.qc_aerosol_optical_depth_filter5 = qc;

% Clean this up for Angstrom Exponent
qc = nc.vars.qc_angstrom_exponent;
vari = bitget(uint32(qc.data),2);  %Test "2" for questionable variability
vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
qc.data = bitset(uint32(qc.data), 3,vari);

vari = bitget(uint32(qc.data),5); %Test "5" for 'bad' variability
vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
qc.data = bitset(uint32(qc.data), 3,vari);
nc.vars.qc_angstrom_exponent = qc;

% nc.vars.qc_aerosol_optical_depth_filter2.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter2.data)	, 12,false);
% nc.vars.qc_aerosol_optical_depth_filter5.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter5.data)	, 12,false);
% nc.vars.qc_angstrom_exponent.data = bitset(uint32(nc.vars.qc_angstrom_exponent.data), 9,false);
%


% At this point we've fixed the existing variability test but have not
% applied the new QC test.

% Populating Boolean T/F arrays
filter2_qc = nc.vars.qc_aerosol_optical_depth_filter2.data >0; % good when ~filter_qc
filter5_qc = nc.vars.qc_aerosol_optical_depth_filter5.data >0;
ang_qc = nc.vars.qc_angstrom_exponent.data > 0; % good when ~ang_qc
Tr_test = real(log10(nc.vars.Tr_filter2.data))<log10(.01);  % good when ~Tr_test

%
tr_ii = 0;
good_pts = []; stripped_pts = [];

tr_range = [0.00001:0.0001:.2];
tr_range = logspace(-8,0,1000);
% tr_range = [0.01];
for tr_ = tr_range
tr_ii = tr_ii+1;

Tr_test = nc.vars.Tr_filter2.data<tr_;  % good when ~Tr_test

nc.vars.qc_aerosol_optical_depth_filter2.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter2.data), 12,Tr_test);
nc.vars.qc_aerosol_optical_depth_filter5.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter5.data), 12,Tr_test);
good_pts(tr_ii) = sum((~filter2_qc& ~Tr_test)); % These are the green points that are in fact pretty good
stripped_pts(tr_ii) = sum((~filter2_qc)& ~(~filter2_qc& ~Tr_test)); % These are the red points that have now been successfully excluded
end
%%

[~,fstem,ext]= fileparts(nc.fname);
figure
plot(tr_range , stripped_pts,'-o');
xlabel('Transmittance cut-off');
ylabel('Points excluded')
title(fstem,'interp','none')
zoom('on')

figure
plot(-log(tr_range) , stripped_pts,'-o' );
xlabel('Equivalent slant path OD');
ylabel('Delta of points excluded')
title(fstem,'interp','none')
zoom('on')

figure
plot(tr_range , good_pts,'-o');
xlabel('Transmittance cut-off');
ylabel('Good Points')
title(fstem,'interp','none')
zoom('on')

% %%
% % The figure below is using the T/F arrays to select only those values
% % corresponding to the T/F states in the arrays.
% % The "~" symbol is negation
% %%

nc = ancload;
%%
filter2_qc = nc.vars.qc_aerosol_optical_depth_filter2.data >0; % good when ~filter_qc
filter5_qc = nc.vars.qc_aerosol_optical_depth_filter5.data >0;
ang_qc = nc.vars.qc_angstrom_exponent.data > 0; % good when ~ang_qc
Tr_test = real(log10(nc.vars.Tr_filter2.data))<log10(.01);  % good when ~Tr_test
Tr_test = nc.vars.Tr_filter2.data<0.04;  % good when ~Tr_test
% for d = floor(datenum(2006,1,1)):ceil(datenum(2006,12,31))
bad_qc = qc_impacts(nc.vars.qc_aerosol_optical_depth_filter2)>0;
nc.vars.aerosol_optical_depth_filter2.data(bad_qc) = NaN;
bad_qc = qc_impacts(nc.vars.qc_aerosol_optical_depth_filter5)>0;
nc.vars.aerosol_optical_depth_filter5.data(bad_qc) = NaN;
bad_qc = qc_impacts(nc.vars.qc_angstrom_exponent)>0;
nc.vars.angstrom_exponent.data(bad_qc) = NaN;
doy = serial2doy(nc.time);
first_day = floor(min(doy));
last_day = floor(max(doy));
days = last_day - first_day + 1;


nc_.vars.qc_aerosol_optical_depth_filter2 = nc.vars.qc_aerosol_optical_depth_filter2;
nc_.vars.qc_aerosol_optical_depth_filter5 = nc.vars.qc_aerosol_optical_depth_filter5;
nc_.vars.qc_angstrom_exponent = nc.vars.qc_angstrom_exponent;
nc_.vars.qc_aerosol_optical_depth_filter2.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter2.data), 12,Tr_test);
nc_.vars.qc_aerosol_optical_depth_filter5.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter5.data), 12,Tr_test);
bad_qc = qc_impacts(nc_.vars.qc_aerosol_optical_depth_filter2)>0;
nc_.vars.aerosol_optical_depth_filter2.data = nc.vars.aerosol_optical_depth_filter2.data;
nc_.vars.aerosol_optical_depth_filter2.data(bad_qc) = NaN;
bad_qc = qc_impacts(nc_.vars.qc_aerosol_optical_depth_filter5)>0;
nc_.vars.aerosol_optical_depth_filter5.data =nc.vars.aerosol_optical_depth_filter5.data;
nc_.vars.aerosol_optical_depth_filter5.data(bad_qc) = NaN;
bad_qc = (qc_impacts(nc_.vars.qc_aerosol_optical_depth_filter2)>0)|(qc_impacts(nc_.vars.qc_aerosol_optical_depth_filter5)>0);
nc_.vars.angstrom_exponent.data =nc.vars.angstrom_exponent.data;
nc_.vars.angstrom_exponent.data(bad_qc) = NaN;
for d = days:-1:1;
   day = (doy >= (first_day -1 + d)) & (doy < (first_day +d));
   orig.time(d) = mean(doy(day));
   orig.aod_500(d) = meannonan(nc.vars.aerosol_optical_depth_filter2.data(day));
   orig.aod_870(d) = meannonan(nc.vars.aerosol_optical_depth_filter5.data(day));
   orig.ang(d) = meannonan(nc.vars.angstrom_exponent.data(day));
   scrn.time(d) = mean(doy(day));
   scrn.aod_500(d) = meannonan(nc_.vars.aerosol_optical_depth_filter2.data(day));
   scrn.aod_870(d) = meannonan(nc_.vars.aerosol_optical_depth_filter5.data(day));
   scrn.ang(d) = meannonan(nc_.vars.angstrom_exponent.data(day));

   disp(d)
end
%%
figure; 
ax(1) = subplot(2,1,1);
aa = plot(serial2doy(orig.time), orig.aod_500,'ro',serial2doy(scrn.time), scrn.aod_500,'go');
title(['Daily averages: ',datestr(mean(nc.time),'yyyy')]);
ylabel('AOD');
ax(2) = subplot(2,1,2);
bb = plot(serial2doy(orig.time), orig.ang,'ro',serial2doy(scrn.time), scrn.ang,'go');
ylabel('AE');
xlabel('time [day of year]');
set(aa(1),'markersize',4,'markerfaceColor','r');
set(aa(2),'markersize',4,'markerfaceColor','g');
set(bb(1),'markersize',4,'markerfaceColor','r');
set(bb(2),'markersize',4,'markerfaceColor','g');
[pname, fname, ext] = fileparts(nc.fname); pname = [pname, filesep];
% saveas(gcf,[pname, 'daily_avgs_',datestr(mean(nc.time),'yyyy'),'.fig']);
%%
% figure; plot(serial2doy(nc_days.time), nc_days.vars.aerosol_optical_depth_filter5.data,'ro');
% figure; plot(serial2doy(nc_days.time), nc_days.vars.angstrom_exponent.data,'kx');
% %%
% 
% %%
figure; 
sb(1) = subplot(2,1,1);
plot(serial2doy(nc.time(~filter2_qc)), nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc), 'r.',...
    serial2doy(nc.time(~filter2_qc & ~Tr_test)), nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc& ~Tr_test), 'g.');
[pn,filename,ext] = fileparts(nc.fname);
title(filename);
legend('bad','good');
ylabel('AOD');
xlabel('time [day of year]');

%Tr_test = nc.vars.Tr_filter2.data<tr_;  % good when ~Tr_test

sb(2) = subplot(2,1,2);
%plot(serial2doy(nc.time(~(ang_qc|filter2_qc))), nc.vars.angstrom_exponent.data(~(ang_qc|filter2_qc)), 'r.',...
%    serial2doy(nc.time(~(ang_qc|filter2_qc|Tr_test))), nc.vars.angstrom_exponent.data(~(ang_qc|filter2_qc|Tr_test)), 'g.')
plot(serial2doy(nc.time(~(ang_qc|filter2_qc))), nc.vars.Tr_filter2.data(~(ang_qc|filter2_qc)), 'r.',...
    serial2doy(nc.time(~(ang_qc|filter2_qc|Tr_test))), nc.vars.Tr_filter2.data(~(ang_qc|filter2_qc|Tr_test)), 'g.')
legend('bad','good');
ylabel('angstrom');
xlabel('time [day of year]');
linkaxes(sb,'x')
% 
% %%
% without_Tr_test = nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc);
% %[wo_Tr_N, bins] = hist(log10(without_Tr_test),50);
% xcenters = -2:0.05:0.5;
% [wo_Tr_N, bins] = hist(log10(without_Tr_test),xcenters);
% figure(99);
% bar(bins, log10(wo_Tr_N));
% title('Here is the PDF before applying the Tr Test')
% 
% %%
% with_Tr_test = nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc&~Tr_test);
% %[w_Tr_N, bins] = hist(log10(with_Tr_test),50);
% xcenters = -2:0.05:0.5;
% [w_Tr_N, bins] = hist(log10(with_Tr_test),xcenters);
% figure(199);
% bar(bins, log10(w_Tr_N));
% title('Here is the PDF AFTER applying the Tr Test')
% %%
% 
% sum((~filter2_qc& ~Tr_test)) % These are the green points that are in fact pretty good
% sum((~filter2_qc)& ~(~filter2_qc& ~Tr_test)) % These are the red points that have now been successfully excluded
% 
% 100.*sum((~filter2_qc)& ~(~filter2_qc& ~Tr_test))./sum((~filter2_qc& ~Tr_test)) 
% %%
% nc.vars.qc_aerosol_optical_depth_filter2.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter2.data), 12,Tr_test);
% nc.vars.qc_aerosol_optical_depth_filter5.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter5.data), 12,Tr_test);
% nc.vars.qc_angstrom_exponent.data = bitset(uint32(nc.vars.qc_angstrom_exponent.data), 9,Tr_test)

% plot_qcs(nc);
return


