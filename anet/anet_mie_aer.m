function anet_mie_aer
% Connor, 2022-03-07, off-shoot of anet_mie to text extension to 10 um for Eli Mlawer AER
% This code tests my mods of Feng Xu's Mie_AERONET in ==>> anet_mie
% which permit use of aeronet intensive property retrievals V3 for 
% refractive index (*.rin) and ASD as either PSD in dVdlnr in (*.size)
% or as log-normal modes in (*.vol)
% Compares Mie-computed AOD against aeronet aod, cad

% Reproduce Aeronet SD from Aeronet lognormal
% Getting close but still have scale factor issue and probably error
% reconstructiong the lognormal PSD from the parameters

% rm=[0.050000,0.065604,0.086077,0.112939,0.148184,0.194429,0.255105,0.334716,0.439173,0.576227,0.756052,0.991996,1.301571,1.707757,2.240702,2.939966,3.857452,5.061260,6.640745,8.713145,11.432287,15.000000];
% dVdlnr = [0.000321,0.002708,0.010422,0.018989,0.018266,0.011193,0.005670,0.003155,0.002377,0.002548,0.003535,0.005525,0.008811,0.013720,0.020467,0.028187,0.032764,0.028586,0.017028,0.006553,0.001587,0.000240];
% dVdlnr= [0.000799	0.000783	0.001214	0.00283	0.008527	0.025265	0.052488	0.056106	0.03332	0.017428	0.011672	0.010808	0.012044	0.01447	0.017286	0.018461	0.017036	0.013154	0.008418	0.004531	0.002083	0.000823];

%specifying a larger/different WL range compared to aeronet provides the
%ability to extend AOD from their specific wavelengths. 

% eaod = rd_anetaip_v3;
rin = rd_anet_rin_v3(getfullname('*.rin','anet_aipv3','Select anet .rin file.'));
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

wl = [rin.lambda];

good = all(rin.Refractive_Index_Real_Part>0,2)&all(rin.Refractive_Index_Imaginary_Part>0,2); 
goods = find(good);

[ainb, bina] = nearest(siz.time(goods), aer_cases_used.time,1./24); size(ainb)% Within 1 hr of each other
aer_cases_used.bina = bina;

wl = [325:25:1050 1100:100:1900 2000:250:4250 4500:500:10000];
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
    Ref_Ind_real = [rin.Refractive_Index_Real_Part(goods(ai),:),2]; % Fe2O3 iron-oxide dust
    Ref_Ind_imag = [rin.Refractive_Index_Imaginary_Part(goods(ai),:),0.02];% Fe2O3 iron-oxide dust
    Ref_Ind_real = [rin.Refractive_Index_Real_Part(goods(ai),:),1.2]; % water
    Ref_Ind_imag = [rin.Refractive_Index_Imaginary_Part(goods(ai),:),0.05];% water

    n_i = Ref_Ind_real+j.*Ref_Ind_imag;
    ni = interp1(lambda, n_i, wl, 'linear','extrap');

    % Construct multi-modal lognormal PSD for plotting
    dVdlnr = vol.VolC_F(goods(ai)).*LnNormal(bin_rad, vol.VMR_F(goods(ai)), exp(vol.Std_F(goods(ai))))+...
        vol.VolC_C(goods(ai)).*LnNormal(bin_rad, vol.VMR_C(goods(ai)), exp(vol.Std_C(goods(ai))));
    % Construct M1 M1 mode structs for passing to anet_mie
    M1.VolC = vol.VolC_F(goods(ai)); M1.vmr = vol.VMR_F(goods(ai)); M1.std = vol.Std_F(goods(ai));
    M2.VolC = vol.VolC_C(goods(ai)); M2.vmr = vol.VMR_C(goods(ai)); M2.std = vol.Std_C(goods(ai));

       sb(1) =subplot(1,2,1);  hold('off');
    plot(siz.bin_radius, siz.dV_dlnr(goods(ai),:),'k-o',bin_rad, dVdlnr,'r-'); xlabel('radius [um]'); ylabel('dV/dlnr'); logx
    %% 
    title(['ASD dV/dlnr bins ',datestr(siz.time(goods(ai)),'yyyy-mm-dd HH:MM')]); legend('PSD bins','SM params','Location','NorthWest')
    hold('on'); set(sb(1),'pos',[ 0.0859    0.1145    0.3956    0.8105]);
    pause(.2)
    % Bi-modal structs
    tic; aod_bm = anet_mie(wl,ni, bin_rad, M1, M2); toc
    aer_cases_used.aod_bm_1700(ij) = aod_bm(wl_1700_ij);
    aer_cases_used.aod_bm_10um(ij) = aod_bm(end);

    % lognormal composed from bi-modal parameters
%     tic;  [aod_lg, ssa_lg] = anet_mie(wl,ni, bin_rad, dVdlnr); toc
    % lognormal PSD bin-wise
    tic; [aod_bin, ssa] = anet_mie(wl,ni, siz.bin_radius, siz.dV_dlnr(goods(ai),:)); toc

   aod_bm; aod_bin; aod_co;
   sb(2) = subplot(1,2,2); hold('on');
   plot(lambda(1:end-1), aod_co,'ro',wl, aod_bin, '-b',wl, aod_bm,'kx'); logy; logx;
   legend('AOD Coi','AOD PSD','AOD BiMod')
   xlabel('wavelength [nm]');ylabel('Optical depth [unitless]');
   hold('on');set(sb(2),'pos',[0.5703    0.1100    0.3805    0.8150]);hold('off')
   title(['AOD from .cad and Mie:',datestr(siz.time(goods(ai)),'yyyy-mm-dd HH:MM')]);
   pause(.1)
end
fid = fopen([rin.pname, filesep,'aer_cases_aods_humid.dat'],'w+');
fprintf(fid,'%s \n', 'YYYY MM DD hh mm PWV[cm] AOD_440nm AOD_675nm AOD_870nm AOD_1020nm AOD_1700nm AOD_10000nm');
A = aer_cases_used.data(bina,:);
A =[A, aer_cases_used.aod_co,aer_cases_used.aod_bm_1700', aer_cases_used.aod_bm_10um']; 
fprintf(fid, '%d %d %d %d %d %1.2f %1.4f %1.4f %1.4f %1.4f %1.4f %1.4f \n', A');
fclose(fid)


return