function out = rd_in102_raw(infile);
% out = rd_in102_raw(infile); 
% Reads a supplied or selected Air Photon IN102 Nephelometer file
% Written by Connor Flynn, OU, 2022-08-03, working
% TBD: make recursive to bundle multiple selected files.

if ~isavar('infile')
   infile = getfullname('IN*.csv','in102','Select IN102 neph raw csv file.');
end

if iscell(infile)&&length(infile)>1
   [out] = rd_in102_raw(infile{1});
   [out2] = rd_in102_raw(infile(2:end));
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

   header = fgetl(fid); header;
   head_str = textscan(header,'%s','Delimiter',',');head_str = head_str{1};
   fmt_str = ['IN%f %s ',repmat('%f ',[1,46]), '%s %f %f'];
   A = textscan(fid,fmt_str,'Delimiter',',');
   fclose(fid);
   out.SN = A{1};
   out.time = datenum(A{2},'yyyy-mm-ddTHH:MM:SS');

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