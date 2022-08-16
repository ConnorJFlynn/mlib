function [ASD] = popsb1_to_ASD_ext(pops)
%[dNdlogDp] = read_pops_b1(pops)
% Reads aaf pops b1 file.  Converts raw measurements to dN and dNdlogDp
if ~isavar('pops')||~isafile(pops)
    pops = anc_bundle_files(getfullname('*aafpops*.nc','aaf_pops'));
end

SD = [pops.vdata.dn_135_150;pops.vdata.dn_150_170;pops.vdata.dn_170_195; pops.vdata.dn_195_220; pops.vdata.dn_220_260; pops.vdata.dn_260_335; pops.vdata.dn_335_510;pops.vdata.dn_510_705; pops.vdata.dn_705_1380; pops.vdata.dn_1380_1760; pops.vdata.dn_1760_2550; pops.vdata.dn_2550_3615];
bounds = [135,150,170,195,220,260,335,510, 705, 1380, 1760, 2550, 3615]';
Dp = mean([bounds(1:end-1), bounds(2:end)],2);
dlogDp = log10(bounds(2:end)./bounds(1:end-1)); % log10
dNdlogDp = SD ./ (dlogDp * ones(size(pops.time)));
tic
for t = length(pops.time):-1:1
    ok = dNdlogDp(:,t)>=0; ok(1) = false;
    if any(ok)
        retval = SizeDist_Optics(1.52, Dp(ok), dNdlogDp(ok,t), 532, 'normalized',false,'nobackscat',true);
        ext_532(t) = retval.extinction;
        retval = SizeDist_Optics(1.52, Dp(ok), dNdlogDp(ok,t), 355, 'normalized',false,'nobackscat',true);
        ext_355(t) = retval.extinction;
    end
end
toc
okk = pops.vdata.alt>0 & ext_532>0;
figure; plot(ext_355(okk),pops.vdata.alt(okk),'*',ext_532(okk),pops.vdata.alt(okk),'x');
figure; scatter(pops.time(okk), pops.vdata.alt(okk), 12, ext_532(okk)); dynamicDateTicks; 
ylabel('Altitude [m AGL]'); xlabel('time [UT]');
title({'POPS-derived extinction and flight profile';...
   [datestr(pops.time(1),'yyyy-mm-dd HH:MM-'),datestr(pops.time(end),'HH:MM')]});
cb = colorbar; set(get(cb,'title'),'string',{'B_E_x_t';'[1/Mm]'});
[pname, fname] = fileparts(pops.fname); pname = [pname, filesep];
fname = [fname, '.Ext_and_Flight'];
saveas(gcf, [pname, fname, '.png']);saveas(gcf, [pname, fname, '.fig']);
% mplext = load(getfullname(['*mplkext*',datestr(pops.time(1),'yyyymmdd'),'*.mat'],'mpl_kext'));
% 
% mplext_on_fltpath = timehtcurtain2rawpopsextfltlvl(mpl, pops);
ASD.time = pops.time;
ASD.Alt_mAGL = pops.vdata.alt;
ASD.dP = Dp;
ASD.dlogDp = dlogDp;
ASD.dNdlogDp = dNdlogDp;
ASD.ext_355 = ext_355;
ASD.ext_532 = ext_532;
end