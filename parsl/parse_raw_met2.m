function [hourly, minutely] = parse_raw_met2(fid);
%[hourly, minutely] = parse_raw_met2(fid);
%some naming inconsistencies between parse_raw_met and parse_raw_met2
%While not EOF
%Scan in first integer
%If value is 148, then read in "148" record
%else if value is 198 then read in "198" record
%else, read to end of line
if nargin==0
    fid = getfile;
end
fseek(fid,0,1);
eof = ftell(fid);
fseek(fid, 0,-1);
m = 0;
h = 0;
in_file = char(fread(fid))';
mins = length(findstr(in_file, [13 10 49 52 57]));
hours = length(findstr(in_file, [13 10 49 57 56]));
minutely = alloc_minutely(mins);
hourly = alloc_hourly(hours);

while length(in_file>0)
    %[C, POSITION] = TEXTSCAN(...)
    [restline, nextline] = textscan(in_file,'%[^\n]',1);
    in_file = in_file(nextline:end);
    restline = char(restline{1});
    [first_int, count, errmsg, nextchar] = sscanf(restline, '%d',1);
    restline = restline(nextchar:end);
    commas = length(findstr(restline,','));
    if (first_int==149)&(commas==48)
        m = m+1;
        [minutely.year(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%d',1);
        restline = restline(nextindex:end);
        [minutely.doy(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%d',1);
        restline = restline(nextindex:end);
        [minutely.hhmm(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%d',1);
        restline = restline(nextindex:end);

        [minutely.press_mb(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.press_mb_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.press_mb_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [minutely.temp_C_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.temp_C_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.temp_C_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [minutely.rh_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.rh_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.rh_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [minutely.wspd_mps_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.wspd_mps_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.wspd_mps_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.wdir_deg_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.wdir_deg_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.wdir_deg_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [minutely.ORG_car_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.rainrate_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.rainrate_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.rainrate_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [minutely.psp_up_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.psp_up_std(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.psp_up_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.psp_up_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [minutely.pir_up_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.pir_up_std(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.pir_up_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.pir_up_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [minutely.pir_Dtemp_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.pir_Dtemp_std(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.pir_Dtemp_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.pir_Dtemp_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [minutely.pir_Ctemp_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.pir_Ctemp_std(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.pir_Ctemp_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.pir_Ctemp_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [minutely.irt_temp_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.irt_temp_std(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.irt_temp_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.irt_temp_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [minutely.temp2_C_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.temp2_C_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.temp2_C_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [minutely.rh2_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.rh2_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [minutely.rh2_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        %    restline = restline(nextindex:end);
    elseif (first_int==198)&(commas==15)
        
        disp(num2str(length(in_file)))

        h = h + 1;
        [hourly.year(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%d',1);
        restline = restline(nextindex:end);
        [hourly.doy(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%d',1);
        restline = restline(nextindex:end);
        [hourly.hhmm(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%d',1);
        restline = restline(nextindex:end);

        [hourly.press_mb(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [hourly.temp_C_max(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [hourly.temp_C_min(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [hourly.temp_C_avg(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [hourly.rh_avg(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [hourly.wspd_mps_S_WVT(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [hourly.wdir_deg_D1_WVT(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [hourly.wspd_mps_max(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [hourly.rainrate_avg(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [hourly.psp_up_avg(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [hourly.pir_up_avg(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [hourly.irt_temp_avg(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);

    else
        disp('Skipping corrupt line...');
    end
    %[first_int] = fscanf(fid, '%d',1);
end
hourly.time = datenum(h_year,1,1)+h_doy+ floor(h_hhmm/100)/24 + mod(h_hhmm,100)/(24*60);
minutely.time = datenum(year,1,1)+ doy+ floor(hhmm/100)/24 + mod(hhmm,100)/(24*60);


if nargin==0
    fclose(fid);
end
end

function h = alloc_hourly(hours)
doy = zeros([hours,1]);
h.year = doy;
h.doy = doy;
h.hhmm = doy;
h.time = doy;
h.press_mb = doy;
h.temp_C_max = doy;
h.temp_C_min = doy;
h.temp_C_avg = doy;
h.rh_avg = doy;
h.wspd_mps_S_WVT = doy;
h.wdir_deg_D1_WVT = doy;
h.wspd_mps_max = doy;
h.rainrate_avg = doy;
h.psp_up_avg = doy;
h.pir_up_avg = doy;
h.irt_temp_avg = doy;
end


function [minutely] = alloc_minutely(mins)
doy = zeros([mins,1]);
minutely.year = doy;
minutely.doy = doy;
minutely.hhmm = doy ;
minutely.time = doy;
minutely.press_mb_avg  = doy;
minutely.press_mb_max  = doy;
minutely.press_mb_min  = doy;
minutely.temp_C_avg = doy;
minutely.temp_C_max = doy;
minutely.temp_C_min = doy;
minutely.rh_avg =  doy;
minutely.rh_max = doy;
minutely.rh_min = doy;
minutely.wspd_mps_avg = doy;
minutely.wspd_mps_max = doy;
minutely.wspd_mps_min = doy;
minutely.wdir_deg_avg = doy;
minutely.wdir_deg_max =  doy;
minutely.wdir_deg_min =  doy;
minutely.ORG_car_avg = doy;
minutely.rainrate_avg = doy;
minutely.rainrate_max = doy;
minutely.rainrate_min = doy;
minutely.psp_up_avg =  doy;
minutely.psp_up_std = doy;
minutely.psp_up_max =  doy;
minutely.psp_up_min =  doy;
minutely.pir_up_avg =  doy;
minutely.pir_up_std =  doy;
minutely.pir_up_max =  doy;
minutely.pir_up_min =  doy;
minutely.pir_Dtemp_avg =  doy;
minutely.pir_Dtemp_std = doy;
minutely.pir_Dtemp_max = doy;
minutely.pir_Dtemp_min =doy;

minutely.pir_Ctemp_avg = doy;
minutely.pir_Ctemp_std =doy;
minutely.pir_Ctemp_max = doy;
minutely.pir_Ctemp_min = doy;

minutely.irt_temp_avg =  doy;
minutely.irt_temp_std = doy;
minutely.irt_temp_max =  doy;
minutely.irt_temp_min = doy;

minutely.temp2_C_avg =  doy;
minutely.temp2_C_max =  doy;
minutely.temp2_C_min =  doy;

minutely.rh2_avg = doy;
minutely.rh2_max = doy;
minutely.rh2_min = doy;

end

minutely = resort_met(minutely);
hourly = resort_met(hourly);