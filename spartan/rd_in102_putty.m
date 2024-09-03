function out = rd_in102_putty(infile);
% out = rd_in102_raw(infile);
% Reads a supplied or selected Air Photon IN102 Nephelometer file
% Written by Connor Flynn, OU, 2024-08-19, working
% TBD: make recursive to bundle multiple selected files.

if ~isavar('infile')
   infile = getfullname('*IN*.dat;*AP*.dat','in102','Select IN102 neph raw csv file.');
end
if iscell(infile)&&length(infile)>1
   [out] = rd_in102_putty(infile{1});
   [out2] = rd_in102_putty(infile(2:end));
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
   fid = fopen(infile,'r');

   header = 'SN,DATE_TIME,YEAR,MONTH,DATE,HOUR,MINUTE,SECOND,RF_PMT,RF_REF,GF_PMT,GF_REF,BF_PMT,BF_REF,RB_PMT,RB_REF,GB_PMT,GB_REF,BB_PMT,BB_REF,TEMP,PRESSURE,RH,TEMP_RAW,PRESSURE_RAW,RH_RAW,PMT_DARK,FORW_DARK_REF,BACK_DARK_REF,BACK_SCATT_RED,BACK_SCATT_GREEN,BACK_SCATT_BLUE,TOTAL_SCATT_RED,TOTAL_SCATT_GREEN,TOTAL_SCATT_BLUE,FAN_RPM,FLOW_PRESSURE,FLOW,DAC,RF_CR,GF_CR,BF_CR,RB_CR,GB_CR,BB_CR,INDEX,CYCLE,TARGET_FLOW,SELECT,SAMPLE_COUNT,AMBIENT_COUNT';
   head_str = textscan(header,'%s','Delimiter',',');head_str = head_str{1};

   % test = 'IN1078,2000-08-19T01:01:56,2000,8,19,1,1,56,3102767,45650307,2526936,13696267,4312866,20335290,2503036,50278996,2151875,14348155,3201577,25850026,25.07,97.45,43.4,27.23,87.04,48.5,1527909,1950356,1976757,1.446922007317,1.293429030845,1.356196431002,10.031450309719,11.809886524328,15.613908654806,0,,,,,,,,,,80,1,2.5,CR,33000,100';
   % test_str = textscan(test,'%s','Delimiter',','); test_str = test_str{1};

   tmp = fgetl(fid);
   fmt_str = ['IN%f %s ',repmat('%f ',[1,46]), '%s %f %f'];
   A = textscan(fid,fmt_str,'Delimiter',',');
   fclose(fid);
   out.SN = A{1};
   out.time = datenum(A{2},'yyyy-mm-ddTHH:MM:SS');
   if out.time(1)<datenum(2020,1,1)
      V = datevec(out.time); 
      V(:,1) = 2024;
      out.time = datenum(V);
   end

   for col=9:51
      out.(head_str{col}) = A{col};
   end

   figure; plot(out.time, out.TOTAL_SCATT_BLUE, 'x',out.time, out.TOTAL_SCATT_GREEN, 'o',out.time, out.TOTAL_SCATT_RED,'+'); dynamicDateTicks
   legend('B_t_s_c_a(B)','B_t_s_c_a(G)','B_t_s_c_a(R)'); ylabel('Scattering [1/Mm]');

   [out.pname,out.fname, ext] = fileparts(infile);
   out.pname = [out.pname, filesep]; out.pname = strrep(out.pname, [filesep filesep], filesep);
   out.fname = {[out.fname, ext]};
end
end
