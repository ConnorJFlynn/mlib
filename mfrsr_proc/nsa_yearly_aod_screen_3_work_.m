function ann = nsa_yearly_aod_screen_3c


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
% Tr_test = real(log10(nc.vars.Tr_filter2.data))<log10(.01);  % good when ~Tr_test

%
tr_ii = 0;
good_pts = []; stripped_pts = [];

tr_range = [0.0001:0.0001:.2];
tr_range = logspace(-6,5e-1,100);
tr_range = [0.01];
for tr_ = tr_range
tr_ii = tr_ii+1;

Tr_test = nc.vars.Tr_filter2.data<tr_;  % good when ~Tr_test

nc.vars.qc_aerosol_optical_depth_filter2.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter2.data), 12,Tr_test);
nc.vars.qc_aerosol_optical_depth_filter5.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter5.data), 12,Tr_test);
good_pts(tr_ii) = sum((~filter2_qc& ~Tr_test)); % These are the green points that are in fact pretty good
stripped_pts(tr_ii) = sum((~filter2_qc)& ~(~filter2_qc& ~Tr_test)); % These are the red points that have now been successfully excluded
end
%%

figure; 

plot(serial2doy(nc.time(~filter2_qc)), nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc), 'r.',...
    serial2doy(nc.time(~filter2_qc & ~Tr_test)), nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc& ~Tr_test), 'g.');
[pn,filename,ext] = fileparts(nc.fname);
title(filename);
legend('bad','good');
ylabel('AOD');
xlabel('time [day of year]');



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
nc.vars.qc_aerosol_optical_depth_filter2.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter2.data), 12,Tr_test);
nc.vars.qc_aerosol_optical_depth_filter5.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter5.data), 12,Tr_test);
nc.vars.qc_angstrom_exponent.data = bitset(uint32(nc.vars.qc_angstrom_exponent.data), 9,Tr_test)

% plot_qcs(nc);
return


