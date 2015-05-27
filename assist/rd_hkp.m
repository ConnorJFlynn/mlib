function [hkp, hkp_raw] = rd_hkp(infile);
% read hkp file [hkp, hkp_raw] = rd_hkp(infile);
% Read each line, parse into bits
if ~exist('infile','var')||~exist(infile,'file')
infile = getfullname_('*_hkp_*.csv','assist_hkp','Select house-keeping file.');
end
%%

fid = fopen(infile);
%%
   fseek(fid,0,-1);
A = textscan(fid,'%s%f%f%f%f%s%s%f','headerlines',0,'delimiter',[',',':'],'treatAsEmpty','N/A');
fclose(fid);
%%
Vo = datevec(datenum(A{1},'yyyy-mm-dd'));
v = [A{2},A{3},A{4}+A{5}./1000];
V = [Vo(:,1:3),v];
hkp_raw.time = datenum(V);
sensor_value = A{8};
sensor_alarm = ~strcmp('NORMAL',deblank(A{6}));
hkp_raw.sensor_value = sensor_value;
hkp_raw.sensor_alarm = sensor_alarm;
%%
tag = deblank(A{7});
tag_list = {'12V ITX Computer','VitxPC12';...
           '15V FTS Board','Vfts15';...
           '15V Pre-Amplifier','Vpreamp15';...
           '24V BBY Heater / Detector Cooler','VbbyDetCooler24';...
           '24V Scan Motor / Step Motor','Vmotor24';...
           '5V Annotator / Ethernet S /1-Wire M','Vannotator5';...
           'Cooler Block Temperarure','TempCoolerBlock';...
           'Electronic Box Enclosure','TempElecBox';...
           'External Humidity','RH_ext';...
           'Front End Enclosure','TempFrontEndEncl';...
           'FTS Enclosure','TempFTSencl';...
           'ITX Computer CPU Heatsink','TempCPUHeatsink';...
           'Power Supplies Box Enclosure','TempPWRSuppplyBox';...
           'Scene Mirror Motor','TempMirrorMotor'};
        found = [];
        %%
% Process first record...
% Define basetime
t = 1;
n = 1;
try
this_tag = find(strcmp(tag(n),tag_list(:,1)));
catch
   disp('caught problem')
end
hkp.time(t) = hkp_raw.time(n);
hkp.(tag_list{this_tag,2})(t) = sensor_value(n);
hkp.([tag_list{this_tag,2},'_status'])(t) = sensor_alarm(n);
hkp.([tag_list{this_tag,2},'_time_lag'])(t) = hkp_raw.time(n)-hkp.time(t);
found = unique([found,find(strcmp(tag(n),tag_list(:,1)))]);
%%
tag{1}
for n = 2:length(sensor_value)
   tag{n}
   this_tag = find(strcmp(tag(n),tag_list(:,1)));
   if ~any(this_tag==found)
      found = unique([found,find(strcmp(tag(n),tag_list(:,1)))]);
   else
      found = [];
      t = t + 1;
      hkp.time(t) = hkp_raw.time(n);
   end
end
%%
t = 1;
n = 1;
found = [];
hkp.(tag_list{this_tag,2})(t) = sensor_value(n);
hkp.([tag_list{this_tag,2},'_status'])(t) = sensor_alarm(n);
hkp.([tag_list{this_tag,2},'_time_lag'])(t) = hkp_raw.time(n)-hkp.time(t);
found = unique([found,find(strcmp(tag(n),tag_list(:,1)))]);
%%
for this_tag = length(tag_list(:,1)):-1:1
  hkp.(tag_list{this_tag,2})= NaN(size(hkp.time));
hkp.([tag_list{this_tag,2},'_status']) = NaN(size(hkp.time));
hkp.([tag_list{this_tag,2},'_time_lag']) = NaN(size(hkp.time)); 
end
%%
found = [];
for n = 1:length(sensor_value)
   this_tag = find(strcmp(tag(n),tag_list(:,1)));
   if ~any(this_tag==found)
      found = unique([found,find(strcmp(tag(n),tag_list(:,1)))]);
   else
      found = [];
      t = t + 1;
   end
hkp.(tag_list{this_tag,2})(t) = sensor_value(n);
hkp.([tag_list{this_tag,2},'_status'])(t) = sensor_alarm(n);
hkp.([tag_list{this_tag,2},'_time_lag'])(t) = hkp_raw.time(n)-hkp.time(t);
end

return
