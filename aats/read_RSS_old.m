% Reads RSS Channel data
pathname='d:\Beat\Data\Oklahoma\RSS\';
filelist=str2mat('aod380nm.970927');
filelist=str2mat(filelist,...
'aod380nm.970929',...
'aod380nm.971001',...
'aod451nm.970927',...
'aod451nm.970929',...
'aod451nm.971001',...
'aod525nm.970927',...
'aod525nm.970929',...
'aod525nm.971001',...
'aod864nm.970927',...
'aod864nm.970929',...
'aod864nm.971001');
filename=filelist(ifile,:); 
fid=fopen(deblank([pathname filename]));
data=fscanf(fid,'%f',[3 inf]);
DOY_RSS=data(1,:);
UT_RSS=data(2,:);
AOD_RSS=data(3,:);
fclose(fid);
lambda_RSS=[380,451,525,864]/1e3;



