function sws_rad_ascii_out(sws)
%sws_rad_ascii_out(sws)
% Generates ascii file containing sws radiance data.
%%

[pname,fname] = fileparts(sws.filename);
V = datevec(sws.time(sws.shutter==0));
%%
doy = serial2doy(sws.time(sws.shutter==0))';
HHhh = (doy - floor(doy)) *24;
%%

header_row = ['yyyy, mm, dd, HH, MM, SS, doy, HHhh, '];
header_row = [header_row, sprintf('nm_%1.1f, ',sws.Si_lambda)];
%%
format_str = ['%d, %d, %d, %d, %d, %0.f, %3.6f, %2.4f'];
format_str = [format_str,repmat(', %1.4f',[1,length(sws.Si_lambda)]), '\n'];
%%
vis_out = [V(1,1),V(1,2), V(1,3), V(1,4), V(1,5), V(1,6), doy(1), HHhh(1), ...
    sws.Si_resp']';
%%
fid = fopen(strrep(sws.filename,'raw.dat','Si_resp.dat'),'wt');
fprintf(fid,'%s \n',header_row );
fprintf(fid,format_str,vis_out);
fclose(fid);

% txt_out needs to be composed of data oriented as column vectors.
vis_out = [V(:,1),V(:,2), V(:,3), V(:,4), V(:,5), V(:,6), doy, HHhh, ...
    sws.Si_spec(:,sws.shutter==0)']';

%%
fid = fopen(strrep(sws.filename,'raw.dat','Si_radiance.dat'),'wt');
% fid = fopen([pname, '/', strrep(fname,'raw.dat','Si_radiance.dat'), '.txt'],'wt');
fprintf(fid,'%s \n',header_row );
fprintf(fid,format_str,vis_out);
fclose(fid);

%%
%%

header_row = ['yyyy, mm, dd, HH, MM, SS, doy, HHhh, '];
header_row = [header_row, sprintf('nm_%1.1f, ',sws.In_lambda)];
%%
format_str = ['%d, %d, %d, %d, %d, %0.f, %3.6f, %2.4f'];
format_str = [format_str,repmat(', %1.4f',[1,length(sws.In_lambda)]), '\n'];
%%
vis_out = [V(1,1),V(1,2), V(1,3), V(1,4), V(1,5), V(1,6), doy(1), HHhh(1), ...
    sws.In_resp']';
%%
fid = fopen(strrep(sws.filename,'raw.dat','In_resp.dat'),'wt');
% fid = fopen([pname, '/', strrep(fname,'raw.dat','In_resp.dat'), '.txt'],'wt');
fprintf(fid,'%s \n',header_row );
fprintf(fid,format_str,vis_out);
fclose(fid);

% txt_out needs to be composed of data oriented as column vectors.
vis_out = [V(:,1),V(:,2), V(:,3), V(:,4), V(:,5), V(:,6), doy, HHhh, ...
    sws.In_spec(:,sws.shutter==0)']';

%%
fid = fopen(strrep(sws.filename,'raw.dat','In_radiance.dat'),'wt');

% fid = fopen([pname, '/', strrep(fname,'raw.dat','In_radiance.dat'), '.txt'],'wt');
fprintf(fid,'%s \n',header_row );
fprintf(fid,format_str,vis_out);
fclose(fid);

%%


return

