% Match beginning and ending of Fan's extinction mat file data to
% corresponding indices from the raw file.

% Identify a good time to examine by looking at the profile in tandem with
% the MPL curtain. Then examine ext at both 532 and 355, comparing Fan's
% results which look correct to mine which do not.  Try converting mine
% from dNdlogDp to dVlogDp, should be a factor of pi/6 D^3 between?  See
% how the profile looks compared to Aeronet SDs which are in dVlogR?

[finb, binf] = nearest(fan.tnum,popsb1.time);
[fine, einf]= nearest(fan.tnum, pops532ext.time);
[einb,bine] = nearest(pops532ext.time,popsb1.time);

figure; scatter(pops532ext.time(einb)  , pops532ext.alt_mAGL(einb),16,pops532ext.ext_um(einb)); zoom('on'); colorbar; dynamicDateTicks;

figure; scatter([1:length(pops532ext.time(einb))]  , pops532ext.alt_mAGL(einb),16,pops532ext.ext_um(einb)); zoom('on'); colorbar; 

SD = [popsb1.vdata.dn_135_150;popsb1.vdata.dn_150_170;popsb1.vdata.dn_170_195; popsb1.vdata.dn_195_220; popsb1.vdata.dn_220_260;...
    popsb1.vdata.dn_260_335; popsb1.vdata.dn_335_510;popsb1.vdata.dn_510_705; popsb1.vdata.dn_705_1380; popsb1.vdata.dn_1380_1760;...
    popsb1.vdata.dn_1760_2550; popsb1.vdata.dn_2550_3615];
bounds = [135,150,170,195,220,260,335,510, 705, 1380, 1760, 2550, 3615]';
Dp = mean([bounds(1:end-1), bounds(2:end)],2);
dlogDp = [log(Dp(3)./Dp(1))./2; log(Dp(2:end)./Dp(1:end-1))];
% Examine the 630th record of einb: record 3817 of pops532ext, record 630
% of popsb1. 
SDi = SD(:,630);
% and we identify the corresponding time and SD from Fan, by time I guess.
% First confirm that popsb1.time(630) == pops532ext.time(3817); Yes.
% Now, find corresponding record in Fan.
fan_t = interp1(fan.tnum, [1:length(fan.tnum)], popsb1.time(630),'nearest'); % fan_t = 7094

figure; plot(Dp, SDi, '-o', Dp, fan.nn(fan_t,:)./8, '-x', fan.Dp, fan.SD(fan_t,:)./120,'k-'); logy;

figure; plot(Dp, SDi.*Dp.^3, '-o', Dp, (fan.nn(fan_t,:))'.*Dp.^3./8, '-x', fan.Dp, fan.SD(fan_t,:)'.*fan.Dp.^3./120,'k-'); logy; ylabel('dV'); xlabel('Dp')

%So, a cunundrum.  The Bond code seems to work properly for log normals in
%that the wavelength dependence is as expected, but when provided SD from
%POPS it does not generate expected WL dependence, but Fan's Mie code does.
% I am going to try to generate an explicit log-normal SD, confirm
% behaviour of Bond is same as for parameterized log-normal, and then feed
% to Fan Mie.

% This section for computing wavelength dependence of Ext using fan 100-bin SD, and Dp values.
for t = fan_t
    dNdlogDp = fan.MC(:,28:end)'./(ones([13056,1])*Dp100)';
    ok = dNdlogDp(:,t)>=0; ok(1) = false;
    dNdlogDp(~ok,t) = 0; ok = dNdlogDp(:,t)>=0;
    if any(ok)
        wl = 355;
        for w = 1:length(wl)
            Boptics=BH_Mie_SizeDist(wl(w),fan.Dp,dNdlogDp(:,t),fan.dlogDp,1.52,.001);
            ext_BH(w) = Boptics(1);
            retval = SizeDist_Optics(1.52+.001i, fan.Dp, dNdlogDp(:,t), wl(w), 'normalized',false,'nobackscat',true);
%             retval = SizeDist_Optics(1.52, 200, 1.25, wl(w), 'normalized',false,'nobackscat',true);
            ext(w) = retval.extinction;
        end
        figure; plot(wl, ext,'r-'); ylabel('ext'); xlabel('wl [nm]')
        figure; plot(wl, ext_BH,'k-'); ylabel('ext'); xlabel('wl [nm]')
        ext532_by_Mm(t) = retval.extinction;
        retval = SizeDist_Optics(1.52, Dp(ok), dNdlogDp(ok,t),355, 'normalized',true,'nobackscat',true);
        ext355_by_Mm(t) = retval.extinction;
    end
    t
end
wl = 300:10:800;
for wi = length(wl):-1:1
retval = SizeDist_Optics(mp, x_range, df, wl(wi), 'normalized',false,'nobackscat',true)
ext_sd(wi) = retval.extinction;
end
figure; plot(wl, ext_sd,'r-x'); legend('ext SD')


% OK, hae reproduced wl trend for BH_Mie_SizeDist_FM and SizeDist_Optics
% but not the absolute scale.  Noticed potential inconsistencies with
% respect to D / R and a factor of pi. Will now try to run both of these
% with a single wavelength and SD derived from a logNormal and track them both to the Mie
% function which they share.  Start by defining the SD in terms of
% LogNormal parameters following the example within SizeDist_Optics
gsd = 1.25;
cmd = 200; % 200 nm count-mean-diameter

   dlogd = log10(gsd)*.25;     % minimum 12 points across range;                                                  
   limit=floor(4*log(gsd)/dlogd)*dlogd;  % integral number to cover 3.5x gsd
   dx = (-limit:dlogd:limit);               
   x_range = cmd * 10.^(dx);                % Log-spaced diameters

   df = LogNormal(x_range, cmd, gsd);  % frequencies for each diameter
   dlogDp = ones(size(x_range)).*dlogd;

   retval = SizeDist_Optics(1.5+.01i, x_range, df, 355, 'normalized', false, 'nobackscat', true); %extinction: 0.0387
  Boptics=BH_Mie_SizeDist_FM(355,x_range',df',dlogDp',1.5,.01)



%  % Mie call in SizeDist_Optics:
%  xval = pi * mr*x_range(i)/lambda;
%  yval = pi * mr*y_range(i)/lambda;
%  one_result = Mie(mp/mr, pi * mr*x_range(i)/lambda);

% Mie call in BH_Mie_SizeDist_FM
%  ==> BH_Mie_FM(wvl,Dp(i)/2,RIreal,RIimag,0);  (Passing radius in...)
%  ==> result(i,:)=Mie(complex(RIreal,RIimag),Dp(i)/2/wvl);
%      result(i,:)=Mie(complex(RIreal,RIimag),pi.*Dp(i)/2/wvl); %pi * mr*x_range(i)/lambda;