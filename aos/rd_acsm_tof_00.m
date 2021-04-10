function tof = rd_acsm_tof_00(tof_file);
% tof = rd_acsm_tof_00(tof_file);
% reads in a raw ACSM-TOF h5 file
% Reads in raw TOF mass spectra, the mass axis, all of the housekeeping
% data in TwData, and parses the "PWM3POSmonitor" field as 0=filtered.

if ~exist('tof_file','var')||~exist(tof_file,'file')
   tof_file = getfullname('*.h5','acsm_tof','Select an ACSM TOF raw h5 file.');
end

% This section gets the starting time as "AcquisitionTimeZero" in crazy
% units of 100 ns intervals from Jan 1 1601 and converts it to Matlab
% serialdate in days since Jan 1, 00 AD.  Then adds the Buftimes which is
% in seconds by dividing to get days.
basetime_uint64 = h5readatt(tof_file, '/TimingData','AcquisitionTimeZero');
basetime_days_since_16010101 = double(basetime_uint64).*(100e-9)./(60*60*24);
serialdate_16010101 = datenum(1601,1,1);
basetime = basetime_days_since_16010101 + serialdate_16010101;
time_ = basetime + h5read(tof_file, '/TimingData/BufTimes')./(60*60*24);
% represent as 1-D time series, not wrapping time in 90-record chuncks
tof.time = time_(:)';clear time_



tof.amu = h5read(tof_file, '/FullSpectra/MassAxis');
tmp = h5read(tof_file, '/FullSpectra/TofData');
% Squeeze eliminates dimensions of length==1
tmp_ = squeeze(tmp);
tof.tof_ms_raw = NaN(size(tmp_,1),size(tmp_,2)*size(tmp_,3));
% Matlab spools out data from tmp_ from left to right.
% That is, it runs down the 1st index, then increments the second by one,
% runs down the 1st again, increments the second until exhausted before
% inrementing the third indexed dimension and so on.
tof.tof_ms_raw(:) = tmp_; clear tmp_;

TwData = h5read(tof_file, '/TPS2/TwData');
%field 27 PWM3POS_monitor is filtered/unfiltered flag, 1 = filtered
TwNames = h5read(tof_file, '/TPS2/TwInfo');
%%
% TofWorks field #27 (26 when indexed from 0 as in HDFview) corresponds to
% PWM3POS monitor [] which reports the position of the filter.

ii = 27;
for ii = 1:length(TwNames)
   field_name = legalize_fieldname(TwNames{ii});
   field_name = strrep(field_name,'[','_b_');field_name = strrep(field_name,']','_B_');
   field_name = strrep(field_name,char(176),'_deg_');
   field_name = deblank(field_name);
   if strcmp(field_name(end),'_')
      field_name(end) = [];
   end
   tmp = TwData(ii,:,:); tmp = squeeze(tmp); tmp_ = tmp(:)';
   tof.TwData.(field_name) = tmp(:)';
%    figure_; 
   plot([1:length(tmp_)],tmp_,'o-'); [~,fname,~] = fileparts(tof_file);
   title({fname;['TwInfo[',num2str(ii),']=',TwNames{ii}]},'interp','none'); ii = ii +1;
   menu('OK','ok');
end

filtered = (tof.TwData.PWM3POSmonitor_b__B==0);% It starts with "0" which I think is filtered.  But not 100% sure
tof.TwNames =TwNames;
tof.filtered = filtered;
%%

return

function newname = legalize_fieldname(oldname)
% Replaces illegal characters in names of structure elements.
if ((oldname(1)>47)&(oldname(1)<58))
oldname = ['n_',oldname];
end
newname = strrep(oldname,' ','');
newname = strrep(newname,'.','');
newname = strrep(newname,',','');
newname = strrep(newname,'<=','le_');
newname = strrep(newname,'>=','ge_');
newname = strrep(newname,'<','lt_');
newname = strrep(newname,'>','gt_');
newname = strrep(newname,'==','eeq_');
newname = strrep(newname,'=','eq_');
%newname = strrep(newname,'-','_dash_');
newname = strrep(newname,'-','_');
newname = strrep(newname,'+','plus_');
newname = strrep(newname,'(','lpar_');
newname = strrep(newname,')','rpar_');
newname = strrep(newname,'#','hash_');
newname = strrep(newname,'/','fslash_');
newname = strrep(newname,'\','bslash_');
newname = strrep(newname,'^','caret_');
newname = strrep(newname,'%','pct_');
if newname(1) == '_'
    newname = ['ubar_',newname(2:end)];
end

return