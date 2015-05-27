% reads WRC Solar Irradiance Spectrum

load d:\beat\data\sun\Atlas85.asc

wvl=Atlas85(:,1);
irradiance=Atlas85(:,2);
plot(wvl,irradiance)
xlabel('Wavelength [nm]')
ylabel('Solar irradiance [W/m^2/nm]')
grid on
axis([-inf inf -inf inf])