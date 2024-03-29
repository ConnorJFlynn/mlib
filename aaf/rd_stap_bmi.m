function [stap] = rd_stap_bmi(ins)
% [stap] = rd_stap(ins);
% Parses a STAP file from the AML test  

if ~exist('ins','var') 
   ins = getfullname('*.TXT','stap');
end
if iscell(ins)&&length(ins)==1
   ins = ins{1};
end
 if iscell(ins)
   infile = ins{end}; ins(end) = []; 
   stap = rd_stap_bmi(infile);
   stap = cat_timeseries(stap, rd_stap_bmi(ins));
else   
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
   
   stap.trans_R = stap.red_rel./max(stap.red_rel);
   stap.trans_G = stap.grn_rel./max(stap.grn_rel);
   stap.trans_B = stap.blu_rel./max(stap.blu_rel);
   
   figure; plot(stap.time, stap.red_rel./max(stap.red_rel),'r.',...
      stap.time, stap.grn_rel./max(stap.grn_rel),'g.',...
      stap.time, stap.blu_rel./max(stap.blu_rel),'b.');
   
end
% bad_status = bitand(uint16(stap.status),uint16(hex2dec('FF00')))>0;

% These raw absorption coefficients don't incorporate a filter-loading
% correction and so don't depend on the "absolute" or unity-normalized
% transmittance.

return