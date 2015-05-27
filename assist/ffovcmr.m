


function [rad,wnp,deltaC1,deltaC2] = ffovcmr(...
  nu,Cm,fovHalfAngle,flagFFOVerr,XMAX,WNB)
%
% function [rad,deltaC1,deltaC2] = ffovcmr(...
%  nu,Cm,fovHalfAngle,XMAX,WNB,flagFFOVerr)
%
% PMR 27 July 2004
%
% Purpose: To perform the FFOV correction to the AERI measurement
% after performing the calibration, in the same way as the AERI
% software itself.  See Knuteson et al. AERIs for Arm paper.
%
% The equation for the correction, deltaC, is the first term only
% of eqn 12 in the Knuteson paper
%
% deltaC ~= (2pi b^2/4)^2 / 3!  IFFT{ x^2 FFT{nu^2 Cm} }
%         - (2pi b^2/4)^4 / 5!  IFFT{ x^4 FFT{nu^4 Cm} }
%
%
%
% Important Variables:
%
%   Input Variables:
%       nu is the frequency in wavenumbers,
%       Cm is an array of calibrated measured spectra
%       fovHalfAngle = b, the half-angle (2.3 mrad),
%       flagFFOVerr=0,1, or 2 for no error, first error, second error
%       XMAX and WNB needed only if error included
%
%   Output Variables:
%       rad: corrected radiances
%       deltaC1: 1st term in correction for FFOV: added to Cm
%       deltaC2: 2nd term in correction for FFOV: subtracted from Cm
%
%   Other Variables (see equation above)
%       Ascalar1 = (2pi b^2/4)^2 / 3!
%       Ascalar2 = (2pi b^2/4)^4 / 5!
%       ftterm1 = FFT{nu^2 Cm}
%       iftterm1 = IFFT{x^2 FFT{nu^2 Cm} } = IFFT{x^2 ftterm}
%       ftterm2 = FFT{nu^4 Cm}
%       iftterm2 = IFFT{x^4 FFT{nu^4 Cm} } = IFFT{x^4 ftterm}
%       x is the mirror position,
%
% Function Calls:
% ift.m and ft.m - perform fft and ifft, but take and return independent
%       variables x and nu in function call.  Also can be 1 or 2 sided
%


% Get dimensions
[len,wid]=size(Cm);
if len==wid
  error('I cannot tell the dimensions apart!');
end
if len==length(nu)
  Nspec=wid;
elseif wid==length(nu)
  Nspec=len;
  Cm=Cm';
  len=length(nu);
else
  error('No dimension or radiance array is length(wavenumber vector)!');
end

Nf = 2^14;
nueff = 15799.38477 ; % cm-1
dnu = nueff / 2 / Nf ;  % lasernu/2/2^14
nup = (1:Nf-1)*dnu;     % max(nup)=7899.21
numax = max(nup)/2 ; clear nup;

% nueff = 15799.38477; % cm-1
% nyquist frequency=nueff/2
% divide by 2 again because double-sided
% numax = nueff/2/2;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% The code ft.m assumes that the spectrum, if 1-sided
% starts from 0 wavenumbers, so we need to pad out to
% zero, and create a wavenumber vector that goes to zero
% Also, pad out to the 16384/2 points for 1-sided to keep
% resolution correct

dwn = nu(2)-nu(1) ;
wn  = nu(:)';

% continue wn out to max length
rhs = zeros(1,length(max(wn)+dwn:dwn:numax));
wn  = [wn max(wn)+dwn:dwn:numax];

% fill in zero to wn(1)
wnp=[0:dwn:wn(1) wn(2:length(wn))];

lhs = zeros(1,length(0:dwn:wn(1))-1);

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %



% note: wnp==wn, to test, uncomment next line
% plot(wnp-wnf)

% NOTES FROM FFOVCMR.f
%C ... DETERMINE POWER-OF-TWO FIELD SIZE FOR FFT'S ...
%      NYQNO=NPTSNU
%      NTOTL=2*(NYQNO-1)
%      IEXP=INT(0.9999+ALOG(FLOAT(NTOTL))/ALOG(2.))
%      NTOTL=2**IEXP
%      NYQNO=1+NTOTL/2
%      DX=1.0/(DFLOAT(NTOTL)*DWN)
%      XMAX = DX * DFLOAT(NYQNO-1)
%      WNLO=WNL-DFLOAT(NPIW)*DWN
%      WNHI=WNLO+DFLOAT(NYQNO-1)*DWN
%
%C ... 26AUG04, ADDED DEFINITION OF "WN" & "WNRATIO"
%      DO I=1,NYQNO
%         WN(I) = WNLO + DFLOAT(I-1)*DWN
%         WNRATIO(I) = WN(I)/WNB
%      ENDDO
%
%   Z = 0.5 * PI * WNB * XMAX * FFOV ** 2
%
%   RAD(NPIW+J)=ORGSPM(I)                   RADIANCE, WITH LIMITS ROLLED OFF
%
%   RAD(I)=RAD(I)*WNRATIO(I)**2             RAD = (WN/WNB)^2 RAD
%   CALL FTINV(ICH,IEXP,FACN,RAD,R)         R = IFFT(RAD)
%   R(I) = R(I) * (X/XMAX)**2               R = R * (X/XMAX)**2
%   CALL FTFWD(ICH,IEXP,NUSED,A,B,R,RAD)    RAD = FT(R)
%
%   so, rad = ft(R * (X/XMAX)**2 )
%           = ft(IFFT(RAD) * (X/XMAX)**2 )
%           = ft(IFFT((WN/WNB)^2 RAD) * (X/XMAX)**2 )
%
%   F1 = Z.^2 / 6
%   CS1(I)=F1*RAD(I)
%     = (0.5 PI WNB XMAX FFOV^2)^2/6 ft(IFFT((WN/WNB)^2 RAD) * (X/XMAX)^2 )
%     = (0.5 PI  FFOV^2)^2/6  ft(IFFT(WN^2 RAD) * X^2 )
%
%   FOR TERM TWO THEY HAVE
%   RAD(I)=RAD(I)*WNRATIO(I)**4
%
%   but instead of RAD they should have OBS!!!
%   RAD = FT( IFFT((WN/WNB)^2 RAD ) * (X/XMAX)**2 )
%   RAD = 1/(XMAX WNB)^2  FT(X^2 IFFT(WN^2 RAD))
%

dC1 = zeros(size(Cm));
dC2 = zeros(size(Cm));
deltaC1 = zeros(length(wnp),Nspec);
deltaC2 = zeros(length(wnp),Nspec);
for i = 1:Nspec


  % First term
  % [x,y]=ft(nu,S,sidesin,sidesout)
  Cmp            = [lhs Cm(:,i)' rhs];  
  [x,ftTerm1]    = ft(wnp,wnp.^2 .* Cmp,1,2);
  [wnf,iftTerm1] = ift(x, x.^2.*ftTerm1,2,1) ;
  Ascalar1       = (2*pi*fovHalfAngle(1)^2/4)^2 / (3*2) ;
  deltaC1(:,i)   = Ascalar1*iftTerm1 ;
  dC1(:,i)       = interp1(wnp,real(deltaC1(:,i)),nu)  ;
  
  
  if flagFFOVerr==1
    error('This option is not here yet');
  elseif flagFFOVerr==2
    % Second Term, with error
    rad_werr    =  1/(XMAX*WNB)^2 * iftTerm1 ;
    %           = ft(IFFT((WN/WNB)^2 RAD) * (X/XMAX)**2 )
    [x,ftTerm2] = ft(wnp,wnp.^4 .* rad_werr,1,2);
  else
    % Second Term
    [x,ftTerm2] = ft(wnp,wnp.^4 .* Cmp,1,2);
  end
  
    [wnf,iftTerm2] = ift(x, x.^4.*ftTerm2,2,1) ;
    Ascalar2       = (2*pi*fovHalfAngle(1)^2/4)^4 / (5*4*3*2) ;
    deltaC2(:,i)   = Ascalar2*iftTerm2 ;
    dC2(:,i)       = interp1(wnp,real(deltaC2(:,i)),nu) ;
  
  %   F2 = Z.^4 / 120
  %   CS2(I)=F2*RAD(I)    = Z'^4 (WNB XMAX).^4 / 120 * (WN/WNB)^4* RAD?
  %                       = Z'^4 (WNB 1/DWN*inu).^4 / 120 * (WN/WNB)^4*RAD?
  %
  %  RAD(I)=OBS(I)+CS1(I)-CS2(I)+CS3(I)
  %
  
end

rad = Cm+dC1-dC2 ;

%
% % First term
% % [x,y]=ft(nu,S,sidesin,sidesout)
% [x,ftTerm1] = ft(wnp,(wnp/wnb).^2 .* Cmp,1,2);
% [wnf,iftTerm1] = ift(x, (x/xmax).^2.*ftTerm1,2,1) ;
% Ascalar1 = (2*pi*fovHalfAngle^2/4)^2 / (3*2) ;
% deltaC1 = Ascalar1*iftTerm1*wnb^2*xmax^2 ;
% rad_werr =  1/(xmax*wnb)^2 * iftTerm1 ;
%
% % Second Term, with error
% [x,ftTerm2]    = ft(wnp,(wnp/wnb).^4 .* rad_werr,1,2);
% [wnf,iftTerm2] = ift(x, (x/xmax).^4.*ftTerm2,2,1) ;
% Ascalar2 = (2*pi*fovHalfAngle^2/4)^4 / (5*4*3*2) ;
% deltaC2_werr = Ascalar2*iftTerm2*wnb^4*xmax^4 ;
%
%
% % Second Term
% [x,ftTerm2]    = ft(wnp,(wnp/wnb).^4 .* Cmp,1,2);
% [wnf,iftTerm2] = ift(x,(x/xmax).^4.*ftTerm2,2,1) ;
% Ascalar2 = (2*pi*fovHalfAngle^2/4)^4 / (5*4*3*2) ;
% deltaC2 = Ascalar2*iftTerm2 *wnb^4*xmax^4 ;




% % % % % % % % % % % % % % % % % % % % % % %

% Extras for testing:


% inds = find(wnp>=1800 & wnp<=2200);
% meas = interp1(rawmeas(:,1),rawmeas(:,2),wnp(inds));
%
% % get new and old rms errors to compare
% sqrt(mean( (Cm(inds)'+deltaCf - meas).^2) )
% sqrt(mean( (Cm(inds)'- meas).^2) )
%
% % Look at plots to see what improvement is made
% plot(wnp(inds),Cm(inds)-meas','.',wnp(inds),Cm(inds)'+deltaC(inds)-meas)
% axis([1800 2200 -.06 .06])
% legend('orig.','ffov corr.')
%
% plot(wnp(inds),Cm(inds)'+ deltaC(inds)-meas)
% axis([1800 2200 -.025 .025])
% xlabel('wavenumber (cm^-^1)')
% ylabel('Difference from AERI software (RU)')





% % Get smallest paramB using interactive minimization
% inds=find(wnp>=1800 & wnp<=2200);
% meas = interp1(rawmeas(:,1),rawmeas(:,2),wnp(inds));
% fovHalfAngles = [0:.005:.025]; clear rmsvec;
% for k=1:length(fovHalfAngles)
% 	fovHalfAngle=fovHalfAngles(k);
% 	Ascalar = (2*pi*fovHalfAngle^2/4)^2 / 3 / 2 ;
%
% 	deltaC = Ascalar * iftTerm;
%
%     rmsvec(k) = sqrt(mean( (Cm(inds)'+ deltaC(inds) ...
%         - meas).^2) );
% end
% plot(paramBs,rmsvec,'.-')
% % % % % % % % % % % % % % % % %
% %error gets down to .00061 RU
% best fovHalfAngle = 0.02034173817144 ;
%
%
% plot(nu(inds),Ls(inds)-meas',nu(inds),Ls(inds)'+deltaCf-meas)
% axis([1800 2200 -.06 .06])
% legend('orig.','ffov corr.')
%
% plot(nu(inds),Ls(inds)'+deltaCf-meas)
% axis([1795 2200 -.008 .015])
% xlabel('wavenumber (cm^-^1)')
% ylabel('Difference from AERI software (RU)')
