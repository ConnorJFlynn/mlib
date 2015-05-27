function status = aod_output(nc, fid);
V = datevec(nc.time);
[pname,fname] = fileparts(nc.fname);
yyyy = V(:,1);
mm = V(:,2);
dd = V(:,3);
HH = V(:,4);
MM = V(:,5);
SS = V(:,6);
doy = serial2doy(nc.time)';
HHhh = (doy - floor(doy)) *24;
% cza = 1./nc.vars.airmass.data;
%
txt_out = [yyyy, mm, dd, HH, MM, SS, doy, HHhh, ...
    nc.vars.aerosol_optical_depth_filter1.data',...
    nc.vars.aerosol_optical_depth_filter2.data',...
    nc.vars.aerosol_optical_depth_filter3.data',...
    nc.vars.aerosol_optical_depth_filter4.data',...
    nc.vars.aerosol_optical_depth_filter5.data',...
    nc.vars.angstrom_exponent.data'];
%
header_row = ['yyyy, mm, dd, HH, MM, SS, doy, HHhh, '];
header_row = [header_row, 'aod_415nm, aod_500nm, '];
header_row = [header_row, 'aod_615nm, aod_676nm, aod_870nm, '];
header_row = [header_row, 'angstrom_exponent'];

format_str = ['%d %d %d %d %d %0.f %3.6f %2.4f '];
% format_str = [format_str, '%2.5f '];
format_str = [format_str, '%2.3f %2.3f '];
format_str = [format_str, '%2.3f %2.3f %2.3f '];
format_str = [format_str, '%2.3f \n'];

% fid = fopen([pname, '/', fname, '.txt'],'wt');
% % fprintf(fid,'%s \n',header_row );
status = fprintf(fid,format_str,txt_out');
% status = fclose(fid);
%%

