function ann = nsa_yearly_aod_screen

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
mfr = getfullname('*mfr*.cdf','nimfr','Select an NIMFR file from the directory you want to process.');
[pname, fname, ext] = fileparts(mfr);
pname = [pname, filesep];
subdir = [pname, 'subdir',filesep];
if ~exist([pname, 'subdir'],'dir')
    mkdir([pname, 'subdir']);
end
catdir = [pname, 'catdir',filesep];
if ~exist([pname, 'catdir'],'dir')
    mkdir([pname, 'catdir']);
end

[ds,part] = strtok(fname,'.'); [dl,part] = strtok(part,'.'); [yearstr,part] = strtok(part,'.');

files = dir([pname, ds,'.',dl,'.*',ext]);
for f = 1:length(files)
    in = ancload([pname, files(f).name]);
    in.fname = [subdir,files(f).name];
    if isfield(in.dims, 'bench_angle')
    in.dims = rmfield(in.dims, 'bench_angle');
    end
    if isfield(in.dims, 'wavelength')
    in.dims = rmfield(in.dims, 'wavelength');
    end
    fields = fieldnames(in.vars);
    for fld = length(fields):-1 :1
        field =fields{fld};
        if ~isempty(strfind(field,'direct_hor'))||~isempty(strfind(field,'total_optical'))||~isempty(strfind(field,'filter6'))...
                ||~isempty(strfind(field,'broadband'))||~isempty(strfind(field,'normalized_transmittance'))...
                ||~isempty(strfind(field,'wavelength_filter'))||~isempty(strfind(field,'wavelength_filter'))...
                ||~isempty(strfind(field,'_raw'))||~isempty(strfind(in.vars.(field).dims{:},'wavelength'))...
                ||~isempty(strfind(field,'bench_angle'))||~isempty(strfind(field,'Ozone'))...
                ||~isempty(strfind(field,'logger'))||~isempty(strfind(field,'head'))...
                ||~isempty(strfind(field,'Rayleigh'))||~isempty(strfind(field,'sun_to_earth'))...
                ||~isempty(strfind(field,'_we_'))||~isempty(strfind(field,'_sn_'))...
                ||~isempty(strfind(field,'diffuse'))||~isempty(strfind(field,'hemisp'))
            in.vars = rmfield(in.vars,field);
        end
    end
    in.vars.Tr_filter2 = in.vars.direct_normal_narrowband_filter2;
    in.vars.Tr_filter2.atts.long_name.data = 'Line-of-sight atmospheric transmittance, Filter 2';
    in.vars.Tr_filter2.atts.units.data = 'unitless';
    %%
    in.vars.Tr_filter2.data = in.vars.direct_normal_narrowband_filter2.data./sscanf(in.atts.filter2_TOA_direct_normal.data,'%g');
    bad_Tr = in.vars.airmass.data<1|in.vars.elevation_angle.data<=0;
%     figure; 
%     ax(1) = subplot(2,1,1); 
%     plot(serial2doy(in.time), in.vars.airmass.data, 'g.',...
%         serial2doy(in.time(in.vars.airmass.data<1)), in.vars.airmass.data(in.vars.airmass.data<1),'r.')
%         
%     ax(2) = subplot(2,1,2);
%         plot(serial2doy(in.time), in.vars.elevation_angle.data, 'g.',...
%         serial2doy(in.time(in.vars.elevation_angle.data<0)), in.vars.airmass.data(in.vars.elevation_angle.data<0),'r.',...
%         serial2doy(in.time(in.vars.elevation_angle.data>90)), in.vars.airmass.data(in.vars.elevation_angle.data>90),'k.');
%     linkaxes(ax,'x')
    
    %%

    
    in.vars.Tr_filter2.data(bad_Tr) = NaN;
    qc_test.description = 'Tr_filter2 < 0.01';
    qc_test.assessment = 'Bad';
%     qc_test.value = in.vars.Tr_filter2.data<0.01;
    qc_test.value = false;
    
%     qc_test.value = false;
%      Bad_AOD_filter2 = in.vars.qc_aerosol_optical_depth_filter2.data>0;
    [in.vars.qc_aerosol_optical_depth_filter2,bit] = vqc_addtest(in.vars.qc_aerosol_optical_depth_filter2,qc_test);
    [in.vars.qc_aerosol_optical_depth_filter5,bit] = vqc_addtest(in.vars.qc_aerosol_optical_depth_filter5,qc_test);
    [in.vars.qc_angstrom_exponent,bit] = vqc_addtest(in.vars.qc_angstrom_exponent,qc_test);

    
%     plot_qcs(in);
        %%
    in.quiet = true;
    in = anccheck(in); 
    in.clobber = true;  
    disp(['Writing ',files(f).name, ' , ',num2str(f),' of ',num2str(length(files))]);
    ancsave(in);
end
disp('Done!')      
clear in
% Next, read and concat contents of yyyy directory.
files = dir([subdir, '*.cdf']);
nc = ancload([subdir, files(1).name]);
for f = 2:length(files)
    disp(['Reading ',num2str(f), ' of ',num2str(length(files))])
    nc = anccat(nc, ancload([subdir, files(f).name]));
end
%
nc.fname = [catdir,files(1).name];
%
nc = anccheck(nc);
%
nc.quiet = true;
disp(['Writing ',nc.fname]);
ancsave(nc);
disp('Done!')


%%

 nc = ancload;
%%

 nc.vars.Tr_filter2.data = nc.vars.direct_normal_narrowband_filter2.data./sscanf(nc.atts.filter2_TOA_direct_normal.data,'%g');
 %%

% At this point, we have created a subset file with appropriate QC
% definitions, and concatenated the results into a single file, but have
% not evaluated the QC test.
%%
% plot_qcs(nim);
% Clean up existin QC error with isolated variability flags at 00:00 UTC
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
ang_qc = nc.vars.qc_angstrom_exponent.data >0; % good when ~ang_qc
Tr_test = real(log10(nc.vars.Tr_filter2.data))<log10(.01);  % good when ~Tr_test

nc.vars.qc_aerosol_optical_depth_filter2.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter2.data), 12,Tr_test);
nc.vars.qc_aerosol_optical_depth_filter5.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter5.data), 12,Tr_test);

% The figure below is using the T/F arrays to select only those values
% corresponding to the T/F states in the arrays.
% The "~" symbol is negation
figure; 
sb(1) = subplot(2,1,1);
plot(serial2doy(nc.time(~filter2_qc)), nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc), 'r.',...
    serial2doy(nc.time(~filter2_qc & ~Tr_test)), nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc& ~Tr_test), 'g.');
[pn,filename,ext] = fileparts(nc.fname);
title(filename);
legend('bad','good');
ylabel('AOD');
xlabel('time [day of year]');

sb(2) = subplot(2,1,2);
plot(serial2doy(nc.time(~filter2_qc)), nc.vars.angstrom_exponent.data(~filter2_qc), 'r.',...
    serial2doy(nc.time(~filter2_qc & ~Tr_test)), nc.vars.angstrom_exponent.data(~filter2_qc& ~Tr_test), 'g.')
legend('bad','good');
ylabel('angstrom');
xlabel('time [day of year]');
linkaxes(sb,'x')
%%
without_Tr_test = nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc);
[wo_Tr_N, bins] = hist(log10(without_Tr_test),50);
figure(99);
bar(bins, log10(wo_Tr_N));
title('Here is the PDF before applying the Tr Test')

%%
with_Tr_test = nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc&~Tr_test);
[w_Tr_N, bins] = hist(log10(with_Tr_test),50);
figure(199);
bar(bins, log10(w_Tr_N));
title('Here is the PDF AFTER applying the Tr Test')
%%

sum((~filter2_qc& ~Tr_test)) % These are the green points that are in fact pretty good
sum((~filter2_qc)& ~(~filter2_qc& ~Tr_test)) % These are the red points that have now been successfully excluded

100.*sum((~filter2_qc)& ~(~filter2_qc& ~Tr_test))./sum((~filter2_qc& ~Tr_test)) 
%%
%% 
tr_ii = 0;
good_pts = []; stripped_pts = [];

tr_range = [0.00001:0.0001:.2];


tr_range = logspace(-8,0,1000);
% tr_range = [0.01];
for tr_ = tr_range
tr_ii = tr_ii+1;

Tr_test = (nc.vars.Tr_filter2.data>0)&(nc.vars.Tr_filter2.data<tr_);  % good when ~Tr_test

nc.vars.qc_aerosol_optical_depth_filter2.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter2.data), 12,Tr_test);
nc.vars.qc_aerosol_optical_depth_filter5.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter5.data), 12,Tr_test);
good_pts(tr_ii) = sum((~filter2_qc& ~Tr_test)); % These are the green points that are in fact pretty good
stripped_pts(tr_ii) = sum((~filter2_qc)& ~(~filter2_qc& ~Tr_test)); % These are the red points that have now been successfully excluded
end
%%
nc.vars.qc_aerosol_optical_depth_filter2.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter2.data), 12,Tr_test);
nc.vars.qc_aerosol_optical_depth_filter5.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter5.data), 12,Tr_test);
nc.vars.qc_angstrom_exponent.data = bitset(uint32(nc.vars.qc_angstrom_exponent.data), 9,Tr_test)


%%
figure; 
sc(1) = subplot(2,1,1);
plot(serial2doy(nc.time(~filter2_qc)), [nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc);nc.vars.aerosol_optical_depth_filter3.data(~filter2_qc);...
    nc.vars.aerosol_optical_depth_filter4.data(~filter2_qc);nc.vars.aerosol_optical_depth_filter5.data(~filter2_qc)], '.');
[pn,filename,ext] = fileparts(nc.fname);
title(filename);
legend('filter 1','filter 2','filter 3','filter 4','filter_5');
ylabel('AOD');
xlabel('time [day of year]');

sc(2) = subplot(2,1,2);
plot(serial2doy(nc.time(~filter2_qc)), nc.vars.angstrom_exponent.data(~filter2_qc), 'g.')
legend('bad','good');
ylabel('angstrom');
xlabel('time [day of year]');
linkaxes(sc,'x')
%%
% plot_qcs(nc);
return


