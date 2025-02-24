function [ae] = rd_ae33x(infile)
% [ae,scan_str] = rd_ae33x(infile, in_str)
% This function reads data files exported from MaGee AE33
% it returns a struct containing the read measurements and format string
% It accepts and optional "in_str" argument representing the beginning of format str
% to be used in textscan and returns it as well

if ~isavar('infile')||isempty(infile)
   infile = getfullname_('AE33*.dat','ae33x','Select an AE33 export dat file.');
end

in_str = ['%s %s', repmat(' %f',[1,30]),repmat(' %x',[1,5]), repmat(' %f',[1,30]), ' %*f %*f %*f'];

if iscell(infile)&&length(infile)>1
   [ae] =  rd_ae33x(infile{1});
   [ae2] = rd_ae33x(infile(2:end));
   if isempty(ae)&&~isempty(ae2)
      ae = ae2;
   elseif ~isempty(ae)&&~isempty(ae2)
      ae_.fname = unique([ae.fname,ae2.fname]);
      ae = cat_timeseries(ae, ae2);ae.fname = ae_.fname;
   end
else
   if iscell(infile)
      fid = fopen(infile{1});
      [ae.pname,ae.fname,ext] = fileparts(infile{1});
   else
      fid = fopen(infile);
      [ae.pname,ae.fname,ext] = fileparts(infile);
   end
   
   if isafile(infile)
      ae.pname = {strrep([ae.pname filesep],[filesep filesep],filesep)}; ae.fname = {[ae.fname, ext]};
      %   Label row, followed by first data row
      %    Date	Time	Inst. Date	Inst. Time	 Timebase	 RefCh1	 Sen1Ch1	 Sen2Ch1	 RefCh2	 Sen1Ch2	 Sen2Ch2	 RefCh3	 Sen1Ch3	 Sen2Ch3	 RefCh4	 Sen1Ch4	 Sen2Ch4	 RefCh5	 Sen1Ch5	 Sen2Ch5	 RefCh6	 Sen1Ch6	 Sen2Ch6	 RefCh7	 Sen1Ch7	 Sen2Ch7	 Flow1	 Flow2	 FlowC	assumed_pressure	assumed_temperature	BC_BrC 	 ContTemp	 SupplyTemp	 Status	 ContStatus	 DetectStatus	 LedStatus	 ValveStatus	 LedTemp	 BC11	 BC12	 BC1	 BC21	 BC22	 BC2	 BC31	 BC32	 BC3	 BC41	 BC42	 BC4	 BC51	 BC52	 BC5	 BC61	 BC62	 BC6	 BC71	 BC72	 BC7	 K1	 K2	 K3	 K4	 K5	 K6	 K7	 TapeAdvCount	Op Comm
      % UTC	UTC
      % yyyy-mm-dd	hh:mm:ss.sss	yyyy/MM/dd	hh:mm:ss	seconds																						ml/min	ml/min	ml/min	Pa	degC	ng/m3	degC	degC						degC
      %
      %
      % 2024-06-26	18:00:00.000	2024/06/26	18:00:00	60	934801	632453	787184	932028	605327	720964	929611	607233	714880	911243	607247	709396	917986	702701	799437	791279	838736	924637	852643	815538	928875	2930	1056	3986	101325	25.00	0	28	41	0	0	10	10	00000	30	187	232	194	156	164	161	183	217	187	152	138	154	130	141	130	140	147	136	167	199	163	0.002562285	0.002709014	0.002009132	0.001010028	-0.0004617775	-0.004752111	-0.005	310
      hdr = fgetl(fid);
      while ~feof(fid) && isempty(findstr(hdr,'Date('))
         hdr = fgetl(fid);
      end
      hdr = textscan(hdr,'%s','delimiter',';'); hdr = hdr{:};
      this = fgetl(fid); this = fgetl(fid);

      %    Date	Time	Inst. Date	Inst. Time	 Timebase	 RefCh1	 Sen1Ch1	 Sen2Ch1	 RefCh2	 Sen1Ch2	 Sen2Ch2	 RefCh3	 Sen1Ch3	 Sen2Ch3	 RefCh4	 Sen1Ch4	 Sen2Ch4	 RefCh5	 Sen1Ch5	 Sen2Ch5	 RefCh6	 Sen1Ch6	 Sen2Ch6	 RefCh7	 Sen1Ch7	 Sen2Ch7	 Flow1	 Flow2	 FlowC	assumed_pressure	assumed_temperature	BC_BrC 	 ContTemp	 SupplyTemp	 Status	 ContStatus	 DetectStatus	 LedStatus	 ValveStatus	 LedTemp	 BC11	 BC12	 BC1	 BC21	 BC22	 BC2	 BC31	 BC32	 BC3	 BC41	 BC42	 BC4	 BC51	 BC52	 BC5	 BC61	 BC62	 BC6	 BC71	 BC72	 BC7	 K1	 K2	 K3	 K4	 K5	 K6	 K7	 TapeAdvCount	Op Comm
      % Now iteratively try to compose the format string starting with "in_str" if
      % provided.
      Aa = textscan(fid, in_str); 
      fclose(fid);
      
      D = Aa{1}; Aa(1) = [];
      T = Aa{1}; Aa(1) = [];
      for N = length(Aa{end}):-1:1
         DT(N) = {[D{N}, ' ', T{N}]};
      end

      ae.time = datenum(DT,'yyyy/mm/dd HH:MM:SS'); clear DT;
      hdr(1:2) = [];
      for lab = 1:length(hdr)

         ae.(legalize_fieldname(hdr{lab})) = Aa{1};
         Aa(1) = [];

      end

   else
      disp('No valid file selected.')
      return
   end
end

ae.zeta_leak = 0.025;
% % % Also according MaGee according to Gunnar, AE33 spot size is 10 mm diam
ae.spot_area = pi .* 5.^2;
 return

