function aos = aoscorr(aos);
% aos = aoscorr(aos);
% Applies corrections to raw aos data
% STP correction to Neph
% Neph truncation
% PSAP spot-size and scattering correction (single wavelength only?)
% Wet neph loss corrections not applied

if ~exist('aos','var')
   aos = ancload('*.cdf','aos','Get AOS file...')
end
flags = uint32(hex2dec((aos.vars.flags_NOAA.data(1:4,:))'));
aos.vars.flags_NOAA.data = flags';
aos.vars.flags_NOAA.dims = aos.vars.time.dims;
aos.vars.flags_NOAA.datatype = 4; %NC_single?
aos.dims = rmfield(aos.dims,'flag_length');
stp = bitget(flags,9);
PSAP_spot = bitget(flags,10);
Neph_trunc = bitget(flags,11);
PSAP_trans_lt_p7 = bitget(flags,6);
badair_flag = bitget(flags,1)&bitget(flags,2)&bitget(flags,3);
submicron = single(bitget(flags,5));
fields = fieldnames(aos.vars);

% Correct Neph to STP
if ~stp
   aos.vars.flags_NOAA.data = bitset(aos.vars.flags_NOAA.data,9,1);
   flags = bitset(flags,9,1);
   % (lrh_pres / 1013.25) * (273.15/lrh_t);
   dryden = ones(size(aos.vars.P_Neph_Dry.data));
   nonNaN = (aos.vars.P_Neph_Dry.data>0)&isfinite(aos.vars.P_Neph_Dry.data)&(aos.vars.T_NephVol_Dry.data>0)&isfinite(aos.vars.T_NephVol_Dry.data);
   dryden(nonNaN) = (1013.25./aos.vars.P_Neph_Dry.data(nonNaN)).*((aos.vars.T_NephVol_Dry.data(nonNaN)+273.15)./273.15); 
   nonNaN = (aos.vars.P_Neph_Wet.data>0)&isfinite(aos.vars.P_Neph_Wet.data)&(aos.vars.T_NephVol_Wet.data>0)&isfinite(aos.vars.T_NephVol_Wet.data);
   wetden(nonNaN) = (1013.25./aos.vars.P_Neph_Wet.data(nonNaN)).*((aos.vars.T_NephVol_Wet.data(nonNaN)+273.15)./273.15); 
   for f = length(fields):-1:1
      if ~isempty(findstr(fields{f},'Neph'))&&~isempty(findstr(fields{f},'Dry'))
         aos.vars.(fields{f}).data = aos.vars.(fields{f}).data .* dryden;
      end
      if ~isempty(findstr(fields{f},'Neph'))&&~isempty(findstr(fields{f},'Wet'))
         aos.vars.(fields{f}).data = aos.vars.(fields{f}).data .* wetden;
      end
% % Correct wet Neph could go here
%   corr_scale fields=13..18 test='$cut==10' slope=1.147 sY=2005 eY=2005 sD=182.0 eD=263.0 $tmpfile | \
%   corr_scale fields=13..18 test='$cut==1' slope=1.03 sY=2005 eY=2005 sD=182.0 eD=263.0 | \
%   corr_scale fields=13..18 test='$cut==10' slope=1.04 sY=2005 eY=2020 sD=263.1 eD=367 | \
%   corr_scale fields=13..18 test='$cut==1' slope=1.05 sY=2005 eY=2020 sD=263.1 eD=367 > $tmp2file
   end
end

if ~Neph_trunc
   %compute angstrom exponents 
   aos.vars.flags_NOAA.data = bitset(aos.vars.flags_NOAA.data,11,1);
   flags = bitset(flags,11,1);
   R = 700; G = 550; B = 450;
   Angstrom_RB_Dry_1um = NaN(size(aos.time));
   Angstrom_RG_Dry_1um = NaN(size(aos.time));
   Angstrom_GB_Dry_1um = NaN(size(aos.time));
   Angstrom_RB_Dry_10um = NaN(size(aos.time));
   Angstrom_RG_Dry_10um = NaN(size(aos.time));
   Angstrom_GB_Dry_10um = NaN(size(aos.time));
   Angstrom_RB_Wet_1um = NaN(size(aos.time));
   Angstrom_RG_Wet_1um = NaN(size(aos.time));
   Angstrom_GB_Wet_1um = NaN(size(aos.time));
   Angstrom_RB_Wet_10um = NaN(size(aos.time));
   Angstrom_RG_Wet_10um = NaN(size(aos.time));
   Angstrom_GB_Wet_10um = NaN(size(aos.time));
   test = aos.vars.Bs_R_Dry_10um_Neph3W_1.data>0 & aos.vars.Bs_B_Dry_10um_Neph3W_1.data>0;
Angstrom_RB_Dry_1um(test) = log(aos.vars.Bs_R_Dry_1um_Neph3W_1.data(test)./aos.vars.Bs_B_Dry_1um_Neph3W_1.data(test))./log(B./R);
Angstrom_RG_Dry_1um(test) = log(aos.vars.Bs_R_Dry_1um_Neph3W_1.data(test)./aos.vars.Bs_G_Dry_1um_Neph3W_1.data(test))./log(G./R);
Angstrom_GB_Dry_1um(test) = log(aos.vars.Bs_G_Dry_1um_Neph3W_1.data(test)./aos.vars.Bs_B_Dry_1um_Neph3W_1.data(test))./log(B./G);
Angstrom_RB_Dry_10um(test) = log(aos.vars.Bs_R_Dry_10um_Neph3W_1.data(test)./aos.vars.Bs_B_Dry_10um_Neph3W_1.data(test))./log(B./R);
Angstrom_RG_Dry_10um(test) = log(aos.vars.Bs_R_Dry_10um_Neph3W_1.data(test)./aos.vars.Bs_G_Dry_10um_Neph3W_1.data(test))./log(G./R);
Angstrom_GB_Dry_10um(test) = log(aos.vars.Bs_G_Dry_10um_Neph3W_1.data(test)./aos.vars.Bs_B_Dry_10um_Neph3W_1.data(test))./log(B./G);
Angstrom_RB_Wet_1um(test) = log(aos.vars.Bs_R_Wet_1um_Neph3W_2.data(test)./aos.vars.Bs_B_Wet_1um_Neph3W_2.data(test))./log(B./R);
Angstrom_RG_Wet_1um(test) = log(aos.vars.Bs_R_Wet_1um_Neph3W_2.data(test)./aos.vars.Bs_G_Wet_1um_Neph3W_2.data(test))./log(G./R);
Angstrom_GB_Wet_1um(test) = log(aos.vars.Bs_G_Wet_1um_Neph3W_2.data(test)./aos.vars.Bs_B_Wet_1um_Neph3W_2.data(test))./log(B./G);
Angstrom_RB_Wet_10um(test) = log(aos.vars.Bs_R_Wet_10um_Neph3W_2.data(test)./aos.vars.Bs_B_Wet_10um_Neph3W_2.data(test))./log(B./R);
Angstrom_RG_Wet_10um(test) = log(aos.vars.Bs_R_Wet_10um_Neph3W_2.data(test)./aos.vars.Bs_G_Wet_10um_Neph3W_2.data(test))./log(G./R);
Angstrom_GB_Wet_10um(test) = log(aos.vars.Bs_G_Wet_10um_Neph3W_2.data(test)./aos.vars.Bs_B_Wet_10um_Neph3W_2.data(test))./log(B./G);

	  aos.vars.Bs_B_Dry_1um_Neph3W_1.data(test)    = aos.vars.Bs_B_Dry_1um_Neph3W_1.data(test) .* (1.165 - (0.046 .* Angstrom_GB_Dry_1um(test))); 
	  aos.vars.Bs_B_Dry_1um_Neph3W_1.data(~test)    = aos.vars.Bs_B_Dry_1um_Neph3W_1.data(~test) .* 1.094; 
	  aos.vars.Bs_G_Dry_1um_Neph3W_1.data(test)    = aos.vars.Bs_G_Dry_1um_Neph3W_1.data(test) .* (1.152 - (0.044 .* Angstrom_RB_Dry_1um(test))); 
	  aos.vars.Bs_G_Dry_1um_Neph3W_1.data(~test)    = aos.vars.Bs_G_Dry_1um_Neph3W_1.data(~test) .* 1.073; 
	  aos.vars.Bs_R_Dry_1um_Neph3W_1.data(test)    = aos.vars.Bs_R_Dry_1um_Neph3W_1.data(test) .* (1.12 - (0.035 .* Angstrom_RG_Dry_1um(test))); 
	  aos.vars.Bs_R_Dry_1um_Neph3W_1.data(~test)    = aos.vars.Bs_R_Dry_1um_Neph3W_1.data(~test) .* 1.049; 

	  aos.vars.Bs_B_Dry_10um_Neph3W_1.data(test)    = aos.vars.Bs_B_Dry_10um_Neph3W_1.data(test) .* (1.365 - (0.156 .* Angstrom_GB_Dry_10um(test))); 
	  aos.vars.Bs_B_Dry_10um_Neph3W_1.data(~test)    = aos.vars.Bs_B_Dry_10um_Neph3W_1.data(~test) .* 1.290; 
	  aos.vars.Bs_G_Dry_10um_Neph3W_1.data(test)    = aos.vars.Bs_G_Dry_10um_Neph3W_1.data(test) .* (1.337 - (0.138 .* Angstrom_RB_Dry_10um(test))); 
	  aos.vars.Bs_G_Dry_10um_Neph3W_1.data(~test)    = aos.vars.Bs_G_Dry_10um_Neph3W_1.data(~test) .* 1.290; 
	  aos.vars.Bs_R_Dry_10um_Neph3W_1.data(test)    = aos.vars.Bs_R_Dry_10um_Neph3W_1.data(test) .* (1.297- (0.113 .* Angstrom_RG_Dry_10um(test))); 
	  aos.vars.Bs_R_Dry_10um_Neph3W_1.data(~test)    = aos.vars.Bs_R_Dry_10um_Neph3W_1.data(~test) .* 1.260; 

     gtz = aos.vars.Bbs_B_Dry_1um_Neph3W_1.data>0;
     aos.vars.Bbs_B_Dry_1um_Neph3W_1.data(gtz) = aos.vars.Bbs_B_Dry_1um_Neph3W_1.data(gtz).* 0.951;
     gtz = aos.vars.Bbs_G_Dry_1um_Neph3W_1.data>0;
     aos.vars.Bbs_G_Dry_1um_Neph3W_1.data(gtz) = aos.vars.Bbs_G_Dry_1um_Neph3W_1.data(gtz).* 0.947;
     gtz = aos.vars.Bbs_R_Dry_1um_Neph3W_1.data>0;
     aos.vars.Bbs_R_Dry_1um_Neph3W_1.data(gtz) = aos.vars.Bbs_R_Dry_1um_Neph3W_1.data(gtz).* 0.952;

     gtz = aos.vars.Bbs_B_Dry_10um_Neph3W_1.data>0;
     aos.vars.Bbs_B_Dry_10um_Neph3W_1.data(gtz) = aos.vars.Bbs_B_Dry_10um_Neph3W_1.data(gtz).* 0.981;
     gtz = aos.vars.Bbs_G_Dry_10um_Neph3W_1.data>0;
     aos.vars.Bbs_G_Dry_10um_Neph3W_1.data(gtz) = aos.vars.Bbs_G_Dry_10um_Neph3W_1.data(gtz).* 0.982;
     gtz = aos.vars.Bbs_R_Dry_10um_Neph3W_1.data>0;
     aos.vars.Bbs_R_Dry_10um_Neph3W_1.data(gtz) = aos.vars.Bbs_R_Dry_10um_Neph3W_1.data(gtz).* 0.985;

	  aos.vars.Bs_B_Wet_1um_Neph3W_2.data(test)    = aos.vars.Bs_B_Wet_1um_Neph3W_2.data(test) .* (1.165 - (0.046 .* Angstrom_GB_Wet_1um(test))); 
	  aos.vars.Bs_B_Wet_1um_Neph3W_2.data(~test)    = aos.vars.Bs_B_Wet_1um_Neph3W_2.data(~test) .* 1.094; 
	  aos.vars.Bs_G_Wet_1um_Neph3W_2.data(test)    = aos.vars.Bs_G_Wet_1um_Neph3W_2.data(test) .* (1.152 - (0.044 .* Angstrom_RB_Wet_1um(test))); 
	  aos.vars.Bs_G_Wet_1um_Neph3W_2.data(~test)    = aos.vars.Bs_G_Wet_1um_Neph3W_2.data(~test) .* 1.073; 
	  aos.vars.Bs_R_Wet_1um_Neph3W_2.data(test)    = aos.vars.Bs_R_Wet_1um_Neph3W_2.data(test) .* (1.12 - (0.035 .* Angstrom_RG_Wet_1um(test))); 
	  aos.vars.Bs_R_Wet_1um_Neph3W_2.data(~test)    = aos.vars.Bs_R_Wet_1um_Neph3W_2.data(~test) .* 1.049; 

	  aos.vars.Bs_B_Wet_10um_Neph3W_2.data(test)    = aos.vars.Bs_B_Wet_10um_Neph3W_2.data(test) .* (1.365 - (0.156 .* Angstrom_GB_Wet_10um(test))); 
	  aos.vars.Bs_B_Wet_10um_Neph3W_2.data(~test)    = aos.vars.Bs_B_Wet_10um_Neph3W_2.data(~test) .* 1.290; 
	  aos.vars.Bs_G_Wet_10um_Neph3W_2.data(test)    = aos.vars.Bs_G_Wet_10um_Neph3W_2.data(test) .* (1.337 - (0.138 .* Angstrom_RB_Wet_10um(test))); 
	  aos.vars.Bs_G_Wet_10um_Neph3W_2.data(~test)    = aos.vars.Bs_G_Wet_10um_Neph3W_2.data(~test) .* 1.290; 
	  aos.vars.Bs_R_Wet_10um_Neph3W_2.data(test)    = aos.vars.Bs_R_Wet_10um_Neph3W_2.data(test) .* (1.297- (0.113 .* Angstrom_RG_Wet_10um(test))); 
	  aos.vars.Bs_R_Wet_10um_Neph3W_2.data(~test)    = aos.vars.Bs_R_Wet_10um_Neph3W_2.data(~test) .* 1.260; 

     gtz = aos.vars.Bbs_B_Wet_1um_Neph3W_2.data>0;
     aos.vars.Bbs_B_Wet_1um_Neph3W_2.data(gtz) = aos.vars.Bbs_B_Wet_1um_Neph3W_2.data(gtz).* 0.951;
     gtz = aos.vars.Bbs_G_Wet_1um_Neph3W_2.data>0;
     aos.vars.Bbs_G_Wet_1um_Neph3W_2.data(gtz) = aos.vars.Bbs_G_Wet_1um_Neph3W_2.data(gtz).* 0.947;
     gtz = aos.vars.Bbs_R_Wet_1um_Neph3W_2.data>0;
     aos.vars.Bbs_R_Wet_1um_Neph3W_2.data(gtz) = aos.vars.Bbs_R_Wet_1um_Neph3W_2.data(gtz).* 0.952;

     gtz = aos.vars.Bbs_B_Wet_10um_Neph3W_2.data>0;
     aos.vars.Bbs_B_Wet_10um_Neph3W_2.data(gtz) = aos.vars.Bbs_B_Wet_10um_Neph3W_2.data(gtz).* 0.981;
     gtz = aos.vars.Bbs_G_Wet_10um_Neph3W_2.data>0;
     aos.vars.Bbs_G_Wet_10um_Neph3W_2.data(gtz) = aos.vars.Bbs_G_Wet_10um_Neph3W_2.data(gtz).* 0.982;
     gtz = aos.vars.Bbs_R_Wet_10um_Neph3W_2.data>0;
     aos.vars.Bbs_R_Wet_10um_Neph3W_2.data(gtz) = aos.vars.Bbs_R_Wet_10um_Neph3W_2.data(gtz).* 0.985;
end