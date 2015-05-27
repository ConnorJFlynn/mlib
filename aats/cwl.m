function [cwvl,FWHM]=cwl(lambda_SPM,response,incr);
%computes effective center wavelength from filter scan weighted by Solar Spectrum

%********* Reads Solar Spectrum***************
%fid=fopen('g:\beat\data\sun\atlas85.asc');
% data=fscanf(fid, '%g %g', [2,inf]);
% lambda_sun=data(1,:);
% sun       =data(2,:);
%fclose(fid);

%figure(7)
%plot(lambda_sun,sun)
%xlabel('Wavelength [nm]');
%ylabel('Irradiance [W/m^2/nm]');
%set(gca,'xlim',[250 2500])
%title('WRC Solar Irradiance Spectrum');


wl=[min(lambda_SPM):incr:max(lambda_SPM)];
response=INTERP1(lambda_SPM,response,wl);

%sun= INTERP1(lambda_sun,sun,lambda_SPM);
%response=sun'.*response;

response=response./max(response);

% compute median wavelength (50% of area under curve)
%x = trapz(wl,response);
%x2=0;
%i=2;
%while x2<=x/2,
%x2=trapz(wl(1:i),response(1:i));
%i=i+1;
%end
%cwvl=wl(i-1);


% compute center wavelength centered at FWHM
i=find(response>=.5);
FWHM=max(wl(i))-min(wl(i));
cwvl=(max(wl(i))+min(wl(i)))/2;
i=find(response>=.01);
FW100=max(wl(i))-min(wl(i));
return


