function ins = SAS_read_Albert_csv(infile)
%ins = SAS_read_ava(infile)
% Reads one of Albert's Labview files for with multiple AvaSpec spectra per data file.
%
if ~exist('infile','var')
   infile= getfullname_('*.csv','ascii');
end
[pname, fname,ext] = fileparts(infile);
fname = [fname,ext];
fid = fopen(infile);
if fid>0
   [pname, fname,ext] = fileparts(infile);
%    [dmp,sn] = strtok(fname,'_');
%    ins.sn = sn(2:end);
   fname = [fname,ext];
   ins.fname{1} = fname;
   ins.pname = [pname,filesep];

   done = false;
   if ~exist('header_rows','var')      
      tmp = fgetl(fid);
      header_row{1} = [];
      while strcmp(tmp(1),'%')
         header_row{end+1} = tmp;
         tmp = fgetl(fid);
      end
      header_row(1)= [];
      labels = textscan(tmp,'%s','delimiter',',');
      labels = labels{:};
      labels = strrep(labels,' ','');
%       data_start = ftell(fid);
%       tmp2 = fgetl(fid);
%       fseek(fid,data_start,-1);
%       test_nums = textscan(tmp2,'%s','delimiter',',');
      
      
      format_str = repmat('%f ',[1,length(labels)]);
      fseek(fid,0,-1);
      txt = textscan(fid,format_str,'headerlines',length(header_row)+1,'delimiter',',','treatAsEmpty','tag');
      ins.time = datenum([txt{1},txt{2},txt{3},txt{4},txt{5},txt{6}]);
      ins.nth = [1:length(ins.time)]';
      x = 1;
      while isempty(findstr(labels{x},'nm_'))&&isempty(findstr(labels{x},'Px_'))
         x = x + 1;
      end
      for z = 7:(x-1) % skip the first six date/time labels
         ins.(labels{z}) = txt{z};
      end
      y = length(labels)-x+1;
      if ~isempty(findstr(labels{x},'nm_'))
         while y > 0
            lab = labels{y+x-1};
            ins.nm(y) = sscanf(lab,'nm_%f');
            ins.spec(:,y) = txt{y+x-1};
            txt(y+x-1) = [];
            y = y-1;

         end
      elseif ~isempty(findstr(labels{x},'Px_'))
         while y >= x
%             lab = labels{y};
            ins.spec(:,y) = txt{y+x-1};
            y = y-1;
         end
      end
      
   end
   fclose(fid);
end
%%
if ~isfield(ins,'nm')
row = length(header_row);done = false;
while row>0&~done
   if ~isempty(strfind(header_row{row},'Lambda'))
      lam_row = header_row{row};
      lam_row = strrep(lam_row,':',' ');[~, lam_row] = strtok(lam_row,'[');
      P = textscan(lam_row(2:end),'%f');
      P = P{:}; 
      N = length(P);
      pixel = [0:size(ins.spec,2)-1];
      ins.nm = zeros(size(pixel));
      for n = 1:N
         ins.nm = ins.nm + P(n).*(pixel.^(n-1));
      end
      done = true;
   end
   row = row -1;
end
end
      

if isfield(ins, 'Shutter_open_TF')
   ins.Shuttered_0 = ins.Shutter_open_TF;
end
darks = mean(ins.spec(ins.Shuttered_0==0,:)); lights = mean(ins.spec(ins.Shuttered_0==1,:));
if sum(ins.Shuttered_0==0)>0&&sum(ins.Shuttered_0==1)>0
figure; 
ax(1) = subplot(2,1,1);
 these = semilogy(ins.nm, lights-darks, 'b-');
 ax(2) = subplot(2,1,2);
 these = plot(ins.nm, lights-darks, 'b-');
 linkaxes(ax,'x');
end

 

%%

return
