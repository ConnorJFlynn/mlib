%%
smos = ancload;
%%
smos = smos1;
V = datevec(smos.time);
[pname,fname] = fileparts(smos.fname);
yyyy = V(:,1);
mm = V(:,2);
dd = V(:,3);
HH = V(:,4);
MM = V(:,5);
SS = V(:,6);
doy = serial2doy(smos.time)';
HHhh = (doy - floor(doy)) *24;
% txt_out needs to be composed of data oriented as column vectors.
txt_out = [yyyy, mm, dd, HH, MM, SS, doy, HHhh, ...
    smos.vars.bar_pres.data',...
    smos.vars.temp.data',...
    smos.vars.rh.data',...
    smos.vars.vap_pres.data',...
    smos.vars.wspd.data',...
    smos.vars.wdir.data',...
    smos.vars.precip.data'];
%
header_row = ['yyyy, mm, dd, HH, MM, SS, doy, HHhh, '];
header_row = [header_row, 'atm_pres, TempC, '];
header_row = [header_row, 'RH, vapor_pres, WindSpeed, '];
header_row = [header_row, 'WindDir, Precip'];

format_str = ['%d, %d, %d, %d, %d, %0.f, %3.6f, %2.4f, '];
format_str = [format_str, '%2.3f, %2.3f, %2.3f, '];
format_str = [format_str, '%2.3f, %2.3f, '];
format_str = [format_str, '%2.3f, %2.3f \n'];

fid = fopen([pname, '/', fname, '.txt'],'wt');
fprintf(fid,'%s \n',header_row );
fprintf(fid,format_str,txt_out');
fclose(fid);
%%

