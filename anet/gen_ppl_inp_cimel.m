function inp = gen_ppl_inp_cimel
% inp = gen_ppl_inp_cimel
% This function populates a structure subsequently used by 
% "gen_aip_cimel_strings"  to create an input file for 
% the Aeronet aip retrieval
%  This is somewhat different than gen_ppl_inp_4STAR due
% to the sequential nature of the sky scans, 1 filter at a time
% yielding different SZA for each filter, etc. 

% first_line: 112   31   1  -1  0  0  1   0  1  : KM KN KL IT ISZ IMSC IMSC1
% READ (*,*) KM,KN,KL,IT,ISZ,IMSC,IMSC1,ISTOP,IEL 	!! Read line 1
% KN number of measurements

geom.WAVE = [0.4407 0.6764 0.8691 1.0194];
geom.WAVE_(1).albedo = [0.055904  0.022608   0.008479];
geom.WAVE_(2).albedo = [0.153587  0.079113   0.025403];
geom.WAVE_(3).albedo = [0.301020  0.189755   0.032080];
geom.WAVE_(4).albedo = [0.343706  0.216637   0.036624];
geom.WAVE_(1).UO3 = 0;
geom.WAVE_(2).UO3 = 0.0117;
geom.WAVE_(3).UO3 = 0;
geom.WAVE_(4).UO3 = 0;
geom.WAVE_(1).DU = 263.5;
geom.WAVE_(2).DU = 263.5;
geom.WAVE_(3).DU = 263.5;
geom.WAVE_(4).DU = 263.5;
geom.WAVE_(1).PWV = 1.5;
geom.WAVE_(2).PWV = 1.5;
geom.WAVE_(3).PWV = 1.5;
geom.WAVE_(4).PWV = 1.5;
geom.WAVE_(1).meas = [0.4928   0.7601   0.6899   0.5964   0.5379   0.4651   0.4166   0.3838   0.3578   0.3341   0.2899   0.2453   0.2080   0.1770   0.1502   0.1289   0.1119   0.0983   0.0880   0.0795   0.0732   0.0657   0.0633   0.0667   0.0748   0.0886   0.1087   0.1324]; 
geom.WAVE_(2).meas = [0.1753   0.8001   0.6832   0.5260   0.4321   0.3283   0.2616   0.2225   0.1949   0.1735   0.1431   0.1168   0.0960   0.0802   0.0658   0.0558   0.0473   0.0408   0.0358   0.0316   0.0282   0.0237   0.0217   0.0216   0.0237   0.0288   0.0388   0.0568]; 
geom.WAVE_(3).meas = [0.0933   0.7789   0.6534   0.4910   0.3898   0.2815   0.2094   0.1686   0.1411   0.1204   0.0943   0.0732   0.0585   0.0474   0.0387   0.0326   0.0279   0.0242   0.0211   0.0188   0.0171   0.0144   0.0135   0.0135   0.0151   0.0187   0.0258   0.0398]; 
geom.WAVE_(4).meas = [0.0649   0.7582   0.6343   0.4698   0.3719   0.2618   0.1883   0.1461   0.1183   0.0984   0.0738   0.0553   0.0425   0.0333   0.0271   0.0226   0.0191   0.0165   0.0145   0.0130   0.0120   0.0100   0.0094   0.0096   0.0105   0.0133   0.0182   0.0282]; 
geom.WAVE_(1).HLYR = 1.107;
geom.WAVE_(2).HLYR = 1.107;
geom.WAVE_(3).HLYR = 1.107;
geom.WAVE_(4).HLYR = 1.107;
geom.WAVE_(1).HLYR_(1).SZA = 68.40;
geom.WAVE_(2).HLYR_(1).SZA = 68.53;
geom.WAVE_(3).HLYR_(1).SZA = 68.67;
geom.WAVE_(4).HLYR_(1).SZA = 68.81;
geom.WAVE_(1).HLYR_(1).SZA_(1).OZA = [68.40 64.90 64.40 63.40 62.40 60.40 58.40 56.40 54.40 52.40 48.40 43.40 38.40 33.40 28.40 23.40 18.40 13.40  8.40  3.40  1.60 11.60 21.60 31.60 41.60 51.60 61.60 71.60];
geom.WAVE_(2).HLYR_(1).SZA_(1).OZA = [68.53   65.03   64.53   63.53    62.53   60.53   58.53   56.53   54.53   52.53   48.53   43.53    38.53   33.53   28.53   23.53   18.53   13.53    8.53    3.53     1.47   11.47   21.47   31.47   41.47   51.47   61.47   71.47];
geom.WAVE_(3).HLYR_(1).SZA_(1).OZA = [68.40 64.90 64.40 63.40 62.40 60.40 58.40 56.40 54.40 52.40 48.40 43.40 38.40 33.40 28.40 23.40 18.40 13.40  8.40  3.40  1.60 11.60 21.60 31.60 41.60 51.60 61.60 71.60];
geom.WAVE_(4).HLYR_(1).SZA_(1).OZA = [68.53   65.03   64.53   63.53    62.53   60.53   58.53   56.53   54.53   52.53   48.53   43.53    38.53   33.53   28.53   23.53   18.53   13.53    8.53    3.53     1.47   11.47   21.47   31.47   41.47   51.47   61.47   71.47];
% If ~isfield(geom.WAVE_(4).HLYR_(1).SZA_(1),'OZA_')
% nphi = 1; phi = geom.WAVE_(1).HLYR_(1).SZA_(1).PHI(noza_ii)
geom.WAVE_(1).HLYR_(1).SZA_(1).PHI = [0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    180  180  180  180  180  180  180  180];
geom.WAVE_(2).HLYR_(1).SZA_(1).PHI = [0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    180  180  180  180  180  180  180  180];
geom.WAVE_(3).HLYR_(1).SZA_(1).PHI = [0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    180  180  180  180  180  180  180  180];
geom.WAVE_(4).HLYR_(1).SZA_(1).PHI = [0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    180  180  180  180  180  180  180  180];



inp.KM = sum([numel(geom.WAVE_(1).meas),numel(geom.WAVE_(2).meas),numel(geom.WAVE_(3).meas),numel(geom.WAVE_(4).meas)]);
% KN retrieved parameters
inp.NW = length(geom.WAVE);
inp.NBIN = 22;
inp.KN = 2*inp.NW + inp.NBIN + 1 ; %= 31
% KL=0 - minimization of absolute errors
% KL=1 - minimization of log
inp.KL = 1;
% IT=0 - refractive index is assumed
% IT=-1 - refractive index is retrieved
inp.IT = -1;
% ISZ=0 initial guess for SD are read point by point
% ISZ=1 - SD is assumed lognormal with the parameters from FILE="SDguess.dat"
inp.ISZ = 0;
% IMSC =0 -multiple scattering regime for signal
% IMSC =1 -single scattering regime for signal
inp.IMSC = 0;
% IMSC1 =0 -multiple scattering regime for sim. matrix
% IMSC1 =1 -single scattering regime for sim. matrix
inp.IMSC1 = 1;
%Fill last two elements: no description in the code...
inp.ISTOP = 0;
inp.IEL=1;

% Second line: % 1 4 1 0 0 1 1 : NSD  NW  NLYR  NBRDF  NBRDF1
% READ (*,*) NSD,NW,NLYR,NBRDF,NBRDF1,NSHAPE,IEND !! Read line 2
% C*****************************************************
% NSD - number of the retrieved aerosol component at each atmospheric layer
inp.NSD = 1;

% C***  WAVE(IW) - values of wavelengths
% NW   - the number of wavelengths


% NLYR - the number of the athmosperic layers redundant with NLYRS NTAU
inp.NLYR = length(geom.WAVE_(1).HLYR); inp.NLYRS = inp.NLYR; inp.NTAU = inp.NLYR;

% NBRDF- the number of the BRDF paremeters for each wavelength
% NBRDF=0 when we use Lambertian approximation
inp.NBRDF = 0;
% C***  NBRDF1- the number of the BRDF paremeters independent of wavelenths
inp.NBRDF1 = 0;

% Fill last two, no description in code.
inp.NSHAPE=1;
inp.IEND=1;

% 1 1 1 1                        INDSK
inp.INDSK = [1 1 1 1];
% 0 0 0 0                        INDSAT
inp.INDSAT = [0 0 0 0];
% 1 1 1 1                        INDTAU
inp.INDTAU = [1 1 1 1];
% 1 1 1 1                        INDORDER
inp.INDORDER = [1 1 1 1];

% -1 22 22 0 -1  : IBIN, (NMIN(I),I=1,NSD)
%       READ (*,*) IBIN, (NBIN(I),I=1,NSD)  !! Read line 8
% C****************************************************
% C***  IBIN - index determining the binning of SD:
% C***         = -1 equal in logarithms
% C***         =  1 equal in absolute scale
% C***         =  0 read from the file
inp.IBIN = -1;
% C***  NBIN(NSD) - the number of the bins in
% C***                 the size distributions



% 0.05 15.0 0 (RMIN(ISD),RMAX(ISD),ISD=1,NSD)
% READ(*,*) (RMIN(ISD),RMAX(ISD),IS(ISD),ISD=1,NSD)	!! Read line 9

inp.RMIN = 0.05;
inp.RMAX = 15;
inp.ISD = 0;

%       READ (*,*) !! Skip line 10
%       READ (*,*) IM,NQ,IMTX,KI !! Read line 11
% C***  Parameters for ITERQ.f (details in "iterqP" subr.)
% C***  IM=1 - q-linear iterations
% C***  IM=2 - matrix inversion
% C***  NQ - key defining the prcedure for stopping
% C***  q-iterations
% C***  KI - defines the type of q-iterations (if IM=1)
% C***  EPSP - for stoping p-iterations
% C***  EPSQ and NQ see in "ITERQ"
% C***  IMTX
% C***  KI   - type of k-iterations
% 3  17000 0 0 : IM,NQ,IMTX, KI
inp.IM = 3;
inp.NQ = 17000;
inp.IMTX = 0;
inp.KI = 0;

% 15 0.0005 0.5 1.33 1.6 0.0005 0.5 IPSTOP, RSDMIN, RSDMAX,REALMIN,REALMAX,AIMAGMIN,AIMAGMAX
%       READ(*,*) IPSTOP, RSDMIN,RSDMAX,REALMIN,REALMAX, ! line 13
inp.IPSTOP = 15;
inp.RSDMIN = 0.0005;
inp.RSDMAX = 0.5;
inp.REALMIN = 1.33;
inp.REALMAX = 1.6;
inp.AIMAGMIN = 0.0005;
inp.AIMAGMAX = 0.5;

% 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000.
%       IF(NSHAPE.GT.0) THEN
%        READ(*,*) (SHAPEMIN(I),SHAPEMAX(I),I=1,NSHAPE) ! Read line 14
SHAPEMIN = 0.001; SHAPEMIN = repmat(SHAPEMIN,[19,1]);
inp.SHAPEMIN=SHAPEMIN;
SHAPEMAX = 1000; SHAPEMAX = repmat(SHAPEMAX,[19,1]);
inp.SHAPEMAX=SHAPEMAX;
%
% SMOOTHNESS parameters:
% 0 1e-4 0 0 0 0
% 3  1.0e-3 1 1.0e-1 1 1.0e-4 IO(...), GSM(...) (SD,Real, Imag) (for each layer !!!)
% 0 0
% 0 0.00e-0
% !! Not sure how to actually construct the information for the smoothing parameters
% !! in terms of the dimensionality and order of the values.
% !! So, just copying the values from the input files we have.
inp.SMOOTHNESS_parameter = 'copy these verbatim';

% 1.0e-3 1.0e-2 1.0e-3 5.0e-3 5.0e-0 1.0e-7 EPSP,EPST,EPSQ,DL,AREF,EPSD
% C****************************************************
%       READ (*,*) EPSP,EPST,EPSQ,DL,AREF,EPSD	!! Read line 20
% C*****************************************************
% C***  EPSP - for stopping p - iterations
% C***  EPST - for stopping iterations in CHANGE
% C***  EPSQ - for stopping q - iterations in ITERQ"
% C***  DL   - for calc. derivatives, (see FMATRIX)
% C*****************************************************
inp.EPSP = 1.0e-3;
inp.EPST = 1.0e-2;
inp.EPSQ = 1.0e-3;
inp.DL = 5.0e-3;
inp.AREF = 5.0e-0;
inp.EPSD = 1.0e-7;


% Real and Imag index of refraction
nreal = 1.5; nreal = repmat(nreal,[1,length(geom.WAVE)]);
inp.nreal=nreal;
nimag = 0.005; nimag = repmat(nimag,[1,length(geom.WAVE)]);
inp.nimag=nimag;

inp.sd_guess = (0.002791./5).*[1 repmat(5,[1,inp.NBIN-2]) 1];

% C***  Accounting for different accuracy levels in the data
% C***       AND   modelling   RANDOM NOISE           ***
%       READ (*,*) INOISE	!! Read line 51
%       READ (*,*) SGMS(1), INN(1), DNN(1) !! Read line 52

% C*******************************************************************
% C*** INOISE  - the number of different noise sources              ***
% C*** SGMS(I) - std of noise in i -th source                       ***
% C*** INN(I)  - EQ.1.THEN error is absolute with                   ***
% C***         - EQ.0 THEN error assumed relative
% C*** DNN(I)  - variation of the noise of the I-th source
% C*** IK(I)   - total number of measurements of i-th source        ***
% C*** KNOISE(1,K)-specific numbers affected by i-th source        ***
% C*** All the measurments which where not listed in  the INOISE-1 ***
% C***  first INOISE-1 sources, they belong to last source of noise***
% C*******************************************************************
inp.INOISE = 2;
% C*** SGMS(I) - std of noise in i -th source                       ***
inp.SGMS = 0;
% C*** INN(I)  - EQ.1.THEN error is absolute with                   ***
% C***         - EQ.0 THEN error assumed relative
inp.INN = 0;
% C*** DNN(I)  - variation of the noise of the I-th source
inp.DNN = 0.05;
if length(inp.SGMS)<inp.INOISE
    inp.SGMS = [inp.SGMS(1) zeros([1,inp.INOISE-1])];
    inp.INN = [inp.INN(1) ones([1,inp.INOISE-1])];
    inp.DNN = [inp.DNN(1) repmat(0.0055,[1,inp.INOISE-1])];
    inp.IK = [0 , repmat(4,[1,inp.INOISE-1])];
    % C*** IK(I)   - total number of measurements of i-th source        ***
end

inp.KNOISE = [1   29   57   85];

% C*** Defining matrix inverse to  covariance ***
% CD      WRITE(*,*) 'BEFORE IC,IACOV, DWW'
%       READ (*,*) IC,IACOV,DWW
% CD      WRITE(*,*) IC,IACOV,DWW,' IC,IACOV, DWW'
% C***    IC  =0 then
% C***           C is unit matrix (for logarithms)
% C***           C is diagonal matrix with the ellements
% C***                1/((F(j)*F(j)) (for non-logarithm case)
% C***    IC  =1 then C is diagonal and defined
% C*** with accounting for different levels of the errors in
% C*** different measurements (according to Dubovik and King [2000]
% C*** !!! the measurements assigned by INOISE=1 usually         !!!
% C*** !!! correspond to the largest set of optical measurements !!!
% C***    IC   <0 then C is read from cov.dat
% C**************************************************************
% C*** IACOV
% C***       =0 - single inversion with unique COV matrix
% C***       >0 - inversion is repeated with different COV matrix
% 1 0 0.01  IC, IACOV,DWW
inp.IC = 1;
inp.IACOV = 0;
inp.DWW = 0.01;

%7 1 1 4 1 1 1  0.00 : NSTR NLYR NLYRS NW IGEOM IDF IDN DPF   - Almucantar
inp.NSTR = 7;
% inp.NLYRS = NLYR;
inp.IGEOM = 1; 
inp.IDF = 1; 
inp.IDN = 1; 
inp.DPF = 0; 

inp.H_LYR = geom.WAVE_(1).HLYR;
inp.W_LYR = [1.0 2.0 1.0];
inp.NS = [1000];
inp.iatmos_1 = '6 0.0 3 0  1              : iatmos suhei';
inp.iatmos_2 = '1.33739    1.33739    1.33739    1.33739  ';
inp.iatmos_3 = '1.12E-09    1.12E-09    1.12E-09    1.12E-09 ';

inp.wind_speed = 5.733;
inp.land_fraction = 1;
if length(inp.H_LYR)==1
    inp.H_LYR = [inp.H_LYR, 70];
end
inp.Latitude =  -15.25361;

inp.whoknows = 7;
inp.mod_bdrf(1) = {[0.470000   0.039492    0.017680    0.006279]};
inp.mod_bdrf(2) = {[0.555000   0.078464    0.048401    0.012594]};
inp.mod_bdrf(3) = {[0.659000   0.070528    0.040370    0.011797]};
inp.mod_bdrf(4) = {[0.858000   0.286635    0.187311    0.024509]};
inp.mod_bdrf(5) = {[1.240000   0.289401    0.158122    0.019617]};
inp.mod_bdrf(6) = {[1.640000   0.179244    0.103298    0.019507]};
inp.mod_bdrf(7) = {[2.130000   0.104197    0.054131    0.017121]};
inp.date_time_site_unit = '02:08:2008,09:52:29,Almucantar,Singapore,22';

inp.geom = geom;
return
