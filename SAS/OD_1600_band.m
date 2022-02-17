% OD_1600_band

% % Gaussian
% [P,sigma] = gaussian_fwhm(w, mu, FWHM);
% Gaussian profile with unit height centered on mu with full-width half-max of FWHM
% Convert to unit area by dividing by (sigma(SS).*sqrt(2*pi))

CO2 = load('CO2.mat');
CH4 = load('CH4.mat');
H2O = load('H2O.mat');
He = load('He');

% So for pixels in He.wl that are within the OD wavelength limits compute a
% gaussian in OD.wl centered on the pixel in question from He.wl. 
% Convolve with each OD spectrum to yield the OD in He for that specie.

wl_ = He.wl>=min(CO2.nm) & He.wl<=max(CO2.nm);
wl_ii =find(wl_);
od.wl = He.wl(wl_);
for w = length(wl_ii):-1:1
    wl = He.wl(wl_ii(w));
    gaus = gaussian_fwhm(CO2.nm, wl, 6);
    area = trapz(CO2.nm, gaus);
    od.CO2(w) = trapz(CO2.nm, gaus.*CO2.block(:,2))./area;
    od.CH4(w) = trapz(CH4.nm, gaus.*CH4.block(:,2))./area;
    od.H2O_5cm(w) = trapz(CH4.nm, gaus.*H2O.block(:,2))./area;
end
figure; plot(He.wl(wl_),od.CO2,'-',He.wl(wl_),od.CH4,'-',He.wl(wl_),od.H2O_5cm,'-',...
   He.wl(wl_),od.CO2+od.CH4+od.H2O_5cm,'k-' ); legend('CO_2','CH_4','H_2O','all');

