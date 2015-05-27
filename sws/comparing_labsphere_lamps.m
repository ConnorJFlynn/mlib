%% Assess comparability of Labsphere SWS cals with different lamps and
%% settings

%% Conclusions: Lamps compare well, esp A & B almost to +/ ~.5% in Si.  InGaAs
%% calibration is poorer to +/- 5% or so.
% Proposed path forward
% Apply initial radiance calibration to both channels mainly to correct
% bulk of responsivity change with wavelength.  Then scale
%
%  
% Iset=2.78	I_out=2.78	V_out=10.43
% LampB	
%  Si_tint	In_tint	Lambert	time(UTC)	fstem
% 1	500	500	2790        	19:12:00	191204
% 2	500	500	2789				19:17:00	191719
% 3	400	400	2789				19:22:00	192114
% 4	200	200	2790				19:25:00	192500
% 5	100	100	2790				19:29:00	192848
lampB_1 = read_sws_cal_pair;
%%
lampB_2 = read_sws_cal_pair;
%%
lampB_3 = read_sws_cal_pair;
%%
lampB_4 = read_sws_cal_pair;
%%
lampB_5 = read_sws_cal_pair;
%%
figure; plot(lampB_1.Si_lambda, [lampB_1.avg_Si_per_ms,lampB_2.avg_Si_per_ms,lampB_3.avg_Si_per_ms,...
   lampB_4.avg_Si_per_ms,lampB_5.avg_Si_per_ms],'-');legend('1','2','3','4','5');
hold('on');
plot(lampB_1.In_lambda, [lampB_1.avg_In_per_ms,lampB_2.avg_In_per_ms,lampB_3.avg_In_per_ms,...
   lampB_4.avg_In_per_ms,lampB_5.avg_In_per_ms],'-')

%%
% Lamp C	Si_tint	In_tint	Lambert	I_set	I_out	V_out	time(UTC)	
% 1	500	500	2905	2.865	2.866	10.43	19:50:00	194948
% 2	400	400	2906	2.865	2.866	10.43	19:54:00	195340
% 3	200	200	2905	2.865	2.865	10.43	20:01:00	195937
% 4	100	100	2906	2.865	2.866	10.43	20:03:00	200318
lampC_1 = read_sws_cal_pair;
%%
lampC_2 = read_sws_cal_pair;
%%
lampC_3 = read_sws_cal_pair;
%%
lampC_4 = read_sws_cal_pair;
%%
figure; plot(lampB_1.Si_lambda, [lampB_1.avg_Si_per_ms,lampB_2.avg_Si_per_ms,lampB_3.avg_Si_per_ms,...
   lampB_4.avg_Si_per_ms,lampB_5.avg_Si_per_ms],'k-',...
   lampC_1.Si_lambda, [lampC_1.avg_Si_per_ms,lampC_2.avg_Si_per_ms,lampC_3.avg_Si_per_ms,...
   lampC_4.avg_Si_per_ms],'R-')
%%
% Lamp A	Si_tint	In_tint	Lambert	I_set	I_out	V_out	time(UTC)	
% 1	500	500	2745	2.786	2.786	10.44	20:17:00	201636
% 2	200	200	2745	2.786	2.786	10.44	20:21:00	202103
% 3	400	400	2745	2.786	2.786	10.44	20:25:00	202440
lampA_1 = read_sws_cal_pair;
%%
lampA_2 = read_sws_cal_pair;
%%
lampA_3 = read_sws_cal_pair;
%%
figure; plot(lampB_1.Si_lambda, [lampB_1.avg_Si_per_ms,lampB_2.avg_Si_per_ms,lampB_3.avg_Si_per_ms,...
   lampB_4.avg_Si_per_ms,lampB_5.avg_Si_per_ms]./2790,'k-',...
   lampC_1.Si_lambda, [lampC_1.avg_Si_per_ms,lampC_2.avg_Si_per_ms,lampC_3.avg_Si_per_ms,...
   lampC_4.avg_Si_per_ms]./2905,'R-',...
   lampA_1.Si_lambda, [lampA_1.avg_Si_per_ms,lampA_2.avg_Si_per_ms,lampA_3.avg_Si_per_ms]./2745,'b-')

%%
% Lamp D	Si_tint	In_tint	Lambert	I_set	I_out	V_out	time(UTC)	
% 1	500	500	2601	2.771	2.771	10.43	20:40:00	203946
% 2	400	400	2601	2.771	2.772	10.43	20:44:00	204336
% 3	200	200	2601	2.771	2.772	10.43	20:47:00	204720
lampD_1 = read_sws_cal_pair;
%%
lampD_2 = read_sws_cal_pair;
%%
lampD_3 = read_sws_cal_pair;
%%
figure; plot(lampB_1.Si_lambda, [lampB_1.avg_Si_per_ms,lampB_2.avg_Si_per_ms,lampB_3.avg_Si_per_ms,...
   lampB_4.avg_Si_per_ms,lampB_5.avg_Si_per_ms]./2790,'k-',...
   lampC_1.Si_lambda, [lampC_1.avg_Si_per_ms,lampC_2.avg_Si_per_ms,lampC_3.avg_Si_per_ms,...
   lampC_4.avg_Si_per_ms]./2905,'R-',...
   lampA_1.Si_lambda, [lampA_1.avg_Si_per_ms,lampA_2.avg_Si_per_ms,lampA_3.avg_Si_per_ms]./2745,'b-',...
   lampD_1.Si_lambda, [lampD_1.avg_Si_per_ms,lampD_2.avg_Si_per_ms,lampD_3.avg_Si_per_ms]./2601,'m-')
%%
figure; plot(lampB_1.Si_lambda, [lampB_1.avg_Si_per_ms,lampB_2.avg_Si_per_ms,lampB_3.avg_Si_per_ms,...
   lampB_4.avg_Si_per_ms,lampB_5.avg_Si_per_ms]./2790,'k-',...
   lampC_1.Si_lambda, [lampC_1.avg_Si_per_ms,lampC_2.avg_Si_per_ms,lampC_3.avg_Si_per_ms,...
   lampC_4.avg_Si_per_ms]./2905,'R-',...
   lampA_1.Si_lambda, [lampA_1.avg_Si_per_ms,lampA_2.avg_Si_per_ms,lampA_3.avg_Si_per_ms]./2745,'b-',...
   lampD_1.Si_lambda, [lampD_1.avg_Si_per_ms,lampD_2.avg_Si_per_ms,lampD_3.avg_Si_per_ms]./2601,'m-',...
   lampB_1.In_lambda, [lampB_3.avg_In_per_ms,...
   lampB_2.avg_In_per_ms,lampB_3.avg_In_per_ms]./2790,'k-',...
   lampC_1.In_lambda, [lampC_1.avg_In_per_ms,lampC_2.avg_In_per_ms,lampC_3.avg_In_per_ms,...
   lampC_4.avg_In_per_ms]./2905,'R-',...
   lampA_1.In_lambda, [lampA_1.avg_In_per_ms,lampA_2.avg_In_per_ms,lampA_3.avg_In_per_ms]./2745,'b-',...
   lampD_1.In_lambda, [lampD_1.avg_In_per_ms,lampD_2.avg_In_per_ms,lampD_3.avg_In_per_ms]./2601,'m-')
%%
labsphere.lampA_1 = lampA_1;
labsphere.lampA_2 = lampA_2;
labsphere.lampA_3 = lampA_3;
labsphere.lampB_2 = lampB_2;
labsphere.lampB_3 = lampB_3;
labsphere.lampB_4 = lampB_4;
labsphere.lampB_5 = lampB_5;
labsphere.lampC_1 = lampC_1;
labsphere.lampC_2 = lampC_2;
labsphere.lampC_3 = lampC_3;
labsphere.lampC_4 = lampC_4;
labsphere.lampD_1 = lampD_1;
labsphere.lampD_2 = lampD_2;
labsphere.lampD_3 = lampD_3;
%%
save(['C:\case_studies\SWS\calibration\NASA_ARC_2008_11_19\from_SWS_PC.20081118\cal\_NASA_ARC_2008_11_20\labsphere\labsphere.mat'],'labsphere');
%%
labsphere = loadinto(['C:\case_studies\SWS\calibration\NASA_ARC_2008_11_19\from_SWS_PC.20081118\cal\_NASA_ARC_2008_11_20\labsphere\labsphere.mat']);
%%
% Nov 20, 2008
% A	150	90	4975.5	21:32:00				213138		4976		20081120.213138
% 'C:\case_studies\SWS\calibration\NASA_ARC_2008_11_19\from_SWS_PC.20081118
% \cal\_NASA_ARC_2008_11_20\optronics\20081120.213138\
sws_Opt_A = read_sws_cal_pair;
%%
OptA = OptronicsAperA_radiance;
figure; plot(OptA.nm, OptA.rad,'xk-');
xlabel('wavelength [nm]');
ylabel(OptA.units);
%%
sws_Opt_A.Si_resp = sws_Opt_A.avg_Si_per_ms ./ interp1(OptA.nm, OptA.rad, sws_Opt_A.Si_lambda,'linear','extrap');
sws_Opt_A.In_resp = sws_Opt_A.avg_In_per_ms ./ interp1(OptA.nm, OptA.rad, sws_Opt_A.In_lambda,'linear','extrap');
save(['C:\case_studies\SWS\calibration\NASA_ARC_2008_11_19\from_SWS_PC.20081118\cal\_NASA_ARC_2008_11_20\sws_Opt_A.mat'],'sws_Opt_A');
%%
sws_Opt_A = loadinto(['C:\case_studies\SWS\calibration\NASA_ARC_2008_11_19\from_SWS_PC.20081118\cal\_NASA_ARC_2008_11_20\sws_Opt_A.mat']);
%%
lampB_1.Si_rad = lampB_1.avg_Si_per_ms./sws_Opt_A.Si_resp;
lampB_1.In_rad = lampB_1.avg_In_per_ms./sws_Opt_A.In_resp;
lampB_2.Si_rad = lampB_2.avg_Si_per_ms./sws_Opt_A.Si_resp;
lampB_2.In_rad = lampB_2.avg_In_per_ms./sws_Opt_A.In_resp;
lampB_3.Si_rad = lampB_3.avg_Si_per_ms./sws_Opt_A.Si_resp;
lampB_3.In_rad = lampB_3.avg_In_per_ms./sws_Opt_A.In_resp;
lampB_4.Si_rad = lampB_4.avg_Si_per_ms./sws_Opt_A.Si_resp;
lampB_4.In_rad = lampB_4.avg_In_per_ms./sws_Opt_A.In_resp;
lampB_5.Si_rad = lampB_5.avg_Si_per_ms./sws_Opt_A.Si_resp;
lampB_5.In_rad = lampB_5.avg_In_per_ms./sws_Opt_A.In_resp;

lampC_1.Si_rad = lampC_1.avg_Si_per_ms./sws_Opt_A.Si_resp;
lampC_1.In_rad = lampC_1.avg_In_per_ms./sws_Opt_A.In_resp;
lampC_2.Si_rad = lampC_2.avg_Si_per_ms./sws_Opt_A.Si_resp;
lampC_2.In_rad = lampC_2.avg_In_per_ms./sws_Opt_A.In_resp;
lampC_3.Si_rad = lampC_3.avg_Si_per_ms./sws_Opt_A.Si_resp;
lampC_3.In_rad = lampC_3.avg_In_per_ms./sws_Opt_A.In_resp;
lampC_4.Si_rad = lampC_4.avg_Si_per_ms./sws_Opt_A.Si_resp;
lampC_4.In_rad = lampC_4.avg_In_per_ms./sws_Opt_A.In_resp;

lampA_1.Si_rad = lampA_1.avg_Si_per_ms./sws_Opt_A.Si_resp;
lampA_1.In_rad = lampA_1.avg_In_per_ms./sws_Opt_A.In_resp;
lampA_2.Si_rad = lampA_2.avg_Si_per_ms./sws_Opt_A.Si_resp;
lampA_2.In_rad = lampA_2.avg_In_per_ms./sws_Opt_A.In_resp;
lampA_3.Si_rad = lampA_3.avg_Si_per_ms./sws_Opt_A.Si_resp;
lampA_3.In_rad = lampA_3.avg_In_per_ms./sws_Opt_A.In_resp;

lampD_1.Si_rad = lampD_1.avg_Si_per_ms./sws_Opt_A.Si_resp;
lampD_1.In_rad = lampD_1.avg_In_per_ms./sws_Opt_A.In_resp;
lampD_2.Si_rad = lampD_2.avg_Si_per_ms./sws_Opt_A.Si_resp;
lampD_2.In_rad = lampD_2.avg_In_per_ms./sws_Opt_A.In_resp;
lampD_3.Si_rad = lampD_3.avg_Si_per_ms./sws_Opt_A.Si_resp;
lampD_3.In_rad = lampD_3.avg_In_per_ms./sws_Opt_A.In_resp;
%%
figure; plot(lampB_1.Si_lambda, [lampB_2.Si_rad,lampB_3.Si_rad,...
   lampB_4.Si_rad,lampB_5.Si_rad],'-');legend('1','2','3','4','5');
hold('on');
plot(lampB_1.In_lambda, [lampB_2.In_rad,lampB_3.In_rad,...
   lampB_4.In_rad,lampB_5.In_rad],'-');
%%
Si_pin_range = lampB_1.Si_lambda>1050 & lampB_1.Si_lambda<1070;
In_pin_range = lampB_1.In_lambda>1050 & lampB_1.In_lambda<1070;
lampB_1.SibyIn = mean(lampB_1.Si_rad(Si_pin_range))./mean(lampB_1.In_rad(In_pin_range));
lampB_2.SibyIn = mean(lampB_2.Si_rad(Si_pin_range))./mean(lampB_2.In_rad(In_pin_range));
lampB_3.SibyIn = mean(lampB_3.Si_rad(Si_pin_range))./mean(lampB_3.In_rad(In_pin_range));
lampB_4.SibyIn = mean(lampB_4.Si_rad(Si_pin_range))./mean(lampB_4.In_rad(In_pin_range));
lampB_5.SibyIn = mean(lampB_5.Si_rad(Si_pin_range))./mean(lampB_5.In_rad(In_pin_range));
%
lampC_1.SibyIn = mean(lampC_1.Si_rad(Si_pin_range))./mean(lampC_1.In_rad(In_pin_range));
lampC_2.SibyIn = mean(lampC_2.Si_rad(Si_pin_range))./mean(lampC_2.In_rad(In_pin_range));
lampC_3.SibyIn = mean(lampC_3.Si_rad(Si_pin_range))./mean(lampC_3.In_rad(In_pin_range));
lampC_4.SibyIn = mean(lampC_4.Si_rad(Si_pin_range))./mean(lampC_4.In_rad(In_pin_range));

%
lampA_1.SibyIn = mean(lampA_1.Si_rad(Si_pin_range))./mean(lampA_1.In_rad(In_pin_range));
lampA_2.SibyIn = mean(lampA_2.Si_rad(Si_pin_range))./mean(lampA_2.In_rad(In_pin_range));
lampA_3.SibyIn = mean(lampA_3.Si_rad(Si_pin_range))./mean(lampA_3.In_rad(In_pin_range));
%
lampD_1.SibyIn = mean(lampD_1.Si_rad(Si_pin_range))./mean(lampD_1.In_rad(In_pin_range));
lampD_2.SibyIn = mean(lampD_2.Si_rad(Si_pin_range))./mean(lampD_2.In_rad(In_pin_range));
lampD_3.SibyIn = mean(lampD_3.Si_rad(Si_pin_range))./mean(lampD_3.In_rad(In_pin_range));

%%

figure; semilogy(OptA_rad.nm,OptA_rad.rad./10 , 'ko',...
   lampB_1.Si_lambda, [lampB_2.Si_rad,lampB_3.Si_rad,lampB_4.Si_rad,lampB_5.Si_rad],'k-',...
   lampA_1.Si_lambda, [lampA_1.Si_rad,lampA_2.Si_rad,lampA_3.Si_rad],'b-',...
   lampD_1.Si_lambda, [lampD_1.Si_rad,lampD_2.Si_rad,lampD_3.Si_rad],'m-',...
   lampB_1.In_lambda, [lampB_2.In_rad.*lampB_2.SibyIn,lampB_3.In_rad.*lampB_3.SibyIn,...
   lampB_4.In_rad.*lampB_4.SibyIn,lampB_5.In_rad.*lampB_5.SibyIn],'k-',...
   lampA_1.In_lambda, [lampA_1.In_rad.*lampA_1.SibyIn,lampA_2.In_rad.*lampA_2.SibyIn,...
   lampA_3.In_rad.*lampA_3.SibyIn],'b-',...
   lampD_1.In_lambda, [lampD_1.In_rad.*lampD_1.SibyIn,lampD_2.In_rad.*lampD_2.SibyIn,...
   lampD_3.In_rad.*lampD_3.SibyIn],'m-')

%%

figure; semilogy(OptA_rad.nm,OptA_rad.rad./10 , 'ko',...
   lampB_1.Si_lambda, [lampB_2.Si_rad,lampB_3.Si_rad,lampB_4.Si_rad,lampB_5.Si_rad],'k-',...
   lampA_1.Si_lambda, [lampA_1.Si_rad,lampA_2.Si_rad,lampA_3.Si_rad],'b-',...
   lampB_1.In_lambda, [lampB_2.In_rad.*lampB_2.SibyIn,lampB_3.In_rad.*lampB_3.SibyIn,...
   lampB_4.In_rad.*lampB_4.SibyIn,lampB_5.In_rad.*lampB_5.SibyIn],'k-',...
   lampA_1.In_lambda, [lampA_1.In_rad.*lampA_1.SibyIn,lampA_2.In_rad.*lampA_2.SibyIn,...
   lampA_3.In_rad.*lampA_3.SibyIn],'b-');

% Define labsphere radiance based on these
%%
Si_range = lampB_1.Si_lambda<1070;
In_range = lampB_1.In_lambda>1050;
tmp = [lampB_2.Si_lambda(Si_range);lampB_3.Si_lambda(Si_range);lampB_4.Si_lambda(Si_range);lampB_5.Si_lambda(Si_range);...
   lampA_1.Si_lambda(Si_range);lampA_2.Si_lambda(Si_range);lampA_3.Si_lambda(Si_range);...
lampB_2.In_lambda(In_range);lampB_3.In_lambda(In_range);lampB_4.In_lambda(In_range);lampB_5.In_lambda(In_range);...
   lampA_1.In_lambda(In_range);lampA_2.In_lambda(In_range);lampA_3.In_lambda(In_range)];
[labsphere.nm_all, ii] = sort(tmp);
tmp_ = [lampB_2.Si_rad(Si_range);lampB_3.Si_rad(Si_range);lampB_4.Si_rad(Si_range);lampB_5.Si_rad(Si_range);...
   lampA_1.Si_rad(Si_range);lampA_2.Si_rad(Si_range);lampA_3.Si_rad(Si_range);...
   lampB_2.In_rad(In_range).*lampB_2.SibyIn;lampB_3.In_rad(In_range).*lampB_3.SibyIn;...
   lampB_4.In_rad(In_range).*lampB_4.SibyIn;lampB_5.In_rad(In_range).*lampB_5.SibyIn;...
   lampA_1.In_rad(In_range).*lampA_1.SibyIn;lampA_2.In_rad(In_range).*lampA_2.SibyIn;...
   lampA_3.In_rad(In_range).*lampA_3.SibyIn];
labsphere.rad_all = tmp_(ii);

labsphere.nm_grid = [labsphere.nm_all(1):labsphere.nm_all(end)];
[nm_all, ij] = unique(labsphere.nm_all); % B = A(I,:)
rad_all = labsphere.rad_all(ij);

labsphere.rad_grid = interp1(nm_all, rad_all, labsphere.nm_grid, 'linear','extrap');
%%
labsphere.planck_curve = (2.5e-1*planck(labsphere.nm_grid.*1e-3,2950));
figure; semilogy(labsphere.nm_all, labsphere.rad_all,'.',labsphere.nm_grid, labsphere.rad_grid,'-r',labsphere.nm_grid, ...
   labsphere.planck_curve,'-c');


% save(['C:\case_studies\SWS\calibration\NASA_ARC_2008_11_19\from_SWS_PC.20081118\cal\_NASA_ARC_2008_11_20\labsphere\labsphere.mat'],'labsphere');
%%
labsphere = loadinto(['C:\case_studies\SWS\calibration\NASA_ARC_2008_11_19\from_SWS_PC.20081118\cal\_NASA_ARC_2008_11_20\labsphere\labsphere.mat']);
sws_Opt_A = loadinto(['C:\case_studies\SWS\calibration\NASA_ARC_2008_11_19\from_SWS_PC.20081118\cal\_NASA_ARC_2008_11_20\sws_Opt_A.mat']);

%%
OptA_rad = OptronicsAperA_radiance;
%%
charts_irrad = read_charts_irradiance;
charts_rad = read_charts_radiance;
%%
nm = (charts_irrad.nm>400) & (charts_irrad.nm<2200);
figure; plot(labsphere.nm_grid, labsphere.rad_grid./1e3,'-c',OptA_rad.nm, OptA_rad.rad,'xk-',...
   charts_irrad.nm(nm), charts_irrad.dir_irrad_nm(nm), 'k-');


