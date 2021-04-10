function lamp_cal = rd_sasze_resp_file(infile)
if ~exist('infile','var')
    infile = getfullname('*.dat','sasze_resp','Select a SASZe responsivity file.');
end
[pname, fname, ext] = fileparts(infile); 
pname = [pname, filesep];
emanp = fliplr(pname); lamp = emanp(6);
% lamp_cal.lamps = sscanf(lamp,'%d');
C = textscan(fname, '%s', 'delimiter','.'); C = C{:}
lamp_cal.sas_unit = C{1};
% lamp_cal.spec_type = C{4};
% if strcmp(lamp_cal.spec_type,'si')
%     lamp_cal.spec_type = 'Si';
% else
%     lamp_cal.spec_type = 'InGaAs';
% end
% lamp_cal.t_int = sscanf(C{5},'%fms');
lamp_cal.first_date = datenum(C{3},'yyyymmddHHMM');
lamp_cal.first_datestr = datestr(lamp_cal.first_date,'yyyy-mm-dd HH:MM');

fid = fopen(infile,'r');
inline = fgetl(fid);
lamp_cal.title_line = inline;
inline = fgetl(fid);
% header(end+1) = {['% SAS_unit: sasze1']};
% header(end+1) = {['% Calibration_Date: ',datestr(vis.time(1),'yyyy-mm-dd HH:MM:SS UTC')]};
% header(end+1) = {['% Cal_source: ',src_fname]};
% header(end+1) = {['% Source_units: W/(m^2.sr.um)']};
% header(end+1) = {['% Lamps: ',num2str(lamp)]};
% header(end+1) = {['% Spectrometer_type: CCD2048']};
% header(end+1) = strrep(vis.header(i),'SN =', 'Spectrometer_SN:');
% header(end+1) = {['% Integration_time_ms: ',num2str(vis_cal.t_int_ms(vt))]};
% header(end+1) = {['% Resp_Units: (count/ms)/(W/(m^2.sr.um))']};
% header(end+1) = {['pixel  lambda_nm   resp    rate      signal    lights     darks      src_radiance'] };
while strcmp(inline(1),'%')
    if ~isempty(strfind(lower(inline),lower('SAS_unit:')))
        lamp_cal.sas_unit = sscanf(inline(strfind(lower(inline), lower('sas_unit:'))+...
            length('sas_unit:'):end),'%s');
    end
    if ~isempty(strfind(lower(inline),lower('Calibration_Date:')))&&~isempty(strfind(inline,'UTC'))
        lamp_cal.measurement_date = datenum(inline(strfind(lower(inline),lower('Calibration_Date:'))+length('Calibration_Date:'):end),'yyyy-mm-dd HH:MM:SS');
        lamp_cal.measurement_datestr = datestr(lamp_cal.measurement_date,'yyyy-mm-dd');
    end
    if ~isempty(strfind(lower(inline), lower('Cal_source:')))
        lamp_cal.cal_source = sscanf(inline(strfind(lower(inline), lower('Cal_source:'))+...
            length('Cal_source:'):end),'%s');
    end
    if ~isempty(strfind(lower(inline), lower('Source_Units:')))
        lamp_cal.source_units = sscanf(inline(strfind(lower(inline), lower('Source_Units:'))+...
            length('Source_Units:'):end),'%s');
    end
    if ~isempty(strfind(lower(inline), lower('Lamps:')))
        lamp_cal.lamps = sscanf(inline(strfind(lower(inline), lower('Lamps:'))+...
            length('Lamps:'):end),'%d');
    end
    if ~isempty(strfind(lower(inline),lower('Spectrometer_type:')))
        lamp_cal.spec_type = sscanf(inline(strfind(lower(inline),lower('Spectrometer_type:'))+...
            length('Spectrometer_type:'):end),'%s');
    end
    if ~isempty(strfind(lower(inline),lower('Spectrometer_SN:')))
        lamp_cal.spec_SN = sscanf(inline(strfind(lower(inline),lower('Spectrometer_SN:'))+...
            length('Spectrometer_SN:'):end),'%s');
    end
    if ~isempty(strfind(lower(inline), lower('Integration_time_ms:')))
        lamp_cal.t_int = sscanf(inline(strfind(lower(inline), lower('Integration_time_ms:'))+...
            length('Integration_time_ms:'):end),'%f');
    end    
    if ~isempty(strfind(lower(inline), lower('Resp_Units:')))
        lamp_cal.resp_units = sscanf(inline(strfind(lower(inline), lower('Resp_Units:'))+...
            length('Resp_Units:'):end),'%s');
    end    
    inline = fgetl(fid);
end
if strcmp(lamp_cal.spec_type,'si')
    lamp_cal.spec_type = 'Si';
else
    lamp_cal.spec_type = 'InGaAs';
end
labels = textscan(inline,'%s');
labels = labels{:};
C = textscan(fid,'%d %f %f %f %f %f %f %f \n');
fclose(fid);
for L = length(labels):-1:1
    lamp_cal.(labels{L}) = C{L};
end
%%
if ~isfield(lamp_cal,'spec_SN')||isempty(lamp_cal.spec_SN)
   lamp_cal.spec_SN = 'SN N/A';
end
figure; plot(lamp_cal.lambda_nm, lamp_cal.resp,'-k.');
xlabel('wavelenght [nm]');
ylabel(lamp_cal.resp_units,'interp','none');
title({[upper(lamp_cal.sas_unit),' ',lamp_cal.spec_type,' detector ', lamp_cal.spec_SN];...
    ['Lamps=',num2str(lamp_cal.lamps), sprintf(', t_ms = %g',lamp_cal.t_int), ' on ', datestr(lamp_cal.measurement_date, 'mmm dd yyyy')]},'interp','none');
%%
return
