lbl_tape5_path = ['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\AER_LNFL_LBLRTM\LBLRTM_tape5_files\res_tests\'];
figure;
fname = 'TAPE5.co2_p0005';
[~,tag,co2_p0005] = call_lbl([lbl_tape5_path, fname]);
co2_p0005nm = 1e7./co2_p0005.nu;
plot(co2_p0005.nm, co2_p0005.od,'-'); title('CO_2'); logy; hold('on');
lg_str = {tag};
pause(.5)
fname = 'TAPE5.ch4_p0005';
[~,tag,ch4_p0005] = call_lbl([lbl_tape5_path, fname]);
plot(ch4_p0005.nm, ch4_p0005.od,'-'); title('CH_4'); logy; hold('on');
lg_str = {tag};
pause(.5)
fname = 'TAPE5.h2o_p0005';
[~,tag,h2o_p0005] = call_lbl([lbl_tape5_path, fname]);
plot(h2o_p0005.nm, h2o_p0005.od,'-'); title('H_2O'); logy; hold('on');
lg_str = {tag};
pause(.5)

figure; plot(spc_p0005.nm,spc_p0005.od,'k-')


cim_filt =  load(getfullname('cim*.mat','cim_filt','Select cimel filter mat file'));
mfr_filt = load(getfullname('intor*.mat','mfr_filt','Select mfrsr filter batch mat file'));
cim_5 = interp1(cim_filt.nm, cim_filt.Tr, co2_p0005.nm, 'nearest'); cim_5(isnan(cim_5)) = 0;
cim_6 = interp1(cim_filt.nm, cim_filt.Tr, h2o_p0005.nm, 'nearest'); cim_6(isnan(cim_6)) = 0;
mfr_5 = interp1(mfr_filt.nm, mfr_filt.filts(:,1), co2_p0005.nm, 'nearest'); mfr_5(isnan(mfr_5))= 0;
mfr_6 = interp1(mfr_filt.nm, mfr_filt.filts(:,1), h2o_p0005.nm, 'nearest'); mfr_6(isnan(mfr_6))= 0;
cim_5 = -cim_5 ./ trapz(co2_p0005.nm, cim_5);
mfr_5 = -mfr_5 ./ trapz(co2_p0005.nm, mfr_5);
cim_6 = -cim_6 ./ trapz(h2o_p0005.nm, cim_6);
mfr_6 = -mfr_6 ./ trapz(h2o_p0005.nm, mfr_6);

figure; plot(cim_filt.nm, cim_filt.Tr,'-', h2o_p0005.nm, h2o_p0005.od,'-',h2o_p0005.nm, cim_6,'k-'); logy

C1 = trapz(spc_2pow20.nm, spc_2pow20.cim_filt);
M1 = trapz(mfr_filt.nm, mfr_filt.filts(:,1));
plot(spc_2pow20.nm, spc_2pow20.cim_filt./C1,'-', mfr_filt.nm, mfr_filt.filts(:,1)./M1,'-' );
legend('CO_2','CH_4','H_2O','Cimel','MFRSR')
liny; ylim([.0001 ,12]); xlim([1605,1655])
title('Transmittance Spectra of Gases and Filter Envelopes near 1.6 microns');
xlabel('wavelength [nm]')
ylabel('Tr [unitless]')
m_air = 1;
figure; plot(co2_p0005.nm, cim_5.*exp(-co2_p0005.od.*m_air),'-',ch4_p0005.nm, cim_5.*exp(-ch4_p0005.od.*m_air),'-', h2o_p0005.nm, cim_6.*exp(-h2o_p0005.od.*m_air),'-'); hold('on');logy
legend('CO_2','CH_4','H_2O')
figure; plot(co2_p0005.nm, mfr_5.*exp(-co2_p0005.od.*m_air),'-',ch4_p0005.nm, mfr_5.*exp(-ch4_p0005.od.*m_air),'-', h2o_p0005.nm, mfr_6.*exp(-h2o_p0005.od.*m_air),'-'); hold('on');logy
figure; plot(mfr_filt.nm, mfr_filt.filts(:,1)./trapz(mfr_filt.nm, mfr_filt.filts(:,1)), '-k', cim_filt.nm, cim_filt.Tr./trapz(cim_filt.nm, cim_filt.Tr), 'k-')

% I don't understand the saw-tooth I'm getting while deconvolving.  
% I've tried convolving the full length (setting middle portion to zero). 
% I've tried setting the mid portion to the mean.  
% only thing that seems to help is a sliding average of width 2.

spc_2pow20.nu = linspace(spc_p0005.nu(1),spc_p0005.nu(end),2.^20);
spc_2pow20.nm = 1e7./spc_2pow20.nu;
spc_2pow20.od = interp1(spc_p0005.nu,spc_p0005.od, spc_2pow20.nu,'linear','extrap');
spc_2pow20.cim_filt = interp1(cim_filt.nm, cim_filt.Tr,spc_2pow20.nm,'linear');
spc_2pow20.cim_filt(isnan(spc_2pow20.cim_filt)) = 0;
spc_2pow20.cim_filt = spc_2pow20.cim_filt ./ trapz(spc_2pow20.nu, spc_2pow20.cim_filt);

% figure; plot(spc_2pow20.nm, spc_2pow20.od, '-',spc_2pow20.nm, 100.*spc_2pow20.cim_filt,'-', mfr_filt.nm, 100.*mfr_filt.filts(:,1)./6.4,'-' );

hod_p0005=[];hod_p001=[];hod_p002=[];hod_p004=[];hod_p008=[];hod_p016=[];hod_p032=[];hod_p064=[];hod_p128=[];hod_p256=[];hod_p512=[];
std_p0005=[];std_p001=[];std_p002=[];std_p004=[];std_p008=[];std_p016=[];std_p032=[];std_p064=[];std_p128=[];std_p256=[];std_p512=[];

for am = 1:.5:10;
od_p0005 = trapz((spc_2pow20.nu), spc_2pow20.od.*spc_2pow20.cim_filt);
Tr_p0005 = spc_2pow20.cim_filt .* exp(-spc_2pow20.od.*am);
std_p0005(end+1) = std(Tr_p0005(Tr_p0005>0));
hod_p0005(end+1) = -log(trapz(spc_2pow20.nu, Tr_p0005))./am;
top = trapz(spc_2pow20.nu, spc_2pow20.od);

dv = .001;
[p001,sig] = gaussian(spc_2pow20.nu,spc_2pow20.nu(1),dv);
c001 = ifft(fft(spc_2pow20.od).*fft(p001));
bot = trapz(spc_2pow20.nu, c001);
Tr_p001 = spc_2pow20.cim_filt .* exp(-(c001.*top./bot).*am);
hod_p001(end+1) = -log(trapz(spc_2pow20.nu, Tr_p001))./am;
std_p001(end+1) = std(Tr_p001(Tr_p001>0));
mn = mean(Tr_p001(Tr_p001>0))
% figure; plot(spc_p0005.nu, spc_p0005.od, '-o',spc_2pow20.nu, spc_2pow20.od, 'x',spc_2pow20.nu-dv./4, c001.*top./bot,'-');logy; axis(v)


dv = .002;
[p002,sig] = gaussian(spc_2pow20.nu,spc_2pow20.nu(1),dv);
c002 = ifft(fft(spc_2pow20.od).*fft(p002));
bot = trapz(spc_2pow20.nu, c002);
Tr_p002 = spc_2pow20.cim_filt .* exp(-(c002.*top./bot).*am);
hod_p002(end+1) = -log(trapz(spc_2pow20.nu, Tr_p002))./am;
std_p002(end+1) = std(Tr_p002(Tr_p002>0));

dv = .004;
[p004,sig] = gaussian(spc_2pow20.nu,spc_2pow20.nu(1),dv);
c004 = ifft(fft(spc_2pow20.od).*fft(p004));
bot = trapz(spc_2pow20.nu, c004);
Tr_p004 = spc_2pow20.cim_filt .* exp(-(c004.*top./bot).*am);
hod_p004(end+1) = -log(trapz(spc_2pow20.nu, Tr_p004))./am;
std_p004(end+1) = std(Tr_p004(Tr_p004>0));

dv = .008;
[p008,sig] = gaussian(spc_2pow20.nu,spc_2pow20.nu(1),dv);
c008 = ifft(fft(spc_2pow20.od).*fft(p008));
bot = trapz(spc_2pow20.nu, c008);
Tr_p008 = spc_2pow20.cim_filt .* exp(-(c008.*top./bot).*am);
hod_p008(end+1) = -log(trapz(spc_2pow20.nu, Tr_p008))./am;
std_p008(end+1) = std(Tr_p008(Tr_p008>0));

dv = .016;
[p016,sig] = gaussian(spc_2pow20.nu,spc_2pow20.nu(1),dv);
c016 = ifft(fft(spc_2pow20.od).*fft(p016));
bot = trapz(spc_2pow20.nu, c016);
Tr_p016 = spc_2pow20.cim_filt .* exp(-(c016.*top./bot).*am);
hod_p016(end+1) = -log(trapz(spc_2pow20.nu, Tr_p016))./am;
std_p016(end+1) = std(Tr_p016(Tr_p016>0));

dv = .032;
[p032,sig] = gaussian(spc_2pow20.nu,spc_2pow20.nu(1),dv);
c032 = ifft(fft(spc_2pow20.od).*fft(p032));
bot = trapz(spc_2pow20.nu, c032);
Tr_p032 = spc_2pow20.cim_filt .* exp(-(c032.*top./bot).*am);
hod_p032(end+1) = -log(trapz(spc_2pow20.nu, Tr_p032))./am;
std_p032(end+1) = std(Tr_p032(Tr_p032>0));

dv = .064;
[p064,sig] = gaussian(spc_2pow20.nu,spc_2pow20.nu(1),dv);
c064 = ifft(fft(spc_2pow20.od).*fft(p064));
bot = trapz(spc_2pow20.nu, c064);
Tr_p064 = spc_2pow20.cim_filt .* exp(-(c064.*top./bot).*am);
hod_p064(end+1) = -log(trapz(spc_2pow20.nu, Tr_p064))./am;
std_p064(end+1) = std(Tr_p064(Tr_p064>0));

dv = .128;
[p128,sig] = gaussian(spc_2pow20.nu,spc_2pow20.nu(1),dv);
c128 = ifft(fft(spc_2pow20.od).*fft(p128));
bot = trapz(spc_2pow20.nu, c128);
Tr_p128 = spc_2pow20.cim_filt .* exp(-(c128.*top./bot).*am);
hod_p128(end+1) = -log(trapz(spc_2pow20.nu, Tr_p128))./am;
std_p128(end+1) = std(Tr_p128(Tr_p128>0));

dv = .256;
[p256,sig] = gaussian(spc_2pow20.nu,spc_2pow20.nu(1),dv);
c256 = ifft(fft(spc_2pow20.od).*fft(p256));
bot = trapz(spc_2pow20.nu, c256);
Tr_p256 = spc_2pow20.cim_filt .* exp(-(c256.*top./bot).*am);
hod_p256(end+1) = -log(trapz(spc_2pow20.nu, Tr_p256))./am;
std_p256(end+1) = std(Tr_p256(Tr_p256>0));

dv = .512;
[p512,sig] = gaussian(spc_2pow20.nu,spc_2pow20.nu(1),dv);
c512 = ifft(fft(spc_2pow20.od).*fft(p512));
bot = trapz(spc_2pow20.nu, c512);
Tr_p512 = spc_2pow20.cim_filt .* exp(-(c512.*top./bot).*am);
hod_p512(end+1) = -log(trapz(spc_2pow20.nu, Tr_p512))./am;
std_p512(end+1) = std(Tr_p512(Tr_p512>0));

end
figure; plot(spc_2pow20.nm, [spc_2pow20.od;c001;c002;c004;c008;c016;c032;c064;c128;c256;c512],'-');


% , '-',spc_2pow20.nu, spc_2pow20.od, 'x',spc_2pow20.nu-dv./4, c001.*top./bot,'-');logy; axis(v)

stds = [std_p0005; std_p001; std_p002; std_p004; std_p008; std_p016; std_p032; std_p064; std_p128; std_p256; std_p512]; 
hods = [hod_p0005; hod_p001; hod_p002; hod_p004; hod_p008; hod_p016; hod_p032; hod_p064; hod_p128; hod_p256; hod_p512];
std_am1 = stds(:,1);std_am1p5 = stds(:,2);std_am2 = stds(:,3);std_am2p5 = stds(:,4);
std_am3 = stds(:,5);std_am3p5 = stds(:,6);std_am4 = stds(:,7);std_am4p5 = stds(:,8);
std_am5 = stds(:,9);std_am5p5 = stds(:,10);std_am6 = stds(:,11);std_am6p5 = stds(:,12);
std_am7 = stds(:,13);std_am7p5 = stds(:,14);std_am8 = stds(:,15);std_am8p5 = stds(:,16);
std_am9 = stds(:,17);std_am9p5 = stds(:,18);std_am10 = stds(:,19);
hod_am1 = hods(:,1);hod_am1p5 = hods(:,2);hod_am2 = hods(:,3);hod_am2p5 = hods(:,4);
hod_am3 = hods(:,5);hod_am3p5 = hods(:,6);hod_am4 = hods(:,7);hod_am4p5 = hods(:,8);
hod_am5 = hods(:,9);hod_am5p5 = hods(:,10);hod_am6 = hods(:,11);hod_am6p5 = hods(:,12);
hod_am7 = hods(:,13);hod_am7p5 = hods(:,14);hod_am8 = hods(:,15);hod_am8p5 = hods(:,16);
hod_am9 = hods(:,17);hod_am9p5 = hods(:,18);hod_am10 = hods(:,19);

ams = [1:.5:10]; res = [.0005, .001, .002, .004, .008, .016, .032, .064,.128, .256, .512];

%restrict to airmass 1-6 for clarity, relevance. 
figure; imagesc(ams(1:12), log2(1000.*res(2:end)), hods(2:end,1:12)); axis('xy'); liny
xlabel('airmass'); ylabel('(<<--finer) resol. (coarser-->)') ;yticks([]);
title('Gas OD depends on resolution and airmass')
cb = colorbar; 
set(get(cb,'title'),'position',[8,-20,0])
set(get(cb,'title'),'string','(OD)')
figure; 
% these = plot(fliplr((stds(2:end,1)*ones([1,12]))'-stds(2:end,1:12)'),fliplr(hods(2:end,1:12)'-(hods(2:end,1)*ones([1,12]))'), '-o'); 
% these = plot(fliplr((stds(2:end,1)*ones([1,12]))'-stds(2:end,1:12)'),fliplr(hods(2:end,1:12)'-(hods(2:end,1)*zeros([1,12]))'), '-o'); 
these = plot(((stds(2:end,1)*ones([1,12]))'-stds(2:end,1:12)'),(hods(2:end,1:12)'-(hods(2:end,1)*zeros([1,12]))'), '-o'); 
recolor((these), log2(1000.*res(2:end)));
xlabel('stddev relative to AM = 1'); ylabel('gas optical depth ')
lg = legend('.512 cm^-^1','.256 cm^-^1','.128 cm^-^1','.064 cm^-^1','.032 cm^-^1','.016 cm^-^1','.008 cm^-^1','.004 cm^-^1','.002 cm^-^1','.001 cm^-^1');
lg = legend('1.6e-4 nm','3.2e-4 nm','6.4e-4 nm','1.2e-3 nm','2.5e-3 nm','5e-3 nm','1e-2 nm','2e-2 nm','4e-2 nm','8e-2 nm');
title('... due to their effect on STD DEV')

figure; thees = plot(spc_2pow20.nm, ([Tr_p0005;Tr_p001;Tr_p002;Tr_p004;Tr_p008;Tr_p016;Tr_p032;Tr_p064;Tr_p128;Tr_p256;Tr_p512]),'-');
recolor(flipud(thees), log2(1000.*res))
lg = legend('8e-2 nm','4e-2 nm','2e-2 nm','1e-2 nm','5e-3 nm','2.5e-3 nm','1.2e-3 nm','6.4e-4 nm','3.2e-4 nm','1.6e-4 nm');

figure; thees = plot(...
spc_2pow20.nm+2e-2, Tr_p512,'-',...
    spc_2pow20.nm+1e-2, Tr_p256,'-',...
    spc_2pow20.nm+5e-3, Tr_p128,'-',...
    spc_2pow20.nm+2.5e-3, Tr_p064,'-',...
    spc_2pow20.nm+1.25e-3, Tr_p032,'-',...
    spc_2pow20.nm, Tr_p016,'-',...
    spc_2pow20.nm, Tr_p008,'-',...
    spc_2pow20.nm, Tr_p004,'-',...
    spc_2pow20.nm, Tr_p002,'-',...
    spc_2pow20.nm, Tr_p001,'-',...
    spc_2pow20.nm, Tr_p0005,'-');
axis(vv)
recolor(flipud(thees), (log2(1000.*res)))
lg = legend('8e-2 nm','4e-2 nm','2e-2 nm','1e-2 nm','5e-3 nm','2.5e-3 nm','1.2e-3 nm','6.4e-4 nm','3.2e-4 nm','1.6e-4 nm','8e-5 nm');

figure; 
subplot(1,2,1); plot(-diff(stds)./mn, diff(hods),'-x'); 
xlabel('std(Tr_1(wn))) - std(Tr_2(wn)))','interp','tex'); ylabel('god_2(wn) - god_1(wn)','interp','tex');
subplot(1,2,2); plot(-diff(stds)./mn, diff(hods),'-x'); 
xlabel('std(Tr_1(wn))) - std(Tr_2(wn)))','interp','tex'); ylabel('god_2(wn) - god_1(wn)','interp','tex'); logy; logx;

% Play with this figure to get resolution on the horizontal axis.
%%
% This section is for AM = 1:.5:6 at 0.0005 1/cm resolution
am = 1;
od_p0005 = trapz((spc_2pow20.nu), spc_2pow20.od.*spc_2pow20.cim_filt);
Tr_p0005_1 = spc_2pow20.cim_filt .* exp(-spc_2pow20.od.*am);
hod_p0005_1 = -log(trapz(spc_2pow20.nu, Tr_p0005_1))./am;
std_p0005_1 = std(Tr_p0005(Tr_p0005_1>0));
mn = mean(Tr_p0005_1(Tr_p0005_1>0));

am = 2;
Tr_p0005_2 = spc_2pow20.cim_filt .* exp(-spc_2pow20.od.*am);
hod_p0005_2 = -log(trapz(spc_2pow20.nu, Tr_p0005_2))./am;
std_p0005_2 = std(Tr_p0005_2(Tr_p0005_2>0));

am = 3;
Tr_p0005_3 = spc_2pow20.cim_filt .* exp(-spc_2pow20.od.*am);
hod_p0005_3 = -log(trapz(spc_2pow20.nu, Tr_p0005_3))./am;
std_p0005_3 = std(Tr_p0005_3(Tr_p0005_3>0));

am = 4;
Tr_p0005_4 = spc_2pow20.cim_filt .* exp(-spc_2pow20.od.*am);
hod_p0005_4 = -log(trapz(spc_2pow20.nu, Tr_p0005_4))./am;
std_p0005_4 = std(Tr_p0005_4(Tr_p0005_4>0));

am = 5;
Tr_p0005_5 = spc_2pow20.cim_filt .* exp(-spc_2pow20.od.*am);
hod_p0005_5 = -log(trapz(spc_2pow20.nu, Tr_p0005_5))./am;
std_p0005_5 = std(Tr_p0005_5(Tr_p0005_5>0));

am = 6;
Tr_p0005_6 = spc_2pow20.cim_filt .* exp(-spc_2pow20.od.*am);
hod_p0005_6 = -log(trapz(spc_2pow20.nu, Tr_p0005_6))./am;
std_p0005_6 = std(Tr_p0005_6(Tr_p0005_6>0));

am = 1.5;
Tr_p0005_1p5 = spc_2pow20.cim_filt .* exp(-spc_2pow20.od.*am);
hod_p0005_1p5 = -log(trapz(spc_2pow20.nu, Tr_p0005_1p5))./am;
std_p0005_1p5 = std(Tr_p0005_1p5(Tr_p0005_1p5>0));

am = 2.5;
Tr_p0005_2p5 = spc_2pow20.cim_filt .* exp(-spc_2pow20.od.*am);
hod_p0005_2p5 = -log(trapz(spc_2pow20.nu, Tr_p0005_2p5))./am;
std_p0005_2p5 = std(Tr_p0005_2p5(Tr_p0005_2p5>0));

am = 3.5;
Tr_p0005_3p5 = spc_2pow20.cim_filt .* exp(-spc_2pow20.od.*am);
hod_p0005_3p5 = -log(trapz(spc_2pow20.nu, Tr_p0005_3p5))./am;
std_p0005_3p5 = std(Tr_p0005_3p5(Tr_p0005_3p5>0));

am = 4.5;
Tr_p0005_4p5 = spc_2pow20.cim_filt .* exp(-spc_2pow20.od.*am);
hod_p0005_4p5 = -log(trapz(spc_2pow20.nu, Tr_p0005_4p5))./am;
std_p0005_4p5 = std(Tr_p0005_4p5(Tr_p0005_4p5>0));

am = 5.5;
Tr_p0005_5p5 = spc_2pow20.cim_filt .* exp(-spc_2pow20.od.*am);
hod_p0005_5p5 = -log(trapz(spc_2pow20.nu, Tr_p0005_5p5))./am;
std_p0005_5p5 = std(Tr_p0005_5p5(Tr_p0005_5p5>0));


stds_am_o = [std_p0005_1, std_p0005_3, std_p0005_5]./mn;
hods_am_o = [hod_p0005_1, hod_p0005_3, hod_p0005_5];
% figure; plot(-diff(stds_am_o), diff(fliplr(hods_am_o)), '-x')

stds_am = [std_p0005_1,std_p0005_1p5,std_p0005_2, std_p0005_2p5, std_p0005_3,...
    std_p0005_3p5,std_p0005_4,std_p0005_4p5,std_p0005_5,std_p0005_5p5,std_p0005_6]./mn;
hods_am = [hod_p0005_1,hod_p0005_1p5,hod_p0005_2, hod_p0005_2p5, hod_p0005_3,...
    hod_p0005_3p5,hod_p0005_4,hod_p0005_4p5,hod_p0005_5,hod_p0005_5p5,hod_p0005_6];
figure; plot(-diff(stds_am), hods_am(1:end-1)-hods_am(2:end), '-'); legend('0005'); hold('on')

%%
% This section is for AM = 1:.5:6 at 0.001 1/cm resolution
am = 1;
top = trapz((spc_2pow20.nu), spc_2pow20.od.*spc_2pow20.cim_filt);
bot = trapz((spc_2pow20.nu), c001.*spc_2pow20.cim_filt);
Tr_p016_1 = spc_2pow20.cim_filt .* exp(-(c001.*top./bot).*am);
hod_p016_1 = -log(trapz(spc_2pow20.nu, Tr_p016_1))./am;
std_p016_1 = std(Tr_p016_1(Tr_p016_1>0));
mn = mean(Tr_p016_1(Tr_p016_1>0));

am = 2;
Tr_p001_2 = spc_2pow20.cim_filt .* exp(-(c001.*top./bot).*am);
hod_p001_2 = -log(trapz(spc_2pow20.nu, Tr_p001_2))./am;
std_p001_2 = std(Tr_p001_2(Tr_p001_2>0));
mn = mean(Tr_p001_2(Tr_p001_2>0));

am = 3;
Tr_p001_3 = spc_2pow20.cim_filt .* exp(-(c001.*top./bot).*am);
hod_p001_3 = -log(trapz(spc_2pow20.nu, Tr_p001_3))./am;
std_p001_3 = std(Tr_p001_3(Tr_p001_3>0));
mn = mean(Tr_p001_3(Tr_p001_3>0));

am = 4;
Tr_p001_4 = spc_2pow20.cim_filt .* exp(-(c001.*top./bot).*am);
hod_p001_4 = -log(trapz(spc_2pow20.nu, Tr_p001_4))./am;
std_p001_4 = std(Tr_p001_4(Tr_p001_4>0));
mn = mean(Tr_p001_4(Tr_p001_4>0));

am = 5;
Tr_p001_5 = spc_2pow20.cim_filt .* exp(-(c001.*top./bot).*am);
hod_p001_5 = -log(trapz(spc_2pow20.nu, Tr_p001_5))./am;
std_p001_5 = std(Tr_p001_5(Tr_p001_5>0));
mn = mean(Tr_p001_5(Tr_p001_5>0));

am = 6;
Tr_p001_6 = spc_2pow20.cim_filt .* exp(-(c001.*top./bot).*am);
hod_p001_6 = -log(trapz(spc_2pow20.nu, Tr_p001_6))./am;
std_p001_6 = std(Tr_p001_6(Tr_p001_6>0));
mn = mean(Tr_p001_6(Tr_p001_6>0));

am = 1.5;
Tr_p001_1p5 = spc_2pow20.cim_filt .* exp(-(c001.*top./bot).*am);
hod_p001_1p5 = -log(trapz(spc_2pow20.nu, Tr_p001_1p5))./am;
std_p001_1p5 = std(Tr_p001_1p5(Tr_p001_1p5>0));
mn = mean(Tr_p001_1(Tr_p001_1>0));

am = 2.5;
Tr_p001_2p5 = spc_2pow20.cim_filt .* exp(-(c001.*top./bot).*am);
hod_p001_2p5 = -log(trapz(spc_2pow20.nu, Tr_p001_2p5))./am;
std_p001_2p5 = std(Tr_p001_2p5(Tr_p001_2p5>0));
mn = mean(Tr_p001_2p5(Tr_p001_2p5>0));

am = 3.5;
Tr_p001_3p5 = spc_2pow20.cim_filt .* exp(-(c001.*top./bot).*am);
hod_p001_3p5 = -log(trapz(spc_2pow20.nu, Tr_p001_3p5))./am;
std_p001_3p5 = std(Tr_p001_3p5(Tr_p001_3p5>0));
mn = mean(Tr_p001_3p5(Tr_p001_3p5>0));

am = 4.5;
Tr_p001_4p5 = spc_2pow20.cim_filt .* exp(-(c001.*top./bot).*am);
hod_p001_4p5 = -log(trapz(spc_2pow20.nu, Tr_p001_4p5))./am;
std_p001_4p5= std(Tr_p001_4p5(Tr_p001_4p5>0));
mn = mean(Tr_p001_4p5(Tr_p001_4p5>0));

am = 5.5;
Tr_p001_5p5 = spc_2pow20.cim_filt .* exp(-(c001.*top./bot).*am);
hod_p001_5p5 = -log(trapz(spc_2pow20.nu, Tr_p001_5p5))./am;
std_p001_5p5 = std(Tr_p001_5p5(Tr_p001_5p5>0));
mn = mean(Tr_p001_5p5(Tr_p001_5p5>0));

stds_p001_am = [std_p001_1,std_p001_1p5,std_p001_2, std_p001_2p5, std_p001_3,...
    std_p001_3p5,std_p001_4,std_p001_4p5,std_p001_5,std_p001_5p5,std_p001_6]./mn;
hods_p001_am = [hod_p001_1,hod_p001_1p5,hod_p001_2, hod_p001_2p5, hod_p001_3,...
    hod_p001_3p5,hod_p001_4,hod_p001_4p5,hod_p001_5,hod_p001_5p5,hod_p001_6];
plot(-diff(stds_p001_am), hods_p001_am(1:end-1)-hods_am(2:end), '-'); legend('001')

figure; those = plot(spc_2pow20.nm, [Tr_p0005_6; Tr_p0005_5p5;Tr_p0005_5;Tr_p0005_4p5;Tr_p0005_4;Tr_p0005_3p5;Tr_p0005_3;Tr_p0005_2p5; Tr_p0005_2;Tr_p0005_1p5; Tr_p0005_1],'-');

figure; those = plot(spc_2pow20.nm, [Tr_p0005_1; Tr_p0005_1p5;Tr_p0005_2;Tr_p0005_2p5;Tr_p0005_3;Tr_p0005_3p5;Tr_p0005_4;Tr_p0005_4p5; Tr_p0005_5;Tr_p0005_5p5; Tr_p0005_6],'-');
recolor((those), [1:.5:6]);
legend('am=1','am=1.5','am=2','am=2.5','am=3','am=3.5','am=4','am=4.5','am=5','am=5.5','am=6')

%%
% This section is for AM = 1:.5:6 at 0.016 1/cm resolution
am = 1;
top = trapz((spc_2pow20.nu), spc_2pow20.od.*spc_2pow20.cim_filt);
bot = trapz((spc_2pow20.nu), c016.*spc_2pow20.cim_filt);
Tr_p016_1 = spc_2pow20.cim_filt .* exp(-(c016.*top./bot).*am);
hod_p016_1 = -log(trapz(spc_2pow20.nu, Tr_p016_1))./am;
std_p016_1 = std(Tr_p016_1(Tr_p016_1>0));
mn = mean(Tr_p016_1(Tr_p016_1>0));

am = 2;
Tr_p016_2 = spc_2pow20.cim_filt .* exp(-(c016.*top./bot).*am);
hod_p016_2 = -log(trapz(spc_2pow20.nu, Tr_p016_2))./am;
std_p016_2 = std(Tr_p016_2(Tr_p016_2>0));
mn = mean(Tr_p016_2(Tr_p016_2>0));

am = 3;
Tr_p016_3 = spc_2pow20.cim_filt .* exp(-(c016.*top./bot).*am);
hod_p016_3 = -log(trapz(spc_2pow20.nu, Tr_p016_3))./am;
std_p016_3 = std(Tr_p016_3(Tr_p016_3>0));
mn = mean(Tr_p016_3(Tr_p016_3>0));

am = 4;
Tr_p016_4 = spc_2pow20.cim_filt .* exp(-(c016.*top./bot).*am);
hod_p016_4 = -log(trapz(spc_2pow20.nu, Tr_p016_4))./am;
std_p016_4 = std(Tr_p016_4(Tr_p016_4>0));
mn = mean(Tr_p016_4(Tr_p016_4>0));

am = 5;
Tr_p016_5 = spc_2pow20.cim_filt .* exp(-(c016.*top./bot).*am);
hod_p016_5 = -log(trapz(spc_2pow20.nu, Tr_p016_5))./am;
std_p016_5 = std(Tr_p016_5(Tr_p016_5>0));
mn = mean(Tr_p016_5(Tr_p016_5>0));

am = 6;
Tr_p016_6 = spc_2pow20.cim_filt .* exp(-(c016.*top./bot).*am);
hod_p016_6 = -log(trapz(spc_2pow20.nu, Tr_p016_6))./am;
std_p016_6 = std(Tr_p016_6(Tr_p016_6>0));
mn = mean(Tr_p016_6(Tr_p016_6>0));

am = 1.5;
Tr_p016_1p5 = spc_2pow20.cim_filt .* exp(-(c016.*top./bot).*am);
hod_p016_1p5 = -log(trapz(spc_2pow20.nu, Tr_p016_1p5))./am;
std_p016_1p5 = std(Tr_p016_1p5(Tr_p016_1p5>0));
mn = mean(Tr_p016_1(Tr_p016_1>0));

am = 2.5;
Tr_p016_2p5 = spc_2pow20.cim_filt .* exp(-(c016.*top./bot).*am);
hod_p016_2p5 = -log(trapz(spc_2pow20.nu, Tr_p016_2p5))./am;
std_p016_2p5 = std(Tr_p016_2p5(Tr_p016_2p5>0));
mn = mean(Tr_p016_2p5(Tr_p016_2p5>0));

am = 3.5;
Tr_p016_3p5 = spc_2pow20.cim_filt .* exp(-(c016.*top./bot).*am);
hod_p016_3p5 = -log(trapz(spc_2pow20.nu, Tr_p016_3p5))./am;
std_p016_3p5 = std(Tr_p016_3p5(Tr_p016_3p5>0));
mn = mean(Tr_p016_3p5(Tr_p016_3p5>0));

am = 4.5;
Tr_p016_4p5 = spc_2pow20.cim_filt .* exp(-(c016.*top./bot).*am);
hod_p016_4p5 = -log(trapz(spc_2pow20.nu, Tr_p016_4p5))./am;
std_p016_4p5= std(Tr_p016_4p5(Tr_p016_4p5>0));
mn = mean(Tr_p016_4p5(Tr_p016_4p5>0));

am = 5.5;
Tr_p016_5p5 = spc_2pow20.cim_filt .* exp(-(c016.*top./bot).*am);
hod_p016_5p5 = -log(trapz(spc_2pow20.nu, Tr_p016_5p5))./am;
std_p016_5p5 = std(Tr_p016_5p5(Tr_p016_5p5>0));
mn = mean(Tr_p016_5p5(Tr_p016_5p5>0));

stds_p016_am = [std_p016_1,std_p016_1p5,std_p016_2, std_p016_2p5, std_p016_3,...
    std_p016_3p5,std_p016_4,std_p016_4p5,std_p016_5,std_p016_5p5,std_p016_6]./mn;
hods_p016_am = [hod_p016_1,hod_p016_1p5,hod_p016_2, hod_p016_2p5, hod_p016_3,...
    hod_p016_3p5,hod_p016_4,hod_p016_4p5,hod_p016_5,hod_p016_5p5,hod_p016_6];
plot(-diff(stds_p016_am), hods_p016_am(1:end-1)-hods_am(2:end), '-'); legend('016')

%%
% This section is for AM = 1:.5:6 at 0.032 1/cm resolution
am = 1;
top = trapz((spc_2pow20.nu), spc_2pow20.od.*spc_2pow20.cim_filt);
bot = trapz((spc_2pow20.nu), c016.*spc_2pow20.cim_filt);
Tr_p032_1 = spc_2pow20.cim_filt .* exp(-(c032.*top./bot).*am);
hod_p032_1 = -log(trapz(spc_2pow20.nu, Tr_p032_1))./am;
std_p032_1 = std(Tr_p032_1(Tr_p032_1>0));
mn = mean(Tr_p032_1(Tr_p032_1>0));

am = 2;
Tr_p032_2 = spc_2pow20.cim_filt .* exp(-(c032.*top./bot).*am);
hod_p032_2 = -log(trapz(spc_2pow20.nu, Tr_p032_2))./am;
std_p032_2 = std(Tr_p032_2(Tr_p032_2>0));
mn = mean(Tr_p032_2(Tr_p032_2>0));

am = 3;
Tr_p032_3 = spc_2pow20.cim_filt .* exp(-(c032.*top./bot).*am);
hod_p032_3 = -log(trapz(spc_2pow20.nu, Tr_p032_3))./am;
std_p032_3 = std(Tr_p032_3(Tr_p032_3>0));
mn = mean(Tr_p032_3(Tr_p032_3>0));

am = 4;
Tr_p032_4 = spc_2pow20.cim_filt .* exp(-(c032.*top./bot).*am);
hod_p032_4 = -log(trapz(spc_2pow20.nu, Tr_p032_4))./am;
std_p032_4 = std(Tr_p032_4(Tr_p032_4>0));
mn = mean(Tr_p032_4(Tr_p032_4>0));

am = 5;
Tr_p032_5 = spc_2pow20.cim_filt .* exp(-(c032.*top./bot).*am);
hod_p032_5 = -log(trapz(spc_2pow20.nu, Tr_p032_5))./am;
std_p032_5 = std(Tr_p032_5(Tr_p032_5>0));
mn = mean(Tr_p032_5(Tr_p032_5>0));

am = 6;
Tr_p032_6 = spc_2pow20.cim_filt .* exp(-(c032.*top./bot).*am);
hod_p032_6 = -log(trapz(spc_2pow20.nu, Tr_p032_6))./am;
std_p032_6 = std(Tr_p032_6(Tr_p032_6>0));
mn = mean(Tr_p032_6(Tr_p032_6>0));

am = 1.5;
Tr_p032_1p5 = spc_2pow20.cim_filt .* exp(-(c032.*top./bot).*am);
hod_p032_1p5 = -log(trapz(spc_2pow20.nu, Tr_p032_1p5))./am;
std_p032_1p5 = std(Tr_p032_1p5(Tr_p032_1p5>0));
mn = mean(Tr_p032_1(Tr_p032_1>0));

am = 2.5;
Tr_p032_2p5 = spc_2pow20.cim_filt .* exp(-(c032.*top./bot).*am);
hod_p032_2p5 = -log(trapz(spc_2pow20.nu, Tr_p032_2p5))./am;
std_p032_2p5 = std(Tr_p032_2p5(Tr_p032_2p5>0));
mn = mean(Tr_p032_2p5(Tr_p032_2p5>0));

am = 3.5;
Tr_p032_3p5 = spc_2pow20.cim_filt .* exp(-(c032.*top./bot).*am);
hod_p032_3p5 = -log(trapz(spc_2pow20.nu, Tr_p032_3p5))./am;
std_p032_3p5 = std(Tr_p032_3p5(Tr_p032_3p5>0));
mn = mean(Tr_p032_3p5(Tr_p032_3p5>0));

am = 4.5;
Tr_p032_4p5 = spc_2pow20.cim_filt .* exp(-(c032.*top./bot).*am);
hod_p032_4p5 = -log(trapz(spc_2pow20.nu, Tr_p032_4p5))./am;
std_p032_4p5= std(Tr_p032_4p5(Tr_p032_4p5>0));
mn = mean(Tr_p032_4p5(Tr_p032_4p5>0));

am = 5.5;
Tr_p032_5p5 = spc_2pow20.cim_filt .* exp(-(c032.*top./bot).*am);
hod_p032_5p5 = -log(trapz(spc_2pow20.nu, Tr_p032_5p5))./am;
std_p032_5p5 = std(Tr_p032_5p5(Tr_p032_5p5>0));
mn = mean(Tr_p032_5p5(Tr_p032_5p5>0));

stds_p032_am = [std_p032_1,std_p032_1p5,std_p032_2, std_p032_2p5, std_p032_3,...
    std_p032_3p5,std_p032_4,std_p032_4p5,std_p032_5,std_p032_5p5,std_p032_6]./mn;
hods_p032_am = [hod_p032_1,hod_p032_1p5,hod_p032_2, hod_p032_2p5, hod_p032_3,...
    hod_p032_3p5,hod_p032_4,hod_p032_4p5,hod_p032_5,hod_p032_5p5,hod_p032_6];
plot(-diff(stds_p032_am), hods_p032_am(1:end-1)-hods_am(2:end), '-'); 

%%
% This section is for AM = 1:.5:6 at 0.064 1/cm resolution
am = 1;
top = trapz((spc_2pow20.nu), spc_2pow20.od.*spc_2pow20.cim_filt);
bot = trapz((spc_2pow20.nu), c064.*spc_2pow20.cim_filt);
Tr_p064_1 = spc_2pow20.cim_filt .* exp(-(c064.*top./bot).*am);
hod_p064_1 = -log(trapz(spc_2pow20.nu, Tr_p064_1))./am;
std_p064_1 = std(Tr_p064_1(Tr_p064_1>0));
mn = mean(Tr_p064_1(Tr_p064_1>0));

am = 2;
Tr_p064_2 = spc_2pow20.cim_filt .* exp(-(c064.*top./bot).*am);
hod_p064_2 = -log(trapz(spc_2pow20.nu, Tr_p064_2))./am;
std_p064_2 = std(Tr_p064_2(Tr_p064_2>0));
mn = mean(Tr_p064_2(Tr_p064_2>0));

am = 3;
Tr_p064_3 = spc_2pow20.cim_filt .* exp(-(c064.*top./bot).*am);
hod_p064_3 = -log(trapz(spc_2pow20.nu, Tr_p064_3))./am;
std_p064_3 = std(Tr_p064_3(Tr_p064_3>0));
mn = mean(Tr_p064_3(Tr_p064_3>0));

am = 4;
Tr_p064_4 = spc_2pow20.cim_filt .* exp(-(c064.*top./bot).*am);
hod_p064_4 = -log(trapz(spc_2pow20.nu, Tr_p064_4))./am;
std_p064_4 = std(Tr_p064_4(Tr_p064_4>0));
mn = mean(Tr_p064_4(Tr_p064_4>0));

am = 5;
Tr_p064_5 = spc_2pow20.cim_filt .* exp(-(c064.*top./bot).*am);
hod_p064_5 = -log(trapz(spc_2pow20.nu, Tr_p064_5))./am;
std_p064_5 = std(Tr_p064_5(Tr_p064_5>0));
mn = mean(Tr_p064_5(Tr_p064_5>0));

am = 6;
Tr_p064_6 = spc_2pow20.cim_filt .* exp(-(c064.*top./bot).*am);
hod_p064_6 = -log(trapz(spc_2pow20.nu, Tr_p064_6))./am;
std_p064_6 = std(Tr_p064_6(Tr_p064_6>0));
mn = mean(Tr_p064_6(Tr_p064_6>0));

am = 1.5;
Tr_p064_1p5 = spc_2pow20.cim_filt .* exp(-(c064.*top./bot).*am);
hod_p064_1p5 = -log(trapz(spc_2pow20.nu, Tr_p064_1p5))./am;
std_p064_1p5 = std(Tr_p064_1p5(Tr_p064_1p5>0));
mn = mean(Tr_p064_1(Tr_p064_1>0));

am = 2.5;
Tr_p064_2p5 = spc_2pow20.cim_filt .* exp(-(c064.*top./bot).*am);
hod_p064_2p5 = -log(trapz(spc_2pow20.nu, Tr_p064_2p5))./am;
std_p064_2p5 = std(Tr_p064_2p5(Tr_p064_2p5>0));
mn = mean(Tr_p064_2p5(Tr_p064_2p5>0));

am = 3.5;
Tr_p064_3p5 = spc_2pow20.cim_filt .* exp(-(c064.*top./bot).*am);
hod_p064_3p5 = -log(trapz(spc_2pow20.nu, Tr_p064_3p5))./am;
std_p064_3p5 = std(Tr_p064_3p5(Tr_p064_3p5>0));
mn = mean(Tr_p064_3p5(Tr_p064_3p5>0));

am = 4.5;
Tr_p064_4p5 = spc_2pow20.cim_filt .* exp(-(c064.*top./bot).*am);
hod_p064_4p5 = -log(trapz(spc_2pow20.nu, Tr_p064_4p5))./am;
std_p064_4p5= std(Tr_p064_4p5(Tr_p064_4p5>0));
mn = mean(Tr_p064_4p5(Tr_p064_4p5>0));

am = 5.5;
Tr_p064_5p5 = spc_2pow20.cim_filt .* exp(-(c064.*top./bot).*am);
hod_p064_5p5 = -log(trapz(spc_2pow20.nu, Tr_p064_5p5))./am;
std_p064_5p5 = std(Tr_p064_5p5(Tr_p064_5p5>0));
mn = mean(Tr_p064_5p5(Tr_p064_5p5>0));

stds_p064_am = [std_p064_1,std_p064_1p5,std_p064_2, std_p064_2p5, std_p064_3,...
    std_p064_3p5,std_p064_4,std_p064_4p5,std_p064_5,std_p064_5p5,std_p064_6]./mn;
hods_p064_am = [hod_p064_1,hod_p064_1p5,hod_p064_2, hod_p064_2p5, hod_p064_3,...
    hod_p064_3p5,hod_p064_4,hod_p064_4p5,hod_p064_5,hod_p064_5p5,hod_p064_6];
plot(-diff(stds_p064_am), hods_p064_am(1:end-1)-hods_am(2:end), '-'); legend('064')

%%
% This section is for AM = 1:.5:6 at 0.128 1/cm resolution
am = 1;
top = trapz((spc_2pow20.nu), spc_2pow20.od.*spc_2pow20.cim_filt);
bot = trapz((spc_2pow20.nu), c128.*spc_2pow20.cim_filt);
Tr_p128_1 = spc_2pow20.cim_filt .* exp(-(c128.*top./bot).*am);
hod_p128_1 = -log(trapz(spc_2pow20.nu, Tr_p128_1))./am;
std_p128_1 = std(Tr_p128_1(Tr_p128_1>0));
mn = mean(Tr_p128_1(Tr_p128_1>0));

am = 2;
Tr_p128_2 = spc_2pow20.cim_filt .* exp(-(c128.*top./bot).*am);
hod_p128_2 = -log(trapz(spc_2pow20.nu, Tr_p128_2))./am;
std_p128_2 = std(Tr_p128_2(Tr_p128_2>0));
mn = mean(Tr_p128_2(Tr_p128_2>0));

am = 3;
Tr_p128_3 = spc_2pow20.cim_filt .* exp(-(c128.*top./bot).*am);
hod_p128_3 = -log(trapz(spc_2pow20.nu, Tr_p128_3))./am;
std_p128_3 = std(Tr_p128_3(Tr_p128_3>0));
mn = mean(Tr_p128_3(Tr_p128_3>0));

am = 4;
Tr_p128_4 = spc_2pow20.cim_filt .* exp(-(c128.*top./bot).*am);
hod_p128_4 = -log(trapz(spc_2pow20.nu, Tr_p128_4))./am;
std_p128_4 = std(Tr_p128_4(Tr_p128_4>0));
mn = mean(Tr_p128_4(Tr_p128_4>0));

am = 5;
Tr_p128_5 = spc_2pow20.cim_filt .* exp(-(c128.*top./bot).*am);
hod_p128_5 = -log(trapz(spc_2pow20.nu, Tr_p128_5))./am;
std_p128_5 = std(Tr_p128_5(Tr_p128_5>0));
mn = mean(Tr_p128_5(Tr_p128_5>0));

am = 6;
Tr_p128_6 = spc_2pow20.cim_filt .* exp(-(c128.*top./bot).*am);
hod_p128_6 = -log(trapz(spc_2pow20.nu, Tr_p128_6))./am;
std_p128_6 = std(Tr_p128_6(Tr_p128_6>0));
mn = mean(Tr_p128_6(Tr_p128_6>0));

am = 1.5;
Tr_p128_1p5 = spc_2pow20.cim_filt .* exp(-(c128.*top./bot).*am);
hod_p128_1p5 = -log(trapz(spc_2pow20.nu, Tr_p128_1p5))./am;
std_p128_1p5 = std(Tr_p128_1p5(Tr_p128_1p5>0));
mn = mean(Tr_p128_1(Tr_p128_1>0));

am = 2.5;
Tr_p128_2p5 = spc_2pow20.cim_filt .* exp(-(c128.*top./bot).*am);
hod_p128_2p5 = -log(trapz(spc_2pow20.nu, Tr_p128_2p5))./am;
std_p128_2p5 = std(Tr_p128_2p5(Tr_p128_2p5>0));
mn = mean(Tr_p128_2p5(Tr_p128_2p5>0));

am = 3.5;
Tr_p128_3p5 = spc_2pow20.cim_filt .* exp(-(c128.*top./bot).*am);
hod_p128_3p5 = -log(trapz(spc_2pow20.nu, Tr_p128_3p5))./am;
std_p128_3p5 = std(Tr_p128_3p5(Tr_p128_3p5>0));
mn = mean(Tr_p128_3p5(Tr_p128_3p5>0));

am = 4.5;
Tr_p128_4p5 = spc_2pow20.cim_filt .* exp(-(c128.*top./bot).*am);
hod_p128_4p5 = -log(trapz(spc_2pow20.nu, Tr_p128_4p5))./am;
std_p128_4p5= std(Tr_p128_4p5(Tr_p128_4p5>0));
mn = mean(Tr_p128_4p5(Tr_p128_4p5>0));

am = 5.5;
Tr_p128_5p5 = spc_2pow20.cim_filt .* exp(-(c128.*top./bot).*am);
hod_p128_5p5 = -log(trapz(spc_2pow20.nu, Tr_p128_5p5))./am;
std_p128_5p5 = std(Tr_p128_5p5(Tr_p128_5p5>0));
mn = mean(Tr_p128_5p5(Tr_p128_5p5>0));

stds_p128_am = [std_p128_1,std_p128_1p5,std_p128_2, std_p128_2p5, std_p128_3,...
    std_p128_3p5,std_p128_4,std_p128_4p5,std_p128_5,std_p128_5p5,std_p128_6]./mn;
hods_p128_am = [hod_p128_1,hod_p128_1p5,hod_p128_2, hod_p128_2p5, hod_p128_3,...
    hod_p128_3p5,hod_p128_4,hod_p128_4p5,hod_p128_5,hod_p128_5p5,hod_p128_6];
plot(-diff(stds_p128_am), hods_p128_am(1:end-1)-hods_am(2:end), '-'); legend('128')

%%
% This section is for AM = 1:.5:6 at 0.256 1/cm resolution
am = 1;
top = trapz((spc_2pow20.nu), spc_2pow20.od.*spc_2pow20.cim_filt);
bot = trapz((spc_2pow20.nu), c256.*spc_2pow20.cim_filt);
Tr_p256_1 = spc_2pow20.cim_filt .* exp(-(c256.*top./bot).*am);
hod_p256_1 = -log(trapz(spc_2pow20.nu, Tr_p256_1))./am;
std_p256_1 = std(Tr_p256_1(Tr_p256_1>0));
mn = mean(Tr_p256_1(Tr_p256_1>0));

am = 2;
Tr_p256_2 = spc_2pow20.cim_filt .* exp(-(c256.*top./bot).*am);
hod_p256_2 = -log(trapz(spc_2pow20.nu, Tr_p256_2))./am;
std_p256_2 = std(Tr_p256_2(Tr_p256_2>0));
mn = mean(Tr_p256_2(Tr_p256_2>0));

am = 3;
Tr_p256_3 = spc_2pow20.cim_filt .* exp(-(c256.*top./bot).*am);
hod_p256_3 = -log(trapz(spc_2pow20.nu, Tr_p256_3))./am;
std_p256_3 = std(Tr_p256_3(Tr_p256_3>0));
mn = mean(Tr_p256_3(Tr_p256_3>0));

am = 4;
Tr_p256_4 = spc_2pow20.cim_filt .* exp(-(c256.*top./bot).*am);
hod_p256_4 = -log(trapz(spc_2pow20.nu, Tr_p256_4))./am;
std_p256_4 = std(Tr_p256_4(Tr_p256_4>0));
mn = mean(Tr_p256_4(Tr_p256_4>0));

am = 5;
Tr_p256_5 = spc_2pow20.cim_filt .* exp(-(c256.*top./bot).*am);
hod_p256_5 = -log(trapz(spc_2pow20.nu, Tr_p256_5))./am;
std_p256_5 = std(Tr_p256_5(Tr_p256_5>0));
mn = mean(Tr_p256_5(Tr_p256_5>0));

am = 6;
Tr_p256_6 = spc_2pow20.cim_filt .* exp(-(c256.*top./bot).*am);
hod_p256_6 = -log(trapz(spc_2pow20.nu, Tr_p256_6))./am;
std_p256_6 = std(Tr_p256_6(Tr_p256_6>0));
mn = mean(Tr_p256_6(Tr_p256_6>0));

am = 1.5;
Tr_p256_1p5 = spc_2pow20.cim_filt .* exp(-(c256.*top./bot).*am);
hod_p256_1p5 = -log(trapz(spc_2pow20.nu, Tr_p256_1p5))./am;
std_p256_1p5 = std(Tr_p256_1p5(Tr_p256_1p5>0));
mn = mean(Tr_p256_1(Tr_p256_1>0));

am = 2.5;
Tr_p256_2p5 = spc_2pow20.cim_filt .* exp(-(c256.*top./bot).*am);
hod_p256_2p5 = -log(trapz(spc_2pow20.nu, Tr_p256_2p5))./am;
std_p256_2p5 = std(Tr_p256_2p5(Tr_p256_2p5>0));
mn = mean(Tr_p256_2p5(Tr_p256_2p5>0));

am = 3.5;
Tr_p256_3p5 = spc_2pow20.cim_filt .* exp(-(c256.*top./bot).*am);
hod_p256_3p5 = -log(trapz(spc_2pow20.nu, Tr_p256_3p5))./am;
std_p256_3p5 = std(Tr_p256_3p5(Tr_p256_3p5>0));
mn = mean(Tr_p256_3p5(Tr_p256_3p5>0));

am = 4.5;
Tr_p256_4p5 = spc_2pow20.cim_filt .* exp(-(c256.*top./bot).*am);
hod_p256_4p5 = -log(trapz(spc_2pow20.nu, Tr_p256_4p5))./am;
std_p256_4p5= std(Tr_p256_4p5(Tr_p256_4p5>0));
mn = mean(Tr_p256_4p5(Tr_p256_4p5>0));

am = 5.5;
Tr_p256_5p5 = spc_2pow20.cim_filt .* exp(-(c256.*top./bot).*am);
hod_p256_5p5 = -log(trapz(spc_2pow20.nu, Tr_p256_5p5))./am;
std_p256_5p5 = std(Tr_p256_5p5(Tr_p256_5p5>0));
mn = mean(Tr_p256_5p5(Tr_p256_5p5>0));

stds_p256_am = [std_p256_1,std_p256_1p5,std_p256_2, std_p256_2p5, std_p256_3,...
    std_p256_3p5,std_p256_4,std_p256_4p5,std_p256_5,std_p256_5p5,std_p256_6]./mn;
hods_p256_am = [hod_p256_1,hod_p256_1p5,hod_p256_2, hod_p256_2p5, hod_p256_3,...
    hod_p256_3p5,hod_p256_4,hod_p256_4p5,hod_p256_5,hod_p256_5p5,hod_p256_6];
plot(-diff(stds_p256_am), hods_p256_am(1:end-1)-hods_am(2:end), '-'); legend('256')

%%
% This section is for AM = 1:.5:6 at 0.512 1/cm resolution
am = 1;
top = trapz((spc_2pow20.nu), spc_2pow20.od.*spc_2pow20.cim_filt);
bot = trapz((spc_2pow20.nu), c512.*spc_2pow20.cim_filt);
Tr_p512_1 = spc_2pow20.cim_filt .* exp(-(c512.*top./bot).*am);
hod_p512_1 = -log(trapz(spc_2pow20.nu, Tr_p512_1))./am;
std_p512_1 = std(Tr_p512_1(Tr_p512_1>0));
mn = mean(Tr_p512_1(Tr_p512_1>0));

am = 2;
Tr_p512_2 = spc_2pow20.cim_filt .* exp(-(c512.*top./bot).*am);
hod_p512_2 = -log(trapz(spc_2pow20.nu, Tr_p512_2))./am;
std_p512_2 = std(Tr_p512_2(Tr_p512_2>0));
mn = mean(Tr_p512_2(Tr_p512_2>0));

am = 3;
Tr_p512_3 = spc_2pow20.cim_filt .* exp(-(c512.*top./bot).*am);
hod_p512_3 = -log(trapz(spc_2pow20.nu, Tr_p512_3))./am;
std_p512_3 = std(Tr_p512_3(Tr_p512_3>0));
mn = mean(Tr_p512_3(Tr_p512_3>0));

am = 4;
Tr_p512_4 = spc_2pow20.cim_filt .* exp(-(c512.*top./bot).*am);
hod_p512_4 = -log(trapz(spc_2pow20.nu, Tr_p512_4))./am;
std_p512_4 = std(Tr_p512_4(Tr_p512_4>0));
mn = mean(Tr_p512_4(Tr_p512_4>0));

am = 5;
Tr_p512_5 = spc_2pow20.cim_filt .* exp(-(c512.*top./bot).*am);
hod_p512_5 = -log(trapz(spc_2pow20.nu, Tr_p512_5))./am;
std_p512_5 = std(Tr_p512_5(Tr_p512_5>0));
mn = mean(Tr_p512_5(Tr_p512_5>0));

am = 6;
Tr_p512_6 = spc_2pow20.cim_filt .* exp(-(c512.*top./bot).*am);
hod_p512_6 = -log(trapz(spc_2pow20.nu, Tr_p512_6))./am;
std_p512_6 = std(Tr_p512_6(Tr_p512_6>0));
mn = mean(Tr_p512_6(Tr_p512_6>0));

am = 1.5;
Tr_p512_1p5 = spc_2pow20.cim_filt .* exp(-(c512.*top./bot).*am);
hod_p512_1p5 = -log(trapz(spc_2pow20.nu, Tr_p512_1p5))./am;
std_p512_1p5 = std(Tr_p512_1p5(Tr_p512_1p5>0));
mn = mean(Tr_p512_1(Tr_p512_1>0));

am = 2.5;
Tr_p512_2p5 = spc_2pow20.cim_filt .* exp(-(c512.*top./bot).*am);
hod_p512_2p5 = -log(trapz(spc_2pow20.nu, Tr_p512_2p5))./am;
std_p512_2p5 = std(Tr_p512_2p5(Tr_p512_2p5>0));
mn = mean(Tr_p512_2p5(Tr_p512_2p5>0));

am = 3.5;
Tr_p512_3p5 = spc_2pow20.cim_filt .* exp(-(c512.*top./bot).*am);
hod_p512_3p5 = -log(trapz(spc_2pow20.nu, Tr_p512_3p5))./am;
std_p512_3p5 = std(Tr_p512_3p5(Tr_p512_3p5>0));
mn = mean(Tr_p512_3p5(Tr_p512_3p5>0));

am = 4.5;
Tr_p512_4p5 = spc_2pow20.cim_filt .* exp(-(c512.*top./bot).*am);
hod_p512_4p5 = -log(trapz(spc_2pow20.nu, Tr_p512_4p5))./am;
std_p512_4p5= std(Tr_p512_4p5(Tr_p512_4p5>0));
mn = mean(Tr_p512_4p5(Tr_p512_4p5>0));

am = 5.5;
Tr_p512_5p5 = spc_2pow20.cim_filt .* exp(-(c512.*top./bot).*am);
hod_p512_5p5 = -log(trapz(spc_2pow20.nu, Tr_p512_5p5))./am;
std_p512_5p5 = std(Tr_p512_5p5(Tr_p512_5p5>0));
mn = mean(Tr_p512_5p5(Tr_p512_5p5>0));

stds_p512_am = [std_p512_1,std_p512_1p5,std_p512_2, std_p512_2p5, std_p512_3,...
    std_p512_3p5,std_p512_4,std_p512_4p5,std_p512_5,std_p512_5p5,std_p512_6]./mn;
hods_p512_am = [hod_p512_1,hod_p512_1p5,hod_p512_2, hod_p512_2p5, hod_p512_3,...
    hod_p512_3p5,hod_p512_4,hod_p512_4p5,hod_p512_5,hod_p512_5p5,hod_p512_6];
plot(-diff(stds_p512_am), hods_p512_am(1:end-1)-hods_am(2:end), '-'); 

%%
legend('0005','001','008','016','032','064','128','256','512')
% legend('0005','001','008','016','032','064','128','256','512')
%legend('8e-5 nm','1.6e-4 nm','1.2e-3 nm','2.5e-3 nm','5e-3 nm','1e-2 nm','2e-3 nm','4e-2 nm','8e-2 nm')
%%

figure; plot(spc_p0005.nu, p001./(sig.*sqrt(2*pi)),'-'); logy;
nu_new = spc_2pow20.nu;
figure; plot(spc_2pow20.nu, spc_2pow20.od,'-'); hold('on'); logy;

N = 2;

iod = fft(spc_2pow20.od);
m = floor(length(iod)./(2.*N));
od_new{1} = real(ifft(iod([1:m end-m:end]))./N);
bod = od_new{end}; bod = bod(1:end-1);
nu_new = nu_new(1:2:end);nu_new = nu_new +(nu_new(1)-nu_new(2))./2;
plot((nu_new(1:end-1)+nu_new(2:end))./2 ,real(bod(1:end-1)+bod(2:end))./2,'-' ); 

iod = fft(bod);
m = floor(length(iod)./(2.*N));
od_new{2} = real(ifft(iod([1:m end-m:end]))./N);
bod = od_new{end};bod =bod(1:end-1);
nu_new = nu_new(1:2:end); nu_new = nu_new +(nu_new(1)-nu_new(2))./2;
plot((nu_new(1:end-1)+nu_new(2:end))./2 ,real(bod(1:end-1)+bod(2:end))./2,'-' ); 




iod = ispc.od; iod(m+1:end-m-1) = mean(iod(m+1:end-m-1));
od_new2 = real(ifft(iod));
nu_new = spc_p0005.nu(1:N:end);

ood = [od_new(1:end-1)+od_new(2:end)]./2;


figure; plot(nm_new, od_new,'-', [nm_new(1:end-1)+nm_new(2:end)]./2, [od_new(1:end-1)+od_new(2:end)]./2,'-')
nm_new = spc_p0005.nm(1:N:end);
cim.nm = cim_filt(:,1); cim.Tr = cim_filt(:,2);
cim_p0005 = interp1(cim.nm, cim.Tr, spc_p0005.nm,'linear'); cim_p0005(isnan(cim_p0005)) = 0;
cim_p0005 = cim_p0005./trapz(spc_p0005.nu, cim_p0005);

cim_p001 = interp1(cim.nm, cim.Tr, nm_new,'linear'); cim_p001(isnan(cim_p001)) = 0;
cim_p001 = cim_p001./trapz(nu_new, cim_p001);
figure; plot(spc_p0005.nu,spc_p0005.od.*cim_p0005,'-',nu_new,od_new.*cim_p001,'-');

trapz(spc_p0005.nu,spc_p0005.od.*cim_p0005)
std(spc_p0005.nu.*cim_p0005)
std(exp(-spc_p0005.od.*cim_p0005))
-log(trapz(spc_p0005.nu,exp(-spc_p0005.od).*cim_p0005))

trapz(nu_new,od_new.*cim_new)
std(od_new.*cim_new)
std(exp(-od_new.*cim_new))
-log(trapz(nu_new,exp(-od_new).*cim_new))

% Some "interesting" saw-tooth pattern with higher nu values, low nm values
% but still preserves the dynamic range, esp once truncated over the filter
% width.


N = 512; m = floor(length(ispc.od)./(2.*N));od_new = ifft(ispc.od([1:m end-m:end]));
figure; plot([1:N:N.*length(od_new)],real(od_new)./N,'k-')
N = 10; m = floor(length(ispc.od)./(2.*N));od_new = ifft(ispc.od([1:m end-m:end]));
figure; plot([1:N:N.*length(od_new)],real(od_new)./N,'k-')
N = 64; m = floor(length(ispc.od)./(2.*N));od_new = ifft(ispc.od([1:m end-m:end]));
figure; plot([1:N:N.*length(od_new)],real(od_new)./N,'k-')
N = 128; m = floor(length(ispc.od)./(2.*N));od_new = ifft(ispc.od([1:m end-m:end]));
figure; plot([1:N:N.*length(od_new)],real(od_new)./N,'k-')

fname = 'TAPE5.ch4_p002';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
pause(.5)

fname = 'TAPE5.ch4_p004';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
pause(.5)

fname = 'TAPE5.ch4_p008';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5);
legend(lg_str)


fname = 'TAPE5.ch4_p016';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

fname = 'TAPE5.ch4_p032';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

fname = 'TAPE5.ch4_p064';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

fname = 'TAPE5.ch4_p128';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

fname = 'TAPE5.ch4_p256';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

fname = 'TAPE5.ch4_p512';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

figure;
fname = 'TAPE5.co2_p0005';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); title('CO_2'); logy; hold('on');
lg_str = {tag};
pause(.5)

fname = 'TAPE5.co2_nadir_noray';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
pause(.5)

fname = 'TAPE5.co2_p002';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
pause(.5)

fname = 'TAPE5.co2_p004';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
pause(.5)

fname = 'TAPE5.co2_p008';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

fname = 'TAPE5.co2_p016';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

fname = 'TAPE5.co2_p032';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

fname = 'TAPE5.co2_p064';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

fname = 'TAPE5.co2_p128';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

fname = 'TAPE5.co2_p256';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

fname = 'TAPE5.co2_p512';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

figure;
fname = 'TAPE5.h2o_p0005';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); title('H_2O'); logy; hold('on');
lg_str = {tag};
pause(.5)

fname = 'TAPE5.h2o_nadir_noray';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
pause(.5)

fname = 'TAPE5.h2o_p002';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
pause(.5)

fname = 'TAPE5.h2o_p004';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
pause(.5)

fname = 'TAPE5.h2o_p008';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

fname = 'TAPE5.h2o_p016';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

fname = 'TAPE5.h2o_p032';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

fname = 'TAPE5.h2o_p064';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

fname = 'TAPE5.h2o_p128';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

fname = 'TAPE5.h2o_p256';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)

fname = 'TAPE5.h2o_p512';
[~,tag,spc] = call_lbl([lbl_tape5_path, fname]);
plot(spc.nu, spc.od,'-'); 
lg_str(end+1) = {tag};
lg = legend(lg_str); set(lg,'interp','none')
pause(.5)
