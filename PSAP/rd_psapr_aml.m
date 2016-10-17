function [psapr] = rd_psapr_aml(ins, spot_area, flow_cal)
% [psapro,psapri] = rd_psapr_aml(ins);
% Parses a PSAP file from the AML test  containing "R" packets
% The "R" packets don't clearly indicate filter changes or include
% normalization values found in the "O" packets so filter-loading
% correction is non-trivial.

if ~exist('ins','var') || ~exist(ins,'file')
    ins = getfullname('psap_*_r.csv','psap_aaf');
end
if ~exist('spot_area','var')
    spot_area = 17.81; % default PSAP spot area in mm^2
end

bo = 0; b1 = 1;
[psapi.pname,psapi.fname,ext] = fileparts(ins);
psapi.pname = [psapi.pname, filesep]; psapi.fname = [psapi.fname, ext];

disp('Loading and processing raw files.')
% 2016 10 13 21 19 03.00 287.888229 R 161013211902
format_str = '%f %f %f %f %f %f %f %s %s ';
% 04ccbe04 062572aa 0cc 00
format_str = [format_str, '%s %s %s %s ']; %blue sig, ref, ct, over
% 0452fc85 0466c4d3 0cc 00
format_str = [format_str, '%s %s %s %s ']; %green sig, ref, ct, over
%02df4ce2 03439ba5 0cc 00
format_str = [format_str, '%s %s %s %s ']; %red sig, ref, ct, over
% fffff939 ffffffa9 0cc 00 1825 1.031 0083
format_str = [format_str, '%s %s %s %s ']; %dark sig, ref, ct, over
% 1825 1.031 0083
format_str = [format_str, '%f %f %s %*[^\n] %*[\n]'];
% 2016 10 13 21 19 04.00 287.888241 R 161013211903 04ccbc09 0625714d 0cc 00 04530367 0466cdd7 0cc 00 02df494f 03439c97 0cc 00 fffffbb7 0000006d 0cc 00 1825 1.031 0083
fid = fopen(ins);
if fid>0
    [C] = textscan(fid,format_str);
    fclose(fid);
end
V = [C{1}, C{2}, C{3}, C{4}, C{5}, C{6}];
psapr.time = datenum(V);
psapr.itime = datenum(C{9},'yymmddHHMMSS');
C(1:7) = [];
Rs = strcmp('R',C{1}); C(1:2) = [];
psapr.blu_sig = hex2nm(C{1});
psapr.blu_ref = hex2nm(C{2});
psapr.blu_adc_cnt = hex2nm(C{3});
psapr.blu_adc_over = hex2nm(C{4});
psapr.grn_sig = hex2nm(C{5});
psapr.grn_ref = hex2nm(C{6});
psapr.grn_adc_cnt = hex2nm(C{7});
psapr.grn_adc_over = hex2nm(C{8});
psapr.red_sig = hex2nm(C{9});
psapr.red_ref = hex2nm(C{10});
psapr.red_adc_cnt = hex2nm(C{11});
psapr.red_adc_over = hex2nm(C{11});
psapr.dark_sig = hexntwo(C{13});
psapr.dark_ref = hexntwo(C{14});
psapr.dark_adc_cnt = hex2nm(C{15});
psapr.dark_adc_over = hex2nm(C{16});
psapr.flow_AD = C{17};
psapr.flow_lpm = C{18};
psapr.status = uint16(hex2nm(C{19}));
%%
psapr.red_rel = (psapr.red_sig-psapr.dark_sig)./(psapr.red_ref-psapr.dark_ref);
psapr.grn_rel = (psapr.grn_sig-psapr.dark_sig)./(psapr.grn_ref-psapr.dark_ref);
psapr.blu_rel = (psapr.blu_sig-psapr.dark_sig)./(psapr.blu_ref-psapr.dark_ref);

psapr.trans_R = (psapr.red_sig-psapr.dark_sig)./(psapr.red_ref-psapr.dark_ref);
psapr.trans_G = (psapr.grn_sig-psapr.dark_sig)./(psapr.grn_ref-psapr.dark_ref);
psapr.trans_B = (psapr.blu_sig-psapr.dark_sig)./(psapr.blu_ref-psapr.dark_ref);

figure; plot(serial2doys(psapr.time), psapr.red_rel./max(psapr.red_rel),'r.',...
    serial2doys(psapr.time), psapr.grn_rel./max(psapr.grn_rel),'g.',...
    serial2doys(psapr.time), psapr.blu_rel./max(psapr.blu_rel),'b.')
bad_status = bitand(uint16(psapr.status),uint16(hex2dec('FF00')))>0;
psapr.mass_flow_last = psapr.flow_lpm;
% These raw absorption coefficients don't incorporate a filter-loading
% correction and so don't depend on the "absolute" or unity-normalized
% transmittance.
tic; 
disp('Computing flow sm');
    ss = 32;
    dt = ss./(24*60*60); % 16-second half-width, 32-second full-width
    psapr.flow_sm = sliding_polyfit(psapr.time, psapr.flow_lpm, dt);

disp(toc);tic; disp('Computing Ba B sm')

[psapr.Ba_B_sm, psapr.trans_B_sm] = smooth_Tr_Bab(psapr.time, psapr.flow_sm, psapr.trans_B,ss,spot_area );
disp(toc);tic;disp('Computing Ba G sm')
[psapr.Ba_G_sm, psapr.trans_G_sm] = smooth_Tr_Bab(psapr.time, psapr.flow_sm, psapr.trans_G,ss,spot_area );
disp(toc);tic;disp('Computing Ba R sm')
[psapr.Ba_R_sm, psapr.trans_R_sm] = smooth_Tr_Bab(psapr.time, psapr.flow_sm, psapr.trans_R,ss,spot_area );
disp(toc);disp('Done computing absorption coefs (no filter-loading correction)')
figure; plot(psapr.time, [psapr.trans_B./max(psapr.blu_rel),psapr.trans_G./max(psapr.grn_rel),psapr.trans_R./max(psapr.red_rel)],'.',...
    psapr.time, [psapr.trans_B_sm./max(psapr.blu_rel),psapr.trans_G_sm./max(psapr.grn_rel),psapr.trans_R_sm./max(psapr.red_rel)],'-');dynamicDateTicks
legend('Tr_B raw','Tr B raw','Tr R raw','Tr B smooth', 'Tr G smooth', 'Tr R smooth');


figure; plot(psapr.time, [psapr.Ba_B_sm, psapr.Ba_G_sm, psapr.Ba_R_sm],'-');dynamicDateTicks
legend('Ba B sm','Ba G sm','Ba R sm');


return