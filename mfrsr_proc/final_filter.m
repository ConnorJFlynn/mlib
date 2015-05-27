function status = final_filter;
% status = final_filters;
% This function expects that the filter files are stored in a directory tree named
% as "*/hexID/yyyymmdd" where hexID is the hex serial number of the head.
% It names the output file based on the hex ID and on the date.


indir = [uigetdir('D:\', 'Select a directory containing filter traces.'),filesep];
outdir = indir;
%Put a big loop around this to recursively drill through the directory
%list finding "final" directories
[ftrace] = read_filter_dir(indir,'*.*');
filters = [];
for i =1:length(ftrace)
    filters = sort(unique([filters, i*~isempty(ftrace{i})]));
end
if filters(1)==0
    filters(1) = [];
end
if length(filters)~=6
    status = output_prefinal_filters(ftrace,indir,filters);
else
    status = output_final_filters(ftrace,indir);
end
disp('Done!')
return
end

function status = output_final_filters(ftrace, indir);
% status = output_final_filters(trace,indir,outdir);
%Uses indir to determine head and date
flip_indir = fliplr(indir);
[tok, rest] = strtok(flip_indir,filesep); %dump "final" directory
date_part = fliplr(tok);
joe_time = serial2joe(datenum(date_part, 'yyyymmdd'));
[tok, rest] = strtok(rest,filesep); % pick off head_ID
head_id = ['$',fliplr(tok)];
outfile = [indir,'FilterInfo.',head_id, '.',date_part, '.dat'];
%open the file, output the filter contents
fid = fopen(outfile,'wt');
if fid<3
   status = -1;
   disp('Failed attempt to open final output file.');
else
   status = 1;
   fprintf(fid,'MULTIFILTER32 7 30 $FFFF %s %5.5f \n',head_id, joe_time );
   for f = 1:6
      fprintf(fid, '%s \n', ['Filter ',num2str(f)]);
      format_str = ['#Nominal = %g nm \n'];
      text_out = [ftrace{f}.nominal];
      fprintf(fid, format_str, text_out);

      format_str = ['CWL = %3.1f nm \n'];
      text_out = [ftrace{f}.normed.cw];
      fprintf(fid, format_str, text_out);

      format_str = ['FWHM = %3.1f nm \n'];
      text_out = [ftrace{f}.normed.FWHM];
      fprintf(fid, format_str, text_out);

      fprintf(fid, '%s \n','# nm      T (normalized to unity area under curve)');
      format_str = ['%3.1f   %1.2e \n'];
      text_out = [ftrace{f}.nm, ftrace{f}.normed.T]';
      fprintf(fid, format_str, text_out);

      fprintf(fid, '%s \n', ['End filter ',num2str(f)]);
      fprintf(fid, '# \n');

      %for each filter, print nominal, print CWL, print FWHM,
      % print lambda and T
   end
   fclose(fid);
   disp('closed fid');
end
return
end

function status = output_prefinal_filters(ftrace,indir,filters);
% status = output_prefinal_filters(trace,indir);
% Produces similar output to final, except only filter at a time and
% without the header string.  This permits manual concatenation
status = -1;

for f = filters
   outfile = [indir,'filter_',num2str(f),'.dat'];
   %open the file, output the filter contents
   fid = fopen(outfile,'wt');
   if fid<3
      disp(['Failed attempt to open output file for filter ', num2str(f)]);
   else
      status = 1;
      fprintf(fid, '%s \n', ['Filter ',num2str(f)]);
      format_str = ['#Nominal = %g nm \n'];
      text_out = [ftrace{f}.nominal];
      fprintf(fid, format_str, text_out);

      format_str = ['CWL = %3.1f nm \n'];
      text_out = [ftrace{f}.normed.cw];
      fprintf(fid, format_str, text_out);

      format_str = ['FWHM = %3.1f nm \n'];
      text_out = [ftrace{f}.normed.FWHM];
      fprintf(fid, format_str, text_out);

      fprintf(fid, '%s \n','# nm      T (normalized to unity area under curve)');
      format_str = ['%3.1f   %1.2e \n'];
      text_out = [ftrace{f}.nm, ftrace{f}.normed.T]';
      fprintf(fid, format_str, text_out);

      fprintf(fid, '%s \n', ['End filter ',num2str(f)]);
      fprintf(fid, '# \n');
      fclose(fid);
   end
end
return
end

