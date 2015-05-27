function [NO2_xsect]=NO2(lambda_SPM,response_SPM)

% Harder, Brault, Johnston and Mount  [JGR, 102, 3861-3880, 1997]
% "Temperature Dependent NO2 Cross Sections at High Spectral Resolution"
% NO2 cross section [10^-19 cm^2/molecule]
% Data Smoothed with a Gaussian FWHM = 0.1 nm
% Compiled by E.P.Shettle, NRL, Washington, DC


% Nvalues  1st Wave  d(wave) last Wave   Temp
%          [nm]     [nm]     [nm]       [K]
%  4093    345.2     0.05     549.8     293.8
load c:\beat\data\xsect\harder_294K.asc
NO2_294K=reshape(harder_294K',1,prod(size(harder_294K)));
clear harder_294K;
NO2_294K(4094:4100)=[];
wvl_294K=345.2:0.05:549.8;

xsect= INTERP1(wvl_294K,NO2_294K,lambda_SPM);
NO2_xsect(1) = trapz(lambda_SPM,xsect.*response_SPM)/trapz(lambda_SPM,response_SPM);


%Nvalues  1st Wave  d(wave) last Wave   Temp
%          [nm]     [nm]     [nm]       [K]
%  4093    345.2    0.05     549.8     238.6
load c:\beat\data\xsect\harder_238K.asc
NO2_238K=reshape(harder_238K',1,prod(size(harder_238K)));
clear harder_238K;
NO2_238K(4094:4100)=[];
wvl_238K=345.2:0.05:549.8;

xsect= INTERP1(wvl_238K,NO2_238K,lambda_SPM);
NO2_xsect(2) = trapz(lambda_SPM,xsect.*response_SPM)/trapz(lambda_SPM,response_SPM);


%Nvalues  1st Wave  d(wave) last Wave   Temp
%          [nm]     [nm]     [nm]       [K]
%  4093    345.2    0.05     549.8     230.2
load c:\beat\data\xsect\harder_230K.asc
NO2_230K=reshape(harder_230K',1,prod(size(harder_230K)));
clear harder_230K;
NO2_230K(4094:4100)=[];
wvl_230K=345.2:0.05:549.8;

xsect= INTERP1(wvl_230K,NO2_230K,lambda_SPM);
NO2_xsect(3) = trapz(lambda_SPM,xsect.*response_SPM)/trapz(lambda_SPM,response_SPM);


%Nvalues  1st Wave  d(wave) last Wave   Temp
%          [nm]     [nm]     [nm]       [K]
%  3193    390.2    0.05     549.8     217.0
load c:\beat\data\xsect\harder_217K.asc
NO2_217K=reshape(harder_217K',1,prod(size(harder_217K)));
clear harder_217K;
NO2_217K(3194:3200)=[];
wvl_217K=390.2:0.05:549.8;

xsect= INTERP1(wvl_217K,NO2_217K,lambda_SPM);
NO2_xsect(4) = trapz(lambda_SPM,xsect.*response_SPM)/trapz(lambda_SPM,response_SPM);

figure(4)
plot(wvl_294K,NO2_294K,...
     wvl_238K,NO2_238K,...
     wvl_230K,NO2_230K,...
     wvl_217K,NO2_217K     )
xlabel('Wavelength [nm]')
ylabel('NO2 cross section [10^-19 cm^2/molecule]')
grid on
axis([345 550 0 inf])
legend('294 K', '238 K', '230 K', '217 K')

NO2_xsect=NO2_xsect*2.686763 %molec/cm2 to atm-cm
return
