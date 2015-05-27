function status = ancwrite (in, ncfile)

% status = ancwrite(in, ncfile)
status = 1;
if ~exist('in','var')
   in = ancload;
end
if ~exist('ncfile','var')
   ncfile = in.fname;
end
quiet = false;
if isfield(in,'quiet')
   quiet = in.quiet;
end

%%
%ancwrite:
% 'opens' existing netcdf file (may be empty)
% writes contents of time-related elements listed with keep.
% 'closes' file
% So the general idea would be to create and save the stub DOD with ancstaticdod,
% copy the stub file to the desired location
% Then call ancwrite to populate the file
% The time-related elements are:
% [ncid,status] = mexnc('open', ncfile, 'nc_write_mode');
try
   ncid = netcdf.open(ncfile,'write');
catch ME
   disp(ME.message)
   status = status -1;
   return;
end

% Write global attributes.
if (isfield(in,'atts'))
   % TODO: Set ARM globals (e.g. history, version).
   in.atts = init_ids(in.atts);
   atts = fieldnames(in.atts);
   for aa = 1:length(atts)
      val = in.atts.(atts{aa});
      key = atts{aa};
      try
         [datatype, len] = netcdf.inqatt(ncid,netcdf.getconstant('global'),key);
      catch ME
         disp(ME.message)
         return
      end
      %       [datatype, len, status] = mexnc('ATTINQ', ncid, -1, key);
      %        [val,key] = getnextelem(in.atts,nextid);
      if (status>0) &&(isfield(val,'keep') == false || (isfield(val,'keep') && val.keep == true))
         key = undolegalize(key);
         if (~isfield(val,'datatype'))
            val = ancfixdatatype(val);
            %                 if ischar(val.data)
            %                     val.datatype = 2;
            %                 else
            %                     val.datatype = 5;
            %                 end
         end
         try
            %             [status] =
            %             mexnc(['put_att_',anctype(val.datatype,false)],ncid,-1,key,val.datatype,length(val.data),val.data);
            netcdf.putAtt(ncid,netcdf.getConstant('GLOBAL'),key,val.data);
         catch ME
            disp(ME.message)
            status = status -1;
            handle_error(ncid);
            return;
         end
      end
   end
end

val = in.vars.base_time;
key = 'base_time';
td = [];
s = 0;

try
   netcdf.putVar(ncid,val.id,val.data)
catch ME
   disp(ME.message);
   status = status -1;
   s = s -1;
   return;
end
td = netcdf.getVar(ncid,val.id);

% status = mexnc(['put_var1_',anctype(val.datatype,true)],ncid,val.id,0,val.data);
% [td,s] = mexnc(['get_var1_',anctype(val.datatype,true)],ncid,val.id,0);
%
% if (status ~= 0)
%    disp(['MEXNC: ',mexnc('strerror', status)]);
%    disp(['ANCWRITE: Error writing variable data: ',key]);
%    handle_error(ncid);
%    return;
% end

% Make sure data was successfully saved to file.
if (s ~= 0)
   disp(['ANCWRITE: Error re-reading variable data for verification: ',key]);
else
   if (any((val.data ~= td)&((~isnan(val.data))|(~isnan(td)))))
      disp(['ANCWRITE: WARNING: Possible data truncation for variable: ',key]);
   end
end

aval = in.vars.base_time.atts.string;
akey = 'string';
% try
%    netcdf.redef(ncid);
% catch ME
%    status = status -1;
%    disp(ME.message);
% end
try
   
%    netcdf.put_att(ncid,in.vars.base_time.id,akey,aval.data);
   netcdf.putAtt(ncid,in.vars.base_time.id,akey,aval.data);
catch ME
   try
      netcdf.redef(ncid);
      netcdf.putAtt(ncid,in.vars.base_time.id,akey,aval.data);
      netcdf.enddef(ncid);
   catch ME
      status = status -1;
      disp(ME.message);
   end
%    status = status -1;
%    disp(ME.message);
end
% try
%    netcdf.enddef(ncid);
% catch ME
%    status = status -1;
%    disp(ME.message);
% end
if (status < 0)
   disp(['ANCWRITE: Cannot write attribute: ',key,':',akey]);
   handle_error(ncid);
   return;
end


aval = in.vars.base_time.atts.units;
akey = 'units';
try
   netcdf.redef(ncid);
catch ME
   status = status -1;
   disp(ME.message);
end
try
   netcdf.putatt(ncid,in.vars.base_time.id,akey,aval.data);
   
catch ME
   status = status -1;
   disp(ME.message);
end

try
   netcdf.enddef(ncid);
catch ME
   status = status -1;
   disp(ME.message);
end

if (status < 0)
   disp(['ANCWRITE: Cannot write attribute: ',key,':',akey]);
   handle_error(ncid);
   return;
end

aval = in.vars.time_offset.atts.units;
akey = 'units';
try
netcdf.redef(ncid);
catch ME
   status = status -1;
   disp(ME.message);
end
try
netcdf.putatt(ncid,in.vars.time_offset.id,akey,aval.data);
catch ME
   status = status -1;
   disp(ME.message);
end
try
netcdf.enddef(ncid);
catch ME
   status = status -1;
   disp(ME.message);
end

if (status < 0)
   disp(['ANCWRITE: Cannot write attribute: ',key,':',akey]);
   handle_error(ncid);
   return;
end

aval = in.vars.time.atts.units;
akey = 'units';
try
netcdf.redef(ncid);
catch ME
   status = status -1;
   disp(ME.message);
end
try
netcdf.putatt(ncid,in.vars.time.id,akey,aval.data);
catch ME
   status = status -1;
   disp(ME.message);
end

try
   netcdf.enddef(ncid);
   catch ME
   status = status -1;
   disp(ME.message);
end

if (status < 0)
   disp(['ANCWRITE: Cannot write attribute: ',key,':',akey]);
   handle_error(ncid);
   return;
end

% Write variable data.
vars = fieldnames(in.vars);
for v = 1:length(vars)
   val = in.vars.(vars{v});
   key = vars{v};
   if any(strcmp('time',val.dims))&&(~isfield(val,'keep') || (isfield(val,'keep') && val.keep == true))
      % Determine new dimension ids.
      if ~quiet disp(['Writing data: ', key]); end
      clear dimids start_ii count;
      dimids = [];
      start_ii = [0];
      count = [1];
      ndims = 0;
      if (isfield(val,'dims'))
         if (~isempty(val.dims{1}))
            ndims = length(val.dims);
         end
      end
%       val.dims = fliplr(val.dims); % flip dimensions because matlab read in reverse.
      for d = ndims:-1:1
         start_ii(d) = 0;
         count(d) = in.dims.(val.dims{d}).length;
      end

            key = undolegalize(key);
            td = [];
            s = 0;
            if ~isempty(val.data)
               if (ndims == 0)
                  try
                     netcdf.putVar(ncid,val.id,val.data)
                  catch ME
                     disp(ME.message);
                     status = status -1;
                     s = s -1;
                     return;
                  end
                  td = netcdf.getVar(ncid,val.id,start_ii);
               else
                  try
                     netcdf.putVar(ncid,val.id,start_ii,count,val.data);
                  catch ME
                     disp(ME.message);
                     status = status -1;
                     s = s -1;
                     return
                  end
                  td = netcdf.getVar(ncid,val.id,start_ii,count);
               end
            else
               s = 0;
            end

      if (status < 0)
         disp(['ANCWRITE: Error writing variable data: ',key]);
         handle_error(ncid);
         return;
      end

      % Make sure data was successfully saved to file.
      if (s ~= 0)
         disp(['ANCWRITE: Error re-reading variable data for verification: ',key]);
      else
         if (ndims == 1)
%             if (in.dims.(val.dims{1}).isunlim == true)
               % Re-orient single-dim, record fields as in ancgetdata.
               td = td'; % Not sure if this is necessary anymore with new netcdf calls
%                disp('ancwrite line 295, transpose commented out.')
%             end
         end
         if (any((val.data ~= td)&((~isnan(val.data))|(~isnan(td)))))
            disp(['ANCWRITE: WARNING: Possible data truncation for variable: ',key]);
         end
      end
   end
end
netcdf.close(ncid);


function handle_error(ncid)
% Procedure for handling errors.

netcdf.close(ncid);

return

function oldname = undolegalize(newname)
% Undo name legalization from anclink.

oldname = strrep(newname,'__dash__','-');
newname = strrep(newname,'__space__',' ');
oldname = strrep(newname,'underbar__','_');

return

