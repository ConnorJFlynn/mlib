function line_num = gen_aip_cimel_strings(inp)
% I think this properly distinguishes ground-level (hlyr) from
% flight-level (houtput) and H(NLYR) and W(NLYR).  
% Adding input data level as ASCII tag to first line 'anet_level"

% first_line: 94   31   1  -1  0  0  1   0  1  : KM KN KL IT ISZ IMSC IMSC1
ln = 1; % Initialize line number to 1
[KM, KN, KL, IT, ISZ, IMSC, IMSC1, ISTOP, IEL] = ...
    deal(inp.KM, inp.KN, inp.KL,inp.IT, inp.ISZ, inp.IMSC, inp.IMSC1, inp.ISTOP, inp.IEL);
lev = inp.anet_level;
line_num(ln) = {sprintf('%-4d %-4d %-4d %-4d %-4d %-4d %-4d %-4d %-4d  : KM KN KL IT ISZ IMSC IMSC1 ISTOP IEL; ANET inp level: %1.1f', ...
    KM, KN, KL, IT, ISZ, IMSC, IMSC1, ISTOP, IEL, lev)};
ln = ln +1;
% Second line: % 1 4 1 0 0 1 1 : NSD  NW  NLYR  NBRDF  NBRDF1
% READ (*,*) NSD,NW,NLYR,NBRDF,NBRDF1,NSHAPE,IEND !! Read line 2
[NSD,NW,NLYR,NBRDF,NBRDF1,NSHAPE,IEND] = ...
    deal(inp.NSD, inp.NW, inp.NLYR, inp.NBRDF, inp.NBRDF1, inp.NSHAPE, inp.IEND);
line_num(ln) = {sprintf('%-3d %-3d %-3d %-3d %-3d %-3d %-3d : NSD,NW,NLYR,NBRDF,NBRDF1,NSHAPE,IEND', ...
 NSD,NW,NLYR,NBRDF,NBRDF1,NSHAPE,IEND)};
ln = ln + 1;
WAV = inp.geom.WAVE;
% Third line: 0.4407 0.6743 0.8711 1.0204 WAVE(NW)
line_num(ln) = {[sprintf('%-2.4f ', WAV),' WAVE(NW)']};
ln = ln + 1;
% 1 1 1 1                        INDSK
line_num(ln) = {[sprintf('%-d ', inp.INDSK),'             INDSK']};
ln = ln + 1;
% 0 0 0 0                        INDSAT
line_num(ln) = {[sprintf('%-d ', inp.INDSAT),'             INDSAT']};
ln = ln + 1;
% 1 1 1 1                        INDTAU
line_num(ln) = {[sprintf('%-d ', inp.INDTAU),'             INDTAU']};
ln = ln + 1;
% 1 1 1 1                        INDORDER
line_num(ln) = {[sprintf('%-d ', inp.INDORDER),'             INDORDER']};
ln = ln + 1;

% -1 22 22 0 -1  : IBIN, (NMIN(I),I=1,NSD)
%       READ (*,*) IBIN, (NBIN(I),I=1,NSD)  !! Read line 8
% C****************************************************
% C***  NBIN(NSD) - the number of the bins in 
% C***                 the size distributions
% C***  IBIN - index determining the binning of SD:
% C***         = -1 equal in logarithms
% C***         =  1 equal in absolute scale
% C***         =  0 read from the file

line_num(ln) = {sprintf('%-d  %-d  %-d  %-d  %-d : IBIN, (NMIN(I),I=1,NSD)',...
    inp.IBIN, inp.NBIN, inp.NBIN, 0, inp.IBIN)};
ln = ln + 1;

% 0.05 15.0 0 (RMIN(ISD),RMAX(ISD),ISD=1,NSD) 
% READ(*,*) (RMIN(ISD),RMAX(ISD),IS(ISD),ISD=1,NSD)	!! Read line 9

line_num(ln) = {sprintf('%-1.2f  %-1.2f  %-d  : (RMIN(ISD),RMAX(ISD),ISD=1,NSD)', ...
    inp.RMIN, inp.RMAX, inp.ISD)};
ln = ln + 1;

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
line_num(ln) = {sprintf('PARAMETERS OF MATRIX INVERSION (or Q-iterations):')};
ln = ln + 1;
[IM,NQ,IMTX, KI] = deal(inp.IM, inp.NQ, inp.IMTX, inp.KI);
line_num(ln) = {sprintf('%-d %-d %-d %-d  : IM,NQ,IMTX, KI', IM,NQ,IMTX, KI)};
ln = ln + 1;

line_num(ln) = {sprintf('PARAMETERS FOR Levenb.-Marquardt correction:')};
ln = ln + 1;
% 15 0.0005 0.5 1.33 1.6 0.0005 0.5 IPSTOP, RSDMIN, RSDMAX,REALMIN,REALMAX,AIMAGMIN,AIMAGMAX
%       READ(*,*) IPSTOP, RSDMIN,RSDMAX,REALMIN,REALMAX, ! line 13
[IPSTOP, RSDMIN, RSDMAX,REALMIN,REALMAX,AIMAGMIN,AIMAGMAX] = ...
    deal(inp.IPSTOP, inp.RSDMIN, inp.RSDMAX, inp.REALMIN, inp.REALMAX, inp.AIMAGMIN, inp.AIMAGMAX);
line_num(ln) = {sprintf('%-d %-1.4f  %-1.1f  %-1.2f %-1.1f  %-1.4f  %-1.1f : IPSTOP, RSDMIN, RSDMAX,REALMIN,REALMAX,AIMAGMIN,AIMAGMAX',...
    IPSTOP, RSDMIN, RSDMAX,REALMIN,REALMAX,AIMAGMIN,AIMAGMAX)};
ln = ln + 1;

% 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000. 0.001 1000.
%       IF(NSHAPE.GT.0) THEN
%        READ(*,*) (SHAPEMIN(I),SHAPEMAX(I),I=1,NSHAPE) ! Read line 14
line_num(ln) = {sprintf('%-1.3f %-1.1f ',[inp.SHAPEMIN, inp.SHAPEMAX]')};
ln = ln + 1;

% 
% SMOOTHNESS parameters:
% 0 1e-4 0 0 0 0
% 3  1.0e-3 1 1.0e-1 1 1.0e-4 IO(...), GSM(...) (SD,Real, Imag) (for each layer !!!) 
% 0 0 
% 0 0.00e-0

% !! Not sure how to actually construct the information for the smoothing parameters
% !! in terms of the dimensionality and order of the values.  
% !! So, just copying the values from the input files we have.
line_num(ln) = {sprintf('SMOOTHNESS parameters:')};
ln = ln + 1;
line_num(ln) = {sprintf('0 1e-4 0 0 0 0')};
ln = ln + 1;
line_num(ln) = {sprintf('3  1.0e-3 1 1.0e-1 1 1.0e-4 IO(...), GSM(...) (SD,Real, Imag) (for each layer !!!)')};
ln = ln + 1;
line_num(ln) = {sprintf('0 0')};
ln = ln + 1;
line_num(ln) = {sprintf('0 0.00e-0 ')};
ln = ln + 1;

% 1.0e-3 1.0e-2 1.0e-3 5.0e-3 5.0e-0 1.0e-7 EPSP,EPST,EPSQ,DL,AREF,EPSD
% C****************************************************
%       READ (*,*) EPSP,EPST,EPSQ,DL,AREF,EPSD	!! Read line 20
% C*****************************************************
% C***  EPSP - for stopping p - iterations
% C***  EPST - for stopping iterations in CHANGE
% C***  EPSQ - for stopping q - iterations in ITERQ"
% C***  DL   - for calc. derivatives, (see FMATRIX)
% C*****************************************************
[EPSP,EPST,EPSQ,DL,AREF,EPSD] = ...
    deal(inp.EPSP, inp.EPST, inp.EPSQ, inp.DL, inp.AREF, inp.EPSD);
line_num(ln) = {[sprintf('%-1.1e ',EPSP,EPST,EPSQ,DL,AREF,EPSD), ' EPSP,EPST,EPSQ,DL,AREF']};
ln = ln + 1;
% Here is where the indication of passing L1.5 or L2.0 input criteria goes
line_num(ln) = {[sprintf('MEASUREMENTS: '),sprintf('(rad scaled by %1.3f)',...
   inp.rad_scale), sprintf(' aods:'),sprintf(' %1.2f',inp.aod), ' dOD:',sprintf('%1.2f',inp.dOD)]};
ln = ln + 1;
for iw = 1:NW
    meas = inp.geom.WAVE_(iw).meas;
    line_num(ln) = {sprintf('%-1.4f ',meas)};
    ln = ln + 1;
end

line_num(ln) = {sprintf('INITIAL GUESS FOR THE SOLUTION:')};
ln = ln + 1;
% Real and Imag index of refraction
line_num(ln) = {[sprintf('%-1.2f ',inp.nreal), sprintf('%-1.3f ',inp.nimag)]};
ln = ln + 1;

for sdi = 1:inp.NBIN
line_num(ln) = {sprintf('%-1.6f',inp.sd_guess(sdi))};
ln = ln + 1;
end
%not sure what this final retrieved quantity is. Maybe sphericity?  
% In any case, since I don't know we'll just use the defaults for now.
line_num(ln) = {sprintf('100.0 1.1 ')};
ln = ln + 1;

% C***  Accounting for different accuracy levels in the data
% C***       AND   modelling   RANDOM NOISE           ***
%       READ (*,*) INOISE	!! Read line 51
%       READ (*,*) SGMS(1), INN(1), DNN(1) !! Read line 52

% C*** INOISE  - the number of different noise sources
[INOISE, SGMS, INN, DNN, IK, KNOISE] = ...
    deal(inp.INOISE, inp.SGMS, inp.INN, inp.DNN, inp.IK, inp.KNOISE);
line_num(ln) = {sprintf('%d  INOISE', INOISE)};
ln = ln + 1;
% C*** SGMS(I) - std of noise in i -th source                       ***
% C*** INN(I)  - EQ.1.THEN error is absolute with                   ***
% C***         - EQ.0 THEN error assumed relative
% C*** DNN(I)  - variation of the noise of the I-th source
line_num(ln) = {[sprintf('%1.1f %d %1.2f ', SGMS(1), INN(1), DNN(1)),'      SGMS(1),INN(1), DNN(1)']};
ln = ln + 1;

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

line_num(ln) = {[sprintf('%1.1f %d %1.4f %d ', SGMS(INOISE), INN(INOISE), DNN(INOISE), IK(INOISE)),...
    sprintf('%3d ',KNOISE) , '   SGMS(I),INN(I),DNN(I),IK(I),(KNOISE(I,K),K=1,IK(I))']};
ln = ln + 1;

% 0.0 1 0.0047 4  1   26   48   72   SGMS(I),INN(I),DNN(I),IK(I),(KNOISE(I,K),K=1,IK(I))

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

line_num(ln) = {sprintf('%-d %-d %-1.2f : IC, IACOV,DWW', inp.IC, inp.IACOV, inp.DWW)};
ln = ln + 1;
% Here's where to start looking hard...  want NLYRS>1 for PPL
[NSTR ,NLYR, NLYRS, NW, IGEOM, IDF, IDN, DPF] = ...
    deal(inp.NSTR, inp.NLYR, inp.NLYRS, inp.NW, inp.IGEOM, inp.IDF, inp.IDN, inp.DPF);
%7 1 1 4 1 1 1  0.00 : NSTR NLYR NLYRS NW IGEOM IDF IDN DPF   - Almucantar
if NLYRS==1
line_num(ln) = {sprintf('%-d %-d %-d %-d %-d %-d %-d %-1.2f : NSTR NLYR NLYRS NW IGEOM IDF IDN DPF   - Almucantar',...
    NSTR ,NLYR, NLYRS, NW, IGEOM, IDF, IDN, DPF)};
else
line_num(ln) = {sprintf('%-d %-d %-d %-d %-d %-d %-d %-1.2f : NSTR NLYR NLYRS NW IGEOM IDF IDN DPF   - PPL',...
    NSTR ,NLYR, NLYRS, NW, IGEOM, IDF, IDN, DPF)};
end
ln = ln + 1;
% H and W assumed atmospheric layers H(1) should be above hlyr, H(2) should
% be about houtput.
[H_NLYR, W_NLYR, NS] = deal(inp.H_NLYR, inp.W_NLYR, inp.NS);
line_num(ln) = {[sprintf('%-1.3f ', H_NLYR(1)), sprintf('%-1.1f ', W_NLYR(1)),sprintf('%-1.3f ', H_NLYR(2)), sprintf('%-1.1f ', W_NLYR(2)),...
    sprintf('%-d ',NS), '      : H(NLYR),W(NLYR),NS']};
ln = ln + 1;

line_num(ln) = {inp.iatmos_1};
ln = ln + 1;
line_num(ln) = {inp.iatmos_2};
ln = ln + 1;
line_num(ln) = {inp.iatmos_3};
ln = ln + 1;

line_num(ln) = {[sprintf('%- 1.3f',inp.wind_speed), '        : wind speed']};
ln = ln + 1;

land_fraction = inp.land_fraction;
line_num(ln) = {[sprintf('%-1.3f %-1.3f ',land_fraction, 1-land_fraction), '  : land_fraction sea_fraction']};
ln = ln + 1;

% if length(H_LYR)==1
%     H_LYR = [H_LYR, 70];
% end
H_LYR = inp.H_LYR;
line_num(ln) = {[sprintf('%-1.3f %-1.3f ',H_LYR), '  :(hlyr(NLYR-I+1),I=1,NLYR+1)']};
ln = ln + 1;

line_num(ln) = {[sprintf('%10.5f ',inp.Latitude), '   Latitude']};
ln = ln + 1;
s_str = [];

for IW = 1:length(WAV)
    NTAU = length(inp.geom.WAVE_(IW).HLYR);  

% For each wavelength, we may need to screen out bad data.
% For now, we treat them all as full, and also treat the altitude as fixed
% and constant so NTAU = 1 (NLYR=NLYRS=NTAU), hlyr=houtput=mean(alt) 
% hylr ~= houtput!!  houtput = mean(alt) but hlyr = ground level =
% s.ground_level
    line_num(ln) = {sprintf('%1.4f WAV(IW)',inp.geom.WAVE(IW))}; ln = ln +1;
    line_num(ln) = {[sprintf('%1.6f ',inp.geom.WAVE_(IW).albedo), ' albedo(IW)']};
    ln = ln +1;
    line_num(ln) = {[sprintf('%1.4f  %3.1f   %3.1f ',...
    inp.geom.WAVE_(IW).UO3,inp.geom.WAVE_(IW).DU,inp.geom.WAVE_(IW).PWV), ...
        ' - UO3(IW) , Ozone Content(dobson) Water Vapor (cm)']}; ln = ln +1;
    line_num(ln) = {[sprintf('%d ',NTAU), ' - NTAU(IW)  -number of output layers']}; ln = ln +1;
    s_str = [s_str, '  '];
    for ITAU = 1:length(NTAU)
        %%
%         houtput = mean(alt(good(IW,:)));
        line_num(ln) = {[s_str,sprintf('%1.3f ',inp.geom.WAVE_(IW).HLYR(ITAU)) ' - houtput(IW,ITAU) ' ]};
        ln = ln +1;
        s_str = [s_str, '  '];
%         SZA = sza(good(IW,:));
%         dec = 10; % higher number saves more digits, more unique numbers
%         [SZA_,SZA_ii, SZA_jj] = unique(round(SZA*dec)/dec);
        
        SZA_IW = inp.geom.WAVE_(IW).HLYR_(ITAU).SZA;
        NSZA = length(SZA_IW);
        line_num(ln) = {[s_str, sprintf('%d ',NSZA),...
            '    - NSZA(IW,ITAU)  - number of solar zenith angles']};
        ln = ln +1; 
        s_str = [s_str, '  '];
        for ISZA = 1:NSZA
            line_num(ln) = {[s_str, sprintf('%2.2f ',SZA_IW(ISZA)),...
                ' - SZA(IW,ITAU,ISZA) - solar zenith angle']};
            ln = ln +1;
            s_str = [s_str, '  '];
            NOZA = length(inp.geom.WAVE_(IW).HLYR_(ITAU).SZA_(ISZA).OZA);
            line_num(ln) = {[s_str, sprintf('%d ',NOZA),...
                '- NUMUY(IW,ITAU,ISZA) - number of observation zenith angles']};
            ln = ln +1;
            s_str = [s_str, '  '];
            for zi = 1:NOZA
                OZA_zi = inp.geom.WAVE_(IW).HLYR_(ITAU).SZA_(ISZA).OZA(zi);
                line_num(ln) = {[s_str, sprintf('%-3.2f ',OZA_zi),...
                    ' - ZENOUTY(IW,ITAU,ISZA,IOZA) - observation zenith angle']};
                ln = ln +1;
                if ~isfield(inp.geom.WAVE_(IW).HLYR_(ITAU).SZA_(ISZA),'OZA_') %No children below OS
                    NPHI = 1; 
%                     [IW,ITAU,ISZA,zi]
% There is only one PHI per Observatioon Zenith Angle (OZA).  This is PPL
% since OZA is changing fast, prohibiting multiple PHI
                    PHI = inp.geom.WAVE_(IW).HLYR_(ITAU).SZA_(ISZA).PHI(zi);
                else
% There are many PHI per OZA.  This is ALM, OZA is held fixed, PHI varies
                    NPHI = length(inp.geom.WAVE_(IW).HLYR_(ITAU).SZA_(ISZA).OZA_(zi).PHI);
                    PHI = inp.geom.WAVE_(IW).HLYR_(ITAU).SZA_(ISZA).OZA_(zi).PHI;
                end
                line_num(ln) = {[s_str, sprintf('%-3d ',NPHI),...
                    ' - NPHIY(IW,ITAU,ISZA,IOZA) - number of observation azimuth angles']};
                ln = ln +1;
                s_str = [s_str, '  '];
                line_num(ln) = {[s_str, sprintf('%-8.1f ',PHI),...
                    ' :(PHI(I,IL),I=1,NPHI(IL))']};
                ln = ln +1;
                s_str(end-1:end) = [];
            end
            s_str = [];
        end
    end
end
line_num(ln) = {sprintf('%d  ',inp.whoknows)};
ln = ln +1;

for bds = 1:length(inp.mod_brdf)
line_num(ln) = {sprintf('%-8.6f  ',inp.mod_brdf{bds})};
ln = ln +1;
end
line_num(ln) = {sprintf('%s',inp.date_time_site_unit)};

return
