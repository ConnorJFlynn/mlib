function ins = SAS_read_ava(infile)
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

% figure; 
%  plot(serial2Hh(ins.time), [ins.Temp],'-')
%%
% figure; plot(ins.nm, ins.spec,'-')
%%

clear lines;

ins.sig = ins.spec(ins.Shuttered_0==1,:)- (ones([sum(ins.Shuttered_0==1),1])*mean(ins.spec(ins.Shuttered_0==0,:)));
ins.norm = ins.sig ./(ones([sum(ins.Shuttered_0==1),1])*max(ins.sig));
down.nm = downsample(ins.nm,10);
down.spec = downsample(ins.spec,10,2);
down.sig = down.spec(ins.Shuttered_0==1,:)- (ones([sum(ins.Shuttered_0==1),1])*mean(down.spec(ins.Shuttered_0==0,:)));
down.norm = down.sig ./(ones([sum(ins.Shuttered_0==1),1])*max(down.sig));
degs = ins.Angle(ins.Shuttered_0==1);
% figure; 
% plot([1:length(degs)],degs,'o-');
% zed = find(degs==0,1,'first');
%%
figure; 
% s(1) = subplot(2,1,1);
lines = plot(degs, down.norm(:,20:125)' , '-'); 
%
%
recolor(lines',down.nm(20:125));
colorbar
%%
% s(2) = subplot(2,1,2);

lines = semilogy(degs, ins.norm(:,350:1200)' , '-'); 
recolor(lines,ins.nm(350:1200));colorbar
%%
title('SAS-Ze FOV test at PNNL, Si CCD');
ylabel('normalized signal');
xlabel('degrees off-axis');
%%
saveas(gcf, [pname, filesep, 'SASZe_FOV_test_at_PNNL.liny.png'])
% linkaxes(s,'xy')
%%
degs = ins.Angle(ins.Shuttered_0==1);
figure; 
plot([1:length(degs)],degs,'o-');
zed = find(degs==max(degs),1,'first');
figure; s(1) = subplot(2,1,1);
lines = semilogy(degs(1:zed), ins.norm(1:zed,:)' , '-'); 
recolor(lines,ins.nm);colorbar
s(2) = subplot(2,1,2);
lines = semilogy(degs(zed:end), ins.norm(zed:end,:)' , '-'); 
recolor(lines,ins.nm);colorbar
linkaxes(s,'xy')
%%

return
