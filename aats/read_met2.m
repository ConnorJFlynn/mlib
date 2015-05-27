% Reads meteo data  tf*.met2.txt files 

[met_filename,met_pathname]=uigetfile('d:\beat\data\ACE-2\Meteo\tf*.met2.txt','Choose Meteo File', 0, 0);
fid=fopen([met_pathname met_filename]);
for i=1:3
   fgetl(fid);
end

met_data=fscanf(fid,'%g',[5,inf]);
fclose(fid);

%remove double lines so X will be monotonic for interpolation
L=find(diff(met_data(1,:))~=0);
met_data=met_data(:,L);

Met_UT   = mod(met_data(1,:),86400)/60/60;
Met_press= met_data(2,:);
Met_temp = met_data(3,:);
Met_dewp_temp = met_data(4,:);
Met_RH = met_data(5,:);

clear met_data

i=find(UT<=max(Met_UT) & UT>=min(Met_UT));
Met_press= interp1(Met_UT,Met_press,UT(i));
Met_temp= interp1(Met_UT,Met_temp,UT(i));
Met_RH = interp1(Met_UT,Met_RH,UT(i));

    
