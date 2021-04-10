function neph = rd_tsv_neph(ins);

if ~isavar('ins') || isempty(ins)
   ins = getfullname('*neph.*.00.*.raw.*','neph','select raw NEPH file');
end

if iscell(ins)&&length(ins)>1
   neph = rd_tsv_neph(ins{1});
   neph2 = rd_tsv_neph(ins(2:end));
   neph_.fname = unique([neph.fname,neph2.fname]);
   neph = cat_timeseries(neph, neph2);neph.fname = neph_.fname;
else
   if iscell(ins);
      [neph.pname,neph.fname,ext] = fileparts(ins{1});
      fid = fopen(ins{1});
   else
      [neph.pname,neph.fname,ext] = fileparts(ins);
      fid = fopen(ins);
   end
    neph.pname = {neph.pname}; neph.fname = {[neph.fname, ext]};
   in = [];
   while (isempty(strfind(in,'Date'))||isempty(strfind(in,'Time')))&&~feof(fid)
      in = fgetl(fid);
   end
   cols = textscan(in,'%s','delimiter','\t'); cols = cols{:};
   in = fgetl(fid);in = fgetl(fid);in = fgetl(fid);in = fgetl(fid);
   data = textscan(fid,['%s %s ',repmat('%f ',[1,length(cols)-3]),'%f'],'delimiter','\t');
   fclose(fid);
   data(1)= {char(data{1})};
   data(2)= {char(data{2})};
   
   T = [data{1},repmat(' ',[length(data{7}),1]), data{2}];
   neph.time = datenum(T,'yyyy-mm-dd HH:MM:SS.fff');
   
   for c = length(cols):-1:9
      cols(c) = {legalize_fieldname(cols{c})};
      if ~strcmp(cols{c},'Comments')&&~strcmp(cols{c},'Unused')
         neph.(cols{c}) = data{end};
      end
      data(end) = [];
   end
end

return