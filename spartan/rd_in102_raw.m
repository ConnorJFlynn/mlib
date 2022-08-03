function out = rd_in102_raw(infile);
% out = rd_in102_raw(infile); 
% Reads a supplied or selected Air Photon IN102 Nephelometer file
% Written by Connor Flynn, OU, 2022-08-03, working
% TBD: make recursive to bundle multiple selected files.

if ~isavar('infile')||~isafile(infile)
   infile = getfullname('IN*.csv','in102','Select IN102 neph raw csv file.');
end

fid = fopen(infile,'r');

header = fgetl(fid); header;
head_str = textscan(header,'%s','Delimiter',',');head_str = head_str{1};
fmt_str = ['IN%f %s ',repmat('%f ',[1,46]), '%s %f %f'];
A = textscan(fid,fmt_str,'Delimiter',',');
fclose(fid);
out.SN = A{1};
out.time = datenum(A{2},'yyyy-mm-ddTHH:MM:SS');

for col=9:51
   out.(head_str{col}) = A{col};
end

figure; plot(out.time, out.TOTAL_SCATT_BLUE, 'x',out.time, out.TOTAL_SCATT_GREEN, 'o',out.time, out.TOTAL_SCATT_RED,'+'); dynamicDateTicks
legend('B_t_s_c_a(B)','B_t_s_c_a(G)','B_t_s_c_a(R)'); ylabel('Scattering [1/Mm]')
end
