function covid = rd_covid

infile = getfullname('time_series_covid19_deaths_US.txt','covid');
fid = fopen(infile,'r+');
fseek(fid,0,-1);
head = fgetl(fid); 
head_label = textscan(head,'%s','delimiter',',');
% UID,iso2,iso3,code3,FIPS,Admin2,Province_State,Country_Region,Lat,Long_,Combined_Key,Population
% 84001001,US,USA,840,1001.0,Autauga,Alabama,US,32.53952745,-86.64408227,"Autauga, Alabama, US",55869,
ndays = length(head_label{1})-12;
fmt_str = ['%d %s %s %f %f %s %s %s %f %f %s %s %s %f',repmat(' %f',[1,ndays])];
A = textscan(fid,fmt_str,'delimiter',',');
fclose(fid);
comb = A{11}; comb2 = A{12};comb3 = A{13}; UID = A{1};
covid.us.UID = A{1}; A(1) = [];
covid.us.iso2 = A{1}; A(1) = [];
covid.us.iso3 = A{1}; A(1) = [];
covid.us.code3 = A{1}; A(1) = [];
covid.us.FIPS = A{1}; A(1) = [];
covid.us.Admin2 = A{1}; A(1) = [];
covid.us.Province_State = A{1}; A(1) = [];
covid.us.Country_Region = A{1}; A(1) = [];
covid.us.Lat = A{1}; A(1) = [];
covid.us.Lon = A{1}; A(1) = [];
 A(1) = []; A(1) = []; A(1) = [];
 covid.us.Population = A{1}; A(1) = [];
 days_str = head_label{1}; days_str(1:12) = [];
 days = datenum(days_str,'mm/dd/yy');
 covid.us.time =days; 
 covid.us.deaths_by_county = zeros(length(covid.us.time),length(covid.us.Lon));
 for t = length(covid.us.time):-1:1
     covid.us.deaths_by_county(t,:) = A{t};
 end
 covid.us.total_deaths_per_county = sum(covid.us.deaths_by_county)';
 covid.us.total_deaths_by_time = sum(covid.us.deaths_by_county,2);
 clv = find(contains(covid.us.Province_State,'Okla')&contains(covid.us.Admin2,'Cleve'));
 okc = find(contains(covid.us.Province_State,'Okla')&contains(covid.us.Admin2,'Okla'));
 
confile = getfullname('time_series_covid19_confirmed_US.txt','covid');
fid = fopen(confile,'r+');
fseek(fid,0,-1);
head2 = fgetl(fid); 
head_label2 = textscan(head2,'%s','delimiter',',');
% UID,iso2,iso3,code3,FIPS,Admin2,Province_State,Country_Region,Lat,Long_,Combined_Key,Population
% 84001001,US,USA,840,1001.0,Autauga,Alabama,US,32.53952745,-86.64408227,"Autauga, Alabama, US",55869,
ndays_2 = length(head_label2{1})-11;
fmt_str = ['%d %s %s %f %f %s %s %s %f %f %s %s %s',repmat(' %f',[1,ndays_2])];
A = textscan(fid,fmt_str,'delimiter',',');
fclose(fid);

if ndays == ndays_2
    A(1:13) = [];
    tmp = A{1};
    covid.us.cases_by_county = zeros(length(covid.us.time),length(covid.us.Lon));
 for t = length(covid.us.time):-1:1
     covid.us.cases_by_county(t,:) = A{t};
 end
 covid.us.total_cases_per_county = sum(covid.us.cases_by_county)';
 covid.us.total_cases_by_time = sum(covid.us.cases_by_county,2);
end

gdfile = getfullname('time_series_covid19_deaths_global.txt','covid');
fid = fopen(gdfile,'r+');
fseek(fid,0,-1);
head = fgetl(fid); 
head_label = textscan(head,'%s','delimiter',',');
% Province/State,Country/Region,Lat,Long,1/22/20,1/23/20
%,Afghanistan,33.93911,67.709953,0,0,0,0,0,0,0,0,0,0
gddays = length(head_label{1})-4;
fmt_str = ['%s %s %f %f',repmat(' %f',[1,gddays])];
A = textscan(fid,fmt_str,'delimiter',',');
fclose(fid);
comb = A{1}; comb2 = A{2};lat = A{3}; lon= A{4}; last = A{end};
covid.g.State = A{1}; A(1) = [];
covid.g.Country = A{1}; A(1) = [];
covid.g.lat = A{1}; A(1) = [];
covid.g.lon = A{1}; A(1) = [];
 gdays_str = head_label{1}; gdays_str(1:4) = [];
 gdays = datenum(gdays_str,'mm/dd/yy');
 covid.g.time =gdays; 
 covid.g.deaths_by_county = zeros(length(covid.g.time),length(covid.g.lon));
 for t = length(covid.g.time):-1:1
     covid.g.deaths_by_county(t,:) = A{t};
 end
 covid.g.total_deaths_per_county = sum(covid.g.deaths_by_county)';
 covid.g.total_deaths_by_time = sum(covid.g.deaths_by_county,2);

 % Now for global cases...
 gdfile = getfullname('time_series_covid19_confirmed_global.txt','covid');
fid = fopen(gdfile,'r+');
fseek(fid,0,-1);
head = fgetl(fid); 
head_label = textscan(head,'%s','delimiter',',');
% Province/State,Country/Region,Lat,Long,1/22/20,1/23/20
%,Afghanistan,33.93911,67.709953,0,0,0,0,0,0,0,0,0,0
gddays2 = length(head_label{1})-4;
fmt_str = ['%s %s %f %f',repmat(' %f',[1,gddays2])];
A = textscan(fid,fmt_str,'delimiter',',');
fclose(fid);
comb = A{1}; comb2 = A{2};lat = A{3}; lon= A{4}; last = A{end};
covid.g.State = A{1}; A(1) = [];
covid.g.Country = A{1}; A(1) = [];
covid.g.lat = A{1}; A(1) = [];
covid.g.lon = A{1}; A(1) = [];
 gdays_str = head_label{1}; gdays_str(1:4) = [];
 gdays = datenum(gdays_str,'mm/dd/yy');
 covid.g.time =gdays; 
 covid.g.cases_by_county = zeros(length(covid.g.time),length(covid.g.lon));
 for t = length(covid.g.time):-1:1
     covid.g.cases_by_county(t,:) = A{t};
 end
 covid.g.total_cases_per_county = sum(covid.g.cases_by_county)';
 covid.g.total_cases_by_time = sum(covid.g.cases_by_county,2);
 

% How about a 4x4 with cases 
 figure; plot(covid.us.time(2:end), diff(smooth(covid.us.total_cases_by_time./sum(covid.us.Population),14)), '-*', ...
 covid.us.time(2:end), diff(smooth(covid.us.total_deaths_by_time./sum(covid.us.Population),14)), '-x'    ); dynamicDateTicks;
 xlabel('date'); ylabel('US cases per capita'); 

  figure; plot(covid.g.time(2:end), diff(smooth(sum(covid.g.cases_by_county(:,117:127),2),14)), '-*', ...
 covid.us.time(2:end), diff(smooth(sum(covid.g.deaths_by_county(:,117:127),2),14)), '-x'); dynamicDateTicks;
 xlabel('date'); ylabel('Global cases'); logy
 
%  figure; subplot(2,1,1); plot(us_deaths.time, us_deaths.by_county(:,clv)./double(us_deaths.Population(clv)), '-o',...
%      us_deaths.time, us_deaths.by_county(:,okc)./double(us_deaths.Population(okc)), '-x'); dynamicDateTicks;
%  xlabel('date'); ylabel('deaths per capita'); legend('Cleveland County','Oklahoma County');
%  
%  figure; plot(us_deaths.time(2:end), diff(smooth(us_deaths.total_by_time./sum(us_deaths.Population),8)), '-*'); dynamicDateTicks;
%  xlabel('date'); ylabel('US deaths per capita'); 
 