
function [nc] = timesync (nc)

% [NC] = TIMESYNC (NC)
%
%   Synchronizes ARM-specific fields/attributes with level-zero time
%   field in netcdf structure.  If this time field does not exist,
%   it will be created based on the existing ARM fields (e.g. time,
%   base_time/time_offset).
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%
%   See also EPOCH2SERIAL.
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: timesync.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: timesync.m,v $
%   Revision 1.1  2013/12/11 00:49:08  cflynn
%   Committing anctools
%
%   Revision 1.1  2011/04/08 13:49:29  cflynn
%   *** empty log message ***
%
%   Revision 1.2  2008/10/20 17:08:50  cflynn
%   Force serial time as double irrespective of incoming time fields in netcdf file.  This was done to get around data type limitation of datenum.  Seems that there is no reason datanum shouldn't eat other numeric data types, but there ya go.
%
%   Revision 1.1  2007/11/09 01:24:20  cflynn
%   This repository is for Matlab m-files
%
%   Revision 1.1  2007/09/05 08:08:56  cflynn
%   Creating Matlab Library for central ARM distribution of matlab scripts and functions
%
%   Revision 1.11  2006/07/20 07:03:38  cflynn
%   Modified to output base_time equal referenced against first sample time and corresponding time_offset starting at 0.
%
%   Revision 1.10  2006/07/06 22:24:49  cflynn
%   Fixed infinite recursion that assumed either time or base_time+time_offset exists in the file.
%
%   Revision 1.9  2006/06/23 17:09:18  sbeus
%   Changed ncmex calls to mexnc.
%
%   Revision 2.0  2009/08/25 23:09:18  flynn
%   Changed mexnc calls to internam matlab netcdf calls.
%
%   Revision 1.8  2006/06/22 21:26:59  sbeus
%   Updated logic pertaining to ordering of single-dimensioned fields:
%     Record field: row vector (1r x nc)
%     Column field: column vector (nr x 1c)
%
%   Revision 1.7  2006/06/19 18:43:01  sbeus
%   Added back CVS log information.
%
%
%-------------------------------------------------------------------

if (isfield(nc, 'time'))
    if (length(nc.time) > 0)
        % Synchronize ARM netcdf fields with this serial time data.
        epoch = serial2epoch(nc.time);
        midnight = serial2epoch(floor(nc.time(1)));
        since_midnight = epoch-midnight;

%         bt = epoch(1) - mod(min(epoch), 86400);
        bt = epoch(1);
        epoch = (epoch - bt);
        
        dims = size(epoch);
        if (dims(2) < dims(1))
            epoch = epoch'; % '
            nc.time = nc.time'; % '
        end

        btstring    = [datestr(epoch2serial(bt), 'dd-mmm-yyyy HH:MM:SS'), ' GMT'];
        timestring  = ['seconds since ', datestr(epoch2serial(bt), 'yyyy-mm-dd HH:MM:SS'), ' 0:00'];
        midnightstring = ['seconds since ', datestr(epoch2serial(midnight), 'yyyy-mm-dd HH:MM:SS'), ' 0:00'];

        % base_time.
        nc.vars.base_time.data                  = int32(bt);
        nc.vars.base_time.dims                  = {''};
        nc.vars.base_time.datatype              = netcdf.getConstant('NC_LONG');        
        nc.vars.base_time.atts.string.data      = btstring;
        nc.vars.base_time.atts.long_name.data   = 'Base time in Epoch';
        nc.vars.base_time.atts.units.data       = 'seconds since 1970-1-1 0:00:00 0:00';

        % time_offset.
        nc.vars.time_offset.data                = epoch;
        nc.vars.time_offset.dims                = {'time'};
        nc.vars.time_offset.datatype            = netcdf.getConstant('NC_DOUBLE');
        nc.vars.time_offset.atts.long_name.data = 'Time offset from base_time';
        nc.vars.time_offset.atts.units.data     = timestring;

        % time.
        if isfield(nc.vars,'time')
        nc.vars.time.data                       = since_midnight;
        nc.vars.time.dims                       = {'time'};
        nc.vars.time.datatype                   = netcdf.getConstant( 'NC_DOUBLE');
        nc.vars.time.atts.long_name.data        = 'Time offset from midnight';
        nc.vars.time.atts.units.data            = midnightstring;
        end
    else
        disp('Time fields are empty.  Creating defaults...');

        % default base_time.
        nc.vars.base_time.data                  = [];
        nc.vars.base_time.atts.string.data      = ['DD-mmm-YYYY,HH:MM:SS GMT'];
        nc.vars.base_time.atts.long_name.data   = 'Base time in Epoch';
        nc.vars.base_time.atts.units.data       = 'seconds since 1970-1-1 0:00:00 0:00';

        % default time_offset.
        nc.vars.time_offset.data                = [];
        nc.vars.time_offset.atts.long_name.data = ['Time offset from base_time'];
        nc.vars.time_offset.atts.units.data     = ['seconds since ' nc.vars.base_time.atts.string.data];

        % default time.
        if isfield(nc.vars,'time')
        nc.vars.time.data                       = [];
        nc.vars.time.atts.long_name.data        = ['Time offset from midnight'];
        nc.vars.time.atts.units.data            = ['seconds since DD-mmm-YYYY,HH:MM:SS GMT'];
        end
   end

   chartype = netcdf.getConstant( 'NC_CHAR');

   nc.vars.base_time.atts.string.datatype       = chartype;
   nc.vars.base_time.atts.long_name.datatype    = chartype;
   nc.vars.base_time.atts.units.datatype        = chartype;
   nc.vars.time_offset.atts.long_name.datatype  = chartype;
   nc.vars.time_offset.atts.units.datatype      = chartype;
   if isfield(nc.vars,'time')
   nc.vars.time.atts.long_name.datatype         = chartype;
   nc.vars.time.atts.units.datatype             = chartype;
   end
else
    % Synchronize serial time data with ARM netcdf fields.
    if (isfield(nc.vars,'base_time') & isfield(nc.vars,'time_offset'))
        nc.time = epoch2serial(double(nc.vars.base_time.data) + double(nc.vars.time_offset.data));
    elseif (isfield(nc.vars, 'time'))
        if isfield(nc.vars.time.atts,'units') & ~isempty(findstr(nc.vars.time.atts.units.data, 'since'))
           this_str = nc.vars.time.atts.units.data(findstr(nc.vars.time.atts.units.data, 'since')+6:end);
           timefac = 1;
           if ~isempty(findstr(nc.vars.time.atts.units.data, 'minutes'))
              timefac = 60;
           elseif ~isempty(findstr(nc.vars.time.atts.units.data, 'hours'))
              timefac = 60*60;
           elseif~isempty(findstr(nc.vars.time.atts.units.data, 'days'))
              timefac = 24*60*60;
           end
           cols = findstr(this_str,':'); 
           if length(cols)>=2
              this_str = this_str(1:cols(2)+2);
           end
           timevec = datenum(this_str);
           nc.time = timevec + double(nc.vars.time.data / (86400./timefac));
        end
    end
    % Sync time fields with newly created serial time data.
   if isfield(nc.vars,'time')|isfield(nc.vars,'base_time')|isfield(nc.vars,'time_offset')
    nc = timesync(nc);
   end

end

% Set time dimension length to length of serial time array.
if isfield(nc, 'time')
nc.dims.time.length = length(nc.time);
end
if isfield(nc, 'recdim')
if (strcmp(nc.recdim.name, 'time'))
    nc.recdim.length = nc.dims.time.length;
   end
end
nc.vars = init_ids(nc.vars);
return

