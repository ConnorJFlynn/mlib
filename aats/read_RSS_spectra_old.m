%filename='aod_spectra_noon.970927' %270.775-270.800
filename='aod_spectra_noon.970929' %272.775-272.800
%filename='aod_spectra_noon.971001'  %274.750-274.800
pathname='d:\Beat\Data\Oklahoma\RSS\';
fid=fopen(deblank([pathname filename]));
fgetl(fid);
data=fscanf(fid,'%f',[2 inf]);
fclose(fid);
lambda_RSS_spectra=data(1,:);
AOD_RSS_spectra=data(2,:);
semilogy(lambda_RSS_spectra,AOD_RSS_spectra)
xlabel('Wavelength [nm]')
ylabel('Optical Depth')
axis([-inf inf 0.01 0.2])
set(gca,'ytick',[0.010,0.020,0.030,0.04,0.05,0.06,0.07,0.08,0.09,0.1,0.2,0.3,0.40,0.5,...
      0.6,0.7,0.8,0.9,1,2]);

grid on