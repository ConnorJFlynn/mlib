function [mpl, status] = read_mpl_nc(ncid);
%function [mpl, status] = read_mpl_nc(ncid);
if nargin==0
    ncid = get_ncid;
end
mpl.statics.deadtime_corrected = 0;
[ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', ncid);
mpl.statics.datastream = '';
for i = 1:natts
    gattname = ncmex('ATTNAME', ncid, 'nc_global', i-1);
    [value] = ncmex('ATTGET', ncid, 'nc_global', gattname);
    dash = findstr(gattname, '-');
    gattname(dash) = '_';
    eval(['mpl.statics.', gattname,' = value;']);


    temp = ncmex('ATTNAME', ncid, 'nc_global', i-1);
    if any(findstr(temp,'eb_platform'))
        [value] = ncmex('ATTGET', ncid, 'nc_global', temp);
        if ischar(value)
            mpl.statics.datastream = value;
        end
    end
    if any(findstr(temp,'erial_number'))
        [value] = ncmex('ATTGET', ncid, 'nc_global', temp);
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
[ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', ncid);
[unlim_name, unlim_length, status] = ncmex('DIMINQ', ncid, recdim);
if unlim_length>0
    if any(findstr(mpl.statics.datastream, 'mplnor'))
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
            mpl.range = nc_getvar(ncid, varid);
        end;
        mpl.statics.maxAltitude = max(mpl.range);

        [varid, rcode] = ncmex('VARID', ncid, 'background_signal');
        if varid>0
            mpl.hk.bg = nc_getvar(ncid, varid);
        end;

        mpl.hk.energy_monitor = nc_getvar(ncid, 'energy_monitor');
        mpl.hk.instrument_temp = nc_getvar(ncid, 'instrument_temp');
        mpl.hk.laser_temp = nc_getvar(ncid, 'laser_temp');
        mpl.hk.detector_temp = nc_getvar(ncid, 'detector_temp');
        mpl.hk.filter_temp = nc_getvar(ncid, 'filter_temp');

        mpl.hk.shots_summed = nc_getvar(ncid, 'shots_summed');
        mpl.hk.pulse_rep = nc_getvar(ncid, 'pulse_rep');
        %mpl.statics.shots_summed = round(mean(mpl.hk.shots_summed));
        mpl.statics.pulse_rep = round(mean(mpl.hk.pulse_rep));

    elseif any(findstr(mpl.statics.datastream, 'ipa'))
        %%
        %disp('Reading ipa file:');
        [varid, rcode] = ncmex('VARID', ncid, 'range');
        if varid>0
            mpl.range = nc_getvar(ncid, varid);
        end
        [varid, rcode] = ncmex('VARID', ncid, 'range_bin_time');
        if varid>0
            mpl.statics.range_bin_time = nc_getvar(ncid, varid);
        end
        
%         [varid, rcode] = ncmex('VARID', ncid, 'preliminary_cbh');
%         if varid>0
%             mpl.hk.cbh = nc_getvar(ncid, varid);
%         end;
        
        %disp('Reading raw counts...');
        [varid, rcode] = ncmex('VARID', ncid, 'detector_counts');
        if varid>0
            mpl.rawcts = nc_getvar(ncid, 'detector_counts');
        end;

        [varid, rcode] = ncmex('VARID', ncid, 'shots_summed');
        if varid>0
            mpl.hk.shots_summed = nc_getvar(ncid, varid);
        end;

        [varid, rcode] = ncmex('VARID', ncid, 'pulse_rep');
        if varid>0
            mpl.hk.pulse_rep = nc_getvar(ncid, varid);
        end;
        
        if findstr(mpl.statics.scanning,'yes')

            %disp('ZenithAngle...');
            [varid, rcode] = ncmex('VARID', ncid, 'zenith_angle');
            if varid>0
                mpl.hk.zenith_angle = nc_getvar(ncid, varid);
            end;
        end

        if (findstr(mpl.statics.polarized,'yes')&~(findstr(mpl.statics.datalevel,'a')))

            varname = 'pol_by_odd_even';
            [varid] = ncmex('VARID', ncid, varname);
            [var_name] = ncmex('VARINQ', ncid, varid);
            if varname==var_name
                [mpl.pol_mode.odd_even] = nc_getvar(ncid, varname);
            end

            varname = 'pol_by_odd_even_span';
            [varid] = ncmex('VARID', ncid, varname);
            [var_name] = ncmex('VARINQ', ncid, varid);
            if varname==var_name
                [mpl.pol_mode.odd_even_span] = nc_getvar(ncid, varname);
            end

            varname = 'pol_by_mean_span';
            [varid] = ncmex('VARID', ncid, varname);
            [var_name] = ncmex('VARINQ', ncid, varid);
            if varname==var_name
                [mpl.pol_mode.gt_mean_span] = nc_getvar(ncid, varname);
                mpl.statics.pol_test_span = ncmex('ATTGET', ncid, varname, 'polarizer_test_span');
            end
        end
        

        mpl.hk.energy_monitor = nc_getvar(ncid, 'energy_monitor');
        mpl.hk.instrument_temp = nc_getvar(ncid, 'instrument_temp');
        mpl.hk.laser_temp = nc_getvar(ncid, 'laser_temp');
        mpl.hk.detector_temp = nc_getvar(ncid, 'detector_temp');
        mpl.hk.filter_temp = nc_getvar(ncid, 'filter_temp');

        mpl.t.doy = nc_getvar(ncid, 'doy');
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
%         earlybins = mean(mpl.prof(1:10,:)');
%         if any(find(earlybins > 1))
%             first_bin = min(find(earlybins > 1));
%         else
%             first_bin = 1;
%         end;
        first_bin = 0;

        %disp('Correcting for range-offset.');
        binwidth = mpl.range(10) - mpl.range(9);
        mpl.r.range_offset = (first_bin - 0.5) * binwidth; % The "0.5" centers the first bin
        mpl.r.range_offset = 0;
        mpl.range = [1:bins-first_bin]';
        mpl.range = mpl.range*binwidth ;

        mpl.rawcts(1:first_bin,:) = [];
        mpl.prof(1:first_bin,:) = [];
        [bins,profs] = size(mpl.rawcts);
        mpl.r.bg = [fix(bins*.87):ceil(bins*.97)];
        mpl.hk.bg = mean(mpl.rawcts(mpl.r.bg,:));
        %disp('Applying range-squared correction.');
        %     for i = 1:profs
        %         mpl.prof(:,i) = mpl.prof(:,i) .* (range.^2);
        %     end;
        mpl.prof = mpl.prof.*((mpl.range.^2)*ones(1,profs));
        %%

    elseif (any(findstr(mpl.statics.datastream, '.a1'))&~any(findstr(mpl.statics.datastream,'ipa')))
        disp('Reading a1-level data...');

        %Reading "a1" netcdf file
        [varid, rcode] = ncmex('VARID', ncid, 'preliminary_cbh');
        if varid>0
            mpl.hk.cbh = nc_getvar(ncid, varid);
        end;
        [varid, rcode] = ncmex('VARID', ncid, 'pulse_rep');
        if varid>0
            mpl.hk.pulse_rep = nc_getvar(ncid, varid);
        end;
        [varid, rcode] = ncmex('VARID', ncid, 'shots_summed');
        if varid>0
            mpl.hk.shots_summed = nc_getvar(ncid, varid);
        end;
        [varid, rcode] = ncmex('VARID', ncid, 'range');
        if varid>0
            mpl.range = nc_getvar(ncid, varid);
        end
        [varid, rcode] = ncmex('VARID', ncid, 'range_bin_time');
        if varid>0
            mpl.statics.range_bin_time = nc_getvar(ncid, varid);
        end


        %disp('Reading raw counts...');
        [varid, rcode] = ncmex('VARID', ncid, 'detector_counts');
        if varid>0
            mpl.rawcts = nc_getvar(ncid, 'detector_counts');
        end;

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
        mpl.r.range_offset = (first_bin - 0.5) * binwidth; % The "0.5" centers the first bin

        mpl.range = [1:bins-first_bin]';
        mpl.range = mpl.range*binwidth ;
        mpl.rawcts(1:first_bin,:) = [];
        mpl.prof(1:first_bin,:) = [];
        [bins,profs] = size(mpl.rawcts);
        mpl.r.bg = [fix(bins*.87):ceil(bins*.97)];
        mpl.hk.bg = mean(mpl.rawcts(mpl.r.bg,:));
        %disp('Applying range-squared correction.');
        %     for i = 1:profs
        %         mpl.prof(:,i) = mpl.prof(:,i) .* (range.^2);
        %     end;
        mpl.prof = ((mpl.range.^2)*ones(1,profs)).* mpl.prof;

        mpl.hk.energy_monitor = nc_getvar(ncid, 'energy_monitor');
        mpl.hk.instrument_temp = nc_getvar(ncid, 'instrument_temp');
        mpl.hk.laser_temp = nc_getvar(ncid, 'laser_temp');
        mpl.hk.detector_temp = nc_getvar(ncid, 'detector_temp');
        mpl.hk.filter_temp = nc_getvar(ncid, 'filter_temp');
        %mpl.statics.shots_summed = round(mean(nc_getvar(ncid, 'shots_summed')));
        if isfield(mpl.hk, 'pulse_rep')
            mpl.statics.pulse_rep = round(mean(mpl.hk.pulse_rep));
        end
    elseif any(findstr(mpl.statics.datastream, 'MPL_Ingest'))
        disp('Reading MPL_Ingest a1-level data...');
        %Reading "a1" netcdf file
        [varid, rcode] = ncmex('VARID', ncid, 'preliminary_cbh');
        if varid>0
            mpl.hk.cbh = nc_getvar(ncid, varid);
        end;
        [varid, rcode] = ncmex('VARID', ncid, 'pulse_rep');
        if varid>0
            mpl.hk.pulse_rep = nc_getvar(ncid, varid);
        end;
        [varid, rcode] = ncmex('VARID', ncid, 'shots_summed');
        if varid>0
            mpl.hk.shots_summed = nc_getvar(ncid, varid);
        end;
        [varid, rcode] = ncmex('VARID', ncid, 'range');
        if varid>0
            mpl.range = nc_getvar(ncid, varid);
        end
        [varid, rcode] = ncmex('VARID', ncid, 'range_bin_time');
        if varid>0
            mpl.statics.range_bin_time = nc_getvar(ncid, varid);
        end


        %disp('Reading raw counts...');
        [varid, rcode] = ncmex('VARID', ncid, 'backscatter');
        if varid>0
            mpl.rawcts = nc_getvar(ncid, 'backscatter');
        end;

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
        mpl.r.range_offset = (first_bin - 0.5) * binwidth; % The "0.5" centers the first bin

        mpl.range = [1:bins-first_bin]';
        mpl.range = mpl.range*binwidth ;
        mpl.rawcts(1:first_bin,:) = [];
        mpl.prof(1:first_bin,:) = [];
        [bins,profs] = size(mpl.rawcts);
        mpl.r.bg = [fix(bins*.87):ceil(bins*.97)];
        mpl.hk.bg = mean(mpl.rawcts(mpl.r.bg,:));
        %disp('Applying range-squared correction.');
        %     for i = 1:profs
        %         mpl.prof(:,i) = mpl.prof(:,i) .* (range.^2);
        %     end;
        mpl.prof = ((mpl.range.^2)*ones(1,profs)).* mpl.prof;

        mpl.hk.energy_monitor = nc_getvar(ncid, 'energy_monitor');
        mpl.hk.instrument_temp = nc_getvar(ncid, 'instrument_temp');
        mpl.hk.laser_temp = nc_getvar(ncid, 'laser_temp');
        mpl.hk.detector_temp = nc_getvar(ncid, 'detector_temp');
        mpl.hk.filter_temp = nc_getvar(ncid, 'filter_temp');
        %mpl.statics.shots_summed = round(mean(nc_getvar(ncid, 'shots_summed')));
        if isfield(mpl.hk, 'pulse_rep')
            mpl.statics.pulse_rep = round(mean(mpl.hk.pulse_rep));
        end

    else
        %Not sure what type of mpl file!
        disp('Not sure what type of mpl netcdf file this is...');
        [varid, rcode] = ncmex('VARID', ncid, 'range');
        if varid>0
            mpl.range = nc_getvar(ncid, varid);
        end
        [varid, rcode] = ncmex('VARID', ncid, 'range_bin_time');
        if varid>0
            mpl.statics.range_bin_time = nc_getvar(ncid, varid);
        end
        %disp('Reading raw counts...');
        [varid, rcode] = ncmex('VARID', ncid, 'detector_counts');
        if varid>0
            mpl.rawcts = nc_getvar(ncid, 'detector_counts');
        end;

        %disp('ZenithAngle...');
        [varid, rcode] = ncmex('VARID', ncid, 'zenith_angle');
        if varid>0
            mpl.hk.zenith_angle = nc_getvar(ncid, 'zenith_angle');
        end;

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
        mpl.r.range_offset = (first_bin - 0.5) * binwidth; % The "0.5" centers the first bin

        mpl.range = [1:bins-first_bin]';
        mpl.range = mpl.range*binwidth ;
        mpl.rawcts(1:first_bin,:) = [];
        mpl.prof(1:first_bin,:) = [];
        [bins,profs] = size(mpl.rawcts);
        mpl.r.bg = [fix(bins*.87):ceil(bins*.97)];
        mpl.hk.bg = mean(mpl.rawcts(mpl.r.bg,:));
        %disp('Applying range-squared correction.');
        for i = 1:profs
            mpl.prof(:,i) = mpl.prof(:,i) .* (mpl.range.^2);
        end;
        % mpl.prof = ((range.^2)*ones(1,profs)).* mpl.prof;
    end
    base_time = nc_getvar(ncid, 'base_time');
    time_offset = nc_getvar(ncid, 'time_offset');
    epoch_time = base_time + time_offset;
    [mpl.time] = epoch2serial(epoch_time);
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
%     mpl.statics.shots_summed = [];
    mpl.statics.pulse_rep = [];
    [varid, rcode] = ncmex('VARID', ncid, 'height');
    if varid>0
        mpl.range = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'range');
    if varid>0
        mpl.range = nc_getvar(ncid, varid);
    end;
    mpl.statics.maxAltitude = max(mpl.range);
    mpl.statics.range_bin_time = [];
end


mpl.statics.lat  = nc_getvar(ncid, 'lat');
mpl.statics.lon = nc_getvar(ncid, 'lon');
mpl.statics.alt = nc_getvar(ncid, 'alt');

[varid, rcode] = ncmex('VARID', ncid, 'max_altitude');
if varid>0
    statics.maxAltitude = nc_getvar(ncid, 'max_altitude');
end;

status = 1;
