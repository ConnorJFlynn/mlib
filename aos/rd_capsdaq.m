function caps = rd_capsdaq(ins)

if ~isavar('ins')
   ins = getfullname('CAPS*.dat','caps_amice','Select AMICE CAPS file.');
end

if iscell(ins)&&length(ins)>1
   [caps] = rd_capsdaq(ins{1});
   [caps2] = rd_capsdaq(ins(2:end));
   caps_.fname = unique([caps.fname, caps2.fname]);
   caps_.nm = [450, 530, 630];
   if isfield(caps,'nm') caps = rmfield(caps,'nm'); end
   if isfield(caps2,'nm') caps2 = rmfield(caps2,'nm'); end
   
   caps = cat_timeseries(caps, caps2);
   caps.pname = caps2.pname;
   caps.fname = caps_.fname;
   caps.nm = caps_.nm;
else
   if iscell(ins); ins = ins{1}; end
   if isafile(ins)
      % First read all commented header into
      % %         23755        23502        23251
      % HHMMSS,Extinction_Red,Loss_Red,Pressure_Red,Temperature_Red,Signal_Red,Span_Red,Status_Red,LastBaseline_Red,Extinction_Green,Loss_Green,Pressure_Green,Temperature_Green,Signal_Green,Span_Green,Status_Green,LastBaseline_Green,Extinction_Blue,Loss_Blue,Pressure_Blue,Temperature_Blue,Signal_Blue,Span_Blue,Status_Blue,LastBaseline_Blue,Timestamp
      % 202736,0.159,394.354,734.12,303.51,379983,0.79,10026,395.098,1.118,477.786,737.25,303.51,309610,0.79,10025,477.773,-3.191,458.153,737.15,303.51,394658,0.79,10024,461.544,2024/08/03 20:27:38.365
      fid = fopen(ins);
      in = fgetl(fid); n = 0;
      while ~feof(fid)&&strcmp('%',in(1))
         n = n+1;
         header(n) = {in};
         in = fgetl(fid);
      end
      if strcmp(in(1:6),'HHMMSS')
         labels = textscan(in,'%s','delimiter',','); labels = labels{1};
      end
      fmt = [repmat('%f ',[1,length(labels)-1]), '%s'];
      A = textscan(fid,fmt,'delimiter',',');
      fclose(fid);
      DT = A{end};
      caps.time = datenum(DT,'yyyy/mm/dd HH:MM:SS.fff');
      for L = 2:length(labels)
         caps.(labels{L}) = A{L};
      end

   else
      disp('No valid file selected.')
      return
   end
   caps.Bep = [caps.Extinction_Blue, caps.Extinction_Green, caps.Extinction_Red];
   caps.Loss = [caps.Loss_Blue, caps.Loss_Green, caps.Loss_Red];
   [caps.pname,caps.fname, ext] = fileparts(ins);
   caps.pname = [caps.pname, filesep]; caps.pname = strrep(caps.pname, [filesep filesep], filesep);
   caps.fname = {[caps.fname, ext]};
end
end

