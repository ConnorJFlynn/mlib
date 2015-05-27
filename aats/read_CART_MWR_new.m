% Reads CART MWR data
pathname='d:\beat\data\Oklahoma\cart_mwr\version_971103\'
filelist=str2mat('mwrtipC1.9709');
filelist=str2mat(filelist,...
'sgpmwrlosC1.a1.9709.asc',...
'sgpmwrlosC1.a1.9710.asc');
filename=filelist(ifile,:); 
fid=fopen(deblank([pathname filename]));
data=fscanf(fid,'%f',[11 inf]);
DOY_CART_MWR=data(1,:);
IPWV_CART_MWR=data(4,:);
ILW_CART_MWR=data(5,:);
fclose(fid);

