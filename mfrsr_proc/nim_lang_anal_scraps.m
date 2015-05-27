% recent to older:
% nim_lang_anal_scraps	Feb 16
% aos_screen		Feb 16
% nim_aod			Feb 07
% lang_nim		Feb 04
% run_lang_anal2		Feb 04
% Io_lang_work		Jan 29
% lang_work		Jan 29

% This block is for the bundle of ARM Langleys
arm_lang = ancload;
%%
good = (arm_lang.vars.michalsky_badflag_filter2.data==0)&(arm_lang.vars.michalsky_solar_constant_sdist_filter2.data>0.05)&(arm_lang.vars.michalsky_solar_constant_sdist_filter2.data<5000);
figure; 

plot(arm_lang.time(good)-datenum(2006,1,1)+1, arm_lang.vars.michalsky_solar_constant_sdist_filter2.data(good),'ko');
title('MFRSR Vo for filter2, Niamey');
xlabel('day of year 2006')
ylabel('Arbitrary units')
%%
%this block is for Barnard's Ios
barn_Io =  read_barnio;
barn_Io_smooth = read_barnio;
%%
biq = IQF_lang(barn_Io.time, barn_Io.filter2_Vo,30);
biq_arm = IQF_lang(arm_lang.time(good), arm_lang.vars.michalsky_solar_constant_sdist_filter2.data(good),45);
figure; plot(barn_Io.time-datenum(2006,1,1)+1,barn_Io.filter2_Vo,'r.',...
   barn_Io.time-datenum(2006,1,1)+1,(biq),'g.',...
   barn_Io_smooth.time - datenum(2006,1,1)+1, barn_Io_smooth.filter2_Vo,'bo', ...
   arm_lang.time(good)-datenum(2006,1,1)+1, biq_arm,'mo');
title('MFRSR Vo for filter2, relaxed constraints');
xlabel('day of year 2006')
ylabel('Arbitrary units')
%%
biq = IQF_lang(barn_Io.time, barn_Io.filter2_Vo,30);
figure; plot(barn_Io.time-datenum(2006,1,1)+1,barn_Io.filter2_Vo,'ro',...
   barn_Io_smooth.time - datenum(2006,1,1)+1, barn_Io_smooth.filter2_Vo,'b.')
title('MFRSR Vo for filter2, relaxed constraints');
xlabel('day of year 2006')
ylabel('Arbitrary units')
%%
figure; plot(barn_Io_smooth.time - datenum(2006,1,1)+1, [barn_Io_smooth.filter1_Vo./mean(barn_Io_smooth.filter1_Vo), ...
   barn_Io_smooth.filter2_Vo./mean(barn_Io_smooth.filter2_Vo), ...
   barn_Io_smooth.filter3_Vo./mean(barn_Io_smooth.filter3_Vo), ...
   barn_Io_smooth.filter4_Vo./mean(barn_Io_smooth.filter4_Vo), ...
   barn_Io_smooth.filter5_Vo./mean(barn_Io_smooth.filter5_Vo)],'-')
legend('filter 1', 'filter 2', 'filter 3', 'filter 4', 'filter 5');
title('MFRSR Vos normalized by mean')
xlabel('day of year 2006')
ylabel('Arbitrary units')
%%
mean_345 = mean([barn_Io_smooth.filter3_Vo./mean(barn_Io_smooth.filter3_Vo), ...
   barn_Io_smooth.filter4_Vo./mean(barn_Io_smooth.filter4_Vo), ...
   barn_Io_smooth.filter5_Vo./mean(barn_Io_smooth.filter5_Vo)],2);
%%
figure; plot(barn_Io_smooth.time - datenum(2006,1,1)+1, ...
   [barn_Io_smooth.filter1_Vo./(mean(barn_Io_smooth.filter1_Vo).*mean_345), ...
   barn_Io_smooth.filter2_Vo./(mean(barn_Io_smooth.filter2_Vo).*mean_345), ...
   barn_Io_smooth.filter3_Vo./(mean(barn_Io_smooth.filter3_Vo).*mean_345), ...
   barn_Io_smooth.filter4_Vo./(mean(barn_Io_smooth.filter4_Vo).*mean_345), ...
   barn_Io_smooth.filter5_Vo./(mean(barn_Io_smooth.filter5_Vo).*mean_345)],'-')
legend('filter 1', 'filter 2', 'filter 3', 'filter 4', 'filter 5');
title('Vos normalized to mean of 3,4,5')
xlabel('day of year 2006')
ylabel('Arbitrary units')

% The following blocks are for my own Langley runs
%%

con_lang = ancload;
filter2.Vo = zeros(size(con_lang.time));
base = datevec(con_lang.time(1)); base = datenum(base(1),1,1);

%%
filter1.Vo = zeros(size(con_lang.time));
filter1.Vo(:) = con_lang.vars.langley_Vo.data(1,1,1,:);
cut = IQ(filter1.Vo,20);
is = NaN(size(filter1.Vo));
is(cut) = IQF_lang(con_lang.time(cut), filter1.Vo(cut),45);
I_new1 = is;
notNaN = ~isNaN(is);
[I_new1(notNaN)] = gsmooth(con_lang.time(notNaN),is(notNaN), 45);

figure; plot(con_lang.time(cut), filter1.Vo(cut), 'r.',(con_lang.time), is, 'k.-',con_lang.time,I_new1,'b.-'); datetick('keepticks')
datetick('keepticks','keeplimits');
title('Flynn MFRSR Io for filter1, Niamey');
xlabel('time')
ylabel('Solar const');

%%
filter2.Vo = zeros(size(con_lang.time));
filter2.Vo(:) = con_lang.vars.langley_Vo.data(2,1,1,:);
cut = IQ(filter2.Vo,20);
is = NaN(size(filter2.Vo));
is(cut) = IQF_lang(con_lang.time(cut), filter2.Vo(cut),45);
I_new2 = is;
notNaN = ~isNaN(is);
[I_new2(notNaN)] = gsmooth(con_lang.time(notNaN),is(notNaN), 45);

figure; plot(con_lang.time(cut), filter2.Vo(cut), 'r.',(con_lang.time), is, 'k.-',con_lang.time,I_new2,'b.-'); datetick('keepticks')
datetick('keepticks','keeplimits');
title('Flynn MFRSR Io for filter2, Niamey');
xlabel('time')
ylabel('Solar const');

%%
filter3.Vo = zeros(size(con_lang.time));
filter3.Vo(:) = con_lang.vars.langley_Vo.data(3,1,1,:);
cut = IQ(filter3.Vo,20);
is = NaN(size(filter3.Vo));
is(cut) = IQF_lang(con_lang.time(cut), filter3.Vo(cut),45);
I_new3 = is;
notNaN = ~isNaN(is);
[I_new3(notNaN)] = gsmooth(con_lang.time(notNaN),is(notNaN), 45);

figure; plot(con_lang.time(cut), filter3.Vo(cut), 'r.',(con_lang.time), is, 'k.-',con_lang.time,I_new3,'b.-'); datetick('keepticks')
datetick('keepticks','keeplimits');
title('Flynn MFRSR Io for filter3, Niamey');
xlabel('time')
ylabel('Solar const');

%%
filter4.Vo = zeros(size(con_lang.time));
filter4.Vo(:) = con_lang.vars.langley_Vo.data(4,1,1,:);
cut = IQ(filter4.Vo,20);
is = NaN(size(filter4.Vo));
is(cut) = IQF_lang(con_lang.time(cut), filter4.Vo(cut),45);
I_new4 = is;
notNaN = ~isNaN(is);
[I_new4(notNaN)] = gsmooth(con_lang.time(notNaN),is(notNaN), 45);

figure; plot(con_lang.time(cut), filter4.Vo(cut), 'r.',(con_lang.time), is, 'k.-',con_lang.time,I_new4,'b.-'); datetick('keepticks')
datetick('keepticks','keeplimits');
title('Flynn MFRSR Io for filter4, Niamey');
xlabel('time')
ylabel('Solar const');

%%
filter5.Vo = zeros(size(con_lang.time));
filter5.Vo(:) = con_lang.vars.langley_Vo.data(5,1,1,:);
cut = IQ(filter5.Vo,20);
is = NaN(size(filter5.Vo));
is(cut) = IQF_lang(con_lang.time(cut), filter5.Vo(cut),45);
I_new5 = is;
notNaN = ~isNaN(is);
[I_new5(notNaN)] = gsmooth(con_lang.time(notNaN),is(notNaN), 45);

figure; plot(con_lang.time(cut), filter5.Vo(cut), 'r.',(con_lang.time), is, 'k.-',con_lang.time,I_new5,'b.-'); datetick('keepticks')
datetick('keepticks','keeplimits');
title('Flynn MFRSR Io for filter5, Niamey');
xlabel('time')
ylabel('Solar const');

%%
iq1 = ~isNaN(I_new1);
I_new1(~iq1) = interp1(con_lang.time(iq1), I_new1(iq1), con_lang.time(~iq1), 'linear','extrap');
iq2 = ~isNaN(I_new2);
I_new2(~iq2) = interp1(con_lang.time(iq2), I_new2(iq2), con_lang.time(~iq2), 'linear','extrap');
iq3 = ~isNaN(I_new3);
I_new3(~iq3) = interp1(con_lang.time(iq3), I_new3(iq3), con_lang.time(~iq3), 'linear','extrap');
iq4 = ~isNaN(I_new4);
I_new4(~iq4) = interp1(con_lang.time(iq4), I_new4(iq4), con_lang.time(~iq4), 'linear','extrap');
iq5 = ~isNaN(I_new5);
I_new5(~iq5) = interp1(con_lang.time(iq5), I_new5(iq5), con_lang.time(~iq5), 'linear','extrap');

figure; plot(con_lang.time-datenum(2006,1,1)+1, ...
   [I_new1./mean(I_new1(iq1));...
   I_new2./mean(I_new2(iq2));...
   I_new3./mean(I_new3(iq3));...
   I_new4./mean(I_new4(iq4));...
   I_new5./mean(I_new5(iq5))],'.');
title('Flynn MFRSR Ios normalized by mean');
%%

flynn_345 = mean([I_new3./mean(I_new3(iq3));...
   I_new4./mean(I_new4(iq4));...
   I_new5./mean(I_new5(iq5))]);
%%
figure; plot(con_lang.time-datenum(2006,1,1)+1, ...
   [I_new1./(mean(I_new1(iq1)).*flynn_345);...
   I_new2./(mean(I_new2(iq2)).*flynn_345);...
   I_new3./(mean(I_new3(iq3)).*flynn_345);...
   I_new4./(mean(I_new4(iq4)).*flynn_345);...
   I_new5./(mean(I_new5(iq5)).*flynn_345)],'.');
title('Flynn MFRSR Ios re-normalized by mean');
%%
figure; plot(barn_Io_smooth.time - datenum(2006,1,1)+1, ...
   [barn_Io_smooth.filter1_Vo./(mean(barn_Io_smooth.filter1_Vo).*mean_345), ...
   barn_Io_smooth.filter2_Vo./(mean(barn_Io_smooth.filter2_Vo).*mean_345)],'.');hold('on')
plot(con_lang.time-datenum(2006,1,1)+1, ...
   [I_new1./(mean(I_new1(iq1)).*flynn_345);...
   I_new2./(mean(I_new2(iq2)).*flynn_345)], 'k.');


%%
con_lang.I_new1 = I_new1;
con_lang.I_new2 = I_new2;
con_lang.I_new3 = I_new3;
con_lang.I_new4 = I_new4;
con_lang.I_new5 = I_new5;
save nim_lang.mat con_lang

%This block is for Jim Barnards AODs after having run my cloud screen
%%
barn_nimaod = loadinto('barn_nimaod.mat');
%%
nonNaN =  ~isNaN(barn_nimaod.aod_870);
[barn_nimaod.aero,barn_nimaod.eps] = aod_screen(barn_nimaod.time(nonNaN), barn_nimaod.aod_870(nonNaN),0,3.5,[],[],3e-4);
%%
keep_barn =(barn_nimaod.cf_mich==1);
barn_nimaod_.time = barn_nimaod.time(keep_barn)-1/24;
barn_nimaod_.airmass = barn_nimaod.airmass(keep_barn);
barn_nimaod_.aod415 = barn_nimaod.aod_415(keep_barn);
barn_nimaod_.aod500 = barn_nimaod.aod_500(keep_barn);
barn_nimaod_.aod615 = barn_nimaod.aod_615(keep_barn);
barn_nimaod_.aod673 = barn_nimaod.aod_673(keep_barn);
barn_nimaod_.aod870 = barn_nimaod.aod_870(keep_barn);
barn_nimaod_.aod940 = barn_nimaod.aod_940(keep_barn);
barn_nimaod_.ang = barn_nimaod.ang(keep_barn);
barn_nimaod_.pwv = barn_nimaod.pwv(keep_barn);
barn_nimaod_.az = barn_nimaod.az(keep_barn);
barn_nimaod_.eps = barn_nimaod.eps(keep_barn);
save 'barn_nimaod_.mat' 'barn_nimaod_'
%% 
% This block loads the cloud-screened Barnard aod saved above
barn_nimaod_ = loadinto('barn_nimaod_.mat');
%%
%This block loads my AODs that already include the cloud screen eps.
% I was looking first at 500 nm compared to Barnard product, so my product
% doesn't have other AOD
flynn_nimaod = loadinto('flynn_nimaod.mat');
%%
keep_con = flynn_nimaod.eps<5e-5;
flynn_nimaod_.time = flynn_nimaod.time(keep_con);
flynn_nimaod_.pres = flynn_nimaod.pres(keep_con);
flynn_nimaod_.pres_frac = flynn_nimaod.pres_frac(keep_con);

flynn_nimaod_.tau_415nm = flynn_nimaod.tau_415nm(keep_con);
flynn_nimaod_.aod_415nm = flynn_nimaod.aod_415nm(keep_con);
flynn_nimaod_.tau_500nm = flynn_nimaod.tau_500nm(keep_con);
flynn_nimaod_.aod_500nm = flynn_nimaod.aod_500nm(keep_con);
flynn_nimaod_.tau_615nm = flynn_nimaod.tau_615nm(keep_con);
flynn_nimaod_.aod_615nm = flynn_nimaod.aod_615nm(keep_con);
flynn_nimaod_.tau_673nm = flynn_nimaod.tau_673nm(keep_con);
flynn_nimaod_.aod_673nm = flynn_nimaod.aod_673nm(keep_con);
flynn_nimaod_.tau_870nm = flynn_nimaod.tau_870nm(keep_con);
flynn_nimaod_.aod_870nm = flynn_nimaod.aod_870nm(keep_con);
flynn_nimaod_.eps = flynn_nimaod.eps(keep_con);

%%
start_date = datenum(2006,1,1)-1;
figure; plot( barn_nimaod_.time-start_date, barn_nimaod_.aod500, 'b.',flynn_nimaod.time-start_date, flynn_nimaod.aod_500nm, 'r.')
legend('Flynn aod','Barnard aod');
xlabel('days since Dec 31, 2005')
ylabel('aerosol optical depth, 500 nm')
%%
[coninbarn, barnincon] = nearest(flynn_nimaod_.time',(barn_nimaod_.time));
%%

figure; plot(flynn_nimaod_.aod_500nm(coninbarn), barn_nimaod_.aod500(barnincon), '.',[0 6],[0 6],'--'); 
xlabel('con aod');
%%

figure; 
ax(1) = subplot(2,1,1); 
plot(flynn_nimaod_.time(coninbarn), flynn_nimaod_.aod_500nm(coninbarn), 'c.',flynn_nimaod_.time(coninbarn),barn_nimaod_.aod500(barnincon)', 'b.'); 
xlabel('time');
ylabel('aod 500 nm')

ax(2) = subplot(2,1,2); 
plot(flynn_nimaod_.time(coninbarn), flynn_nimaod_.aod_500nm(coninbarn)-barn_nimaod_.aod500(barnincon)', 'k.'); 
xlabel('time');
linkaxes(ax,'x')

ylabel('con aod - barn aod')

%%
anet_nim = read_cimel_aip;
%%
[coninanet, anetincon] = nearest(flynn_nimaod_.time', anet_nim.time);
%%
figure; 
ax(1) = subplot(2,1,1); 
plot(flynn_nimaod_.time(coninanet)-start_date, flynn_nimaod_.aod_500nm(coninanet), 'c.',anet_nim.time(anetincon)-start_date,anet_nim.AOT_500(anetincon), 'b.'); 
legend('con aod','anet aod')
xlabel('time');
ylabel('aod 500 nm')

ax(2) = subplot(2,1,2); 
plot(flynn_nimaod_.time(coninanet)-start_date, flynn_nimaod_.aod_500nm(coninanet)'-anet_nim.AOT_500(anetincon), 'k.'); 
xlabel('time');
linkaxes(ax,'x')

ylabel('con aod - anet aod')
%%

[P_anet_con] = polyfit(anet_nim.AOT_500(anetincon),flynn_nimaod_.aod_500nm(coninanet)',1)
figure; plot(anet_nim.AOT_500(anetincon),flynn_nimaod_.aod_500nm(coninanet),  '.',[0 6],[0 6],'--',...
  anet_nim.AOT_500(anetincon),polyval(P_anet_con,anet_nim.AOT_500(anetincon)),'r-' ); 
ylabel('con aod');
xlabel('anet aod');
xlim([0,2]);ylim([0,2]);

%%
[barn_Io.incon, con_lang.inbarn] = nearest(barn_Io.time, con_lang.time');
figure; plot(barn_Io.time(barn_Io.incon), barn_Io.filter2_Vo(barn_Io.incon), 'b.', ...
   con_lang.time(con_lang.inbarn), filter2.Vo(con_lang.inbarn),'c.');
%%

figure; plot(barn_Io.time, barn_Io.filter2_Vo, 'r.', ...
   barn_Io.time(barn_Io.incon), barn_Io.filter2_Vo(barn_Io.incon), 'b.');
%%
figure; plot(con_lang.time, filter2.Vo, 'r.', ...
   con_lang.time(con_lang.inbarn), filter2.Vo(con_lang.inbarn),'c.');

