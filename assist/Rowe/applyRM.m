% $Id: applyRM.m,v 1.1 2012/10/06 19:59:41 dataman Exp $
function [rad,nubads,Tamb] = applyRM(nup,rf,rb,nu,Time,rad,ikeep,...
  nulo,nuhi,Nstands)
%
%
%function [rad,nubads,Tamb] = applyRM(nup,rf,rb,nu,Time,rad,ikeep,...
%  nulo,nuhi,Nstands)
%
% Purpose:
%     To identify and replace radiances at wavenumbers where calibration
%     is impossible because the signals from the calibration sources are
%     zero to within the noise.
%
%     This method is an alternative to the "ratio method" in the AERI
%     processing (in aericalv) as of 2009/09/23.  The ratio is that of
%     uncalibrated spectral differences (Cs-Cc)/(Ch-Cc) used in the
%     calibration equation.  Insensitive wavenumbers are at wavenumbers
%     where the value of the ratio falls outside limits based on the
%     input parameter RATFAC, typically 1.5, implying -1.5 and 1.5.
%
%     The new method is called the instrument response or r method.
%     Wavenumbers are identified where the instrument response is zero
%     to within the noise.  The noise is determined from the standard
%     deviation in r just outside the band.
%
%     The input parameters (eventually will go in the SIP files) are then
%
% Input parameters:
%     nup:     wavenumber corresponding to rf, rb
%     rf, rb:  forward and backward responsivities
%     nu:      wavenumber corresponding to rad
%     Time:    time corresponding to rad
%     rad:     radiance
%     ikeep:   indices to spectra to keep
%     nulo:    low  wavenumber range to get the noise in r, for channel 1
%     nuhi:    high wavenumber range to get the noise in r, for channel 1
%     Nstands: Number of standard deviations to use (default=3)
%
% Channel 1 only!
%
% by Penny M. Rowe
% 23 Sept. 2009
%



% Get the brightness temperature near center of CO2 band
inu  = find(nu>=672 & nu<=682) ;
Tams = NaN*ones(size(Time));
Tamb = NaN*ones(size(Time));
for k=1:length(Time)
  Tams(k)  = mean(brightnessT(nu(inu),rad(inu,k))) ;
end


% Only keep Tamb for spectra that weren't QC'd out.
Tamb(ikeep) = Tams(ikeep);
if size(Tamb,1)==1
  Tamb = Tamb' ;     % row vector
end

% Get an estimate of the noise using the out-of-band region
ilo=find(nup>=nulo(1) & nup<=nulo(2));
ihi=find(nup>=nuhi(1) & nup<=nuhi(2));


% always exclude the points around the very center of the CO2 band
iex = find(nu>=667 & nu<=669);  % Changed upper limit from 668 to 669 
                                % PMR 6 Jan. 2012

% Get uncertainty estimates at high and low ends of instrument response
siglo = std(  ( rf(ilo,:) + rb(ilo,:) )/2 );
sighi = std(  ( rf(ihi,:) + rb(ihi,:) )/2 );
nubads = NaN*ones(size(rad)); maxlen=0;
for iskyf = ikeep(:)'
  
  % ... Get the standard deviation as a linear function based on
  %     the means at the low and high nus (i.e. on either side of r)
  sigma = interp1([mean(nup(ilo)) mean(nup(ihi))],...
    [siglo(iskyf) sighi(iskyf)],nu);
  
  % ... Interpolated the instrument response onto the final grid,
  %     (assuming nu has same, but fewer wavenumbers than nup)
  rf_nu = interp1(nup,rf(:,iskyf),nu);
  rb_nu = interp1(nup,rb(:,iskyf),nu);
  
  % ... Find instrument response (r) values that are < 3 sigma
  ibadsf = find( rf_nu <Nstands*sigma);     % forward mirror scan
  ibadsb = find( rb_nu <Nstands*sigma);     % backward mirror scan
  ibads  = union(ibadsf,ibadsb);   % combined
  ibads  = union(ibads,iex);       % also including co2 band center
  
  nubads(1:length(ibads),iskyf) = nu(ibads);
  maxlen = max(length(ibads),maxlen) ;
  
  % ... Replace the selected wavenumbers with Rad(BT), where BT is the
  %     brightness temperature from 672-682 wavenumbers, Planck(Tamb).
  R_BTamb   = 1e3*plancknu(nu(ibads),Tamb(iskyf));
  rad(ibads,iskyf) = R_BTamb ;
  
end

% Chop nubads down to maximum necessary length to get all
nubads = nubads(1:maxlen,:);
nubads = nubads';            % flip dimensions so files are easier to read




