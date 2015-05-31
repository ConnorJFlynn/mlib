function [hourly, minutely] = parse_raw_met(fid);
%[hourly, minutely] = parse_raw_met(fid);
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
[first_int] = fscanf(fid, '%d',1);
while ~isempty(first_int)
    restline = textscan(fid,'%[^\n]',1);
    restline = char(restline{1});
    commas = length(findstr(restline,','));
    if (first_int==149)&(commas==48)
        m = m+1;
        [year(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%d',1);
        restline = restline(nextindex:end);
        [doy(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%d',1);
        restline = restline(nextindex:end);
        [hhmm(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%d',1);
        restline = restline(nextindex:end);

        [press_mb(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [press_mb_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [press_mb_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [temp_C_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [temp_C_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [temp_C_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [rh_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [rh_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [rh_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [wspd_mps_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [wspd_mps_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [wspd_mps_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [wdir_deg_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [wdir_deg_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [wdir_deg_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [ORG_car_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [rainrate_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [rainrate_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [rainrate_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [psp_up_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [psp_up_std(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [psp_up_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [psp_up_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [pir_up_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [pir_up_std(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [pir_up_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [pir_up_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [pir_Dtemp_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [pir_Dtemp_std(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [pir_Dtemp_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [pir_Dtemp_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [pir_Ctemp_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [pir_Ctemp_std(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [pir_Ctemp_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [pir_Ctemp_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [irt_temp_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [irt_temp_std(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [irt_temp_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [irt_temp_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [temp2_C_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [temp2_C_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [temp2_C_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [rh2_avg(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [rh2_max(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [rh2_min(m),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        %    restline = restline(nextindex:end);
    elseif (first_int==198)&(commas==15)
        cur = ftell(fid);
        disp(num2str(eof-cur))

        h = h + 1;
        [h_year(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%d',1);
        restline = restline(nextindex:end);
        [h_doy(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%d',1);
        restline = restline(nextindex:end);
        [h_hhmm(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%d',1);
        restline = restline(nextindex:end);

        [h_press_mb(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [h_temp_C_max(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [h_temp_C_min(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [h_temp_C_avg(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [h_rh_avg(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [h_wspd_mps_S_WVT(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [h_wdir_deg_D1_WVT(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [h_wspd_mps_max(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);

        [h_rainrate_avg(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [h_psp_up_avg(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [h_pir_up_avg(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);
        restline = restline(nextindex:end);
        [h_irt_temp_avg(h),COUNT,ERRMSG,nextindex] = sscanf(restline,'%*c%f', 1);

    else
        disp('Skipping corrupt line...');
    end
    [first_int] = fscanf(fid, '%d',1);
end
hourly.time = datenum(h_year,1,1)+h_doy+ floor(h_hhmm/100)/24 + mod(h_hhmm,100)/(24*60);
hourly.press_mb = h_press_mb;
hourly.temp_C_max = h_temp_C_max;
hourly.temp_C_min = h_temp_C_min;
hourly.temp_C_avg = h_temp_C_avg;
hourly.rh_avg = h_rh_avg;
hourly.wspd_mps_S_WVT = h_wspd_mps_S_WVT;
hourly.wdir_deg_D1_WVT = h_wdir_deg_D1_WVT;
hourly.wspd_mps_max = h_wspd_mps_max;
hourly.rainrate_avg = h_rainrate_avg;;
hourly.psp_up_avg = h_psp_up_avg;
hourly.pir_up_avg = h_pir_up_avg;
hourly.irt_temp_avg =h_irt_temp_avg;

minutely.time = datenum(year,1,1)+ doy+ floor(hhmm/100)/24 + mod(hhmm,100)/(24*60);

minutely.press_mb_avg = press_mb;
minutely.press_mb_max = press_mb_max;
minutely.press_mb_min = press_mb_min;
minutely.temp_C_avg = temp_C_avg;
minutely.temp_C_max = temp_C_max;
minutely.temp_C_min = temp_C_min;
minutely.rh_avg = rh_avg;
minutely.rh_max =  rh_max;
minutely.rh_min = rh_min;
minutely.wspd_mps_avg = wspd_mps_avg;
minutely.wspd_mps_max = wspd_mps_max;
minutely.wspd_mps_min = wspd_mps_min;
minutely.wdir_deg_avg = wdir_deg_avg;
minutely.wdir_deg_max = wdir_deg_max;
minutely.wdir_deg_min = wdir_deg_min;
minutely.ORG_car_avg = ORG_car_avg;
minutely.rainrate_avg = rainrate_avg;
minutely.rainrate_max = rainrate_max;
minutely.rainrate_min = rainrate_min;
minutely.psp_up_avg = psp_up_avg;
minutely.psp_up_std = psp_up_std;
minutely.psp_up_max = psp_up_max;
minutely.psp_up_min = psp_up_min;
minutely.pir_up_avg = pir_up_avg;
minutely.pir_up_std = pir_up_std;
minutely.pir_up_max = pir_up_max;
minutely.pir_up_min = pir_up_min;
minutely.pir_Dtemp_avg = pir_Dtemp_avg;
minutely.pir_Dtemp_std = pir_Dtemp_std;
minutely.pir_Dtemp_max = pir_Dtemp_max;
minutely.pir_Dtemp_min = pir_Dtemp_min;

minutely.pir_Ctemp_avg = pir_Ctemp_avg;
minutely.pir_Ctemp_std = pir_Ctemp_std;
minutely.pir_Ctemp_max = pir_Ctemp_max;
minutely.pir_Ctemp_min = pir_Ctemp_min;

minutely.irt_temp_avg = irt_temp_avg;
minutely.irt_temp_std = irt_temp_std;
minutely.irt_temp_max = irt_temp_max;
minutely.irt_temp_min = irt_temp_min;

minutely.temp2_C_avg = temp2_C_avg;
minutely.temp2_C_max = temp2_C_max;
minutely.temp2_C_min = temp2_C_min;

minutely.rh2_avg = rh2_avg;
minutely.rh2_max = rh2_max;
minutely.rh2_min = rh2_min;

if nargin==0
    fclose(fid);
end
minutely = resort_met(minutely);
hourly = resort_met(hourly);