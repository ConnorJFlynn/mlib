function [stap] = rd_stap(ins, spot_area, flow_cal)
% [stap] = rd_stap(ins);
% Parses a STAP file from the AML test  

if ~exist('ins','var') || ~exist(ins,'file')
    ins = getfullname('*.TXT','stap');
end
if ~exist('spot_area','var')
    spot_area = 17.91; %  spot area = 0.188" in diam = 0.094" rad = 2.3876 mm ==> 17.91 mm^2
    % psap default = 17.81
    % in mm^2
% TAP Pall E70 default: 3.0721E-5
end

bo = 0; b1 = 1;
[stap.pname,stap.fname,ext] = fileparts(ins);
stap.pname = [stap.pname, filesep]; stap.fname = [stap.fname, ext];

disp('Loading and processing raw files.')
% #YY/MM/DD	HR:MN:SC	invmm_r	invmm_g	invmm_b	red_smp	red_ref	grn_smp	grn_ref	blu_smp	blu_ref	blk_smp	blk_ref	smp_flw	smp_tmp	smp_prs	pump_pw	psvolts	err_rpt	cntdown	fltstat	flow_sp	intervl	stapctl	
% 16/10/13 	21:37:16 	0.00  	0.00  	0.00  	767672 	799869 	771299 	808811 	767576 	803590 	8038   	7977   	1.30  	24.2 	981  	77 	12.24 	0      	59 	7 	1.30  	30  	1 	

% #YY/MM/DD	HR:MN:SC	invmm_r	invmm_g	invmm_b	red_smp	red_ref	grn_smp	grn_ref	blu_smp	blu_ref	blk_smp	blk_ref
% 16/10/13 	21:37:16 	0.00  	0.00  	0.00  	767672 	799869 	771299 	808811 	767576 	803590 	8038   	7977   
format_str = '%s %s %f %f %f %d %d %d %d %d %d %d %d ';
% smp_flw	smp_tmp	smp_prs	pump_pw	psvolts	err_rpt	cntdown	fltstat	flow_sp	intervl	stapctl	
% 	1.30  	24.2 	981  	77 	    12.24 	0      	59 	      7 	1.30  	30  	1 	
format_str = [format_str, '%f %f %f %f %f %s %d %s %f %f %d %*[^\n] %*[\n]'];

fid = fopen(ins);
if fid>0
        mark =ftell(fid);
    tmp = fgetl(fid);
    while strcmp(tmp(1),'#')
        mark =ftell(fid);
    tmp = fgetl(fid);
    end
    fseek(fid, mark,-1);
    [C] = textscan(fid,format_str);
    fclose(fid);
end
dates = datenum(C{1},'yy/mm/dd'); C(1) = [];
hours = datenum(C{1},'HH:MM:SS'); C(1) = []; hours = hours - floor(hours);
stap.time = dates + hours;
stap.Ba_R = C{1}; C(1) = [];
stap.Ba_G = C{1}; C(1) = [];
stap.Ba_B = C{1}; C(1) = [];

stap.red_smp = C{1}; C(1) = [];
stap.red_ref = C{1}; C(1) = [];
stap.grn_smp = C{1}; C(1) = [];
stap.grn_ref = C{1}; C(1) = [];
stap.blu_smp = C{1}; C(1) = [];
stap.blu_ref = C{1}; C(1) = [];

stap.dark_smp = C{1}; C(1) = [];
stap.dark_ref = C{1}; C(1) = [];
% smp_flw	smp_tmp	smp_prs	pump_pw	psvolts	err_rpt	cntdown	fltstat	flow_sp	intervl	stapctl	
% 	1.30  	24.2 	981  	77 	    12.24 	0      	59 	      7 	1.30  	30  	1 	
stap.sample_flow = C{1}; C(1) = [];
stap.sample_temp_C = C{1}; C(1) = [];
stap.sample_pres = C{1}; C(1) = [];
stap.pump_pwr = C{1}; C(1) = [];
stap.ps_volts = C{1}; C(1) = [];
stap.error_report = C{1}; C(1) = [];stap.error_report = hex2nm(stap.error_report);
stap.countdown = C{1}; C(1) = [];
stap.filter_status = C{1}; C(1) = []; stap.filter_status = hex2nm(stap.filter_status);
stap.flow_setpoint = C{1}; C(1) = [];
C(1) = [];
stap.on = C{1}; C(1) = [];

%%
stap.red_rel = double(stap.red_smp-stap.dark_smp)./double(stap.red_ref-stap.dark_ref);
stap.grn_rel = double(stap.grn_smp-stap.dark_smp)./double(stap.grn_ref-stap.dark_ref);
stap.blu_rel = double(stap.blu_smp-stap.dark_smp)./double(stap.blu_ref-stap.dark_ref);

stap.trans_R = double(stap.red_smp-stap.dark_smp)./double(stap.red_ref-stap.dark_ref);
stap.trans_G = double(stap.grn_smp-stap.dark_smp)./double(stap.grn_ref-stap.dark_ref);
stap.trans_B = double(stap.blu_smp-stap.dark_smp)./double(stap.blu_ref-stap.dark_ref);

figure; plot(stap.time, stap.red_rel./max(stap.red_rel),'r.',...
    stap.time, stap.grn_rel./max(stap.grn_rel),'g.',...
    stap.time, stap.blu_rel./max(stap.blu_rel),'b.')
% bad_status = bitand(uint16(stap.status),uint16(hex2dec('FF00')))>0;

% These raw absorption coefficients don't incorporate a filter-loading
% correction and so don't depend on the "absolute" or unity-normalized
% transmittance.
tic; 
disp('Computing flow sm');
    ss = 30;
    dt = ss./(24*60*60); % 8-second half-width, 16-second full-width
    stap.flow_sm = sliding_polyfit(stap.time, stap.sample_flow, dt);
figure; plot(stap.time, stap.sample_flow, '.',stap.time, stap.flow_sm,'r.')
disp(toc);tic; disp('Computing Ba B sm')
stap.trans_B_sm = sliding_polyfit(stap.time,stap.trans_B,dt./2);
stap.trans_G_sm = sliding_polyfit(stap.time,stap.trans_G,dt./2);
stap.trans_R_sm = sliding_polyfit(stap.time,stap.trans_R,dt./2);
[stap.Ba_B_sm] = smooth_Bab(stap.time, stap.flow_sm, stap.trans_B_sm, ss, spot_area );
disp(toc);tic;disp('Computing Ba G sm')
[stap.Ba_G_sm] = smooth_Bab(stap.time, stap.flow_sm, stap.trans_G_sm,ss,spot_area );
disp(toc);tic;disp('Computing Ba R sm')
[stap.Ba_R_sm] = smooth_Bab(stap.time, stap.flow_sm, stap.trans_R_sm,ss,spot_area );
disp(toc);disp('Done computing absorption coefs (no filter-loading correction)')

stap.Ba_B_Bond =  stap.Ba_B_sm.* WeissBondOgren(stap.trans_B);
stap.Ba_G_Bond =  stap.Ba_G_sm.* WeissBondOgren(stap.trans_G);
stap.Ba_R_Bond =  stap.Ba_R_sm.* WeissBondOgren(stap.trans_R);

figure; plot(stap.time, [stap.Ba_B_Bond, stap.Ba_G_Bond, stap.Ba_R_Bond],'.',...
   stap.time-1./(24*60), [stap.Ba_B, stap.Ba_G, stap.Ba_R],'.' );dynamicDateTicks
legend('Ba B stap sm','Ba G stap sm','Ba R stap sm','Ba B bmi','Ba G bmi','Ba R bmi');
[~,title_str] = fileparts(ins);
title(title_str,'interp','none')
saveas(gcf,strrep(ins,'.TXT','.fig'))
save(strrep(ins,'.TXT','.mat'),'-struct','tap');
return