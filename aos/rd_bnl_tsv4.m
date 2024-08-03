function [bnl,in_str] = rd_bnl_tsv4(infile, in_str)
% [bnl,scan_str] = rd_bnl_tsv4(bnl, in_str)
% This function reads BNL supplied "cpcf tsv" files for the AOS system
% it returns a struct containing the read measurements and format string
% It accepts and optional "in_str" argument representing the beginning of format str
% to be used in textscan and returns it as well

% error('Currently broken!!')
% Need to more robustly distinguish between BNL files that have different numbers of time strings.
if ~isavar('infile')||isempty(infile)
   infile = getfullname_('*.tsv','bnl_tsv','Select a BNL tsv file.');
end
if ~isavar('in_str')
   in_str = '%s %s ';
end
if iscell(infile)&&length(infile)>1
   [bnl,in_str] =  rd_bnl_tsv4(infile{1},in_str);
   [bnl2,in_str] = rd_bnl_tsv4(infile(2:end),in_str);
   if isempty(bnl)&&~isempty(bnl2)
      bnl = bnl2;
   elseif ~isempty(bnl)&&~isempty(bnl2)
      bnl_.fname = unique([bnl.fname,bnl2.fname]);
      bnl = cat_timeseries(bnl, bnl2);bnl.fname = bnl_.fname;
   end
else
   if iscell(infile)
      fid = fopen(infile{1});
      [bnl.pname,bnl.fname,ext] = fileparts(infile{1});
   else
      fid = fopen(infile);
      [bnl.pname,bnl.fname,ext] = fileparts(infile);
   end
   
   if isafile(infile)
      bnl.pname = {strrep([bnl.pname filesep],[filesep filesep],filesep)}; bnl.fname = {[bnl.fname, ext]};
      %   Label row, followed by first data row
      %    Date	Time	Inst. Date	Inst. Time	 Timebase	 RefCh1	 Sen1Ch1	 Sen2Ch1	 RefCh2	 Sen1Ch2	 Sen2Ch2	 RefCh3	 Sen1Ch3	 Sen2Ch3	 RefCh4	 Sen1Ch4	 Sen2Ch4	 RefCh5	 Sen1Ch5	 Sen2Ch5	 RefCh6	 Sen1Ch6	 Sen2Ch6	 RefCh7	 Sen1Ch7	 Sen2Ch7	 Flow1	 Flow2	 FlowC	assumed_pressure	assumed_temperature	BC_BrC 	 ContTemp	 SupplyTemp	 Status	 ContStatus	 DetectStatus	 LedStatus	 ValveStatus	 LedTemp	 BC11	 BC12	 BC1	 BC21	 BC22	 BC2	 BC31	 BC32	 BC3	 BC41	 BC42	 BC4	 BC51	 BC52	 BC5	 BC61	 BC62	 BC6	 BC71	 BC72	 BC7	 K1	 K2	 K3	 K4	 K5	 K6	 K7	 TapeAdvCount	Op Comm
      % UTC	UTC
      % yyyy-mm-dd	hh:mm:ss.sss	yyyy/MM/dd	hh:mm:ss	seconds																						ml/min	ml/min	ml/min	Pa	degC	ng/m3	degC	degC						degC
      %
      %
      % 2024-06-26	18:00:00.000	2024/06/26	18:00:00	60	934801	632453	787184	932028	605327	720964	929611	607233	714880	911243	607247	709396	917986	702701	799437	791279	838736	924637	852643	815538	928875	2930	1056	3986	101325	25.00	0	28	41	0	0	10	10	00000	30	187	232	194	156	164	161	183	217	187	152	138	154	130	141	130	140	147	136	167	199	163	0.002562285	0.002709014	0.002009132	0.001010028	-0.0004617775	-0.004752111	-0.005	310

      this = fgetl(fid);
      a = 1;
      this = []; that = []; thother = [];
      while isempty(strfind(this,'yyyy-mm-dd'))&&isempty(strfind(this,'hh:mm:ss.sss'))&&isempty(strfind(this,'YYMMDDhhmmss'))&&~feof(fid)
         %%
         thother = that;
         that = this;
         this = fgetl(fid);
         a = a + 1;
         %%
      end
      AA = textscan(thother, '%s','delimiter','\t');AA=AA{:};
      while a < 39
         tmp = fgetl(fid);
         a = a +1;
      end
      %    Date	Time	Inst. Date	Inst. Time	 Timebase	 RefCh1	 Sen1Ch1	 Sen2Ch1	 RefCh2	 Sen1Ch2	 Sen2Ch2	 RefCh3	 Sen1Ch3	 Sen2Ch3	 RefCh4	 Sen1Ch4	 Sen2Ch4	 RefCh5	 Sen1Ch5	 Sen2Ch5	 RefCh6	 Sen1Ch6	 Sen2Ch6	 RefCh7	 Sen1Ch7	 Sen2Ch7	 Flow1	 Flow2	 FlowC	assumed_pressure	assumed_temperature	BC_BrC 	 ContTemp	 SupplyTemp	 Status	 ContStatus	 DetectStatus	 LedStatus	 ValveStatus	 LedTemp	 BC11	 BC12	 BC1	 BC21	 BC22	 BC2	 BC31	 BC32	 BC3	 BC41	 BC42	 BC4	 BC51	 BC52	 BC5	 BC61	 BC62	 BC6	 BC71	 BC72	 BC7	 K1	 K2	 K3	 K4	 K5	 K6	 K7	 TapeAdvCount	Op Comm
      % Now iteratively try to compose the format string starting with "in_str" if
      % provided.

      flds = length(AA);
      fld = length(findstr(in_str,'%'));
      mark = ftell(fid); % identifies the location of the first data row
      scan_str = [in_str, '%f ', repmat('%f ',[1,flds-fld-1])]; % Test read with %f for float
      Aa = textscan(fid, scan_str,'delimiter','\t');
      while length(Aa{1})~=length(Aa{end}) && fld<flds
         in_str = [in_str, '%s '];
         fld = fld + 1;
         fseek(fid,mark,-1);
         scan_str = [in_str, '%f ', repmat('%f ',[1,flds-fld-1])];
         Aa = textscan(fid, scan_str,'delimiter','\t');
      end
      fclose(fid);
      D = Aa{1}; Aa(1) = [];
      T = Aa{1}; Aa(1) = [];
      for N = length(Aa{end}):-1:1
         DT(N) = {[D{N}, ' ', T{N}]};
      end
      try
         bnl.time = datenum(D,'yyyy-mm-dd HH:MM:SS.fff'); clear D;
      catch
         try
            bnl.time = datenum(D,'yyyy-mm-dd HH:MM:SS'); clear D;
         catch
            try
               bnl.time = datenum(DT,'yyyy-mm-dd HH:MM:SS.fff'); clear DT;
            catch
               bnl.time = datenum(DT,'yyyy-mm-dd HH:MM:SS'); clear DT;
            end
         end
      end
      for lab = 3:length(AA)

         bnl.(legalize_fieldname(AA{lab})) = Aa{1};
         Aa(1) = [];

      end

   else
      disp('No valid file selected.')
      return
   end
end
   % if ~isfield(bnl,'pname')&&~isfield(bnl,'fname')
   %    [pname, fname, ext] = fileparts(infile);
   %    bnl.pname = [pname, filesep];
   %    bnl.fname = [fname, ext];
   % elseif ~isfield(bnl,'filename')
   %    bnl.filename = infile;
   % else
   %    bnl.filename_ = infile;
   % end

 return

