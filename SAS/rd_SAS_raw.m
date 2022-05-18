function sas = rd_SAS_raw(ins,plots)
% Read SAS instrument-raw data
% sas = rd_raw_SAS(infile, plots)
% 2022 updating to handle files with irregular lengths
if ~isavar('ins')||isempty(ins)
   ins = getfullname_('*raw*.csv','sas', 'Select raw sas/sws file(s)');
end

if iscell(ins)&&length(ins)>1
   [sas] = rd_SAS_raw(ins{1});
   [sas2] = rd_SAS_raw(ins(2:end));
   if isempty(sas)&&~isempty(sas2)
      sas = sas2;
   elseif ~isempty(sas)&&~isempty(sas2)       
       sas_.fname = unique([sas.fname,sas2.fname]);
       sas = cat_timeseries(sas, sas2);sas.fname = sas_.fname;
   end
else
   if iscell(ins);
      fid = fopen(ins{1});
      [sas.pname,sas.fname,ext] = fileparts(ins{1});
   else
      fid = fopen(ins);
      [sas.pname,sas.fname,ext] = fileparts(ins);
   end
   sas.pname = {strrep([sas.pname filesep],[filesep filesep],filesep)}; sas.fname = {[sas.fname, ext]};
   in = [];
   
   if fid>0
%       [pname, fname,ext] = fileparts(infile);
%       fname = [fname,ext];
      %    sas.fname{1} = fname;
      %    sas.pname = [pname,filesep];
      tmp = fgetl(fid);
      sas.header = {};
      r = 1;
      while strcmp(tmp(1),'%')
         sas.header(r,1) = {tmp};
         tmp = fgetl(fid);
         r = r+1;
      end
      labels = textscan(tmp,'%s','delimiter',',');
      labels = labels{:};
      labels = strrep(labels,' ','');
      sas.labels = labels;
      
      %%
      fseek(fid,0,-1);
      txt = textscan(fid,(repmat('%f ',size(labels'))),'headerlines',r,'delimiter',',','treatAsEmpty','Infinity');
      fclose(fid);
      %%
      sas.time = datenum([txt{1},txt{2},txt{3},txt{4},txt{5},txt{6}]);
      if length(sas.time)>0
      for h = 1:length(sas.header)
         test_str = '_coefs = [';
         str_ii = findstr(sas.header{h},test_str);
         if ~isempty(str_ii)
            tmp_str = sas.header{h};
            tmp_str = tmp_str(str_ii+length(test_str):end);
            sas.lambda_fit = textscan(tmp_str,'%f','delimiter',':');
            sas.lambda_fit = sas.lambda_fit{:};
         end
         %         pix_range = findstr(sas.header{h},'Pixels [first:last]');
         test_str = '% Pixels [first:last] = [';
         str_ii = findstr(sas.header{h},test_str);
         if ~isempty(str_ii)
            tmp_str = sas.header{h};
            tmp_str = tmp_str(str_ii+length(test_str):end);
            sas.pix_range = textscan(tmp_str,'%f','delimiter',':');
            sas.pix_range = sas.pix_range{:};
         end
      end
      sas.wl = polyval(flipud(sas.lambda_fit), (sas.pix_range(1):sas.pix_range(2)));
      
      pix_start = find(strcmp(labels,sprintf('Px_%d',sas.pix_range(1))));
      pixels = length(labels)-pix_start+1;
      for p = pixels:-1:1
          sas.spec(:,p) = txt{pix_start +p-1};
      end
      for r = 7:pix_start-1
          sas.(labels{r}) = txt{r};
      end
      sas.sig = NaN(size(sas.spec));
      [rows,cols] = size(sas.spec(sas.Shutter_open_TF==1,:));
      % Improve darks, take mean of contiguous darks, interpolate between
      % mean values
      dark_start = zeros(size(sas.time)); dark_start(1) = sas.Shutter_open_TF(1)==0;
      dark_start(2:end) = sas.Shutter_open_TF(1:end-1)==1 & sas.Shutter_open_TF(2:end)==0;
      ds = sum(dark_start);
      dark_start = cumsum(dark_start); dark_start(sas.Shutter_open_TF==1) = 0;
      if ds == 1
          dtime = sas.time(dark_start==ds);
          darks = sas.spec(dark_start==ds,:);
          tint = sas.t_int_ms(dark_start==ds);
      else        
          for d = ds:-1:1
              dtime(d) = mean(sas.time(dark_start==d));
              if sum(dark_start==d)>1
                  darks(d,:) = mean(sas.spec(dark_start==d,:));
              else 
                 darks(d,:) = sas.spec(dark_start==d,:);
              end
              tint(d) = mean(sas.t_int_ms(dark_start==d));
          end
      end
%       if length(dtime)==1
%           dtime  = [sas.time(1);dtime];darks = [darks;darks]; tint = [tint;tint];
%       end
      tints = unique(tint);
      if length(dtime)>1
         for ti = length(tints):-1:1
            if sum(tint==tints(ti))>1
            sas.darks(sas.t_int_ms==tints(ti),:) = interp1(dtime(tint==tints(ti)), ...
               darks(tint==tints(ti),:), sas.time(sas.t_int_ms==tints(ti)),'linear','extrap');
            else
               sas.darks(sas.t_int_ms==tints(ti),:) = ones([sum(sas.t_int_ms==tints(ti)),1]) * darks(tint==tints(ti),:);
            end
            %          nans = isNaN(sas.darks(sas.t_int_ms==tints(ti),:));
            %          darks_nonans = interp1(dtime(tint==tints(ti)), ...
            %             darks(tint==tints(ti),:), sas.time(sas.t_int_ms==tints(ti)),'nearest','extrap');
            %          sas.darks(nans) = darks_nonans(nans);
         end
      else
          sas.darks = ones(size(sas.time))*darks;
      end
      
%       figure_(199); plot(sas.time(sas.Shutter_open_TF==0), sas.spec(sas.Shutter_open_TF==0,100),'-',sas.time, sas.darks(:,100),'.')
      sas.sig = sas.spec - sas.darks;
      sas.rate = sas.sig ./ (sas.t_int_ms * ones([1,cols]));
      % This line added to handle Zeiss / Tec5 (SWS) spectrometers with
      % flipped InGaAs arrays
      if sas.wl(1)>sas.wl(2)
         sas.wl = fliplr(sas.wl);
         %        sas.spec = fliplr(sas.spec);
      end
      else
       sas = [];
   end
   end
end
if isavar('plots') && plots && ~isempty(sas)
   figure_(2000); these = plot(sas.wl, sas.sig(sas.Shutter_open_TF==1,:),'-');
   recolor(these,[1:sum(sas.Shutter_open_TF==1)]);
   figure_(2001);these = plot(sas.wl, sas.rate(sas.Shutter_open_TF==1,:),'-');
   recolor(these,sas.t_int_ms(sas.Shutter_open_TF==1))
   recolor(these,[1:sum(sas.Shutter_open_TF==1)]);
   if iscell(sas.fname)&&length(sas.fname)>0
      fname = {['start: ',sas.fname{1}]; ['end :',sas.fname{end}]};
   else
      fname = sas.fname;
   end
   
   figure_(1001); plot(sas.wl, mean(sas.spec(sas.Shutter_open_TF==1,:))-mean(sas.spec(sas.Shutter_open_TF==0,:)),'-');
   title(fname, 'interp','none');
   
   figure_(1002); plot(sas.wl, sas.spec(sas.Shutter_open_TF==0,:),'-');
   title(fname, 'interp','none');
   
   figure_(1003); those = plot(sas.wl, sas.rate(sas.Shutter_open_TF==1,:),'-');
   recolor(those,[1:sum(sas.Shutter_open_TF==1)]);
end
%%

return
