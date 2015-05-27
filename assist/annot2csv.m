function outfile = annot2csv(infile);
if ~exist('infile','var')
   infile = getfullname_('*.xls','xls_data','Select xls file');
end
[pname, fname, ext] = fileparts(infile);
[xl_num, xl_txt, xl_raw]= xlsread(infile);
outfile = [pname, filesep,fname, '.csv'];
[indate,tmp] = strtok(fname,'_');
[intime,~] = strtok(tmp,'_');
this_time = datenum([indate, intime],'yyyymmddHHMMSS');

fid = fopen(outfile, 'w+');
c = onCleanup(@()fclose(fid));
fprintf(fid,'%s \n',xl_raw{1,1});
labels = [xl_raw(2,:)];
format_str = ['%s ',repmat([', %s'],1,length(labels)-1),'\n'];
fprintf(fid,format_str,labels{:});
for r = 3:size(xl_raw,1)
xl_raw{r,4} = sscanf([xl_raw{r,4}],'%g');
xl_raw{r,12} = sscanf([xl_raw{r,12}],'%g');
xl_raw{r,18} = sscanf([xl_raw{r,18}],'%g');
xl_raw{r,39} = sscanf([xl_raw{r,39}],'%g');
xl_raw{r,55} = sscanf([xl_raw{r,55}],'%g');
end
% rows 1-10: 
% Scan Number	Direction	Scene	Scene Angle (°)	Size	ZPD	Year	Day	Time of Day	Detector A
% 47995	Forward	Cold Blackbody	256.0	32768	16382	2011	54	17:35:57.039030	MCT WB
format_str = ['%d,%s,%s,%g,%d,%d,%g,%g,%s,%s,'];
% rows 11-20:
% Filter A	Gain A	P-P A	Min A Loc	Max A Loc	Detector B	Filter B	Gain B	P-P B	Min B Loc
% 0	32	10011	16388	16381	InSb	0	16	3083	16385
format_str = [format_str,'%d,%d,%d,%d,%d,%s,%d,%d,%d,%d,'];
% rows 21-30:
% Max B Loc	Cooler Software revision	Cooler Set Point	Cooler Diode Voltage	Cooler Ready Window	Cooler Voltage AC	Cooler Voltage DC	Cooler AC Output Freq.	Cooler Ambient Temp	Cooler Current DC
% 16381	9501 836 03502	1054	1054	4	5.980000019	24.87999916	50	22.36000061	0.569999993
format_str = [format_str,'%d,%s,%d,%g,%d,%g,%g,%g,%g,%g']; 
% rows 31-40:
% Cooler Pwr Up Cycles	Cooler Remote Status	Cooler Output Voltage	Hatch Open	Hatch Closed	Hatch Mode	Hatch Rain Out	Hatch Rain Aux	Hatch Sun	Hot BB Set Point
% 401	TRUE	9.5	TRUE	FALSE	Automatic	Clear	Light	0	60
format_str = [format_str,'%g,%s,%g,%s,%s,%s,%s,%s,%d,%g'];
% rows 41-50:
% Hot BB Mean	Hot BB Thermistor 1	Hot BB Thermistor 2	Hot BB Thermistor 3	Cold BB Set Point	Cold BB Mean	Cold BB Thermistor 1	Cold BB Thermistor 2	Cold BB Thermistor 3	GPS UTC of Position
% 59.998	60.104	60.11	59.782	35	3.812	3.804	3.836	3.798	21:58:37
format_str = [format_str,'%g,%g,%g,%g,%g,%g,%g,%g,%g,%s'];
% rows 51-56:
% GPS Latitude	GPS Longitude	GPS Altitude	GPS Fix Quality	GPS NB Satellites	GPS Precision
% N40.454	W106.77298	2780.8M	DGPS Fix	9	1.7m
format_str = [format_str,'%s,%s,%s,%s,%d,%s\n'];
for r = 3:size(xl_raw,1)
   values = [xl_raw(r,:)];
   fprintf(fid,format_str,values{:});
end
% fclose(fid);

return