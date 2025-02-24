function out = rd_in102_vi(infile);
% out = rd_in102_vi(infile); 
% Reads a supplied or selected Air Photon IN102 file from IN102 VI
% Written by Connor Flynn, OU, 2024-12-18, working


if ~isavar('infile')
   infile = getfullname('IN*.csv','in102','Select IN102 neph raw csv file.');
end

if iscell(infile)&&length(infile)>1
   [out] = rd_in102_vi(infile{1});
   [out2] = rd_in102_vi(infile(2:end));
   out_.fname = unique([out.fname, out2.fname]);
   out_.nm = [450, 530, 630]; !check
   if isfield(out,'nm') out = rmfield(out,'nm'); end
   if isfield(out2,'nm') out2 = rmfield(out2,'nm'); end

   out = cat_timeseries(out, out2);
   out.pname = out2.pname;
   out.fname = out_.fname;
   out.nm = out_.nm;
else
   if iscell(infile); infile = infile{1}; end

 % header = 'SN,DATE_TIME,YEAR,MONTH,DATE,HOUR,MINUTE,SECOND,RF_PMT,RF_REF,GF_PMT,GF_REF,BF_PMT,BF_REF,RB_PMT,RB_REF,GB_PMT,GB_REF,BB_PMT,BB_REF,TEMP,PRESSURE,RH,TEMP_RAW,PRESSURE_RAW,RH_RAW,PMT_DARK,FORW_DARK_REF,BACK_DARK_REF,BACK_SCATT_RED,BACK_SCATT_GREEN,BACK_SCATT_BLUE,TOTAL_SCATT_RED,TOTAL_SCATT_GREEN,TOTAL_SCATT_BLUE,FAN_RPM,FLOW_PRESSURE,FLOW,DAC,RF_CR,GF_CR,BF_CR,RB_CR,GB_CR,BB_CR,INDEX,CYCLE,TARGET_FLOW,SELECT,SAMPLE_COUNT,AMBIENT_COUNT';
 %   head_str = textscan(header,'%s','Delimiter',',');head_str = head_str{1};

   fid = fopen(infile,'r');
   header = fgetl(fid); header;
   head_str = textscan(header,'%s','Delimiter',',');head_str = head_str{1};
   fmt_str = ['%sIN%f%s',repmat('%f',[1,46]), '%s%f%f'];

   A = textscan(fid,fmt_str,'Delimiter',',','HeaderLines',1);
   fclose(fid);
   out.time = datenum(A{1},'yyyy-mm-dd HH:MM:SS'); A(1)= [];head_str(1) = [];
   out.SN = A{1};
   out.IN_time = datenum(A{2},'yyyy-mm-ddTHH:MM:SS');

   for col=9:51
      out.(head_str{col}) = A{col};
   end

   % figure; plot(out.time, out.TOTAL_SCATT_BLUE, 'x',out.time, out.TOTAL_SCATT_GREEN, 'o',out.time, out.TOTAL_SCATT_RED,'+'); dynamicDateTicks
   % legend('B_t_s_c_a(B)','B_t_s_c_a(G)','B_t_s_c_a(R)'); ylabel('Scattering [1/Mm]');
   [out.pname,out.fname, ext] = fileparts(infile);
   out.pname = [out.pname, filesep]; out.pname = strrep(out.pname, [filesep filesep], filesep);
   out.fname = {[out.fname, ext]};
end


end