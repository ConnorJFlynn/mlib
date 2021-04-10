function [sas, tau_O3, tau_NO2, tau_O4 , tau_CO2_CH4_N2O, tau_O3_err, tau_NO2_err, tau_O4_err, tau_CO2_CH4_N2O_abserr]=SAS_gases(t, nm, Lat, Lon, Alt, Pst, O3col, NO2col)

% development
% NO2, O3 concentrations should be input from starinfo or OMI gridded file
% cross section should be updated every time wavelengths and FWHM are
% updated. Keep track of the past records with t (input).

% load cross section data
% all options are commented since new cross section version is unified
% MS, modified, 2015-11-30, added an option to read OMI data and use
%                           seperate value for each t, unlike O3col
%                           and NO2col from starinfo, which is constant
%                           separated functionallity whether called
%                           from starc0 or starwrapper
%                           now has 7 nargin
% Borrowed heavily from 4STAR taugases by Michal Segal-Rozenhaimer, NASA
%----------------------------------------------------------------------

% set functionallity

if length(Lat)==1
     % this is being called from starc0
     flag_interpOMIno2  = 'no';% use default
     flag_interpOMIo3   = 'no';% use default
     % default value; might want to adjust
     coeff_polyfit_tauO3model=[8.60377e-007  -3.26194e-005   3.54396e-004  -1.30386e-003  -5.67021e-003   9.99948e-001];
     frac_tauO3 = polyval(coeff_polyfit_tauO3model,Alt/1000);
     
elseif strcmp(datestr(t(1),'yyyymmdd'),'20160426')
    % check if this is Langley; don't apply
    flag_interpOMIno2  = 'no';% use default
    flag_interpOMIo3   = 'no';% use default
    
    % apply appropriate o3 scaling polynomial
    % this is for April, Lat bin 45
    coeff_polyfit_tauO3model = [2.0744e-06 -7.3077e-05 7.9684e-04 -0.0029 -0.0092 0.9995];
    
else
     % all other cases - yes, KORUS-AQ, 'no' OMI seems to be over-cloaded
     flag_interpOMIno2  = 'no';% this is new no2 interpolation, from L2 gridded product
     flag_interpOMIo3   = 'no';% this is new o3 interpolation, from L2 gridded product
     
     % mid-lat July
     % coeff_polyfit_tauO3model=[8.60377e-007  -3.26194e-005   3.54396e-004  -1.30386e-003  -5.67021e-003   9.99948e-001];
     % this is for April, Lat bin 45
     coeff_polyfit_tauO3model = [2.0744e-06 -7.3077e-05 7.9684e-04 -0.0029 -0.0092 0.9995];
end

if t>=datenum([2012 7 3 0 0 0]);
    cross_sections=load(which( 'cross_sections_uv_vis_swir_all.mat')); % load newest cross section vesion (October 15th 2012) MS
    fn=fieldnames(cross_sections);
    sas.wln = interp1([1:length(cross_sections.wln)], cross_sections.wln, nm, 'pchip')';
    for ff=2:length(fn);
       sas.(fn{ff}) = interp1(cross_sections.wln, cross_sections.(fn{ff}),sas.wln, 'pchip');
    end;
end;

%% get NO2 optical depth

Loschmidt=2.686763e19; %molecules/cm3xatm
if nargin<8 || isempty(NO2col);
    NO2col=2.0e15; % molec/cm2
    O3col =0.250;  % atm x cm
end

% calculate from OMI or from default value
if strcmp(flag_interpOMIno2,'yes')
    try
        daystr = datestr(t(1),'yyyymmdd');
        g = processOMIdata(Lat,Lon,daystr,'NO2');
        
        tau_NO2 =(g.omi/Loschmidt)*sas.no2;
        tau_NO2s=(g.omino2S/Loschmidt)*sas.no2;
        tau_NO2t=(g.omino2T/Loschmidt)*sas.no2;
        tau_NO2d=(repmat(2.0e15,length(g.omi),1)/Loschmidt)*sas.no2;% d is for default
        nanid = find(isnan(tau_NO2(:,1)));
        % assign tau_NO2 according to aircraft altitude
        tau_NO2(Alt> 3000,:)  = tau_NO2s(Alt> 3000,:);
        % assign constant no2 at missing values
        tau_NO2(nanid,:)      = tau_NO2d(nanid,:);
        
    catch
        tau_NO2=(NO2col/Loschmidt)*sas.no2;
        % adjust struct size
        tau_NO2=repmat(tau_NO2,length(t),1);
    end
else
    tau_NO2=(NO2col/Loschmidt)*sas.no2;
    % adjust struct size
    tau_NO2=repmat(tau_NO2,length(t),1);
end

%% get O4 optical depths
[O2_vercol,O4_vercol]=O2_VCYMSez(Alt, t, Lat);
if isfield(sas,'o4all'); % Yohei, 2013/01/16, for the legacy July 3, 2012 cross sections
    tau_O4=O4_vercol*sas.o4all;
else
    tau_O4=O4_vercol*sas.o4;
end;
tau_O2=zeros(size(sas.wln)); % don't subtract O2 % O2_vercol*cross_sections.o2;
tau_O2=O2_vercol*sas.o2;
tau_CO2_CH4_N2O=zeros(size(sas.wln)); % legacy from AATS's 14th channel, not covered by 4STAR VIS.

%% get O3 optical depths

%following added by Livingston 12/19/2002 to account for altitude in columnar ozone correction
%use previously calculated (Livingston program ozonemdlcalc.m) 5th order polynomial fit to ozone model
%to calculate fraction of total column ozone above each altitude
% coeff_polyfit_tauO3model=[8.60377e-007  -3.26194e-005   3.54396e-004  -1.30386e-003  -5.67021e-003   9.99948e-001];
% frac_tauO3 = polyval(coeff_polyfit_tauO3model,Alt/1000); % Livingston used GPS_Alt
% if strcmp(flag_adj_ozone_foraltitude,'no') frac_tauO3=1*ones(1,n(1)); end

% correction is based on zstar altitude so calculate
if length(Lat)>1
    zstar = 16*log10(1013./Pst);
    frac_tauO3 = polyval(coeff_polyfit_tauO3model,zstar);
end

flag_interpOMIozone='no';%'yes';  'no' for MLO; this is John's heritage code

if strcmp(flag_interpOMIozone,'yes')
    
    % John heritage omi adjustment
    imoda_OMI=100*month+day;
    if strcmp(flag_OMI_substitute,'yes')
        imoda_OMI=imoda_OMI_substitute;
    end
    [OMIozone_interp,filename_OMIO3] = readinterp_OMIozone(imoda_OMI,geog_lat,geog_long);
    ozone=(frac_tauO3.*OMIozone_interp)';
    tau_O3=(ozone*cross_sections.o3')';
    
elseif strcmp(flag_interpOMIo3,'yes')
    
    try
        
        % interpolated o3 fields from OMI L2G product
        daystr = datestr(t(1),'yyyymmdd');
        % go3 = processOMIdataO3(Lat,Lon,daystr);
        g = processOMIdata(Lat,Lon,daystr,'O3');
        
        % calculate o3OD
        tau_O3=(frac_tauO3.*(g.omi/1000))*sas.o3;
        % fill-in with mean values
        
        nanid = find(isnan(tau_O3(:,407)));
        tau_O3(nanid,:) = (frac_tauO3(nanid)*O3col)*sas.o3;
    
    catch
        % if OMI data files are missing
        % defualt read from starinfo
        filename_OMIO3=[];
        ozone=(frac_tauO3*O3col)';
        tau_O3=O3col*sas.o3;
        tau_O3=frac_tauO3*tau_O3;
    end
    
else
        % defualt read from starinfo
        filename_OMIO3=[];
        ozone=(frac_tauO3*O3col)';
        tau_O3=O3col*sas.o3;
        tau_O3=frac_tauO3*tau_O3;
end

% give uncertainties - inherited from the AATS code. From Schmid et al.
% (1996)?
    tau_O3_err=0.05;       %relative error
    tau_NO2_err=0.27;      %relative error
    tau_O4_err=0.12;       %relative error
%     tau_H2O_err=0.15;      %relative error
%     a_H2O_err=0.02;        %relative error
%     b_H2O_err=0.02;        %relative error
    tau_CO2_CH4_N2O_abserr=zeros(size(tau_CO2_CH4_N2O));
    tau_CO2_CH4_N2O_abserr(tau_CO2_CH4_N2O>0)=1.0e-04;  %absolute error


