function files = ARM_order(mask,str_date,end_date,savedir)
% files = ARM_order(mask,str_date,end_date,savedir)
% mask (required):datastream name with site, stream, facility, and level
% str_date (optional): start date in yyyy-mm-dd format; default yesterday
% end_date (optional): end date in yyyy-mm-dd format; default today
% savedir (optional): prompted if not provided
% data = webread(['https://adc.arm.gov/armlive/data/query?user=flynn:6a983c5a089b42f8&ds=sgpaospass3wC1.a1&start=2015-06-25&end=2015-10-01'])
if ~isavar('mask')||isempty(mask)
   mask = ['sgpaosclap3w1mC1.b1'];
end
if ~isavar('sdate')
   str_date = [datestr(now-1,'yyyy-mm-dd')];
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

host = ['https://adc.arm.gov/armlive/data/'];
% To get the userkey, go here to login: https://adc.arm.gov/armlive/register
usr = ['user=cflynn:6987a3ff021446b7'];
reqst = ['query?',usr];
ds = ['&ds=',mask];
if isavar('mask')&&~isempty(mask)&&~isempty(findstr(mask,'.'))
   ds = ['&ds=',mask];
end

data = jsondecode(char(webread([host,reqst,ds,sdate,edate, '&wt=json']))');
if ~isempty(data.files)
   if ~isavar('savedir')||~isadir(savedir)
      savedir = [uigetdir,filesep];
   end
end
req = ['saveData?',usr];
for f = 1:length(data.files)
   fid = fopen([savedir,data.files{f}],'w+'); fwrite(fid,webread([host,req,data.files{f}])); fclose(fid);
end


files = data.files{:};

return