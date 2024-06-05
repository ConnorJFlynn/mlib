function caps = rd_caps_ssa_raw(ins);

if ~isavar('ins') || isempty(ins)
   ins = getfullname('*_SN*.dat','caps_ssa','select raw CAPSssa file');
end

if iscell(ins)&&length(ins)>1
   caps = rd_caps_ssa_raw(ins{1});
   caps2 = rd_caps_ssa_raw(ins(2:end));
   caps_.fname = unique([caps.fname,caps2.fname]);
   caps_.header = unique([caps.header,caps2.header]);

   caps = cat_timeseries(caps, caps2);
   caps.fname = caps_.fname; caps.header = caps_.header;
else
   if iscell(ins);
      [caps.pname,caps.fname,ext] = fileparts(ins{1});
      fid = fopen(ins{1});
   else
      [caps.pname,caps.fname,ext] = fileparts(ins);
      fid = fopen(ins);
   end
   caps.pname = {caps.pname}; caps.fname = {[caps.fname, ext]};

   % %             0            0
   % IgorTime,Extinction,Scattering,Loss,Pressure,Temperature,Signal,LossRef,Status,WC,SignalRef,RawScatRef,RawScat,SDR,WCRef,Timestamp
   % 3779968199.161,0.339,0.004,523.431,751.62,297.73,96679,465.568,10132,0.280,96837.065,29323.129,29294,0,0.280,2023/10/12 15:10:00.481
   in = fgetl(fid);
   caps.header = {};
   while fid>0 && ~feof(fid) && ~isempty(in) && strcmp(in(1),'%')
      caps.header(end+1) = {in};
      in = fgetl(fid);
   end

   while (isempty(strfind(in,'IgorTime')))&&~feof(fid)
      in = fgetl(fid);
   end
   cols = textscan(in,'%s','delimiter',','); cols = cols{:};
   fmt = '';
   for c = 1:length(cols)
      if strcmp(cols{c},'Timestamp')
         fmt = [fmt, '%s'];
      else
         fmt = [fmt, '%f'];
      end
   end

   dat = textscan(fid,fmt,'delimiter',',');


   fclose(fid);
   caps.time = igor2serial(dat{1});
   caps.timestamp = datenum(dat{end},'yyyy/mm/dd HH:MM:SS.FFF');
   for c = 2:length(cols)-1
      caps.(legalize_fieldname(cols{c})) = dat{c};
   end
end

return