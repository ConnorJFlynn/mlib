function caps = rd_bnl_tsv_caps(ins);

if ~isavar('ins') || isempty(ins)
   ins = getfullname('*.caps.*.00.*.raw.*','caps','select raw CAPS file');
end

if iscell(ins)&&length(ins)>1
   caps = rd_bnl_tsv_caps(ins{1});
   caps2 = rd_bnl_tsv_caps(ins(2:end));
   caps_.fname = unique([caps.fname,caps2.fname]);
   caps = cat_timeseries(caps, caps2);caps.fname = caps_.fname;
else
   if iscell(ins);
      fid = fopen(ins{1});
      [caps.pname,caps.fname,ext] = fileparts(ins{1});
   else
      fid = fopen(ins);
      [caps.pname,caps.fname,ext] = fileparts(ins);
   end
   caps.pname = {caps.pname}; caps.fname = {[caps.fname, ext]};
   this = fgetl(fid);
   
%    fid = fopen(ins);
   in = [];
   while (isempty(strfind(in,'Date'))||isempty(strfind(in,'Time')))&&~feof(fid)
      in = fgetl(fid);
   end
   cols = textscan(in,'%s','delimiter','\t'); cols = cols{:};
   in = fgetl(fid);in = fgetl(fid);in = fgetl(fid);in = fgetl(fid);
   data = textscan(fid,['%s %s ',repmat('%f ',[1,length(cols)-3]),'%f'],'delimiter','\t');
   fclose(fid);
   date = data{1}; UTC = data{2};
   for r = length(date):-1:1
      dates(r) = {[date{r}, ' ',UTC{r}]};
   end
   caps.time = datenum(dates,'yyyy-mm-dd HH:MM:SS.fff');
   
   for c = length(cols):-1:4
      if ~strcmp(cols{c},'Comments')&&~strcmp(cols{c},'Unused')
         caps.(cols{c}) = data{end};
      end
      data(end) = [];
   end
   

end
   
   return