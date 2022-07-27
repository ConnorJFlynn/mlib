function [dNdlogDp,Dp, pops,dlogDp] = popsb1_to_dNdlogDp(pops)
%[dNdlogDp] = read_pops_b1(pops)
% Reads aaf pops b1 file.  Converts raw measurements to dN and dNdlogDp
if ~isavar('pops')||~isafile(pops)
    pops = anc_bundle_files(getfullname('*aafpops*.nc','aaf_pops'));
end

SD = [pops.vdata.dn_135_150;pops.vdata.dn_150_170;pops.vdata.dn_170_195; pops.vdata.dn_195_220; pops.vdata.dn_220_260; pops.vdata.dn_260_335; pops.vdata.dn_335_510;pops.vdata.dn_510_705; pops.vdata.dn_705_1380; pops.vdata.dn_1380_1760; pops.vdata.dn_1760_2550; pops.vdata.dn_2550_3615];
bounds = [135,150,170,195,220,260,335,510, 705, 1380, 1760, 2550, 3615]';
Dp = mean([bounds(1:end-1), bounds(2:end)],2);
dlogDp = log10(bounds(2:end)./bounds(1:end-1)); % Not sure if supposed to be log10 or ln
dNdlogDp = SD ./ (dlogDp * ones(size(pops.time)));

for t = length(pops.time):-1:1
    ok = dNdlogDp(:,t)>=0; ok(1) = false;
    if any(ok)
        retval = SizeDist_Optics(1.52, Dp(ok), dNdlogDp(ok,t), 532, 'normalized',false,'nobackscat',true);
        ext(t) = retval.extinction;
    end
    t
end
okk = pops.vdata.alt>0 & ext>0;
figure; plot(ext(okk),pops.vdata.alt(okk),'c*');
figure; scatter(pops.time(okk), pops.vdata.alt(okk), 12, ext(okk)); dynamicDateTicks; 
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

end