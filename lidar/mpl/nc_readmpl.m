function [mpl, status, nc] = nc_readmpl(filename);
%function [mpl, status] = nc_readmpl(filename);
%CJF: 2006-10-25: removed 1/2 bin centering and stopped trimming profiles
%for range <0.
if nargin==0
    nc = ancload;
else
    nc = ancload(filename);
end

mpl.statics.deadtime_corrected = 0;

%[ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', ncid);
gatts = fieldnames(nc.atts);
natts = length(gatts);
nvars = length(fieldnames(nc.vars));
ndims = length(fieldnames(nc.dims));
recdim = nc.recdim.id;

mpl.statics.datastream = '';

for i = 1:natts
    eval(['mpl.statics.',char(gatts(i)), ' = nc.atts.', char(gatts(i)), '.data;'])
    temp = char(gatts(i));
    if any(findstr(temp,'eb_platform'))
        value = eval(['nc.atts.', temp, '.data']);
        if ischar(value)
            mpl.statics.datastream = value;
        end
    end
    if any(findstr(temp,'erial_number'))
        value = eval(['nc.atts.', temp, '.data']);
        if ischar(value)
            mpl.statics.unitSN = str2double(value);
        else
            mpl.statics.unitSN = value;
        end
    end
    if any(findstr(temp,'Deadtime_correction'))
        mpl.statics.deadtime_corrected = 1;
    end
end
if isfield(mpl.statics, 'created_by')
    if findstr(mpl.statics.created_by,'MPL_Ingest')
        mpl.statics.datastream = 'MPL_Ingest';
    end
end

unlim_name = nc.recdim.name;
unlim_length = nc.recdim.length;
if unlim_length>0
    if any(findstr(mpl.statics.datastream, 'mplnor'))
        %Reading mplnor data file
        disp('reading mplnor file...');
        mpl.prof = nc.vars.backscatter.data;
        mpl.hk.cbh = nc.vars.cloud_base_height.data;
        mpl.range = nc.vars.height.data;
        mpl.statics.maxAltitude = max(mpl.range);
        mpl.hk.bg = nc.vars.background_signal.data;
        mpl.hk.energy_monitor = nc.vars.energy_monitor.data;
        mpl.hk.instrument_temp = nc.vars.instrument_temp.data;
        mpl.hk.laser_temp = nc.vars.laser_temp.data;
        mpl.hk.detector_temp = nc.vars.detector_temp.data;
        mpl.hk.filter_temp = nc.vars.filter_temp.data;
        mpl.hk.shots_summed = nc.vars.shots_summed.data;
        mpl.hk.pulse_rep = nc.vars.pulse_rep.data;
        mpl.statics.pulse_rep = round(mean(mpl.hk.pulse_rep));

    elseif any(findstr(mpl.statics.datastream, 'ipa'))
        mpl.range = nc.vars.range.data';
        mpl.statics.range_bin_time = nc.vars.range_bin_time.data;
        mpl.rawcts = nc.vars.detector_counts.data;
        mpl.hk.shots_summed = nc.vars.shots_summed.data;
        mpl.hk.pulse_rep = nc.vars.pulse_rep.data;
        if findstr(mpl.statics.scanning,'yes')
            mpl.hk.zenith_angle = nc.vars.zenith_angle.data;
        end

        if (findstr(mpl.statics.polarized,'yes')&~(findstr(mpl.statics.datalevel,'a')))
            [mpl.pol_mode.odd_even] = nc.vars.pol_by_odd_even.data;
            [mpl.pol_mode.odd_even_span] = nc.vars.pol_by_odd_even_span.data;
            mpl.statics.pol_test_span = nc.vars.pol_by_mean_span.data;
        end
        mpl.hk.energy_monitor = nc.vars.energy_monitor.data;
        mpl.hk.instrument_temp = nc.vars.instrument_temp.data;
        mpl.hk.laser_temp = nc.vars.laser_temp.data;
        mpl.hk.detector_temp = nc.vars.detector_temp.data;
        mpl.hk.filter_temp = nc.vars.filter_temp.data;
        mpl.t.doy = nc.vars.doy.data;
        %disp('Determining preliminary bkgnd.');
        [bins,profs] = size(mpl.rawcts);
        mpl.r.bg = [fix(bins*.87):ceil(bins*.97)];
        mpl.hk.bg = mean(mpl.rawcts(mpl.r.bg,:));
        mpl.prof = mpl.rawcts - ones(size(mpl.range'))*mpl.hk.bg;
%         for i = profs:-1:1
%             mpl.prof(:,i) = mpl.rawcts(:,i) - mpl.hk.bg(i);
%         end;
        first_bin = 0;

        %disp('Correcting for range-offset.');
        binwidth = mpl.range(10) - mpl.range(9);
        mpl.r.range_offset = (first_bin) * binwidth; % The "0.5" centers the first bin
        mpl.r.range_offset = 0;
        mpl.range = [1:bins]'-first_bin;
        mpl.range = mpl.range*binwidth ;

        %         mpl.rawcts(1:first_bin,:) = [];
        %         mpl.prof(1:first_bin,:) = [];
        [bins,profs] = size(mpl.rawcts);
        mpl.r.bg = [fix(bins*.87):ceil(bins*.97)];
        mpl.hk.bg = mean(mpl.rawcts(mpl.r.bg,:));
        mpl.prof = mpl.prof.*((mpl.range.^2)*ones(1,profs));
    elseif (any(findstr(mpl.statics.datastream, '.a1'))&~any(findstr(mpl.statics.datastream,'ipa')))
        disp('Reading a1-level data...');
        mpl.hk.cbh = nc.vars.preliminary_cbh.data;
        mpl.hk.pulse_rep = nc.vars.pulse_rep.data;
        mpl.hk.shots_summed = nc.vars.shots_summed.data;
        mpl.range = nc.vars.range.data';
        if isfield(nc.vars, 'range_bin_time');
            mpl.statics.range_bin_time = nc.vars.range_bin_time.data;
        end
        if isfield(nc.vars, 'detector_counts');
            mpl.rawcts = nc.vars.detector_counts.data;
        end
        %disp('Determining preliminary bkgnd.');
        [bins,profs] = size(mpl.rawcts);
        mpl.r.bg = [fix(bins*.87):ceil(bins*.97)];
        mpl.hk.bg = mean(mpl.rawcts(mpl.r.bg,:));

        %disp('Subtracting preliminary bkgnd.');
        %    mpl.prof = mpl.rawcts - ones(bins,1)*bkgnd;
        mpl.prof = mpl.rawcts - ones(size(mpl.range'))*mpl.hk.bg;
%         for i = profs:-1:1
%             mpl.prof(:,i) = mpl.rawcts(:,i) - mpl.hk.bg(i);
%         end;

        %disp('Finding earlybins/firstbin for range offset.');
        earlybins = mean(mpl.prof(1:10,:)');
        if any(find(earlybins > 1))
            first_bin = min(find(earlybins > 1));
        else
            first_bin = 1;
        end;

        %disp('Correcting for range-offset.');
        binwidth = mpl.range(10) - mpl.range(9);
        mpl.r.range_offset = (first_bin) * binwidth; % The "0.5" centers the first bin

        mpl.range = [1:bins]'-first_bin;
        mpl.range = mpl.range*binwidth ;
        %         mpl.rawcts(1:first_bin,:) = [];
        %         mpl.prof(1:first_bin,:) = [];
        [bins,profs] = size(mpl.rawcts);
        mpl.r.bg = [fix(bins*.87):ceil(bins*.97)];
        mpl.hk.bg = mean(mpl.rawcts(mpl.r.bg,:));
        mpl.prof = ((mpl.range.^2)*ones(1,profs)).* mpl.prof;
        mpl.hk.energy_monitor = nc.vars.energy_monitor.data;
        mpl.hk.instrument_temp = nc.vars.instrument_temp.data;
        mpl.hk.laser_temp = nc.vars.laser_temp.data;
        mpl.hk.detector_temp = nc.vars.detector_temp.data;
        mpl.hk.filter_temp = nc.vars.filter_temp.data;
        if isfield(mpl.hk, 'pulse_rep')
            mpl.statics.pulse_rep = round(mean(mpl.hk.pulse_rep));
        end
    elseif any(findstr(mpl.statics.datastream, 'MPL_Ingest'))
        disp('Reading MPL_Ingest a1-level data...');
        %Reading "a1" netcdf file
        mpl.hk.cbh = nc.vars.preliminary_cbh.data;
        mpl.hk.pulse_rep = nc.vars.pulse_rep.data;
        mpl.hk.shots_summed = nc.vars.shots_summed.data;
        mpl.range = nc.vars.range.data';
        mpl.statics.range_bin_time = nc.vars.range_bin_time.data;
        mpl.rawcts = nc.vars.backscatter.data;

        %disp('Determining preliminary bkgnd.');
        [bins,profs] = size(mpl.rawcts);
        mpl.r.bg = [fix(bins*.87):ceil(bins*.97)];
        mpl.hk.bg = mean(mpl.rawcts(mpl.r.bg,:));

        %disp('Subtracting preliminary bkgnd.');
        %    mpl.prof = mpl.rawcts - ones(bins,1)*bkgnd;
        mpl.prof = mpl.rawcts - ones(size(mpl.range'))*mpl.hk.bg;
%         for i = profs:-1:1
%             mpl.prof(:,i) = mpl.rawcts(:,i) - mpl.hk.bg(i);
%         end;

        %disp('Finding earlybins/firstbin for range offset.');
        earlybins = mean(mpl.prof(1:10,:)');
        if any(find(earlybins > 1))
            first_bin = min(find(earlybins > 1));
        else
            first_bin = 1;
        end;

        %disp('Correcting for range-offset.');
        binwidth = mpl.range(10) - mpl.range(9);
        mpl.r.range_offset = (first_bin) * binwidth;

        mpl.range = [1:bins]'-first_bin;
        mpl.range = mpl.range*binwidth ;
        %         mpl.rawcts(1:first_bin,:) = [];
        %         mpl.prof(1:first_bin,:) = [];
        [bins,profs] = size(mpl.rawcts);
        mpl.r.bg = [fix(bins*.87):ceil(bins*.97)];
        mpl.hk.bg = mean(mpl.rawcts(mpl.r.bg,:));
        %disp('Applying range-squared correction.');
        %     for i = 1:profs
        %         mpl.prof(:,i) = mpl.prof(:,i) .* (range.^2);
        %     end;
        mpl.prof = ((mpl.range.^2)*ones(1,profs)).* mpl.prof;


        mpl.hk.energy_monitor = nc.vars.energy_monitor.data;
        mpl.hk.instrument_temp = nc.vars.instrument_temp.data;
        mpl.hk.laser_temp = nc.vars.laser_temp.data;
        mpl.hk.detector_temp = nc.vars.detector_temp.data;
        mpl.hk.filter_temp = nc.vars.filter_temp.data;

        if isfield(mpl.hk, 'pulse_rep')
            mpl.statics.pulse_rep = round(mean(mpl.hk.pulse_rep));
        end

    else
        %Not sure what type of mpl file!
        disp('Not sure what type of mpl netcdf file this is...');
        if isfield(nc.vars, 'range')
            mpl.range = nc.vars.range.data';
        end
        if isfield(nc.vars, 'range_bin_time');
            mpl.statics.range_bin_time = nc.vars.range_bin_time.data;
        end
        %disp('Reading raw counts...');
        if isfield(nc.vars, 'detector_counts')
            mpl.rawcts = nc.vars.detector_counts.data;
        end

        %disp('ZenithAngle...');
        if isfield(nc.vars, 'zenith_angle')
            mpl.hk.zenith_angle = nc.vars.zenith_angle.data;
        end

        %disp('Determining preliminary bkgnd.');
        [bins,profs] = size(mpl.rawcts);
        mpl.r.bg = [fix(bins*.87):ceil(bins*.97)];
        mpl.hk.bg = mean(mpl.rawcts(mpl.r.bg,:));

        %disp('Subtracting preliminary bkgnd.');
        %    mpl.prof = mpl.rawcts - ones(bins,1)*bkgnd;
        for i = profs:-1:1
            mpl.prof(:,i) = mpl.rawcts(:,i) - mpl.hk.bg(i);
        end;

        %disp('Finding earlybins/firstbin for range offset.');
        earlybins = mean(mpl.prof(1:10,:)');
        if any(find(earlybins > 1))
            first_bin = min(find(earlybins > 1));
        else
            first_bin = 1;
        end;

        %disp('Correcting for range-offset.');
        binwidth = mpl.range(10) - mpl.range(9);
        mpl.r.range_offset = (first_bin) * binwidth; % The "0.5" centers the first bin

        mpl.range = [1:bins]'-first_bin;
        mpl.range = mpl.range*binwidth ;
        %         mpl.rawcts(1:first_bin,:) = [];
        %         mpl.prof(1:first_bin,:) = [];
        [bins,profs] = size(mpl.rawcts);
        mpl.r.bg = [fix(bins*.87):ceil(bins*.97)];
        mpl.hk.bg = mean(mpl.rawcts(mpl.r.bg,:));
        %disp('Applying range-squared correction.');
        for i = 1:profs
            mpl.prof(:,i) = mpl.prof(:,i) .* (mpl.range.^2);
        end;
        % mpl.prof = ((range.^2)*ones(1,profs)).* mpl.prof;
    end
%     base_time = nc.vars.base_time.data;
%     time_offset = nc.vars.time_offset.data;
%     epoch_time = double(base_time) + time_offset;
%     [mpl.time] = epoch2serial(epoch_time);
    mpl.time = nc.time;
else
    mpl.time =[];
    mpl.rawcts =  [];
    mpl.prof = [];
    hk.cbh = [];
    mpl.t.doy =  [];

    mpl.hk.bg = [];
    mpl.hk.energy_monitor = [];
    mpl.hk.instrument_temp = [];
    mpl.hk.laser_temp = [];
    mpl.hk.detector_temp = [];
    mpl.hk.filter_temp = [];
    mpl.hk.shots_summed = [];
    mpl.hk.pulse_rep = [];
    mpl.hk.zenith_angle =  [];
    mpl.statics.pulse_rep = [];
    if isfield(nc.vars, 'height')
        mpl.range = nc.vars.height.data;
    end
    if isfield(nc.vars, 'range')
        mpl.range = nc.vars.range.data';
    end
    mpl.statics.maxAltitude = max(mpl.range);
    mpl.statics.range_bin_time = [];
end

mpl.statics.lat  = nc.vars.lat.data;
mpl.statics.lon = nc.vars.lon.data;
mpl.statics.alt = nc.vars.alt.data;

if isfield(nc.vars, 'max_altitude')
    statics.maxAltitude = nc.vars.max_altitude.data;
end
status = 1;
