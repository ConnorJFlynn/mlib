function in_file = read_avantes_trt(filename,quiet);
%This reads the Avantes csv data (trt) in the format provided via email
if ~exist('filename', 'var')
   filename= getfullname('*.trt','ascii');
   [pname, fname,ext] = fileparts(filename);
   fname = [fname,ext];
end
if ~exist('quiet','var')
   quiet = false;
end
% MASTER- Dummy Data
% Integration time: 10.00 ms
% Average: 1 scans
% Nr of pixels used for smoothing: 0
% Data measured with spectrometer name: Simulation Channel 0
% Wave   ,Dark     ,Ref      ,Sample   ,Absolute Irradiance  ,Photon Counts
% [nm]   ,[counts] ,[counts] ,[counts] ,[µWatt/cm²/nm]       ,[µMol/s/m²/nm]
% 214.50,0,95.711,520.86,17.959,0.3220
format_str = ['%f %f '];
fid = fopen(filename);
if fid>0
      [pname, fname,ext] = fileparts(filename);
   fname = [fname,ext];
   in_file.fname{1} = fname;
   in_file.pname = [pname,filesep];
   done = false;
   if ~exist('header_rows','var')
      header_rows = 0;
      tmp2 = [];
      while ~done
         tmp = fgetl(fid);

         if (~isempty(tmp)&&(~isempty(findstr(tmp2,'[nm]'))))||feof(fid)
            tmp2 =tmp;
            done = true;
         else
            tmp2 =tmp;
            header_rows = header_rows +1;
            if header_rows==1
               in_file.title{1} = tmp;
            end
            if ~isempty(findstr(lower(tmp),'dark'))
               in_file.dark = true;
            end
            if ~isempty(findstr(tmp,'Integration time:'))
               substr = tmp(1+findstr(tmp,'Integration time:')+length('Integration time:'):end);
               in_file.tint = sscanf(substr,'%f');
            elseif any(findstr(tmp,'Average:'))
               substr = tmp(findstr(tmp,'Average:')+length('Average:'):end);
               in_file.Nsamples = sscanf(substr,'%f');
            elseif any(findstr(tmp,'Nr of pixels used for smoothing:'))
               substr = tmp(findstr(tmp,'Nr of pixels used for smoothing:')+length('Nr of pixels used for smoothing:'):end);
               in_file.AdjacentPixels = sscanf(substr,'%d');
            elseif any(findstr(tmp,'Data measured with spectrometer name:'))
               substr = tmp(findstr(tmp,'Data measured with spectrometer name:')+length('Data measured with spectrometer name:'):end);
               substr = deblank(substr);
               [beg,rest] = strtok(substr,' ');
               if ~isempty(findstr(upper(beg),'AVASPEC'))
                  in_file.Spec_desc{1} = strtok(rest);
               else
                  in_file.Spec_desc{1} = beg;
               end
            elseif any(findstr(tmp,'Timestamp [10 microsec ticks]'))
               substr = tmp(findstr(tmp,'Timestamp [10 microsec ticks]')+length('Timestamp [10 microsec ticks]'):end);
               substr = deblank(substr);
               in_file.timestamp = double(sscanf(substr,'%ld'));
               
            elseif findstr(tmp,'Wave')==1
               label_ii = findstr(tmp,';');
               label{1} = 'nm';
               label{length(label_ii)+1} = tmp(label_ii(end)+1:end);
               for ii = 1:length(label_ii)-1
                  label{ii+1} = tmp(label_ii(ii)+1:label_ii(ii+1)-1);
               end
            end
         end
         in_file.header{1}{header_rows} = tmp;         
      end      
   end
   if ~isfield(in_file,'dark')
      in_file.dark = false;
   end
   in_file.header_rows = header_rows;
   fseek(fid,0,-1);
   txt = textscan(fid,format_str,'headerlines',header_rows,'delimiter',';','treatAsEmpty','N/A');
   sizes = size(txt{1});
   spec_len = max([sizes(sizes==256),sizes(sizes==2048),sizes(sizes==808)]);
   spec_len  = max(sizes);
   for ii = 1:length(txt)
      
      in_file.(label{ii}) = NaN(1,spec_len);
      in_file.(label{ii})(1:length(txt{ii})) =  txt{ii};
      
   end
   in_file.good = ~isnan(in_file.nm);
   if ~quiet
   figure(9);
%    figure;
   ax(1) = subplot(2,1,1); 
   plot(in_file.nm, in_file.(label{2}),'-');
   title({['Filename: ', char(in_file.fname)]  ['Spectrometer label: ' char(in_file.Spec_desc)]},'interp','none');
   
   ax(2) = subplot(2,1,2);
   semilogy(in_file.nm, in_file.(label{2}),'-');
   title({char(in_file.title),...
      ['t_int =',sprintf('%4.1f',in_file.tint), ...
      ', timestamp (us)=',sprintf('%1.2f',in_file.timestamp*1e-5./(60*60))]},...
      'interp','none')
   linkaxes(ax,'x');
%    mn = menu('Hit enter','Y');
   end
end
fclose(fid);
return;
