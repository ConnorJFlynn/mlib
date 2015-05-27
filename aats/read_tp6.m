%reads columnar amounts from MODTRAN 3.7 tape6 (minimized) output

fid2=fopen('d:\beat\mod3_7\results\column.txt','a');

fid=fopen('d:\beat\mod3_7\Tape6','r');
model=fgetl(fid)
for iline=2:37
 fgetl(fid);
end

for iangle=1:14
 height=fgetl(fid)
 fgetl(fid);
 angle=fgetl(fid)
 for iline=41:52
  fgetl(fid);
 end;
 header1=fgetl(fid);
 units1=fgetl(fid);
 fgetl(fid);
 data1=fscanf(fid,'%e',[7,1])
 fgetl(fid);
 fgetl(fid);
 header2=fgetl(fid);
 units2=fgetl(fid);
 fgetl(fid);
 data2=fscanf(fid,'%e',[8,1])
 fgetl(fid);
 fgetl(fid);
 header3=fgetl(fid);
 units3=fgetl(fid);
 fgetl(fid);
 data3=fscanf(fid,'%e',[6,1])
 fgetl(fid);
 fgetl(fid);
 header4=fgetl(fid);
 units4=fgetl(fid);
 fgetl(fid);
 data4=fscanf(fid,'%e',[5,1])
 fgetl(fid);
 fgetl(fid);
 header5=fgetl(fid);
 units5=fgetl(fid);
 fgetl(fid);
 data5=fscanf(fid,'%e',[7,1])
 fgetl(fid);
 fgetl(fid);
 header6=fgetl(fid);
 units6=fgetl(fid);
 fgetl(fid);
 data6=fscanf(fid,'%e',[6,1])
 fgetl(fid);
 for iline=87:103
  fgetl(fid);
 end;

 fprintf(fid2,'%s',height,angle);
 fprintf(fid2,'%12.4e',data1(7),data3([1:3]),data4([1 4 5]));
 fprintf(fid2,'\n');
end
fclose(fid);
fclose(fid2);
