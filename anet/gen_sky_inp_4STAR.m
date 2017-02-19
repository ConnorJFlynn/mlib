function [inp,line_num] = gen_sky_inp_4STAR(star)
% inp = gen_sky_inp_4STAR
% % This function populates a structure subsequently used by
% "gen_aip_cimel_strings"  to create an input file for
% the Aeronet aip retrieval
% Patterned directly on gen_ppl_inp_cimel
% first_line: 112   31   1  -1  0  0  1   0  1  : KM KN KL IT ISZ IMSC IMSC1
% READ (*,*) KM,KN,KL,IT,ISZ,IMSC,IMSC1,ISTOP,IEL 	!! Read line 1
% KN number of measurements
% geom.WAVE = [0.4407 0.6764 0.8691 1.0194];
if ~isfield(star,'rad_scale')
    star.rad_scale = 1;
end
if isfield(star,'rad')
    sat_rad = star.rad_scale .* star.rad;
elseif isfield(star,'skyrad')
    sat_rad = star.rad_scale .* star.skyrad;
end
inp.rad_scale = star.rad_scale;
% Here is where we attempt to screen out pixels or times when saturation
% was encountered.  We may need to consider accepted non-saturated pixels
% perhaps when relatively few other pixels were saturated. 
sat_rad(star.sat_time,star.sat_ij) = NaN;
% sat_rad(star.sat_ij) = NaN;
sat_rad = sat_rad(:,star.wl_ii);
skymask = star.skymask;

sat_rad = sat_rad.*skymask;
good_sky = star.good_sky&~isnan(sat_rad);

% if isfield(star,'good_ppl')
%     good_sky = star.good_ppl;
% elseif isfield(star,'good_alm')
%     good_sky = star.good_alm;
% else
%     !Not PPL or ALM?
%     return
% end
% star.vis_pix = star.vis_pix(2:end-1); % Why are we keeping only the center selected pixels?
% good_sky(star.SA<5.5,:) = false; % = good_sky & star.SA>=5.5;

% good_sky(good_ii(2:2:end)) = false; % Why are we throwing half of these away?
% good_sky(star.SA==max(star.SA(good_sky))) = false;
% good_sky(star.SA==max(star.SA(good_sky))) = false;
% Compute "normalized" radiances as pi*sky_rad/ESR
% Also, need to check how we're restricting good_sky as a function of wavelength. 
% sat_rad = sat_rad(:,star.wl_ii);
% sat_rad = sat_rad.*skymask;
% radiance units: [cts/ms / W/(m^2.sr.um)]

% Actually we should not be using Gueymard here.
% We should be using the one Michal has used.  Thulier?
guey_ESR = gueymard_ESR;
% for iw = 1:length(star.w(star.aeronetcols(star.vis_pix)))
for iw = length(star.wl_ii):-1:1    
%     guey_ESR = gueymard_ESR; % nm, W/(m2 nm)
    g_ESR(iw) = interp1(guey_ESR(:,1), 1000.*guey_ESR(:,3), 1000.*star.w(star.wl_ii(iw)),'pchip','extrap');
end
%%
% figure; plot(1000.*star.w(star.aeronetcols(star.vis_pix)), g_ESR, 'o',guey_ESR(:,1), 1000.*guey_ESR(:,3),'-')
%%

sat_rad = pi.*sat_rad ./(repmat(g_ESR,size(sat_rad,1),1)); inp.ESR = g_ESR;

geom.WAVE = star.w(star.wl_ii);
if length(star.wl_ii)~=length(star.tau)
    tods = star.tau(star.wl_ii);
    aods = star.tau_aero(star.wl_ii);
    tau_O3 = star.tau_O3(star.wl_ii);
else
    tods = star.tau;
    aods = star.tau_aero;
    tau_O3 = star.tau_O3;
end    

inp.aods = aods;
if ~isfield(star,'brdf')
   if isfield(star,'sfc_alb')
      flight_alb = interp1(star.w, star.sfc_alb, [0.470,0.555,0.659,0.858,1.24, 1.64, 2.13]', 'nearest','extrap');
   else
      [flight_alb, out_time] = get_ssfr_flight_albedo(mean(star.t(good_sky(:,1))),[0.470,0.555,0.659,0.858,1.24, 1.64, 2.13]');
   end
   
   star.brdf =[...
      [0.470,0.555,0.659,0.858,1.24, 1.64, 2.13]', flight_alb, zeros(size(flight_alb)), zeros(size(flight_alb))];
end
%         0.470000   0.067233    0.027191    0.010199
%         0.555000   0.108960    0.060560    0.017044
%         0.659000   0.141415    0.072841    0.023388
%         0.858000   0.297822    0.187741    0.031740
%         1.240000   0.388852    0.209102    0.030470
%         1.640000   0.365508    0.195612    0.039094
%         2.130000   0.278381    0.129836    0.046197];

geom.HLYR = [star.ground_level, 70];

%Now convert 4STAR Az/El geometry (that permits El from horizon to horizon)
%to AERONET geometry with El from 0 to 90 and Az adjusted by 180 when El is
%on oppposite side of zenith from sun.
over_top = star.El_gnd>90;
star.El_gnd(over_top) = 180-star.El_gnd(over_top);
star.Az_gnd(over_top) = mod(star.Az_gnd(over_top)+180,360);

for w= length(geom.WAVE):-1:1
    geom.WAVE_(w).SA = [];
    in_meas = [tods(w)];
    geom.WAVE_(w).albedo = fill_albedo(geom.WAVE(w),star.brdf);
%     geom.WAVE_(w).UO3 = interp1(star.w, star.cross_sections.o3, geom.WAVE(w),'pchip','extrap');
%     wi = interp1(star.w,[1:length(star.w)],geom.WAVE(w),'nearest');
    geom.WAVE_(w).UO3 = tau_O3(w); %Not crosss section, ozone OD s.O3col
    geom.WAVE_(w).DU = star.O3col*1000;
    if ~isfield(star,'PWV')
            !We_need_PWV...
        geom.WAVE_(w).PWV = 1.5;
    else
        geom.WAVE_(w).PWV = star.PWV;
    end
    % Now we're gettting there!
    % We could screen the values for this wavelength here...
%     geom.WAVE_(w).meas = [aods(w), sat_rad(:,w)'./1000];
    layer_alt = (unique(round(0.04.*(star.Alt(good_sky(:,w))-mean(star.Alt(good_sky(:,w)))))./0.04) ...
        + round(0.04.*mean(star.Alt(good_sky(:,w))))./0.04)./1000; % 25 meter resolution.
    % According to Sasha Sinyuk, hlyr should be ground level.  So setting
    % it to the aircraft altitude here may be wrong.
    % Sasha says: lyr basically specify the boundaries of atmospheric layer, so yes it is ground or sea level.
    % inp.geom.WAVE_(IW).HLYR(ITAU)
    geom.WAVE_(w).HLYR =  layer_alt; % convert to km.
    layer_alts = ((round(0.04.*(star.Alt(good_sky(:,w))-mean(star.Alt(good_sky(:,w)))))./0.04) ...
        + round(0.04.*mean(star.Alt(good_sky(:,w))))./0.04)/1000;
    % By stepping through length of layer_alt, with test against layer_alts we
    % can support multiple independent layers for each WL
    % for ly = 1:length(layer_alt)
    for ly = 1: length(layer_alt);
        good_lyr = good_sky(:,w);
        good_lyr(good_lyr) = layer_alts==layer_alts(ly);
        res = 0.1; des = 1./res;
        sunel = unique(round(des.*(star.sunel(good_lyr)-mean(star.sunel(good_lyr))))./des)...
            + round(des.*mean(star.sunel(good_lyr)))./des; % 0.2 degree resolution
        sunel = round(mean(des.*(star.sunel(good_lyr))))./des;
        sunza = 90-sunel;
        sunels =(round(des.*(star.sunel(good_lyr)-mean(star.sunel(good_lyr))))./des)...
            + round(des.*mean(star.sunel(good_lyr)))./des;
        sunels = sunel;
        sunzas = 90-sunels;
        geom.WAVE_(w).HLYR_(ly).SZA = sunza;
            % Hypothetically, we can accept any arbitrary combination of
            % OZA and OAZ, with PPL: OZA(NOZA) and OAZ(1), ALM: OAZ(NOAZ)
            % and OZA(1) and anything in between, but our PPL and ALM
            % example files only show the pairing noted above, and there
            % may be details/inconsistencies with how meas and sza are
            % handled, so for now we'll support only these two cases.
            % So in essense, we require NOZA==1 (ALM) or NOAZ==1 (PPL).
            in_OZA = sunzas(1);
            in_PHI = 0;            

        for sz = 1: length(sunza)
            good_sza = good_lyr;
            good_sza(good_sza) = (sunzas ==sunzas(sz));
            
%             OZAs = [90-star.El_true(good_sza)']';
            %%
            res = 0.1; des = 1./res;
%             OEL = unique(round(des.*(star.El_true(good_sza)-mean(star.El_true(good_sza))))./des)...
%                 + round(des.*mean(star.El_true(good_sza)))./des; % 0.2 degree resolution
            OEL = unique(round(des.*(star.El_gnd(good_sza)-mean(star.El_gnd(good_sza))))./des)...
                + round(des.*mean(star.El_gnd(good_sza)))./des; % 0.2 degree resolution
            OZA = 90-OEL;
%             OELs = (round(des.*(star.El_true(good_sza)-mean(star.El_true(good_sza))))./des)...
%             + round(des.*mean(star.El_true(good_sza)))./des; % 0.2 degree resolution
            OELs = (round(des.*(star.El_gnd(good_sza)-mean(star.El_gnd(good_sza))))./des)...
            + round(des.*mean(star.El_gnd(good_sza)))./des; % 0.2 degree resolution            
            OZAs = 90-OELs;
            res = 0.1; des = 1./res;
%             daz = abs(star.sunaz(good_sza) - star.Az_true(good_sza));
            daz = abs(star.sunaz(good_sza) - star.Az_gnd(good_sza));

            phis = (round(des.*daz)./des);
            geom.WAVE_(w).HLYR_(ly).SZA_(sz).OZA = [in_OZA;OZAs]; in_OZA = [];
%             geom.WAVE_(IW).HLYR_(ITAU).SZA_(ISZA).OZA
            geom.WAVE_(w).HLYR_(ly).SZA_(sz).PHI = [in_PHI; phis]; in_PHI = [];
            in_meas = [in_meas; sat_rad(good_lyr,w)]; 
            geom.WAVE_(w).meas = [in_meas]; 
            in_meas = [];
            % [cts/ms / W/(m^2.sr.um)]
            %%
%             for oz = 1:length(OZAs)
%                 good_ozs = good_sza;
%                 good_ozs(good_sza) = OZAs==OZAs(oz);
%                 obs_za = OZAs(good_ozs(good_sza));
%                 phi = phis(good_ozs(good_sza));
% %                 geom.WAVE_(w).HLYR_(ly).SZA_(sz).PHI = [0 phis'];
%                 
% 
%             end
            %%
%             try
%            geom.WAVE_(w).SA = [geom.WAVE_(w).SA; scat_ang_degs(sunzas, star.sunaz(good_sza),  geom.WAVE_(w).HLYR_(ly).SZA_(sz).OZA(2:end),star.Az_gnd(good_sza))];
%             catch
%                 disp('mismatch in fields sent to scat_ang_degs')
%             end
        end
    end
%     try
%     figure(48); semilogy(geom.WAVE_(w).SA, geom.WAVE_(w).meas(2:end),'o', star.SA(good_sky(:,w)),pi.*star.skyrad(good_sky(:,w),star.wl_ii(w))./inp.ESR(w),'x'); legend('star','inp.meas');
% title(['normalized radiance: ', sprintf('%4.1f nm',1000.*geom.WAVE(w))]);
%     catch
%         disp('Skipping SA plot due to error in scat_ang mismatch')
%     end
end

inp.KM=0;
% inp.KNOISE = [1   29   57   85];
for wi = length(geom.WAVE):-1:1
    inp.KM =inp.KM + numel(geom.WAVE_(wi).meas);
end
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
inp.NLYR = length(geom.WAVE_(1).HLYR); inp.NLYRS = inp.NLYR+19*star.isPPL; inp.NTAU = inp.NLYR;

% NBRDF- the number of the BRDF paremeters for each wavelength
% NBRDF=0 when we use Lambertian approximation
inp.NBRDF = 0;
% C***  NBRDF1- the number of the BRDF paremeters independent of wavelenths
inp.NBRDF1 = 0;

% Fill last two, no description in code.
inp.NSHAPE=1;
inp.IEND=1;

% 1 1 1 1                        INDSK
inp.INDSK = ones(size(geom.WAVE));
% 0 0 0 0                        INDSAT
inp.INDSAT = 0.*inp.INDSK;
% 1 1 1 1                        INDTAU
inp.INDTAU = inp.INDSK;
% 1 1 1 1                        INDORDER
inp.INDORDER = inp.INDSK;

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
% Maybe need help on the below...
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
    inp.IK = [0 , repmat(inp.NW,[1,inp.INOISE-1])];
    % C*** IK(I)   - total number of measurements of i-th source        ***
end

%  inp.KNOISE = [1   29   57   85]; Maybe need help here...
 ikn = 1;
 for iw = 1:inp.NW
     inp.KNOISE(iw) = ikn;
     ikn = ikn + length(geom.WAVE_(iw).meas);
 end

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

inp.H_LYR = [star.ground_level, 70]; % geom.WAVE_(1).HLYR; % This is wrong.    
% inp.H_NLYR = [.1 5]; %Hard coding a low layer and a high layer - higher than 4STAR altitude.
inp.H_NLYR = [star.ground_level 4+star.ground_level]; %Hard coding a low layer and a high layer - higher than 4STAR altitude.
inp.W_NLYR = [1.0 1.0];
inp.NS = [1000];
inp.iatmos_1 = '6 0.0 3 0  1              : iatmos suhei';
inp.iatmos_2 = '1.33739    1.33739    1.33739    1.33739  ';
inp.iatmos_3 = '1.12E-09    1.12E-09    1.12E-09    1.12E-09 ';
inp.iatmos_2 = repmat('1.33739    ',[1,length(geom.WAVE)]);
inp.iatmos_3 = repmat('1.12E-09   ',[1,length(geom.WAVE)]);
! Need_windspeed_and_land_fraction
if isfield(star,'wind_speed')
    inp.wind_speed = mean(star.wind_speed);
else
   inp.wind_speed = 5.733;  %Need to improve this for airborne
end
if isfield(star,'land_fraction')
    inp.land_fraction = mean(star.land_fraction);
else
   inp.land_fraction = 1;  %Need to improve this for airborne
end
if length(inp.H_LYR)==1
    inp.H_LYR = [inp.H_LYR, 70];
end
inp.Latitude = mean(star.Lat(good_sky(:,1)));

%     if ~isfield(star,'brdf')
%        geom.WAVE_(w).albedo = fill_albedo(geom.WAVE(w));
%     else
%        geom.WAVE_(w).albedo = fill_albedo(geom.WAVE(w),star.brdf);
%     end

modis_wave = [0.47 0.555 0.659 0.858  1.24 1.64 2.13];
inp.whoknows = length(modis_wave);
for m = 1:length(modis_wave)
    alb = fill_albedo(modis_wave(m),star.brdf);
    inp.mod_brdf(m) = {[modis_wave(m)   alb]};
end
if star.isPPL
    sky_str = 'Principal_Plane';
else
    sky_str = 'Almucantar';
end
inp.date_time_site_unit = [datestr(mean(star.t),'dd:mm:yyyy,HH:MM:SS,'),sky_str,',4STAR,01'];
inp.geom = geom;

line_num = gen_aip_cimel_strings(inp);
%   [~,fstem,ext] = fileparts(star.filename{1});
% fstem = strrep(fstem, '_VIS','');
% % from run_4STAR_AERONET_retrieval
% pname = 'C:\z_4STAR\work_2aaa__\';
% fname = ['4STAR_.input'];

% fid = fopen([pname_tagged,fname_tagged],'w');
fid = fopen([star.pname_tagged,star.fname_tagged],'w');
for lin = 1:length(line_num)
    fprintf(fid,'%s \n',line_num{lin});
end
fclose(fid);

return
