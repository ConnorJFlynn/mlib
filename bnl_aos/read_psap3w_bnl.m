function psapr = read_psap3w_bnl(ins);

% psapr = read_psap3w_bnlr(ins);
if ~isavar('ins') || isempty(ins)
   ins = getfullname_('*psap3w*.tsv','bnl_psap');
end

if iscell(ins)&&length(ins)>1
   psapr = read_psap3w_bnl(ins{1});
   psapr2 = read_psap3w_bnl(ins(2:end));
   if ~isempty(psapr)
      psapr_.fname = unique([psapr.fname,psapr2.fname]);
      psapr = cat_timeseries(psapr, psapr2);psapr.fname = psapr_.fname;
   else
      psapr = psapr2;
   end
else
   if iscell(ins);
      fid = fopen(ins{1});
      [psapr.pname,psapr.fname,ext] = fileparts(ins{1});
   else
      fid = fopen(ins);
      [psapr.pname,psapr.fname,ext] = fileparts(ins);
   end
   psapr.pname = {psapr.pname}; psapr.fname = {[psapr.fname, ext]};

   % fid = fopen(ins);
   % [psapr.pname,psapr.fname,ext] = fileparts(ins);
   % psapr.fname = [psapr.fname, ext];

   this = fgetl(fid);
   a = 1;
   while isempty(strfind(this,'yyyy-mm-dd'))&&isempty(strfind(this,'hh:mm:ss.sss'))&&isempty(strfind(this,'YYMMDDhhmmss'))
      %%
      this = fgetl(fid);
      a = a + 1;
      %%
   end
   % Date	Time	Inst. Time	Blue	Green	Red	Blue transmission	Green transmission	Red transmission	Mass flow LPM	Mass flow mV	Averaging time	Flags
   % UTC	UTC
   % yyyy-mm-dd	hh:mm:ss.sss	YYMMDDhhmmss	Inverse megameters	Inverse megameters	Inverse megameters				LPM	mV	s

   % yyyy-mm-dd	hh:mm:ss.sss	YYMMDDhhmmss
   format_str = '%s %s %12s ';
   format_str = [format_str,'%f %f %f ']; % blue_Bap, green_Bap, red_Bap
   format_str = [format_str,'%f %f %f ']; % blue_Tr, green_Tr, red_Tr
   format_str = [format_str,'%f %f %d %s %s %f %f %*[^\n]']; % Flow_lpm, flow_mV, Tint, flag

   %
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
   psapr.Bap_blu = C{4};
   psapr.Bap_grn = C{5};
   psapr.Bap_red = C{6};
   psapr.Tr_blu = C{7};
   psapr.Tr_grn = C{8};
   psapr.Tr_red = C{9};
   psapr.flow_lpm = C{10};
   psapr.flow_mv = C{11};
   psapr.t_avg = double(C{12});
   psapr.flags = hex2nm(strrep(C{13},'NaN','0000'));
   psapr.valve_open = ~strcmp(C{14},'closed');
   psapr.dil_flow_setpt = C{15};
   psapr.dil_flow_reading = C{16};

   %%
end
return
% Date	Time	Inst. Time	Blue signal sum	Blue ref. sum	Blue sample count	Blue overflow count	Green signal sum	Green ref. sum	Green sample count	Green overflow count	Red signal sum	Red ref. sum	Red sample count	Red overflow count	Dark Signal sum	Dark ref. sum	Dark sample count	Dark overflow count	Mass flow output, 1 sec	Mass flow	Flags
% UTC	UTC																				
% yyyy-mm-dd	hh:mm:ss.sss	YYMMDDhhmmss	signed 32bit hex int		unsigned 12bit hex int		signed 32bit hex int		unsigned 12bit hex int		signed 32bit hex int		unsigned 12bit hex int						mV	LPM	
% 																					
% 																					
% 2011-04-01	00:00:00.359	110401000532	03e06f05	06500182	12c	00	02c212a7	0340f533	12c	00	02c3992c	03b856fe	12c	00	fffff62f	ffffff2f	12c	00	1599	.906	0081

