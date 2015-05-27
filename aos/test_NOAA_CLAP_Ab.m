function test_NOAA_PSAP_Ab

% Load psap.a1 and psap.b1.
% Confirm that I can reproduce a1 absorption coefficients from absorbance
% measurements
clapa1 = anc_bundle_files(getfullname('*.*','clapa1','Select clap a1'));
clapb1 = anc_bundle_files(getfullname('*.*','clapb1','Select clap b1'));

% Confirm that I can reproduce a1 absorption coefficients from absorbance
% measurements

% a1
%     'Ba_B_CLAP3W'
%     'Ba_G_CLAP3W'
%     'Ba_R_CLAP3W'
%     'transmittance_B'
%     'transmittance_G'
%     'transmittance_R'
%     'sample_length'
%     'clap_flow_rate'
%     'impactor_setting'
%     'instrument_flags'
%     'filter_id'
%     'active_filter_number'

% b1
%     'transmittance_blue'
%     'transmittance_green'
%     'transmittance_red'
%     'absorbance_blue'
%     'absorbance_green'
%     'absorbance_red'
%     'sample_flow_rate'
%     'seconds_after_transition'
%     'impactor_state'
%     'dilution_correction_factor'
%     'spot_size_area'

% ,A=0.814;B=1.237;Area=17.81 
% "00,e1,296916be,d4e1,141211002400,B1999:ba=b0/(k1*Tr+k0)"
% "01,06b006669b,c4d6a9b48f,a4fab0,a9,K0=0.866,K1=1.317"
% "02,6d087b63fe,7b199a8541,a49280,2c,area=17.81"

k1=1.317; ko=0.866; Tr = 0.66;
% or A=0.814;B=1.237;
% k1 = 1.237; k0 = .814;
% kf = 1./(k1.*psap.A11a.IrB_A11 + ko);
kf = 1./(k1.*clapb1.vdata.transmittance_green + ko);
spot_size_area = 1e6.*clapb1.vdata.spot_size_area(clapa1.vdata.active_filter_number)'; % mm^2
sample_flow = clapb1.vdata.sample_flow_rate; %liter/min
T = 2;
dt = diffN(clapb1.time,T).*24.*60.*60; dt(1:T-1) = dt(T); dt(end-T+1:end) = dt(end-T);
dL = (1000.*1000.*sample_flow)./(60.*17.81); % mm/sec
dL = dL ./ (1000); %m per 60-sec average
dL = dL .* dt;

bo = clapb1.vdata.absorbance_green./dL;

figure; plot(serial2hs(clapb1.time), kf.*1e6.*bo,'g*', serial2hs(clapa1.time), clapa1.vdata.Ba_G_CLAP3W,'rx');
%  figure; plot(serial2hs(psapb1.time), kf.*Bap_G*1e6,'r.', serial2hs(psapa1.time), psapa1.Ba_G_PSAP3W,'kx' );
%Not a match, but similar. 
figure; plot(serial2hs(clapb1.time), 1e6.*bo,'m*'); legend('CLAP w/o B1999');
 % This seems to agree better with PSAP from M1 and S1 than with the
 % correction applied.  Note that none of these has dilution correction or
 % scattering correction applied.


return