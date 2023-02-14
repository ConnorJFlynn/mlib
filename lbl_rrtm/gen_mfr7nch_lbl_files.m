function gen_mfr7nch_lbl_files
% gen_mfr7nch_lbl_files
% 2022-11-11: regenerated TAPE12 files for mfr7nch and cimel for CO2, CH4, and H2O at
% 0.001 1/cm res.  
% So, we'll want to load them as well as the filter transmittance.
[ch4] = rd_lblrtm_tape12_od;
[co2] = rd_lblrtm_tape12_od;
[h2o_p1] = rd_lblrtm_tape12_od;[h2o_p5] = rd_lblrtm_tape12_od;[h2o_1] = rd_lblrtm_tape12_od;
[h2o_2] = rd_lblrtm_tape12_od;[h2o_4] = rd_lblrtm_tape12_od;[h2o_6] = rd_lblrtm_tape12_od;
[h2o_8] = rd_lblrtm_tape12_od;
h2o.nm = h2o_1.nm;h2o.nu = h2o_1.nu; h2o.pwv = [.1, .5, 1, 2, 4,6, 8];
h2o.od = [h2o_p1.od, h2o_p5.od, h2o_1.od, h2o_2.od, h2o_4.od, h2o_6.od, h2o_8.od];
mfr7 = anc_load(getfullname('*mfr*7nch*.nc','mfr7'));
good = mfr7.vdata.wavelength_filter7>0 & mfr7.vdata.normalized_transmittance_filter7>0;
ch7.Tr = interp1(mfr7.vdata.wavelength_filter7(good), mfr7.vdata.normalized_transmittance_filter7(good), ch4.nm,'linear');
bad = isnan(ch7.Tr); ch7.Tr(bad) = 0;
ch7.Tr = ch7.Tr ./ trapz(ch4.nu, ch7.Tr); % Normalize to area in wavenumber
ams = [1:.25:6];
for am = length(ams):-1:1;
   OD_ch4(am) = -log(trapz(ch4.nu, ch7.Tr.*exp(-ch4.od.*ams(am))))./ams(am);
   OD_co2(am) = -log(trapz(ch4.nu, ch7.Tr.*exp(-co2.od.*ams(am))))./ams(am);
   for pwv = 1:length(h2o.pwv)
      OD_H2O_pwv(am,pwv) = -log(trapz(h2o.nu, ch7.Tr.*exp(-h2o.od(:,pwv).*ams(am))))./ams(am);
   end
end

figure; plot(h2o.pwv, OD_H2O_pwv./(ones(size(ams'))*h2o.pwv),'-'); 
logy; xlabel('pwv [cm]'); ylabel('OD/pwv');
title('This shows we care only about PWV, not airmass-dependence');


figure; plot(h2o.pwv, OD_H2O_pwv,'-'); 
logy; xlabel('pwv [cm]'); ylabel('OD');
title('This shows we care only about PWV, not airmass-dependence');
% So, we pick an middling airmass like 2.5 (=pwv(7)) and fit the log(OD_H2O_pwv(7,:))
 P_h2o = polyfit(h2o.pwv,log(OD_H2O_pwv(7,:)),2)

 figure; plot(h2o.pwv, exp(polyval(P_h2o,h2o.pwv)),'r*'); logy;


P_ch4 = polyfit(ams, OD_ch4,2);
P_co2 = polyfit(ams, OD_co2,2);

figure; plot(ams, OD_ch4,'-o',ams, OD_co2,'-x')





% Interpolate the filter to the same wn scale and renormalize.

% Then for the range of airmass am = 1:.25:6 we compute the OD_eff of CH4 and CO2 as
% OD_eff = trapz(wn, Tr_filt .* exp(-OD_gas.*am)); for both CH4 and CO2
% Then fit P_OD_eff = polyfit(am, OD_eff,2); for both CH4 and CO2
% and for range of water vapor amounts pwv = 0:.25:what?  5? 7? 10?
% Then fit P_OD_pwv = polyfit(pwv,OD_h20,2);


% Next will be to load 


% preparing this function to generate LBLRTM tape5 files for CO2, CH4, and H2O
% covering both MFRSR (INTOR) and Cimel filter traces if possible.
% This is using the LNFL and LBLRTM executables compiled with MinGW in 
% 'C:\MinGW\msys\1.0\home\LBLRTM\'
% as 'C:\MinGW\msys\1.0\home\LBLRTM\lblrtm_v12.9_mingw_gnu_dbl.exe'


% Edit TAPE5s to generate one per specie at highest wavenumber, Done
%get LBL_path
b4 = pwd;
lbl_path = getpname('lbl');
if isafile('lbl_exe.mat')
    lbl_exe = load('lbl_exe.mat');
else
    lbl_exe.fname = getfullname('lbl*','lbl','Select lblrtm executable.');
    save('lbl_exe.mat','-struct','lbl_exe');
end
if ~isafile(lbl_exe.fname)
    lbl_exe.fname = getfullname('lbl*','lbl','Select lbl executable.');
    save('lbl_exe.mat','-struct','lbl_exe');
end
cd(lbl_path);
TAPE3_list = dirlist_to_filelist(dir_('TAPE3.gas256_*','TAPE3s'));% getfullname('TAPE3.gas256_*','TAPE3s');
TAPE5_list = dirlist_to_filelist(dir_('TAPE5_*29800','TAPE5s')); %getfullname('TAPE5_*29800','TAPE5s')
TAPE5_mol_pat = {'_CH4_','_CO2_','_H2O_','_O2_','_O3_'};
all_res = [.02 .01 .008 .004 .002 .001];
% Get list of TAPE3

bot_pat = '28100.00'; top_pat = '29800.00';
wn_table.str = {'_40','_55','_70','_85','_10','_11','_13','_14','_16','_17','_19','_20','_22','_23','_25','_26','_28'};
wn_table.bot_wn = [4000:1500:28000]+100; % sprintf('%8.2f',wn_table.bot_wn(1))
wn_table.top_wn = wn_table.bot_wn+1700;

for T3 = 1:length(TAPE3_list)
    copyfile(TAPE3_list{T3},[lbl_path,'TAPE3']);
    [~,fname, ext] = fileparts(TAPE3_list{T3}); ext(1:7) = [];
    wn_pat = ext(1:3);
    wn_i = find(foundstr(wn_table.str,wn_pat));
    bot_str = sprintf('%8.2f',wn_table.bot_wn(wn_i)); top_str = sprintf('%8.2f',wn_table.top_wn(1));

    for mol = 1:length(TAPE5_mol_pat)
        mol_str = TAPE5_mol_pat{mol};
        tape5_fname = getfullname(['TAPE5',mol_str,'*'],'lbl_sas');
        fid = fopen(tape5_fname,'r');
        L = 0;
        while ~feof(fid)
            L = L+1;
            tape5(L) = {fgetl(fid)};
        end
        fclose(fid);
        four = strrep(tape5{4},bot_pat, bot_str); four = strrep(four, top_pat, top_str);

        for res = 1:length(all_res) % all_res = [.02 .01 .008 .004 .002 .001]
            tape5(4) = {strrep(four,'0.01000',sprintf('%7.5f',all_res(res)))};
            fid2 = fopen([lbl_path,'TAPE5'], 'w+');
            fprintf(fid2,'%s\n',tape5{:});
            fclose(fid2);
            status = system(lbl_exe.fname);
            delete([lbl_path, 'TAPE5']);
            spc.(strrep(mol_str,'_',''))(res) = rd_lblrtm_tape12_od([lbl_path,'TAPE12.']);
            delete([lbl_path, 'TAPE12']);
        end
    end
end

cd(b4)
return
% Then run LBL for the selected TAPE5.
% Move the TAPE12 file to SAS while appending specie and WN range to end of filename
% Then read in TAPE5 using fgetl. 
% Write out a new TAPE5 replacing the WN range with a new range
% 
% LNFL TAP3 bounds  16050-17850
% LBL TAPE5 bounds  16100-17800
% 
% 29800-28100
% 28300-26600
% 26800-25100
% 25300-23600
% 23800-22100
% 22300-20600
% 20800-19100
% 19300-17600
% 17800-16100
% 16300-14600
% 14800-13100
% 13300-11600
% 11800-10100
% 10300-9600
% 8800-7100
% 7300-6600
% 5800-4100
