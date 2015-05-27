% Reads RSS spectra
%DOY = 261.58611	AIRMASS = 2.77818
%Lambda		AOD
%512 wvl

pathname='c:\Beat\Data\Oklahoma\WVIOP2\RSS\version_990216\';
filelist=str2mat('rss103.970918.aod');
filelist=str2mat(filelist,...
    'rss103.970927.aod',...
    'rss103.970928.aod',...
    'rss103.970929.aod',...
    'rss103.970930.aod',...
    'rss103.971001.aod',...
    'rss103.971002.aod',...
    'rss103.971003.aod',...
    'rss103.971004.aod',...
    'rss103.971005.aod');

filename=filelist(ifile,:); 
fid=fopen(deblank([pathname filename]));
i=1;
while 1
    [DOY,count]=fscanf(fid, 'DOY = %f');
    if count==0, break, end
    DOY_RSS(i)=DOY;
    line=fgetl(fid);
    line=fgetl(fid);
    data=fscanf(fid,'%f',[2 512]);
    line=fgetl(fid);
    
    if i==1
        lambda_RSS=data(1,:)/1000;
    end;
    AOD_RSS(:,i)=data(2,:)';
    %semilogy(lambda_RSS,AOD_RSS)
    %xlabel('Wavelength [nm]')
    %ylabel('Optical Depth')
    %axis([-inf inf 0.01 0.2])
    %set(gca,'ytick',[0.010,0.020,0.030,0.04,0.05,0.06,0.07,0.08,0.09,0.1,0.2,0.3,0.40,0.5,...
    %      0.6,0.7,0.8,0.9,1,2]);
    %grid on
    %pause(0.01)
    i=i+1;
end
fclose(fid);
clear data;



