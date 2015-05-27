function nomcal = gen_nomcal_file(infile)
% This function generates new format NominalCals files from CalibInfo files 
if ~exist('infile','var')
   [fname, pname] = uigetfile('*CalibInfo*');
   if length(pname>0)
      infile = [pname, fname];
   end
end
fid = fopen(infile);
infofile = char(fread(fid,'char')');
fclose(fid);
[fpath, fname, fext, fver] = fileparts(infile);

header_row = (infofile(1:min(find(infofile==10))-1));
[tok, rest] = strtok(header_row);
[tok, rest] = strtok(rest);[tok, rest] = strtok(rest);[tok, rest] = strtok(rest);[tok, rest] = strtok(rest);
[tok, rest] = strtok(rest);

header_time = datenum('1900','yyyy') + sscanf(tok,'%e');
yyyymmdd = datestr(header_time, 'yyyymmdd');
hhmmss = datestr(header_time, 'HHMMSS');

[tok, rest] = strtok(fname, '.');
filename = ['NominalCals', rest];
%%
if any(findstr(infofile, 'C0A'))&any(findstr(infofile, 'C0C'))&any(findstr(infofile, 'C6A'))&any(findstr(infofile, 'C6C'))
   found = true;
   % Get channel senstivities, "C_A" terms
   for i = 0:6
      colon = findstr(infofile, ['C',num2str(i),'A :=']);
      semicolon = findstr(infofile(colon:end),';');
      det_sens_str{i+1} = infofile((colon(1)+6):(colon(1)+semicolon(1)-2)); %advances past := and stops before ;
      det_sens(i+1) = eval(char(det_sens_str{i+1}));
   end
   % Get logger gains, "C_C" terms
   for i = 0:6
      colon = findstr(infofile, ['C',num2str(i),'C :=']);
      semicolon = findstr(infofile(colon:end),';');
      logger_gain_str{i+1} = infofile((colon(1)+6):(colon(1)+semicolon(1)-2)); %advances past := and stops before ;
      logger_gain(i+1) = eval(char(logger_gain_str{i+1}));
   end
elseif any(findstr(infofile, 'FR1 :='))&any(findstr(infofile, 'GFR1 :='))&any(findstr(infofile, 'FR7'))&any(findstr(infofile, 'GFR7'))
      found = true;
   % Get Filter Responsivities "FR" terms (equivalent to "C_A" terms)
   for i = 1:7
      colon = findstr(infofile, ['FR',num2str(i),' :=']);
      semicolon = findstr(infofile(colon:end),';');
      det_sens_str{i} = infofile((colon(1)+6):(colon(1)+semicolon(1)-2)); %advances past := and stops before ;
      det_sens(i) = eval(char(det_sens_str{i}));
   end
   % Get logger gains, "GFR" terms (equivalent to "C_C" terms)
   for i = 1:7
      colon = findstr(infofile, ['GFR',num2str(i),' :=']);
      semicolon = findstr(infofile(colon:end),';');
      logger_gain_str{i} = infofile((colon(1)+7):(colon(1)+semicolon(1)-2)); %advances past := and stops before ;
      logger_gain(i) = eval(char(logger_gain_str{i}));
   end
elseif  any(findstr(infofile, 'SR1, SR2, SR3, SR4, SR5, SR6, SR7'))&any(findstr(infofile, 'GSR1'))
      found = true;
   % Get Filter Responsivities "FR" terms (equivalent to "C_A" terms)
   for i = 1:7
      colon = findstr(infofile, ['SR',num2str(i),' :=']);
      semicolon = findstr(infofile(colon:end),';');
      det_sens_str{i} = infofile((colon(1)+6):(colon(1)+semicolon(1)-2)); %advances past := and stops before ;
      det_sens(i) = eval(char(det_sens_str{i}));
   end
   % Get logger gains, "GFR" terms (equivalent to "C_C" terms)
   for i = 1:7
      colon = findstr(infofile, ['GSR',num2str(i),' :=']);
      semicolon = findstr(infofile(colon:end),';');
      logger_gain_str{i} = infofile((colon(1)+7):(colon(1)+semicolon(1)-2)); %advances past := and stops before ;
      logger_gain(i) = eval(char(logger_gain_str{i}));
   end
else
   found = false;
   for i = 1:7
      det_sens(i) = 1;
      logger_gain(i) = 1;
      det_sens_str{i} = 'not found';
      logger_gain_str{i} = 'not found';
   end
end
nomcal = det_sens .* logger_gain;

%%
if found 
outfile = fullfile(fpath, [filename, '.dat']);
else
   outfile = fullfile(fpath, [filename, '.no_cal.dat']);
end
fid = fopen(outfile,'wt');
if fid<3
   pause
end
fprintf(fid,'%s \n',header_row );
fprintf(fid, ' %s \n', '');
fprintf(fid, '%s \n', upper('# detector sensitivities in V/W/( m^2_nm)'));
% sprintf('%s \n',header_row )
% sprintf('%s \n', upper('# detector sensitivities:'))

for f = 0:6
   format_str = ['#     := %g ; \n'];
   text_out = [det_sens(f+1)];
   %     sprintf(['# C', num2str(f),'A := %s ; \n'], char(det_sens_str{f+1}))
   %     sprintf(format_str,text_out)
   fprintf(fid,['# C', num2str(f),'A := %s ; \n'], char(det_sens_str{f+1}));
   fprintf(fid, format_str, text_out);
end
fprintf(fid, ' %s \n', '');
fprintf(fid, '%s \n', upper('# logger gains in cts/V'));
% sprintf('%s \n', upper('# logger gains'))
for f = 0:6
   format_str = ['#     := %g ; \n'];
   text_out = [logger_gain(f+1)];
   %     sprintf(format_str,text_out)
   fprintf(fid,['# C', num2str(f),'C := %s ; \n'], char(logger_gain_str{f+1}));
   fprintf(fid, format_str, text_out);
end
% sprintf('%s \n', upper('# nominal cals = det_sens * logger_gain'))
fprintf(fid, ' %s \n', '');
fprintf(fid, '%s \n', upper('# nominal cals in cts/W/( m^2_nm) = det_sens * logger_gain '));
for f = 0:6
   format_str = ['%g \n'];
   text_out = [nomcal(f+1)];
   %     sprintf(format_str,text_out)
   fprintf(fid, format_str, text_out);
end

fclose(fid);

