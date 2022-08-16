function ASD = popsb1_to_dNdlogDp(pops)
%[dNdlogDp] = read_pops_b1(pops)
% Reads aaf pops b1 file.  Converts raw measurements to dN and dNdlogDp
if ~isavar('pops')||~isafile(pops)
    pops = anc_bundle_files(getfullname('*aafpops*.nc','aaf_pops'));
end
% load Dn from netcdf file
% concatenate into a single field "SD"
SD = [pops.vdata.dn_135_150;pops.vdata.dn_150_170;pops.vdata.dn_170_195; ...
    pops.vdata.dn_195_220; pops.vdata.dn_220_260; pops.vdata.dn_260_335; ...
    pops.vdata.dn_335_510;pops.vdata.dn_510_705; pops.vdata.dn_705_1380; ...
    pops.vdata.dn_1380_1760; pops.vdata.dn_1760_2550; pops.vdata.dn_2550_3615];
% Specify the bounds as the end-points of the dn fields in the netcdf file
bounds = [135,150,170,195,220,260,335,510, 705, 1380, 1760, 2550, 3615]';
% Compute Dp (I've tried both an arithmetic mean and a geometric mean (below)
Dp = gmean([bounds(1:end-1), bounds(2:end)]')';
% Compute dlogDp, log base 10
dlogDp = log10(bounds(2:end)./bounds(1:end-1)); % log10 is correct
% SD is in concentration, divide by dlogDp to get dNdlogDp
dNdlogDp = SD ./ (dlogDp * ones(size(pops.time)));
tic
fan = load(['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\AAF\2021_Nov\sgpaafpopsext.01\20211109_SN09.mat']);
fan = fan.MSave;

[binf, finb] = nearest(pops.time, fan.tnum);
figure; plot(fan.Dp, fan.SD(finb(6000),:),'r-o',Dp, 10.*dNdlogDp(:,binf(6000)),'kx-'); logy; legend('from Fan Mei','10 x from aafpops.b1')


for t = length(pops.time):-1:1
    ok = dNdlogDp(:,t)>=0; ok(1) = false;
    dNdlogDp(~ok,t) = 0; ok = dNdlogDp(:,t)>=0;
    if any(ok)
        % Test WL dependence
%         wl = 300:10:800;
%         for w = 1:length(wl)
%             retval = SizeDist_Optics_TB_CF(1.52+.01i, Dp(ok), dNdlogDp(ok,t), wl(w), 'normalized',false,'nobackscat',true);
%             ext(w) = retval.extinction;
%             Boptics=BH_Mie_SizeDist_FM_CF(wl(w), Dp,dNdlogDp(:,t), dlogDp,1.52,.01);
%             ext_FM(w) = Boptics(1);
%         end
%         figure; plot(wl, ext,'-',wl,ext_FM,'r-'); ylabel('ext [1/Mm]'); xlabel('wl [nm]'); legend('TB','FM');
        % Decent but not perfect.  Don't know why yet.  Close enough for now.
        retval = SizeDist_Optics_TB_CF(1.52+.01i, Dp(ok), dNdlogDp(ok,t), 532, 'normalized',false,'nobackscat',true);
        Boptics=BH_Mie_SizeDist_FM_CF(532, Dp,dNdlogDp(:,t), dlogDp,1.52,.01); 
        ext_532_FM_CF(t) = Boptics(1);
        ext_532_by_Mm(t) = retval.extinction;
        retval = SizeDist_Optics(1.52+.01i, Dp(ok), dNdlogDp(ok,t),355, 'normalized',true,'nobackscat',true);
        ext_355_by_Mm(t) = retval.extinction;
        Boptics=BH_Mie_SizeDist_FM_CF(355, Dp,dNdlogDp(:,t), dlogDp,1.52,.01);
        ext_355_FM_CF(t) = Boptics(1);
    end
%     t
end
toc
okk = pops.vdata.alt>0 & ext_532_by_Mm>0;
figure; plot(ext_532_by_Mm(okk),pops.vdata.alt(okk),'c*',ext_532_FM_CF(okk), pops.vdata.alt(okk), 'k.');
xlabel('extinction [1/Mm]'); ylabel('Altitude [m AGL]');
title({'POPS-derived extinction 532 nm';...
   [datestr(pops.time(1),'yyyy-mm-dd HH:MM-'),datestr(pops.time(end),'HH:MM')]});
figure; scatter(pops.time(okk), pops.vdata.alt(okk), 12, (ext_532_by_Mm(okk)./1000)); dynamicDateTicks; 
ylabel('Altitude [m AGL]'); xlabel('time [UT]');
title({'POPS-derived extinction and flight profile';...
   [datestr(pops.time(1),'yyyy-mm-dd HH:MM-'),datestr(pops.time(end),'HH:MM')]});
cb = colorbar; set(get(cb,'title'),'string',{'B_E_x_t';'[1/km]'});
[pname, fname] = fileparts(pops.fname); pname = [pname, filesep];
fname = [fname, '.Ext_and_Flight'];
saveas(gcf, [pname, fname, '.png']);saveas(gcf, [pname, fname, '.fig']);
% mplext = load(getfullname(['*mplkext*',datestr(pops.time(1),'yyyymmdd'),'*.mat'],'mpl_kext'))
% mplext_on_fltpath = timehtcurtain2rawpopsextfltlvl(mpl, pops);
ASD.time = pops.time;
ASD.Dp = Dp;
ASD.dlogDp = dlogDp;
ASD.dNdlogDp = dNdlogDp;
ASD.ext_532_by_Mm = ext_532_by_Mm;
ASD.ext_355_by_Mm = ext_355_by_Mm;
ASD.ext_532_FM = ext_532_FM_CF;
ASD.ext_355_FM = ext_355_FM_CF;

end