function anet_mie_aer
% Connor, 2022-03-07, off-shoot of anet_mie to test extension to 10 um for Eli Mlawer AER
% Initially tested extension of index of refraction to 10 um assuming one
% of two bounding cases: 
% 1) Hygroscopic aerosol dominated by large essentially droplets, n* = Re 1.2 Im 0.05
% 2) Fe2O3 iron oxide dust n* = Re 2 Im 0.02
% Next testing using 
% 1) an aod-weighted average of Re @ 1020 nm = 1.5 ==> Re @ 10um 1.7 
% 2) interpolated Im between 1.2-> 2 and 0.05 -> 0.02 via Re from 1.3->1.6

% I attempted to explicitly assign the index of refraction at 10 um based on the value at 1020 um with the assumption that the aerosol most impacting the optical properties at 10 um could be represented as a mixture of aqueous and mineral dust aerosol as described below.
% 
% 1.	Identified 86 Aeronet lv 1.5 retrievals of refractive index and size distribution within 1 hr of the 453 AER cases. 
% 2.	Extended the retrieval results to include a value for refractive index at 10 um by:
% a.	Assuming that AOD at 10 um will be most impacted by the fraction of the PSD in the coarse mode.
% b.	Assuming that the AOD in the coarse mode could be represented as some external mixture of aqueous aerosol (n_Re(1020nm) = 1.3) and mineral dust (n_Re(1020nm) = 1.6. (Maximum n_Re from Aeronet retrieval).
% c.	Projected this mixture to 10 um with water n* = 1.2 + 0.05i and mineral dust (Fe2O3) having n* = 2 + 0.02i. (This is a common but not the only mineral type for Oklahoma but fortunately for the scope of this exploration it isn’t strongly absorbing until ~20 um.)
% d.	Computed AOD with Mie theory for 32 wavelengths wl = [325..(+50)..1050, 1100..(+200)..1900, 2000..(+500)..4500, 5000..(+1000)..10000];
% e.	Regressed AOD(10um) vs PWV[cm], excluding values with coarse/fine mean volume ratio > 5.5 (black filled circles below) on the premise that water-dominated aerosols will not be exclusively coarse mode. (Including all points makes a small difference yielding Y = 5.3e-3 PWV + 5.8e-3.

% Considering Dave Ts remark that montmorillonite is common to SGP, attempting to
% incorporate n* for that. 
% n_*(montmorillonite) =  n_Re(1020nm) + n_Im(1020nm) = 1.518 + 1.15e-3i Arakawa 1994
% n_*(montmorillonite) =  n_Re(1020nm) + n_Im(1020nm) = 2.486 + .546i Query 1987

% rm=[0.050000,0.065604,0.086077,0.112939,0.148184,0.194429,0.255105,0.334716,0.439173,0.576227,0.756052,0.991996,1.301571,1.707757,2.240702,2.939966,3.857452,5.061260,6.640745,8.713145,11.432287,15.000000];
% dVdlnr = [0.000321,0.002708,0.010422,0.018989,0.018266,0.011193,0.005670,0.003155,0.002377,0.002548,0.003535,0.005525,0.008811,0.013720,0.020467,0.028187,0.032764,0.028586,0.017028,0.006553,0.001587,0.000240];
% dVdlnr= [0.000799	0.000783	0.001214	0.00283	0.008527	0.025265	0.052488	0.056106	0.03332	0.017428	0.011672	0.010808	0.012044	0.01447	0.017286	0.018461	0.017036	0.013154	0.008418	0.004531	0.002083	0.000823];

%specifying a larger/different WL range compared to aeronet provides the
%ability to extend AOD from their specific wavelengths. 

% eaod = rd_anetaip_v3;
rin = rd_anet_rin_v3(getfullname('*.rin','anet_aipv3','Select anet .rin file.')); % 20160301_20180930
partname = [rin.pname, filesep, rin.fname(1:end-3)];  
lambda=[rin.lambda, 10000]; %lambda=[rin.lambda];
cad = rd_anetaip_v3([partname, 'cad']); 

aod_coi = [cad.AOD_Coincident_Input_440nm_,cad.AOD_Coincident_Input_675nm_,cad.AOD_Coincident_Input_870nm_,cad.AOD_Coincident_Input_1020nm_];
% aod_lev1p5 = rd_anetaod_v3;
% aod_lev2 = rd_anetaod_v3;

siz = rd_anet_siz_v3([partname, 'siz']);

vol = rd_anetaip_v3([partname, 'vol']);

aer_cases_used = importdata(['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\NASA\anet\aip_v3\20160301_20180930_Cart_Site\SGP_usedCases.txt']);
aer_cases_used.time = datenum(aer_cases_used.data(:,1),aer_cases_used.data(:,2),...
    aer_cases_used.data(:,3),aer_cases_used.data(:,4),aer_cases_used.data(:,5),...
    zeros(size(aer_cases_used.data(:,1))));

good = all(rin.Refractive_Index_Real_Part>0,2)&all(rin.Refractive_Index_Imaginary_Part>0,2); 
goods = find(good);

[ainb, bina] = nearest(siz.time(goods), aer_cases_used.time,1./24); size(ainb)% Within 1 hr of each other
aer_cases_used.bina = bina;

wl = [325:25:1050 1100:100:1900 2000:250:4250 4500:500:10000];
wl = [325:50:1050 1100:200:1900 2000:500:4500 sort([5000:1000:10000, 7690,8333,9091,11111,12500])]; %Eli's request
wl_1700_ij = interp1(wl, [1:length(wl)],1700,'nearest');
% wl = [325:25:1700];
% ni = interp1(lambda, n_i, wl, 'linear','extrap');

figure_(99);
bin_rad = logspace(log10(siz.bin_radius(1)./2), log10(2.*siz.bin_radius(end)),4.*length(siz.bin_radius));

for ij = length(ainb):-1:1
    ai = ainb(ij);
    aod_co = aod_coi(goods(ai),:);
    aer_cases_used.aod_co(ij,:) = aod_co;
%     Ref_Ind_real = [rin.Refractive_Index_Real_Part(goods(ai),:)];
%     Ref_Ind_imag = [rin.Refractive_Index_Imaginary_Part(goods(ai),:)];
    Ref_Re_10um(ij) = interp1([1.3,1.518],[1.2,2.486],rin.Refractive_Index_Real_Part(goods(ai),4),'linear');
    if isnan(Ref_Re_10um(ij))
        Ref_Re_10um(ij) = interp1([1.3,1.518],[1.2,2.486],rin.Refractive_Index_Real_Part(goods(ai),4),'nearest','extrap');
    end
    Ref_Im_10um(ij) = interp1([1.3,1.518],[.05,.546],rin.Refractive_Index_Real_Part(goods(ai),4),'linear');
    if isnan(Ref_Im_10um(ij))
        Ref_Im_10um(ij) = interp1([1.3,1.518],[.05,.546],rin.Refractive_Index_Real_Part(goods(ai),4),'nearest','extrap');
    end
    Ref_Ind_real = [rin.Refractive_Index_Real_Part(goods(ai),:),Ref_Re_10um(ij)]; % water
    Ref_Ind_imag = [rin.Refractive_Index_Imaginary_Part(goods(ai),:),Ref_Im_10um(ij)];% water
    n_i = Ref_Ind_real+j.*Ref_Ind_imag;
    ni = interp1(lambda, n_i, wl, 'linear','extrap');

    % Construct multi-modal lognormal PSD for plotting
    dVdlnr = vol.VolC_F(goods(ai)).*LnNormal(bin_rad, vol.VMR_F(goods(ai)), exp(vol.Std_F(goods(ai))))+...
        vol.VolC_C(goods(ai)).*LnNormal(bin_rad, vol.VMR_C(goods(ai)), exp(vol.Std_C(goods(ai))));
    % Construct M1 M1 mode structs for passing to anet_mie
    M1.VolC = vol.VolC_F(goods(ai)); M1.vmr = vol.VMR_F(goods(ai)); M1.std = vol.Std_F(goods(ai));
    M2.VolC = vol.VolC_C(goods(ai)); M2.vmr = vol.VMR_C(goods(ai)); M2.std = vol.Std_C(goods(ai));

%        sb(1) =subplot(1,2,1);  hold('off');
%     plot(siz.bin_radius, siz.dV_dlnr(goods(ai),:),'k-o',bin_rad, dVdlnr,'r-'); xlabel('radius [um]'); ylabel('dV/dlnr'); logx
%     %% 
%     title(['ASD dV/dlnr bins ',datestr(siz.time(goods(ai)),'yyyy-mm-dd HH:MM')]); legend('PSD bins','SM params','Location','NorthWest')
%     hold('on'); set(sb(1),'pos',[ 0.0859    0.1145    0.3956    0.8105]);
%     pause(.2)
    % Bi-modal structs
    tic; aod_bm = anet_mie(wl,ni, bin_rad, M1, M2); toc
    aer_cases_used.aod_bm_1700(ij) = aod_bm(wl_1700_ij);
    aer_cases_used.aod_bm_10um(ij) = aod_bm(end);

    % lognormal composed from bi-modal parameters
%     tic;  [aod_lg, ssa_lg] = anet_mie(wl,ni, bin_rad, dVdlnr); toc
    % lognormal PSD bin-wise
    tic; [aod_bin(ij,:), ssa] = anet_mie(wl,ni, siz.bin_radius, siz.dV_dlnr(goods(ai),:)); toc

   aod_bm; aod_bin; aod_co;
          sb(1) =subplot(1,2,1);  hold('off');
    plot(siz.bin_radius, siz.dV_dlnr(goods(ai),:),'k-o',bin_rad, dVdlnr,'r-'); xlabel('radius [um]'); ylabel('dV/dlnr'); logx
    %% 
    title(['ASD dV/dlnr bins ',datestr(siz.time(goods(ai)),'yyyy-mm-dd HH:MM')]); legend('PSD bins','SM params','Location','NorthWest')
    hold('on'); set(sb(1),'pos',[ 0.0859    0.1145    0.3956    0.8105]);
   sb(2) = subplot(1,2,2); hold('on');
   plot(lambda(1:end-1), aod_co,'ro',wl, aod_bin(ij,:), '-b',wl, aod_bm,'kx'); logy; logx;
   legend('AOD Coi','AOD PSD','AOD BiMod')
   xlabel('wavelength [nm]');ylabel('Optical depth [unitless]');
   hold('on');set(sb(2),'pos',[0.5703    0.1100    0.3805    0.8150]);hold('off')
   title(['AOD from .cad and Mie:',datestr(siz.time(goods(ai)),'yyyy-mm-dd HH:MM')]);
   yl = ylim;
   tx = text(1.1e3,1.15.*yl(1),sprintf('n_R_e = %1.2f',Ref_Re_10um(ij))); tx.Color = [0,.7,.7]; tx.Interpreter = 'tex';
   hold('off');
   pause(.1)
end
wl_out = [7690,8333,9091, 10000, 11111,12500]; out_ij = interp1(wl, [1:length(wl)],wl_out,'nearest');
colr = vol.VolC_C(goods(ainb))./vol.VolC_F(goods(ainb));
% mask = zeros(size(A(:,1))); mask(colr>5.5) = NaN;
% [P,S] = polyfit(A(colr<5.5,6),A(colr<5.5,end),1);[P_,S_] = polyfit(A(:,6),A(:,end),1);
% figure; scatter(A(:,6), A(:,end),36,colr,'filled'); caxis([0,6]); cb = colorbar; cbt = get(cb,'title'); set(cbt, 'string','VolC_C/VolC_F');
% xl = xlim; hold('on'); v = axis; plot(xl, polyval(P,xl), 'r--',xl, polyval(P_,xl), 'k--'); axis(v)

fid = fopen([rin.pname, filesep,'aer_cases_aods_mont_dust_dat'],'w+');
fprintf(fid,'%s \n', 'YYYY MM DD hh mm PWV[cm] VolC_C/VolC_F n_1020 n_Re_10um n_Im_10um AOD_440nm AOD_675nm AOD_870nm AOD_1020nm AOD_1700nm AOD_7692nm AOD_8333nm AOD_9091nm  AOD_10000nm AOD_11111nm AOD_12500nm');
A = aer_cases_used.data(bina,:);
NN = [rin.Refractive_Index_Real_Part(goods(ainb),4), Ref_Re_10um', Ref_Im_10um'];
A =[A, colr,NN, aer_cases_used.aod_co,aer_cases_used.aod_bm_1700', aod_bin(:,out_ij)]; 
fprintf(fid, '%d %d %d %d %d %1.2f %1.1f %1.3f %1.3f %1.2e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e \n', A');
fclose(fid)


return