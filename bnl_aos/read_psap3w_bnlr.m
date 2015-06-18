function psapr = read_psap3w_bnlr(ins);

if ~exist('ins','var') || ~exist(ins,'file')
    ins = getfullname_('*psap3wr*.tsv','bnl_psap');
end

fid = fopen(ins);
[psapr.pname,psapr.fname,ext] = fileparts(ins);
psapr.fname = [psapr.fname, ext];

this = fgetl(fid);
a = 1;
while isempty(strfind(this,'yyyy-mm-dd'))&&isempty(strfind(this,'hh:mm:ss.sss'))&&isempty(strfind(this,'YYMMDDhhmmss'))
    %%
    this = fgetl(fid);
    a = a + 1;
    %%
end
% yyyy-mm-dd	hh:mm:ss.sss	YYMMDDhhmmss	
format_str = '%s %s %s ';
%signed 32bit hex int		unsigned 12bit hex int	 signed 32bit hex int		unsigned 12bit hex int		signed 32bit hex int		unsigned 12bit hex int						
format_str = [format_str,'%s %s %s %s ']; % blu sig, ref, ct, over
format_str = [format_str,'%s %s %s %s ']; % grn sig, ref, ct, over
format_str = [format_str,'%s %s %s %s ']; % red sig, ref, ct, over
format_str = [format_str,'%s %s %s %s ']; % dark sig, ref, ct, over
% Dark Signal sum	Dark ref. sum	Dark sample count	Dark overflow count	
%Mass flow output, 1 sec	Mass flow	Flags
format_str = [format_str, '%f %f %s %*[^\n]'];
%
%mV	LPM	
C = textscan(fid, format_str);
fclose(fid);
A = C{1};
B = C{2};
D = C{3};
for x =length(A):-1:1
    D_str(x) = {[A{x}, ' ',B{x}]};
    D_str_(x) = {['20',D{x}]};
end
psapr.time = datenum(D_str,'yyyy-mm-dd HH:MM:SS.FFF');
% psapr.time_ = datenum(D_str_,'yyyymmddHHMMSS');
psapr.blu_sig = hex2nm(C{4});
psapr.blu_ref = hex2nm(C{5});
psapr.blu_adc_cnt = hex2nm(C{6});
psapr.blu_adc_over = hex2nm(C{7});
psapr.grn_sig = hex2nm(C{8});
psapr.grn_ref = hex2nm(C{9});
psapr.grn_adc_cnt = hex2nm(C{10});
psapr.grn_adc_over = hex2nm(C{11});
psapr.red_sig = hex2nm(C{12});
psapr.red_ref = hex2nm(C{13});
psapr.red_adc_cnt = hex2nm(C{14});
psapr.red_adc_over = hex2nm(C{15});
psapr.dark_sig = hexntwo(C{16});
psapr.dark_ref = hexntwo(C{17});
psapr.dark_adc_cnt = hex2nm(C{18});
psapr.dark_adc_over = hex2nm(C{19});
psapr.flow_AD = C{20};
psapr.flow_lpm = C{21};
psapr.flags = hex2nm(C{22});
%%
psapr.red_rel = (psapr.red_sig-psapr.dark_sig)./(psapr.red_ref-psapr.dark_ref);
psapr.grn_rel = (psapr.grn_sig-psapr.dark_sig)./(psapr.grn_ref-psapr.dark_ref);
psapr.blu_rel = (psapr.blu_sig-psapr.dark_sig)./(psapr.blu_ref-psapr.dark_ref);

%%
% 
% figure; plot(serial2Hh(psapr.time), [psapr.red_ref - mean(psapr.red_ref),psapr.grn_ref - mean(psapr.grn_ref),psapr.blu_ref - mean(psapr.blu_ref)],'.');
% legend('red','grn','blu');
% title('mean subtracted reference for each wavelength');
% xlabel('time [UTC]');
% %%
% 
% figure; plot(serial2doy(psapr.time), [psapr.red_sig./psapr.red_ref - mean(psapr.red_sig./psapr.red_ref),psapr.grn_sig./psapr.grn_ref - mean(psapr.grn_sig./psapr.grn_ref),psapr.blu_sig./psapr.blu_ref - mean(psapr.blu_sig./psapr.blu_ref)],'.');
% legend('red','grn','blu')
%%
return
% Date	Time	Inst. Time	Blue signal sum	Blue ref. sum	Blue sample count	Blue overflow count	Green signal sum	Green ref. sum	Green sample count	Green overflow count	Red signal sum	Red ref. sum	Red sample count	Red overflow count	Dark Signal sum	Dark ref. sum	Dark sample count	Dark overflow count	Mass flow output, 1 sec	Mass flow	Flags
% UTC	UTC																				
% yyyy-mm-dd	hh:mm:ss.sss	YYMMDDhhmmss	signed 32bit hex int		unsigned 12bit hex int		signed 32bit hex int		unsigned 12bit hex int		signed 32bit hex int		unsigned 12bit hex int						mV	LPM	
% 																					
% 																					
% 2011-04-01	00:00:00.359	110401000532	03e06f05	06500182	12c	00	02c212a7	0340f533	12c	00	02c3992c	03b856fe	12c	00	fffff62f	ffffff2f	12c	00	1599	.906	0081

