
% b_abs_652_reference,b_abs_528_reference,b_abs_467_reference,ln_Tr_467,b_atn_467,b_scat_467,ln_Tr_528,b_atn_528,b_scat_528,ln_Tr_652,b_atn_652,b_scat_652,time_psap_avg
% b_abs_652_reference,b_abs_528_reference,b_abs_467_reference,ln_Tr_467,b_atn_467,b_scat_467,ln_Tr_528,b_atn_528,b_scat_528,ln_Tr_652,b_atn_652,b_scat_652,time_psap_avg

% ,,,,,,,,,,,,
% 0.494325,0.678853,0.816489,-0.103889,4.99605,26.5073,-0.0879183,4.09652,21.3015,-0.0688237,3.12604,14.6302,2/1/2013 0:10


fid = fopen(getfullname('E:\case_studies\Li_etal_filter_corrs\Li_et_al_2020_data_share\PSAP*.csv'),'r')
A = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %s','Delimiter',',','TreatAsEmpty','#NAME?','EmptyValue',NaN,'HeaderLines',1 );
fclose(fid)



d_str = A{end};
for t = length(d_str):-1:1
bad(t) = isempty(d_str{t});
end
psap_raw.time = datenum(d_str(~bad),'mm/dd/yyyy HH:MM');
psap_raw.b_abs_R_ref = A{1}; psap_raw.b_abs_G_ref = A{2};psap_raw.b_abs_B_ref = A{3};
psap_raw.ln_Tr_B = A{4}; psap_raw.b_atn_B = A{5}; psap_raw.b_scat_B = A{6};
psap_raw.ln_Tr_G = A{7}; psap_raw.b_atn_G = A{8}; psap_raw.b_scat_G = A{9};
psap_raw.ln_Tr_R = A{10}; psap_raw.b_atn_R = A{11}; psap_raw.b_scat_R = A{12};

psap_raw.b_abs_R_ref(bad) = [];
psap_raw.b_abs_G_ref(bad) = [];
psap_raw.b_abs_B_ref(bad) = [];

psap_raw.ln_Tr_B(bad) = []; psap_raw.b_atn_B(bad) = [];psap_raw.b_scat_B(bad) = [];
psap_raw.ln_Tr_G(bad) = [];  psap_raw.b_atn_G(bad) = [];  psap_raw.b_scat_G(bad) = []; 
psap_raw.ln_Tr_R(bad) = []; psap_raw.b_atn_R(bad) = []; psap_raw.b_scat_R(bad) = []; 

figure; plot(psap_raw.time, [psap_raw.b_atn_B,psap_raw.b_atn_G,psap_raw.b_atn_R],'.',...
   psap_raw.time, [psap_raw.b_scat_B,psap_raw.b_scat_G,psap_raw.b_scat_R],'o');dynamicDateTicks


fid = fopen(getfullname('E:\case_studies\Li_etal_filter_corrs\Li_et_al_2020_data_share\PSAP*.csv'),'r')
A = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %s','Delimiter',',','TreatAsEmpty','#NAME?','EmptyValue',NaN,'HeaderLines',1 );
fclose(fid)
d_str = A{end};
for t = length(d_str):-1:1
bad(t) = isempty(d_str{t});
end
psap_praw.time = datenum(d_str(~bad),'mm/dd/yyyy HH:MM');
psap_praw.b_abs_R_ref = A{1}; psap_praw.b_abs_G_ref = A{2};psap_praw.b_abs_B_ref = A{3};
psap_praw.ln_Tr_B = A{4}; psap_praw.b_atn_B = A{5}; psap_praw.b_scat_B = A{6};
psap_praw.ln_Tr_G = A{7}; psap_praw.b_atn_G = A{8}; psap_praw.b_scat_G = A{9};
psap_praw.ln_Tr_R = A{10}; psap_praw.b_atn_R = A{11}; psap_praw.b_scat_R = A{12};

psap_praw.b_abs_R_ref(bad) = [];
psap_praw.b_abs_G_ref(bad) = [];
psap_praw.b_abs_B_ref(bad) = [];

psap_praw.ln_Tr_B(bad) = []; psap_praw.b_atn_B(bad) = []; psap_praw.b_scat_B(bad) = [];
psap_praw.ln_Tr_G(bad) = []; psap_praw.b_atn_G(bad) = []; psap_praw.b_scat_G(bad) = []; 
psap_praw.ln_Tr_R(bad) = []; psap_praw.b_atn_R(bad) = []; psap_praw.b_scat_R(bad) = []; 

figure; plot(psap_praw.time, [psap_praw.b_atn_B,psap_praw.b_atn_G,psap_praw.b_atn_R],'.',...
   psap_praw.time, [psap_praw.b_scat_B,psap_praw.b_scat_G,psap_praw.b_scat_R],'o');dynamicDateTicks
title('PSAP Proc Raw')

figure; plot(psap_raw.time, psap_raw.b_atn_B,'.',psap_praw.time, psap_praw.b_atn_B,'ro'); dynamicDateTicks

% Construct test data set for Li_Algo_B from SGP
% 2013-07-08 thru 07-11: relatively flat absorption 3 filter
psap = ARM_display_beta;
neph = ARM_display_beta;
xl = xlim; %zoomed into plot of PSAP Tr 
xlim(xl); % for Neph and PSAP windows to set them equal
% sift psap data based on qc_Bab_G_Weiss
bad = anc_qc_impacts(psap.vdata.qc_Ba_B_Weiss, psap.vatts.qc_Ba_B_Weiss)~=0;
bad = bad | anc_qc_impacts(psap.vdata.qc_Ba_G_Weiss, psap.vatts.qc_Ba_G_Weiss)~=0;
bad = bad | anc_qc_impacts(psap.vdata.qc_Ba_R_Weiss, psap.vatts.qc_Ba_R_Weiss)~=0;
psap = anc_sift(psap,~bad);
bad = anc_qc_impacts(neph.vdata.qc_Bs_B_Dry_Neph3W, neph.vatts.qc_Bs_B_Dry_Neph3W)~=0;
bad = bad | anc_qc_impacts(neph.vdata.qc_Bs_G_Dry_Neph3W, neph.vatts.qc_Bs_G_Dry_Neph3W)~=0;
bad = bad | anc_qc_impacts(neph.vdata.qc_Bs_R_Dry_Neph3W, neph.vatts.qc_Bs_R_Dry_Neph3W)~=0;
neph = anc_sift(neph,~bad);

xl_p = psap.time>=xl(1)&psap.time<xl(2); 
xl_n = neph.time>=xl(1)&neph.time<xl(2);



[pinn, ninp] = nearest(psap.time, neph.time);
Bsp = [neph.vdata.Bs_B_Dry_Neph3W(ninp);neph.vdata.Bs_G_Dry_Neph3W(ninp);neph.vdata.Bs_R_Dry_Neph3W(ninp)];
Ba = [psap.vdata.Ba_B_raw(pinn);psap.vdata.Ba_G_raw(pinn);psap.vdata.Ba_R_raw(pinn)];
Tr = [psap.vdata.transmittance_blue(pinn);psap.vdata.transmittance_green(pinn);psap.vdata.transmittance_red(pinn)];
serial_time = psap.time(pinn);
dout = [Bsp(3,:);Bsp(2,:);Bsp(1,:);Ba(3,:);Ba(2,:);Ba(1,:);Tr(3,:);Tr(2,:);Tr(1,:);serial_time; ];
% Check 
fid = fopen(['E:\case_studies\Li_etal_filter_corrs\SGP_PSAP_algo_B_July7_11.csv'],'w');
fprintf(fid, '%s \n', 'bscat_red,bscat_green,bscat_blue,batn_red,batn_green,batn_blue,Tr_red,Tr_green,Tr_blue,serial_time');
fprintf(fid, '%f, %f, %f, %f, %f, %f, %f, %f, %f, %f \n',dout);
fclose(fid)
% Then compose the data to write to a csv file, remembering not to include
% spaces between the commas for the header_row
% Li_out cut-and-paste from text file to command window
figure; plot(psap.time(pinn), fliplr(Li_out),'*'); dynamicDateTicks


for tt = length(Li_out):-1:1
P = polyfit(log([648,529,464]),log(Li_out(tt,:)),2);
aae(tt,:) =-polyval(P,log([648,529,464]));
end

figure; plot(serial_time, fliplr(aae),'x'); dynamicDateTicks; legend('aae'); xlim(this_x)


end