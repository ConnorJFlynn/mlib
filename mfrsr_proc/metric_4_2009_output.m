%%
abe_day = ancload;
[pname,fname] = fileparts(abe_day.fname);

%%
V = datevec(abe_day.time); % Convert the matlab serial date "time" to an array with columns of year, month, day, hour, minute, and second
yyyy = V(:,1);
mm = V(:,2);
dd = V(:,3);
HH = V(:,4);
MM = V(:,5);
SS = V(:,6);
doy = serial2doy(abe_day.time)';% Also represent time as "day of year"


% Arrange the data to be written to file as column vectors: 
txt_out = [yyyy, mm, dd, HH+1, doy, ...
    abe_day.vars.be_aod_500.data',...
    abe_day.vars.be_angst_exp.data'];
% Define the header row for the resulting text file
header_row = ['yyyy, mm, dd, HH, doy, '];
header_row = [header_row, 'aod_500nm, angstrom_exponent'];

% Define the corresponding format string to convert the data in txt_out
% into columns corresponding to the header row
format_str = ['%d, %d, %d, %d, %2.1f, '];
format_str = [format_str, '%2.3f, %2.3f \n'];

% Open the text file for writing 
fid = fopen([pname, '/', fname, '.txt'],'wt');
% Print the header row to the file
fprintf(fid,'%s \n',header_row );
% Print the column-ordered data to the file
fprintf(fid,format_str,txt_out');
% Close the file
fclose(fid);
%%

