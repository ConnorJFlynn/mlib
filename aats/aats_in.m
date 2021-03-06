function aats = aats_in(pathname);
[day,month,year,UT_Laptop,UT_Can,Airmass,Temperature,Latitude,Longitude,Press_Alt,Pressure,Heading,...
      Mean_volts,Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,filename,flight_no]=AATS14_Laptop99_239(pathname);
aats.time = datenum(year,month,day)+UT_Laptop./24;
aats.time_CAN = datenum(year,month,day)+UT_Can./24;
aats.Airmass = Airmass;
aats.Temperature = Temperature;
aats.Latitude = Latitude;
aats.Longitude = Longitude;
aats.Press_Alt = Press_Alt;
aats.Pressure = Pressure;
aats.Heading = Heading;
aats.Mean_volts = Mean_volts([8 1 2 4:7 9:12 3 14 13],:);
aats.Sd_volts = Sd_volts([8 1 2 4:7 9:12 3 14 13],:);
aats.Az_err = Az_err;
aats.Elev_err = Elev_err;
aats.Az_pos = Az_pos;
aats.Elev_pos = Elev_pos;
aats.Voltref = Voltref;
aats.ScanFreq = ScanFreq;
aats.AvePeriod = AvePeriod;
aats.RecInterval = RecInterval;
aats.site = site;
aats.filename = filename;
aats.flight_no =flight_no;
%     data=data; % Put channels in order of wavelength
%     Sd_volts=Sd_volts([8 1 2 4:7 9:12 3 14 13],:);