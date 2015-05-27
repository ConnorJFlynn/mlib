function cpd = rd_noaa_cpd(infile)
% cpd = rd_noaa_cpd(infile);
% This function reads NOAA cpd2 files for CLAP and PSAP.  
% This is an difficult format and this code is not absolutely general but
% instead contains portions unique to each of these instrumennts.
if ~exist('infile','var')
   infile = getfullname__('*.*','noaa_cpd');
elseif ~exist(infile,'file')
   infile = getfullname__(infile,'noaa_cpd');
end
cpd = [];
fid = fopen(infile);
if fid>0
   [cpd.pname, cpd.fname, ext] = fileparts(infile);
   cpd.pname = [cpd.pname, filesep]; cpd.fname = [cpd.fname, ext];
else
   cpd.pname = []; cpd.fname = [];
end
while ~feof(fid)
   inline = fgetl(fid);
   if strcmp(inline(1),'!')
      A = textscan(inline(2:end),'%s','delimiter',';');
      A = A{:};
      if ~isempty(strfind(inline,'Area_m2,')) %note the comma after Area_m2.  
         % This is important to handle PSAP (with comma)
         % and CLAP (no comma)
         ii = strfind(inline,'Area_m2,');
         B = inline(ii+length('Area_m2,'):end); 
         C = textscan(B,'%f');
         cpd.Area_m2 = C{:};
      end
      if strcmp(A{1},'Area_m2')
         B = A{2}; C = textscan(B,'%f','delimiter',','); C = C{:};
         cpd.Area_m2(C(1)) = C(2);
      elseif strcmp(A{1},'row')
         B = A(2:end,1);
         if strcmp(B(1),'colhdr')
            hdr= B{2}; hdr_ = strtok(hdr,',');
            colhdr.(hdr_) = B([4:end]);
         elseif strcmp(B(1),'mvc')
            hdr= B{2}; hdr_ = strtok(hdr,',');
            mvc.(hdr_) = B([4:end]);
         elseif strcmp(B(1),'varfmt')
            hdr= B{2}; hdr_ = strtok(hdr,',');
            varfmt.(hdr_) = B([4:end]);
         end
      elseif strcmp(A{1},'var')
         if length(A)==3
            B = A{3}; C = textscan(B,'%s','delimiter',','); C = C{:};
            var.(A{2}).(C{1}) = C{2};
         else
            B = A{4}; C = textscan(B,'%f','delimiter',','); C = C{:};
            var.(A{2}).(A{3}) = C;
         end
      end
      
   else
      [hdr,tmp] = strtok(inline,',');[~,tmp] = strtok(tmp(2:end),',');
      cols = colhdr.(hdr);
      if ~isfield(cpd, hdr)
         n = 1;
      else
         n = length(cpd.(hdr).EPOCH) +1;
      end
      for col = 1:length(cols)
         [out,tmp] = strtok(tmp(2:end),',');
         if ~strcmp(cols(col),'DateTime')
            cvar = cols(col); cvar = cvar{:};
            fmt = strrep(varfmt.(hdr){col},'*@0','%');
            if strcmp(fmt(end),'f')
               fmt = '%f';
            end
            if strcmp(out,mvc.(hdr){col})
               cpd.(hdr).(cvar)(n) = NaN;
            else
               try
                  cpd.(hdr).(cvar)(n) = sscanf(out,fmt);
               catch
                  disp('Caught conversion error, filling with NaN')
                  cpd.(hdr).(cvar)(n) = NaN;
               end
            end
         end
      end
      
end
end
hdr = fieldnames(cpd);
for head = hdr'
   if isfield(cpd.(head{:}),'EPOCH')
      cpd.(head{:}).time = epoch2serial(cpd.(head{:}).EPOCH);
   end
end
fclose(fid);

cpd.row.mvc = mvc;
cpd.row.varfmt = varfmt;
cpd.row.colhdr = colhdr;
cpd.var = var;
return