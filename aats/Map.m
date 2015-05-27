% Tenerife
fid=fopen('c:\beat\data\ace-2\map-points\tenerife');
fgetl(fid);
fgetl(fid);
xy=fscanf(fid,'%f',[2,inf]);
fclose(fid);
fill(xy(2,:),xy(1,:),'g')
text(-16.92,28.65,'Tenerife','FontSize',12)
hold on
%Izana
plot(-16.5, 28.3,'r*')
%Teide
plot(-16.6333, 28.2667,'r*')

% Gomera
fid=fopen('c:\beat\data\ace-2\map-points\gomera');
fgetl(fid);
fgetl(fid);
xy=fscanf(fid,'%f',[2,inf]);
fclose(fid);
fill(xy(2,:),xy(1,:),'g')

% El Hierro
fid=fopen('c:\beat\data\ace-2\map-points\hierro');
fgetl(fid);
fgetl(fid);
xy=fscanf(fid,'%f',[2,inf]);
fclose(fid);
fill(xy(2,:),xy(1,:),'g')

% La Palma
fid=fopen('c:\beat\data\ace-2\map-points\palma');
fgetl(fid);
fgetl(fid);
xy=fscanf(fid,'%f',[2,inf]);
fclose(fid);
fill(xy(2,:),xy(1,:),'g')

% Gran Canaria
fid=fopen('c:\beat\data\ace-2\map-points\GranCanaria');
fgetl(fid);
fgetl(fid);
xy=fscanf(fid,'%f',[2,inf]);
fclose(fid);
fill(xy(2,:),xy(1,:),'g')
text(-15.72,27.65,'Gran Canaria','FontSize',12)

