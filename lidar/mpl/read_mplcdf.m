function [mpl, status] = read_mplcdf(ncid);
%function [mpl, status] = read_mplcdf(ncid);

statics.deadtime_corrected = 0;
[ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', ncid);
for i = 1:natts
   temp = ncmex('ATTNAME', ncid, 'nc_global', i-1);
   attname{i} = temp;
   if any(findstr(temp,'eb_platform'))
      [value] = ncmex('ATTGET', ncid, 'nc_global', temp);
      if ischar(value)
         statics.datastream = value;
      end
   end    
   if any(findstr(temp,'erial_number'))
      [value] = ncmex('ATTGET', ncid, 'nc_global', temp);
      if ischar(value)
         statics.unitSN = str2double(value);
      else
         statics.unitSN = value;
      end
   end
   if any(findstr(temp,'Deadtime_correction'))
      statics.deadtime_corrected = 1;
   end
end

if any(findstr(statics.datastream, 'mplnor'))
    %Reading mplnor data file
    disp('reading mplnor file...');
    [varid, rcode] = ncmex('VARID', ncid, 'backscatter');
    if varid>0
        mpl.prof = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'cloud_base_height');
    if varid>0
        hk.cbh = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'height');
    if varid>0
        range = nc_getvar(ncid, varid);
    end;
    statics.maxAltitude = max(range);
    
    [varid, rcode] = ncmex('VARID', ncid, 'background_signal');
    if varid>0
        hk.bg = nc_getvar(ncid, varid);
    end;

    hk.energyMonitor = nc_getvar(ncid, 'energy_monitor');
    hk.instrumentTemp = nc_getvar(ncid, 'instrument_temp');
    hk.laserTemp = nc_getvar(ncid, 'laser_temp');
    hk.detectorTemp = nc_getvar(ncid, 'detector_temp');
elseif any(findstr(statics.datastream, 'ipa'))
%%
disp('Reading ipa file:');
    [varid, rcode] = ncmex('VARID', ncid, 'range');
    if varid>0
        range = nc_getvar(ncid, varid);
    end
    [varid, rcode] = ncmex('VARID', ncid, 'range_bin_time');
    if varid>0
        range_bin_time = nc_getvar(ncid, varid);
    end
    %disp('Reading raw counts...');
    [varid, rcode] = ncmex('VARID', ncid, 'detector_counts');
    if varid>0
        mpl.rawcts = nc_getvar(ncid, 'detector_counts');
    end;    
    
    [varid, rcode] = ncmex('VARID', ncid, 'pulse_rep');
    if varid>0
        hk.PRF = nc_getvar(ncid, varid);
    end;
    
    [varid, rcode] = ncmex('VARID', ncid, 'shots_summed');
    if varid>0
        hk.shotSummed = nc_getvar(ncid, varid);
    end;
    
    %disp('ZenithAngle...');
    [varid, rcode] = ncmex('VARID', ncid, 'zenith_angle');
    if varid>0
        hk.zenithAngle = nc_getvar(ncid, 'zenith_angle');
    end;
    
     hk.energyMonitor = nc_getvar(ncid, 'energy_monitor');
     hk.instrumentTemp = nc_getvar(ncid, 'instrument_temp');
     hk.laserTemp = nc_getvar(ncid, 'laser_temp');
     hk.detectorTemp = nc_getvar(ncid, 'detector_temp');

     mpl.t.doy = nc_getvar(ncid, 'doy');
    %disp('Determining preliminary bkgnd.');
    [bins,profs] = size(mpl.rawcts);
    r.bg = [fix(bins*.87):ceil(bins*.97)];
    hk.bg = mean(mpl.rawcts(r.bg,:));

    %disp('Subtracting preliminary bkgnd.');
%    mpl.prof = mpl.rawcts - ones(bins,1)*bkgnd;
     for i = profs:-1:1
         mpl.prof(:,i) = mpl.rawcts(:,i) - hk.bg(i);
     end;

    %disp('Finding earlybins/firstbin for range offset.');
    earlybins = mean(mpl.prof(1:10,:)');
    if any(find(earlybins > 1))
        first_bin = min(find(earlybins > 1));
    else 
        first_bin = 1;
    end;

    %disp('Correcting for range-offset.');
    binwidth = range(10) - range(9);
    r.range_offset = (first_bin - 0.5) * binwidth; % The "0.5" centers the first bin

    range = [1:bins-first_bin]';
    range = range*binwidth ;
    mpl.rawcts(1:first_bin,:) = [];
    mpl.prof(1:first_bin,:) = [];
    [bins,profs] = size(mpl.rawcts);
    r.bg = [fix(bins*.87):ceil(bins*.97)];
    hk.bg = mean(mpl.rawcts(r.bg,:));    
    %disp('Applying range-squared correction.');
%     for i = 1:profs
%         mpl.prof(:,i) = mpl.prof(:,i) .* (range.^2);
%     end;
     mpl.prof = mpl.prof.*((range.^2)*ones(1,profs));
     mpl.r = r;

%%
    
elseif (any(findstr(statics.datastream, '.a1'))&~any(findstr(statics.datastream,'ipa')))
    disp('Reading a1-level data...');

    %Reading "a1" netcdf file
    [varid, rcode] = ncmex('VARID', ncid, 'preliminary_cbh');
    if varid>0
        hk.cbh = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'pulse_rep');
    if varid>0
        hk.PRF = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'shots_summed');
    if varid>0
        hk.shotSummed = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'range');
    if varid>0
        range = nc_getvar(ncid, varid);
    end
    [varid, rcode] = ncmex('VARID', ncid, 'range_bin_time');
    if varid>0
        range_bin_time = nc_getvar(ncid, varid);
    end
    
    
    %disp('Reading raw counts...');
    [varid, rcode] = ncmex('VARID', ncid, 'detector_counts');
    if varid>0
        mpl.rawcts = nc_getvar(ncid, 'detector_counts');
    end;

    %disp('Determining preliminary bkgnd.');
    [bins,profs] = size(mpl.rawcts);
    r.bg = [fix(bins*.87):ceil(bins*.97)];
    hk.bg = mean(mpl.rawcts(r.bg,:));

    %disp('Subtracting preliminary bkgnd.');
%    mpl.prof = mpl.rawcts - ones(bins,1)*bkgnd;
     for i = profs:-1:1
         mpl.prof(:,i) = mpl.rawcts(:,i) - hk.bg(i);
     end;

    %disp('Finding earlybins/firstbin for range offset.');
    earlybins = mean(mpl.prof(1:10,:)');
    if any(find(earlybins > 1))
        first_bin = min(find(earlybins > 1));
    else 
        first_bin = 1;
    end;

    %disp('Correcting for range-offset.');
    binwidth = range(10) - range(9);
    r.range_offset = (first_bin - 0.5) * binwidth; % The "0.5" centers the first bin

    range = [1:bins-first_bin]';
    range = range*binwidth ;
    mpl.rawcts(1:first_bin,:) = [];
    mpl.prof(1:first_bin,:) = [];
    [bins,profs] = size(mpl.rawcts);
    r.bg = [fix(bins*.87):ceil(bins*.97)];
    hk.bg = mean(mpl.rawcts(r.bg,:));    
    %disp('Applying range-squared correction.');
%     for i = 1:profs
%         mpl.prof(:,i) = mpl.prof(:,i) .* (range.^2);
%     end;
     mpl.prof = ((range.^2)*ones(1,profs)).* mpl.prof;
     mpl.r = r;
     hk.energyMonitor = nc_getvar(ncid, 'energy_monitor');
     hk.instrumentTemp = nc_getvar(ncid, 'instrument_temp');
     hk.laserTemp = nc_getvar(ncid, 'laser_temp');
     hk.detectorTemp = nc_getvar(ncid, 'detector_temp');
else
     %Not sure what type of mpl file!
disp('Not sure what type of mpl netcdf file this is...');
    [varid, rcode] = ncmex('VARID', ncid, 'range');
    if varid>0
        range = nc_getvar(ncid, varid);
    end
    [varid, rcode] = ncmex('VARID', ncid, 'range_bin_time');
    if varid>0
        range_bin_time = nc_getvar(ncid, varid);
    end
    %disp('Reading raw counts...');
    [varid, rcode] = ncmex('VARID', ncid, 'detector_counts');
    if varid>0
        mpl.rawcts = nc_getvar(ncid, 'detector_counts');
    end;    
    
    %disp('ZenithAngle...');
    [varid, rcode] = ncmex('VARID', ncid, 'zenithAngle');
    if varid>0
        hk.zenithAngle = nc_getvar(ncid, 'zenithAngle');
    end;

    %disp('Determining preliminary bkgnd.');
    [bins,profs] = size(mpl.rawcts);
    r.bg = [fix(bins*.87):ceil(bins*.97)];
    hk.bg = mean(mpl.rawcts(r.bg,:));

    %disp('Subtracting preliminary bkgnd.');
%    mpl.prof = mpl.rawcts - ones(bins,1)*bkgnd;
     for i = profs:-1:1
         mpl.prof(:,i) = mpl.rawcts(:,i) - hk.bg(i);
     end;

    %disp('Finding earlybins/firstbin for range offset.');
    earlybins = mean(mpl.prof(1:10,:)');
    if any(find(earlybins > 1))
        first_bin = min(find(earlybins > 1));
    else 
        first_bin = 1;
    end;

    %disp('Correcting for range-offset.');
    binwidth = range(10) - range(9);
    r.range_offset = (first_bin - 0.5) * binwidth; % The "0.5" centers the first bin

    range = [1:bins-first_bin]';
    range = range*binwidth ;
    mpl.rawcts(1:first_bin,:) = [];
    mpl.prof(1:first_bin,:) = [];
    [bins,profs] = size(mpl.rawcts);
    r.bg = [fix(bins*.87):ceil(bins*.97)];
    hk.bg = mean(mpl.rawcts(r.bg,:));    
    %disp('Applying range-squared correction.');
    for i = 1:profs
        mpl.prof(:,i) = mpl.prof(:,i) .* (range.^2);
    end;
    % mpl.prof = ((range.^2)*ones(1,profs)).* mpl.prof;
     mpl.r = r;

end

base_time = nc_getvar(ncid, 'base_time');
time_offset = nc_getvar(ncid, 'time_offset');
epoch_time = base_time + time_offset;
[time] = epoch2serial(epoch_time);

statics.range_bin_time = range_bin_time;

statics.lat  = nc_getvar(ncid, 'lat');
statics.lon = nc_getvar(ncid, 'lon');
statics.alt = nc_getvar(ncid, 'alt');

[varid, rcode] = ncmex('VARID', ncid, 'max_altitude');
if varid>0
    statics.maxAltitude = nc_getvar(ncid, 'max_altitude');
end;

mpl.time = time;
mpl.statics = statics;
mpl.hk = hk;
mpl.range = range;
r.squared = range.^2;
mpl.r = r;

status = 1;
