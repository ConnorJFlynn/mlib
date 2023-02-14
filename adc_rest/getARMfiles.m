function files = getARMfiles(mask,str_date,end_date,savedir)
% files = getARMfiles(mask,str_date,end_date,savedir)
% mask (required):datastream name with site, stream, facility, and level
% str_date (optional): start date in yyyy-mm-dd format; default yesterday
% end_date (optional): end date in yyyy-mm-dd format; default today
% savedir (optional): prompted if not provided
% first time will prompt for ARM user ID with instructions to obtain token

%% This block identifies which input arguments were provided and either prompts the
%% user or adopts reasonable defaults

if ~isavar('mask')||isempty(mask)
   mask = ['sgpaosclap3w1mC1.b1'];
end
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


%% This block sends thh query and parses the json return
data = jsondecode(char(webread([host,reqst,ds,sdate,edate, '&wt=json']))');
if ~isempty(data.files)
   if ~isavar('savedir')||~isadir(savedir)
      reset = true;
      [savedir] = getfilepath(mask,['Select save path for ',mask,'.  [Cancel to just see file list]'],reset);
%       savedir = [uigetdir,filesep];
   else
      % Catch missing filesep terminator
      savedir = strrep([savedir, filesep],[filesep,filesep],filesep);
   end
end

%Now display files (if savedir is empty) 
if isempty(savedir)
   disp(data.files(:))
else
   % Or download the files one at a time to savedir
   req = ['saveData?',usr,'&file='];
   for f = 1:length(data.files)
      fid = fopen([savedir,data.files{f}],'w+'); fwrite(fid,webread([host,req,data.files{f}])); fclose(fid);
   end
end

files = data.files(:);

return