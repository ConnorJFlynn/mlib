function files = getARMfiles(mask,str_date,end_date,savedir)
% files = getARMfiles(mask,str_date,end_date,savedir)
% mask (required):datastream name with site, stream, facility, and level
%   [A blank or empty mask will prompt user for ARM user ID and recover token]
% str_date (optional): start date in yyyy-mm-dd format; default yesterday
% end_date (optional): end date in yyyy-mm-dd format; default today
% savedir (optional): prompted if not provided
%   [A blank savedir will only display file list.]

% Connor J. Flynn, Univerity of Oklahoma
% getARMfiles v1.0, 2023-02-17
% Queries the ARM Archive to generate a list of files found between start_date and
% end_date for a user-specified datastream.  Files will be retrieved and saved to a
% target directory if provided.

%% This block identifies which input arguments were provided and either prompts the
%% user or adopts reasonable defaults

if nargin==0
   help('getARMfiles');
else

   if isempty(mask)
      % If no mask is supplied, set the ARM user token
      files = setARMusertoken;
   else
      if ~isavar('str_date')
         if isavar('savedir') % if savedir supplied, default str_date to yesterday if not supplied
            str_date = [datestr(now-1,'yyyy-mm-dd')];
         else
            str_date = '1990-01-01'; %If both empty, assume display so default to beginning of ARM
         end
      end
      if isavar('str_date')&&~isempty(str_date)&&length(strfind(str_date,'-'))==2
         sdate = ['&start=',str_date];
      end
      if ~isavar('end_date')
         end_date  = [datestr(now, 'yyyy-mm-dd')];
      end
      if isavar('end_date')&&~isempty(end_date)&&length(strfind(end_date,'-'))==2
         edate = ['&end=',end_date];
      end

      %% This block assembles the pieces needed construct the query and
      %% call ARMLive
      host = ['https://adc.arm.gov/armlive/data/'];
      % To get the userkey, go here to login: https://adc.arm.gov/armlive/register
      usr = ['user=',getARMusertoken];
      reqst = ['query?',usr];
      ds = ['&ds=',mask];
      if isavar('mask')&&~isempty(mask)&&~isempty(strfind(mask,'.'))
         ds = ['&ds=',mask];
      end


      %% This block sends the query and parses the json return
      data = jsondecode(char(webread([host,reqst,ds,sdate,edate, '&wt=json']))');
      if ~isempty(data.files)
         if ~isavar('savedir')||~isadir(savedir)
            reset = true;
            [savedir] = getfilepath(mask,['Select save path for ',mask,'.  [Select "Cancel" to just display file list]'],reset);
            %       savedir = [uigetdir,filesep];
         else
            % Catch missing filesep terminator
            savedir = strrep([savedir, filesep],[filesep,filesep],filesep);
         end
      end

      %Now display files (if savedir is empty)
      if ~isavar('savedir')||isempty(savedir)
         disp(data.files(:))
      else
         % Or download the files one at a time to savedir
         req = ['saveData?',usr,'&file='];
         N = length(data.files);
         for f = 1:N
            disp(['Retrieving ',num2str(f),' of ',num2str(N),': ',data.files{f}])
            fid = fopen([savedir,data.files{f}],'w+'); fwrite(fid,webread([host,req,data.files{f}])); fclose(fid);
         end
      end

      files = data.files(:);
   end
end
return