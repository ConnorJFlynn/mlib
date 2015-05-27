%reads error in computed Caltech extionction
[filename,pathname]=uigetfile('d:\beat\data\ACE-2\Caltech\*errors.txt','Choose Caltech Error File', 0, 0);
fid=fopen([pathname filename]);
for ii=1:4
   fgetl(fid);
end   
data=fscanf(fid,'%g',[7,inf]);
fclose(fid);
Altitude_Caltech_errors=data(1,:)/1e3;
Caltech_err_plus=data([2 4 6],:);
Caltech_err_minus=data([3 5 7],:);
