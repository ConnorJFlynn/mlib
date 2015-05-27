function [wvl450,wvl550,wvl700,response450,response550,response700]=read_TSI_filter();
pathname='c:\beat\data\strawa\';
filename='fwave.dat';
fid=fopen([pathname filename]);

for i=1:4
    fgetl(fid);
end
data=fscanf(fid,'%g',[2,10]);
wvl450=data(1,:)./1e3;
response450=data(2,:);
response450=response450/trapz(wvl450,response450); % normalize such that integral=1
% trapz(wvl450,response450)

for i=1:6
    fgetl(fid);
end
data=fscanf(fid,'%g',[2,15]);
wvl550=data(1,:)./1e3;
response550=data(2,:);
response550=response550/trapz(wvl550,response550); % normalize such that integral=1
% trapz(wvl550,response550)

for i=1:6
    fgetl(fid);
end
data=fscanf(fid,'%g',[2,15]);
wvl700=data(1,:)./1e3;
response700=data(2,:);
response700=response700/trapz(wvl700,response700); % normalize such that integral=1
% trapz(wvl700,response700)

figure(7)
plot(wvl450,response450,wvl550,response550,wvl700,response700)
fclose(fid);