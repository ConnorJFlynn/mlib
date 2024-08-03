function [psapr, psapi, xmsn_reset] = rd_psap_putty(infile);

if ~isavar('infile')
   infile = getfullname('psap*.dat','psap_tty','Select psap puTTY log file.');
end

if iscell(infile)&&length(infile)>1
   [psap, raw] = rd_tap_putty(infile{1});
   raw.time = psap.time; psap.fname = raw.fname; 
   [psap2, raw2] = rd_tap_putty(infile(2:end));
   raw2.time = psap2.time;psap2.fname = raw2.fname;

   raw_.fname = unique([raw.fname, raw2.fname]);
   raw = cat_timeseries(raw, raw2);raw.fname = raw_.fname;
   psapp = cat_timeseries(psap, psap); psap.fname = raw.fname; psap.pname = raw.pname;
else
   if iscell(infile); infile = infile{1}; end
   if isafile(infile)
      [raw.pname, raw.fname, ext] = fileparts(infile);
      enamf = fliplr(raw.fname); [emit, etad] = strtok(enamf, '.');
      time_str = fliplr(emit); etad = strtok(etad,'.'); d_str = fliplr(etad);
      start_time = datenum([d_str, ' ',time_str],'yyyymmdd HHMMSS');
      raw.pname = {[raw.pname, filesep]}; raw.fname = {[raw.fname, ext]};
      %   Detailed explanation goes here
      fid = fopen(infile);
   else
      disp('No valid file selected.')
      return
   end
   
   A = textscan(fid, '%s', 'delimiter','\r\n','EndofLine','\r\n');
   A = A{:};
   Is = A(foundstr(A, 'I 24')); Rs = A(foundstr(A,'R 24'));
   psapr = parse_Rs(Rs);
   [psapi, xmsn_reset] = parse_Is(Is);
   
end

return

function [psapi, xmsn_reset] =  parse_Is(Is)
for x = length(Is):-1:1
   As = textscan(Is{x},'%s'); As = As{1};
   IT(x,:) = ['20',As{2}];
   I_str(x) = As(3);
end
psapi.time  = datenum(IT,'yyyymmddHHMMSS');
psapi.itime = psapi.time;
V = datevec(psapi.itime);
psapi.I_SS = floor(V(:,6));
psapi.I_str = strrep(I_str, '"','');
resets= find(psapi.I_SS==4);
reset_str = psapi.I_str(resets);

for no = length(reset_str):-1:1
   out = textscan(char(reset_str{no}),'%*s %*s %*s %*s %*s %*s %*s %s','delimiter',',');
   reset_time(no) = out{:};
end
if ~isavar('reset_time');
   reset_time = [];
end
[~, ij] = unique(reset_time);
if length(psapi.time)>= resets(ij(end))+3
   % time:  04,14,00005634,0014,fffff6,fffffe,03,180618210120
   % blue:  05,0018663ad1,00289b8091,00ecf0,00,0.615
   % green: 06,0022f7e68b,0029b00fb5,00ecf0,00,0.868
   % red :  07,001a9adf01,002356a662,00ecf0,00,0.773
   for N = length(ij):-1:1
      tim_ = textscan(char(psapi.I_str(resets(ij(N)))),'%d %*s %*s %*s %*s %*s %*s %s','delimiter',',');
      blu_ = textscan(char(psapi.I_str(resets(ij(N))+1)),'%d %*s %*s %*s %*s %f','delimiter',',');
      grn_ = textscan(char(psapi.I_str(resets(ij(N))+2)),'%d %*s %*s %*s %*s %f','delimiter',',');
      red_ = textscan(char(psapi.I_str(resets(ij(N))+3)),'%d %*s %*s %*s %*s %f','delimiter',',');
      if tim_{1}==4 && blu_{1}==5 && grn_{1}==6 && red_{1}==7
         try
            xmsn_reset.R_time(N) = datenum(['20',char(tim_{2})],'yyyymmddHHMMSS');
         catch
            xmsn_reset.R_time(N) = psapi.itime(1);
         end
         xmsn_reset.R_timestr(N) = {datestr(xmsn_reset.R_time(N),'yymmddHHMMSS')};
         xmsn_reset.blu_norm_factor(N) = blu_{2};
         xmsn_reset.grn_norm_factor(N) = grn_{2};
         xmsn_reset.red_norm_factor(N) = red_{2};
      end
   end
end

return

function psapr = parse_Rs(Rs)
recs = length(Rs); rec = textscan(Rs{1},'%s'); flds = length(rec{1});
% 'R 240619225221 00e62421 0160c829 12c 00 01f54046 01a2fa2c 12c 00 00d4a08c 00bc56c3 12c 00 fffff3a2 ffffff1b 12c 00 1061  .077 0791'
   format_str = '%*s %s ';
   %signed 32bit hex int		unsigned 12bit hex int	 signed 32bit hex int		unsigned 12bit hex int		signed 32bit hex int		unsigned 12bit hex int
   format_str = [format_str,'%s %s %s %s ']; % blu sig, ref, ct, over
   format_str = [format_str,'%s %s %s %s ']; % grn sig, ref, ct, over
   format_str = [format_str,'%s %s %s %s ']; % red sig, ref, ct, over
   format_str = [format_str,'%s %s %s %s ']; % dark sig, ref, ct, over
   % Dark Signal sum	Dark ref. sum	Dark sample count	Dark overflow count
   %Mass flow output, 1 sec	Mass flow	Flags
   format_str = [format_str, '%f %f %s %*[^\n]'];
for r = recs:-1:1
   C = textscan(Rs{r},format_str); 
   c = C{1}; R.IT(r,:) = {['20',c{:}]}; 
   c = C{2}; R.blu_sig(r,:) = c; 
   c = C{3}; R.blu_ref(r,:) = c; 
   c = C{4}; R.blu_adc_cnt(r,:) = c;
   c = C{5}; R.blu_adc_ovr(r,:) = c; 
   c = C{6}; R.grn_sig(r,:) = c; 
   c = C{7}; R.grn_ref(r,:) = c; 
   c = C{8}; R.grn_adc_cnt(r,:) = c;
   c = C{9}; R.grn_adc_ovr(r,:) = c;
   c = C{10}; R.red_sig(r,:) = c; 
   c = C{11}; R.red_ref(r,:) = c; 
   c = C{12}; R.red_adc_cnt(r,:) = c;
   c = C{13}; R.red_adc_ovr(r,:) = c;   
   c = C{14}; R.dark_sig(r,:) = c; 
   c = C{15}; R.dark_ref(r,:) = c; 
   c = C{16}; R.dark_adc_cnt(r,:) = c;
   c = C{17}; R.dark_adc_ovr(r,:) = c; 
   c = C{18}; R.flow_AD(r) = c;
   c = C{19}; R.flow_lpm(r) = c;
   c = C{20}; R.flags(r,:) = c;   
end
psapr.itime = datenum(R.IT,'yyyymmddHHMMSS');
psapr.blu_sig = hex2nm(R.blu_sig);
psapr.blu_ref = hex2nm(R.blu_ref);
psapr.blu_adc_cnt = hex2nm(R.blu_adc_cnt);
psapr.blu_adc_ovr = hex2nm(R.blu_adc_ovr);
psapr.grn_sig = hex2nm(R.grn_sig);
psapr.grn_ref = hex2nm(R.grn_ref);
psapr.grn_adc_cnt = hex2nm(R.grn_adc_cnt);
psapr.grn_adc_ovr = hex2nm(R.grn_adc_ovr);
psapr.red_sig = hex2nm(R.red_sig);
psapr.red_ref = hex2nm(R.red_ref);
psapr.red_adc_cnt = hex2nm(R.red_adc_cnt);
psapr.red_adc_ovr = hex2nm(R.red_adc_ovr);
psapr.dark_sig = hex2nm(R.dark_sig);
psapr.dark_ref = hex2nm(R.dark_ref);
psapr.dark_adc_cnt = hex2nm(R.dark_adc_cnt);
psapr.dark_adc_ovr = hex2nm(R.dark_adc_ovr);
psapr.flow_AD = R.flow_AD';
psapr.flow_lpm = R.flow_lpm';
psapr.flags = hex2nm(R.flags);

return
